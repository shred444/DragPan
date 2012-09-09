//
//  ToolBoxViewController.h
//  MonkeyPinch
//
//  Created by Jonathan Cohn on 9/7/12.
//
//

#import <UIKit/UIKit.h>

@interface ToolBoxViewController : UIViewController <UIGestureRecognizerDelegate>
{
    
    UIView *dropShadow;
    
}
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;

@property (weak, nonatomic) IBOutlet UIImageView *monkey;
@property bool showCoords;
@property bool showDropShadow;
@property bool snapToGrid;
@property float gridSpacing;
@property float scaling;
@property (nonatomic, weak) UIView *mainView;
@end
