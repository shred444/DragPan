//
//  ToolBoxViewController.m
//  MonkeyPinch
//
//  Created by Jonathan Cohn on 9/7/12.
//
//

#import "ToolBoxViewController.h"

@interface ToolBoxViewController ()

@end

@implementation ToolBoxViewController

@synthesize monkey = _monkey;
@synthesize showCoords = _showCoords;
@synthesize showDropShadow = _showDropShadow;
@synthesize gridSpacing = _gridSpacing;
@synthesize snapToGrid = _snapToGrid;
@synthesize scaling = _scaling;
@synthesize mainView = _mainView;
@synthesize dropView = _dropView;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
   
    
    return self;
}

+(ToolBoxViewController *)displayToolBoxInViewController:(UIViewController *)viewController inView:(UIView *)view withTargetView:(UIView *)targetView
{
    ToolBoxViewController *tbvc = [[ToolBoxViewController alloc]initWithNibName:@"Toolbox" bundle:nil];
    
    [viewController addChildViewController:tbvc];
    [view addSubview:tbvc.view];
    tbvc.showCoords = NO;
    tbvc.showDropShadow = YES;
    tbvc.gridSpacing = 20;
    tbvc.snapToGrid = YES;
    tbvc.scaling = 2;
    
    tbvc.dropView = targetView;
    
    return tbvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //initialize tools
    for(UIImageView *image in self.view.subviews)
    {
        //add a gesture recognizer to each one
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        panGest.delegate = self;
        panGest.minimumNumberOfTouches = 1;
        panGest.maximumNumberOfTouches = 1;
        
        [image addGestureRecognizer:panGest];
        NSLog(@"GESTURE: %@",image.gestureRecognizers);
        //@selector(handlePan:);
        if (![panGest respondsToSelector:@selector(handlePan:)]) {
            //[panGest release];
            //panGest = nil;
            NSLog(@"Does not respond");
        }
    }
    
     
    NSLog(@"gestures: %@",self.monkey.gestureRecognizers);
    
    NSLog(@"Initialized %d objects in the ToolBox", self.view.subviews.count);
}

- (void)viewDidUnload
{
    [self setMonkey:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)test
{
    NSLog(@"this is a test");
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"Recognizer Started");
        
        //get the view that was clicked
        UIImageView *recognizerView = (UIImageView *)recognizer.view;
        CGRect frameInMainView = [self.view convertRect:recognizerView.frame toView:self.mainView];
        CGPoint touchPoint = recognizerView.frame.origin;
        CGPoint translatedPoint = frameInMainView.origin;
        NSLog(@"Touch Point Center: %d, %d",(int)recognizerView.frame.origin.x,(int)recognizerView.frame.origin.y);
        NSLog(@"Trans Point Center: %d, %d",(int)translatedPoint.x,(int)translatedPoint.y);
        
        //add the dragged object to the main view
        //[self.dropView addSubview:recognizerView];
        [self.dropView addSubview:recognizerView];
        
        //translate image to new coord system
        recognizerView.center = translatedPoint;
        NSLog(@"translation occured from %d %d -> %d %d",(int)touchPoint.x, (int)touchPoint.y, (int)translatedPoint.x, (int)translatedPoint.y);
        
        //create the copy
        [self createCopyOfImageView:recognizerView atPosition:touchPoint inView:self.view];
        
        //scale original by scaling value
        if(self.scaling !=0)
        {
            //UIView *viewToAnimate = recognizerView;
            [UIView animateWithDuration:.25 animations:^{
                
                
                CGRect scaledFrame = recognizerView.frame;
                scaledFrame.size.height = scaledFrame.size.height*self.scaling;
                scaledFrame.size.width = scaledFrame.size.width*self.scaling;
                recognizerView.frame = scaledFrame;
                NSLog(@"Copy has been scaled. Origin:");
                
            }];
        }
        
        //create the coordinates
        if(self.showCoords)
        {
            UILabel *coords = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
            coords.backgroundColor = [UIColor redColor];
            
            //add the coords to the imageview
            [recognizerView addSubview:coords];
        }
        
        //initialize drop shadow
        if(self.showDropShadow)
        {
            [self createDropShadowWithRecognizer:recognizer];
            
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"State ended");
        UIImageView *currentImage = (UIImageView *)recognizer.view;
        UIPanGestureRecognizer *moveGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
        moveGest.delegate = self;
        moveGest.minimumNumberOfTouches = 1;
        moveGest.maximumNumberOfTouches = 1;
        NSLog(@"Removed Original %d Gestures", currentImage.gestureRecognizers.count);
        [recognizer.view removeGestureRecognizer:recognizer];

        
        currentImage.userInteractionEnabled = YES;
        
        [currentImage addGestureRecognizer:moveGest];
        NSLog(@"Added new gesture %d", currentImage.gestureRecognizers.count);
        
        //create the pinch recognizer for the copy image
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        pinchRecognizer.delegate = self;
        
        [currentImage addGestureRecognizer:pinchRecognizer];
        NSLog(@"Added Pinch Recognizer");
        
        //snap final image to grid
        currentImage.center = [self snapToGrid:currentImage.center gridSpacing:self.gridSpacing];
        
        //remove dropshadow
        [self removeDropShadowWithRegister:recognizer];
        
        //notify the delegate
        [self.delegate didDropView:currentImage inTarget:self.dropView];
        
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self performTranslationWithRecognizer:recognizer];
    }
    
    //self.subviewCount.text = [NSString stringWithFormat:@"%d",self.littleView.subviews.count];
    //self.mainviewCount.text = [NSString stringWithFormat:@"%d",self.view.subviews.count];
    
    
}


- (IBAction)moveImage:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        //move has begun
        //initialize drop shadow
        if(self.showDropShadow)
        {
            [self createDropShadowWithRecognizer:recognizer];
            
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        //move has ended
        
        //remove drop shadow
        [self removeDropShadowWithRegister:recognizer];
        
        //snap to grid
        if(self.snapToGrid)
        {
            recognizer.view.center = [self snapToGrid:recognizer.view.center gridSpacing:self.gridSpacing];
        }
        
    }else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        //move is happening
        [self performTranslationWithRecognizer:recognizer];
        
    }
}


-(UIImageView *)createCopyOfImageView:(UIImageView *)imageView atPosition:(CGPoint)point inView:(UIView *)view
{
    UIImageView *imageCopy;
    
    //get the image in the view
    UIImage *clickedImage = imageView.image;
    
    //create the copy image
    imageCopy = [[UIImageView alloc] initWithImage:clickedImage];
    
    //find the press point
    //CGPoint touchPoint = [recognizer locationInView:self.view];
    
    //new frame for copy of image
    CGRect newFrame = CGRectMake(point.x, point.y, imageView.frame.size.width, imageView.frame.size.height);
    
    //set frame to copy
    imageCopy.frame = newFrame;
    
    //create the pan recognizer for the copy image
    UIPanGestureRecognizer *newRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    newRecognizer.delegate = self;
    newRecognizer.minimumNumberOfTouches = 1;
    newRecognizer.maximumNumberOfTouches = 1;
    
    //add recognizer to copy
    [imageCopy addGestureRecognizer:newRecognizer];
    
    //NSLog(@"%@",imageCopy.gestureRecognizers);
    NSLog(@"Copy has been created with %d recognizer attached", imageCopy.gestureRecognizers.count);
    
    imageCopy.userInteractionEnabled = YES;
    
    [view addSubview:imageCopy];
    
    return imageCopy;
}

-(void)performTranslationWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint recViewCenter = recognizer.view.center;
    CGPoint newPoint = CGPointMake(recViewCenter.x + translation.x,
                                   recViewCenter.y + translation.y);
    CGPoint snapPoint = newPoint;
    recognizer.view.center = newPoint;
    
    
    if(self.snapToGrid){
        snapPoint = [self snapToGrid:newPoint gridSpacing:20];
    }
    
    
    //NSLog(@"centerx: %d   centery: %d   |   x: %d   y: %d   |   x: %d   y: %d", (int)recViewCenter.x, (int)recViewCenter.y, (int)snapPoint.x, (int)snapPoint.y, (int)newPoint.x, (int)newPoint.y);
    
    if(self.showCoords)
    {
        UILabel *coords = [recognizer.view.subviews objectAtIndex:0];
        coords.text = [NSString stringWithFormat:@"%dx %dy",(int)newPoint.x,(int)newPoint.y];
    }
    
    
    
    //handle drop shadow
    dropShadow.frame = recognizer.view.frame;
    dropShadow.center = snapPoint;
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    //self.xPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.x];
    //self.yPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.y];
}

-(CGPoint)snapToGrid:(CGPoint)originalPoint gridSpacing:(float)grid
{
    if(self.gridSpacing > 0)
    {
        CGPoint newPoint;
        newPoint.x = grid * floor((originalPoint.x / grid) + 0.5);
        newPoint.y = grid * floor((originalPoint.y / grid) + 0.5);
        
        return newPoint;
        
    }else{
        //grid spacing was never set, so don't snap
        return originalPoint;
    }
}

-(UIView *)createDropShadowWithRecognizer:(UIGestureRecognizer *)recognizer
{
    
    dropShadow = [[UIView alloc]initWithFrame:recognizer.view.frame];
    dropShadow.backgroundColor = [UIColor grayColor];
    dropShadow.alpha = .5;
    
    [self.dropView addSubview:dropShadow];
    dropShadow.center = recognizer.view.center;
    
    [self.dropView bringSubviewToFront:recognizer.view];
    
    return dropShadow;
}

-(void)removeDropShadowWithRegister:(UIGestureRecognizer *)recognizer
{
    if(self.showDropShadow)
    {
        [dropShadow removeFromSuperview];
        dropShadow = nil;
    }
}


@end
