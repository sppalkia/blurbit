//
//  SGAppDelegate.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/22/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGAppDelegate.h"

#import "SGViewController.h"
#import "SGPlayer.h"
#import "SGGame.h"
#import "SGLocalDataUtility.h"
#import "SGUserInfo.h"
#import "SGAWSUtility.h"

@implementation SGAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize localDataUtility;
@synthesize userInfo;
@synthesize firstRun;
@synthesize defaultInfoUsed;
@synthesize facebook;
@synthesize facebookLoginToken;
@synthesize facebookDidPerformLoad;

#pragma mark - Class Methods

+(NSString *)makeUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return uuidString;
}

+(NSString *)getUniqueDeviceID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"UUID"];
}

-(void)startFacebook {
    self.facebookLoginToken = NO;
    self.facebookDidPerformLoad = YES;
    Facebook *fb = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
    self.facebook = fb;
    [fb release];
    
    if (![self.facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
        [self.facebook authorize:permissions];
        [permissions release];
    }
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    self.firstRun = NO;
    self.defaultInfoUsed = NO;
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		NSLog(@"ManagedObjectContext Error in applicationDidFinishLaunching)");
	}
    
    SGLocalDataUtility *d = [[SGLocalDataUtility alloc] initWithManagedObjectContext:context];
    self.localDataUtility = d;
    [d release];
    
    //Generate a UUID and store it (unique to device)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults objectForKey:@"UUID"]) {
        NSString *uuid = [SGAppDelegate makeUUID];
        [defaults setObject:uuid forKey:@"UUID"];
        [defaults synchronize];        
        self.firstRun = YES;
    }
        
    NSString *uuid = [SGAppDelegate getUniqueDeviceID];
    SGPlayer *defaultPlayer = [[SGPlayer alloc] initWithName:@"Anonymous" uuid:uuid];
    _defaultInfo = [[SGUserInfo alloc] initWithPlayer:defaultPlayer
                                                     UUID:uuid
                                              playerSince:[NSDate date]
                                                 trophies:[NSArray array] 
                                                  upvotes:0
                                                downvotes:0];
    self.userInfo = _defaultInfo;
    [defaultPlayer release];
    
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        Facebook *fb = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
        self.facebook = fb;
        [fb release];
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        
        if (![self.facebook isSessionValid]) {
            NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
            [self.facebook authorize:permissions];
            [permissions release];
        }
    }
        
    SGViewController *viewController = [[[SGViewController alloc] initWithNibName:@"SGViewController" bundle:nil] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.userInfo) {
        [self.localDataUtility writeUserInfo:self.userInfo];
    }
}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.userInfo) {
        [self.localDataUtility writeUserInfo:self.userInfo];
    }
}

#pragma mark - FBSessionDelegate 

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    self.facebookLoginToken = YES;
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    self.facebookLoginToken = YES;
}

- (void)fbDidExtendToken:(NSString*)accessToken
expiresAt:(NSDate*)expiresAt {

}

- (void)fbDidLogout {
    self.facebookLoginToken = NO;
}

- (void)fbSessionInvalidated {
    self.facebookLoginToken = YES;
}

#pragma mark - Core Data

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Blurbit.sqlite"]];
    
    firstRun = NO;	
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path] isDirectory:NULL]) {
		firstRun = YES;		
	}
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil 
                                                           URL:storeUrl 
                                                       options:nil 
                                                         error:&error]) {}
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]] retain];
    return managedObjectModel;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - Memory Management

- (void)dealloc {
    self.localDataUtility = nil;
    self.userInfo = nil;
    self.facebook = nil;
    
    [_defaultInfo release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];

    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
