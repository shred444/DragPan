//
//  ViewController.m
//  MonkeyPinch
//
//  Created by Ray Wenderlich on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PanViewController2.h"

@implementation PanViewController2
@synthesize yPosition;
@synthesize xPosition;
@synthesize subviewCount;
@synthesize mainviewCount;
@synthesize bananaPan;
@synthesize littleView;
@synthesize monkeyPan;
@synthesize chompPlayer;
@synthesize hehePlayer;
@synthesize showCoords = _showCoords;
@synthesize showDropShadow = _showDropShadow;
@synthesize snapToGrid = _snapToGrid;
@synthesize scaling = _scaling;
@synthesize gridSpacing = _gridSpacing;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (AVAudioPlayer *)loadWav:(NSString *)filename {
    NSURL * url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"wav"];
    NSError * error;
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!player) {
        NSLog(@"Error loading %@: %@", url, error.localizedDescription);
    } else {
        [player prepareToPlay];
    }
    return player;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView * view in self.view.subviews) {
        
        
    }
    self.showCoords = NO;
    self.showDropShadow = YES;
    self.snapToGrid = YES;
    self.scaling = 2;
    self.gridSpacing = 20;
    self.subviewCount.text = [NSString stringWithFormat:@"%d",self.littleView.subviews.count];
    self.mainviewCount.text = [NSString stringWithFormat:@"%d",self.view.subviews.count];

    for(UIImageView *image in self.littleView.subviews)
    {
        //add a gesture recognizer to each one
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        panGest.delegate = self;
        panGest.minimumNumberOfTouches = 1;
        panGest.maximumNumberOfTouches = 1;
        
        [image addGestureRecognizer:panGest];
        NSLog(@"Gesture: %@",image.gestureRecognizers);

    }
    
    //self.chompPlayer = [self loadWav:@"chomp"];
    //self.hehePlayer = [self loadWav:@"hehehe1"];
    
    
    //add toolbox
    ToolBoxViewController *tbvc = [[ToolBoxViewController alloc]initWithNibName:@"Toolbox" bundle:nil];
    
    [self addChildViewController:tbvc];
    NSLog(@"ChildVC: %d",self.childViewControllers.count);
    [self.view addSubview:tbvc.view];
}

- (void)viewDidUnload
{
    [self setBananaPan:nil];
    [self setMonkeyPan:nil];
    [self setLittleView:nil];
    yPosition = nil;
    [self setYPosition:nil];
    [self setXPosition:nil];
    [self setSubviewCount:nil];
    [self setMainviewCount:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    //NSLog(@"State: %d", recognizer.state);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"Recognizer Started");
        
        //get the view that was clicked
        UIImageView *recognizerView = (UIImageView *)recognizer.view;
        CGRect frameInMainView = [self.littleView convertRect:recognizerView.frame toView:self.view];
        CGPoint touchPoint = recognizerView.frame.origin;
        CGPoint translatedPoint = frameInMainView.origin;
        NSLog(@"Touch Point Center: %d, %d",(int)recognizerView.frame.origin.x,(int)recognizerView.frame.origin.y);
        NSLog(@"Trans Point Center: %d, %d",(int)translatedPoint.x,(int)translatedPoint.y);
        
        //add the dragged object to the main view
        [self.view addSubview:recognizerView];
        
        //translate image to new coord system
        recognizerView.center = translatedPoint;
        NSLog(@"translation occured from %d %d -> %d %d",(int)touchPoint.x, (int)touchPoint.y, (int)translatedPoint.x, (int)translatedPoint.y);
        
        //create the copy
        [self createCopyOfImageView:recognizerView atPosition:touchPoint inView:self.littleView];
        
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
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
        panGest.delegate = self;
        panGest.minimumNumberOfTouches = 1;
        panGest.maximumNumberOfTouches = 1;
       
        [recognizer.view removeGestureRecognizer:recognizer];
       
        currentImage.userInteractionEnabled = YES;
       
        [currentImage addGestureRecognizer:panGest];
        
        //create the pinch recognizer for the copy image
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        pinchRecognizer.delegate = self;
        
        [currentImage addGestureRecognizer:pinchRecognizer];
        
       
        //snap final image to grid
        currentImage.center = [self snapToGrid:currentImage.center gridSpacing:self.gridSpacing];
       
        //remove dropshadow
        [self removeDropShadowWithRegister:recognizer];
       
    }else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self performTranslationWithRecognizer:recognizer];
    }
    
    self.subviewCount.text = [NSString stringWithFormat:@"%d",self.littleView.subviews.count];
    self.mainviewCount.text = [NSString stringWithFormat:@"%d",self.view.subviews.count];
    
    
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {        
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {    
    [self.chompPlayer play];
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
- (void)littleViewPan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"NEW PAN");
}

- (void)handleTickle:(TickleGestureRecognizer *)recognizer {
    [self.hehePlayer play];
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
    newRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
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
    self.xPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.x];
    self.yPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.y];
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
        
    [self.view addSubview:dropShadow];
    dropShadow.center = recognizer.view.center;
        
    [self.view bringSubviewToFront:recognizer.view];

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
