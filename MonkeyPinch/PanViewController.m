//
//  ViewController.m
//  MonkeyPinch
//
//  Created by Ray Wenderlich on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PanViewController.h"

@implementation ViewController
@synthesize yPosition;
@synthesize xPosition;
@synthesize bananaPan;
@synthesize littleView;
@synthesize monkeyPan;
@synthesize chompPlayer;
@synthesize hehePlayer;

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

    self.chompPlayer = [self loadWav:@"chomp"];
    self.hehePlayer = [self loadWav:@"hehehe1"];
}

- (void)viewDidUnload
{
    [self setBananaPan:nil];
    [self setMonkeyPan:nil];
    [self setLittleView:nil];
    yPosition = nil;
    [self setYPosition:nil];
    [self setXPosition:nil];
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
    
    [self performTranslationWithRecognizer:recognizer];
    
   if (recognizer.state == UIGestureRecognizerStateBegan) {
        
       NSLog(@"Recognizer Started");
       
       //get the view that was clicked
       UIImageView *recognizerView = (UIImageView *)recognizer.view;
       CGPoint touchPoint = recognizerView.frame.origin;
       NSLog(@"Start Center: %d, %d",(int)recognizerView.center.x,(int)recognizerView.center.y);
       //create the copy
       UIImageView *copy = [self createCopyOfImageView:recognizerView atPosition:touchPoint];
       //add copy to toolbar view
       [recognizerView.superview addSubview:copy];
       
       //bring the copy to the front
       //[self.view bringSubviewToFront:recognizerView];
       
       //scale copy x2
       CGRect scaledFrame = recognizerView.frame;
       scaledFrame.size.height = scaledFrame.size.height*2;
       scaledFrame.size.width = scaledFrame.size.width*2;
       recognizerView.frame = scaledFrame;
       //recognizerView.center =
       //[recognizerView removeFromSuperview];
       CGPoint translation = [recognizer translationInView:self.view];
       
       
       
       [self.view addSubview:recognizerView];
       
       NSLog(@"Continuing Center: %d, %d",(int)recognizerView.center.x,(int)recognizerView.center.y);
       
       CGPoint newPoint = CGPointMake(recognizerView.center.x + translation.x,
                                      recognizerView.center.y + translation.y);
       recognizerView.center = newPoint;
       
       //initialize drop shadow
       dropShadow = [[UIView alloc]initWithFrame:recognizerView.frame];
       dropShadow.backgroundColor = [UIColor grayColor];
       dropShadow.alpha = .5;
       [self.view addSubview:dropShadow];
       [self.view bringSubviewToFront:recognizerView];
    
   }else if(recognizer.state == UIGestureRecognizerStateEnded)
   {
       NSLog(@"State ended");
       NSLog(@"Recognizer Image: %@",recognizer.view);
       UIImageView *currentImage = (UIImageView *)recognizer.view;
       NSLog(@"Current Image: %@",currentImage);
       UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveImage:)];
       panGest.delegate = self;
       panGest.minimumNumberOfTouches = 1;
       panGest.maximumNumberOfTouches = 1;
       
       //add recognizer to copy
       NSLog(@"Remaining Gestures %d: %@",recognizer.view.gestureRecognizers.count, recognizer.view.gestureRecognizers);
       
       //[recognizer removeTarget:nil action:NULL];
       
       [recognizer.view removeGestureRecognizer:recognizer];
       
       NSLog(@"Remaining Gestures %d: %@",recognizer.view.gestureRecognizers.count, recognizer.view.gestureRecognizers);
       
       currentImage.userInteractionEnabled = YES;
       
       [currentImage addGestureRecognizer:panGest];
       
       NSLog(@"Snapped to grid");
       //move image to dropshadow location
       currentImage.frame = dropShadow.frame;
       currentImage.center = dropShadow.center;
       NSLog(@"Dropshadow.center = %d,%d",(int)dropShadow.center.x, (int)dropShadow.center.y);
       
       NSLog(@"Recognizer = %d,%d",(int)recognizer.view.center.x, (int)recognizer.view.center.y);
       
       
       //remove dropshadow
       [dropShadow removeFromSuperview];
       dropShadow = nil;
       
       
       
       
       NSLog(@"Remaining Gestures %d: %@",currentImage.gestureRecognizers.count, currentImage.gestureRecognizers);
   }
    
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

- (void)handleCopyPan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"NEW PAN");
    
}

- (IBAction)moveImage:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"MOVE THE IMAGE PAN");
    [self performTranslationWithRecognizer:recognizer];
    
}
- (void)littleViewPan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"NEW PAN");
}

- (void)handleTickle:(TickleGestureRecognizer *)recognizer {
    [self.hehePlayer play];
}

-(UIImageView *)createCopyOfImageView:(UIImageView *)imageView atPosition:(CGPoint)point
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
    
    NSLog(@"%@",imageCopy.gestureRecognizers);
    
    imageCopy.userInteractionEnabled = YES;
    return imageCopy;
}

-(void)performTranslationWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint recViewCenter = recognizer.view.center;
    CGPoint newPoint = CGPointMake(recViewCenter.x + translation.x,
                                         recViewCenter.y + translation.y);
    CGPoint snapPoint = newPoint;
    
    
    
    float step = 20.0; // Grid step size.
    snapPoint.x = step * floor((newPoint.x / step) + 0.5);
    snapPoint.y = step * floor((newPoint.y / step) + 0.5);
    
    recognizer.view.center = newPoint;
    
    NSLog(@"centerx: %d   centery: %d   |   x: %d   y: %d   |   x: %d   y: %d", (int)recViewCenter.x, (int)recViewCenter.y, (int)snapPoint.x, (int)snapPoint.y, (int)newPoint.x, (int)newPoint.y);

    //handle drop shadow
    dropShadow.frame = recognizer.view.frame;
    dropShadow.center = snapPoint;
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    self.xPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.x];
    self.yPosition.text = [NSString stringWithFormat:@"%d",(int)recognizer.view.center.y];
}

@end
