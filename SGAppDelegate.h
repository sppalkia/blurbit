//
//  SGAppDelegate.h
//  Blurbit
//
//  Created by Shoumik Palkar on 1/22/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class SGViewController, SGPlayer, SGGame, SGLocalDataUtility, SGUserInfo;
@interface SGAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate> {
    BOOL firstRun;
    BOOL defaultInfoUsed;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    SGUserInfo *userInfo;
    SGUserInfo *_defaultInfo;
    SGLocalDataUtility *localDataUtility;
    
    Facebook *facebook;
    BOOL facebookLoginToken;
    BOOL facebookDidPerformLoad;
}

@property(nonatomic, retain) SGLocalDataUtility *localDataUtility;
@property(nonatomic, retain) SGUserInfo *userInfo;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic) BOOL firstRun;
@property(nonatomic) BOOL defaultInfoUsed;


@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic) BOOL facebookLoginToken;
@property (nonatomic) BOOL facebookDidPerformLoad;

+(NSString *)getUniqueDeviceID;

-(void)startFacebook;

@end
