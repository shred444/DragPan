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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    for(UIImageView *image in self.view.subviews)
    {
        //add a gesture recognizer to each one
        UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        panGest.delegate = self;
        panGest.minimumNumberOfTouches = 1;
        panGest.maximumNumberOfTouches = 1;
        
        [image addGestureRecognizer:panGest];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
