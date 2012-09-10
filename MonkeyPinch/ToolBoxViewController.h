//
//  ToolBoxViewController.h
//  MonkeyPinch
//
//  Created by Jonathan Cohn on 9/7/12.
//
//

#import <UIKit/UIKit.h>
@class ToolBoxViewController;
@protocol ToolBoxViewControllerDelegate <NSObject>


-(void)didDropView:(UIView *)view inTarget:(UIView *)targetView;


@end


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
@property (weak, nonatomic) UIView *dropView;
@property (weak, nonatomic) id <ToolBoxViewControllerDelegate> delegate;

+ (ToolBoxViewController *)displayToolBoxInViewController:(UIViewController *)viewController inView:(UIView *)view withTargetView:(UIView *)targetView;
@end
