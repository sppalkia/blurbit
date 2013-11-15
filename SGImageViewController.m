//
//  SGImageViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGImageViewController.h"

@implementation SGImageViewController
@synthesize imageView;

-(void)dealloc {
    self.imageView = nil;
    [super dealloc];
}

@end
