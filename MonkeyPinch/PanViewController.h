//
//  ViewController.h
//  MonkeyPinch
//
//  Created by Ray Wenderlich on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TickleGestureRecognizer.h"
#import "ToolBoxViewController.h"

@interface PanViewController : UIViewController <UIGestureRecognizerDelegate>{
    
	UIImageView		*copiedImage;
    UIPanGestureRecognizer *newRecognizer;
    UIView *dropShadow;
}

- (IBAction)moveImage:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer;
- (IBAction)handleCopyPan:(UIPanGestureRecognizer *)recognizer;
@property (weak, nonatomic) IBOutlet UIView *toolboxView;

@property (strong) AVAudioPlayer * chompPlayer;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *monkeyPan;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *bananaPan;
@property (weak, nonatomic) IBOutlet UIView *littleView;

@property (strong) AVAudioPlayer * hehePlayer;
- (void)handleTickle:(TickleGestureRecognizer *)recognizer;

-(void)performTranslationWithRecognizer:(UIPanGestureRecognizer *)recognizer;
@property (weak, nonatomic) IBOutlet UILabel *yPosition;
@property (weak, nonatomic) IBOutlet UILabel *xPosition;
@property (weak, nonatomic) IBOutlet UILabel *subviewCount;
@property (weak, nonatomic) IBOutlet UILabel *mainviewCount;
@property bool showCoords;
@property bool showDropShadow;
@property bool snapToGrid;
@property float gridSpacing;
@property float scaling;

@end
