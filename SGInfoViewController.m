//
//  SGInfoViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation SGInfoViewController
@synthesize shadowedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    self.shadowedView.layer.masksToBounds = NO;
    self.shadowedView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    self.shadowedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowedView.layer.shadowOpacity = 1.0f;
    self.shadowedView.layer.shadowRadius = 5.0f;
    
    CGSize size = self.shadowedView.bounds.size;
    
    //From http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    self.shadowedView.layer.shadowPath = path.CGPath;
    
    [super viewDidLoad];
}

-(IBAction)back:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

-(void)dealloc {
    self.shadowedView = nil;
    [super dealloc];
}

@end
