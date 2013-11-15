//
//  SGLocalDataUtility.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/27/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGLocalDataUtility.h"
#import "SGUserInfo.h"
#import "SGPlayer.h"

//Abstract these away from other classes
#import "URL.h"
#import "Story.h"
#import "UserInfo.h"

@interface SGLocalDataUtility(PrivateMethods)
-(NSArray *)getManagedObjectsForEntity:(NSString *)entityName;
@end

@implementation SGLocalDataUtility
@synthesize managedObjectContext;

//constants
#define URL_ENTITY      @"URL"
#define STORY_ENTITY    @"Story"
#define USERINFO_ENTITY @"UserInfo"

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        self.managedObjectContext = context;
    }
    return self;
}

-(BOOL)commitChanges {
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
        return FALSE;
    }
    return TRUE;
}

#pragma mark - Game URLs
/*
 *Data held in _managedGameURLs
 *Key: url (NSString *)
 *Value: URL (NSManagedObject subclass)
 */

-(NSArray *)getGameURLs {
    if (_managedGameURLs) [_managedGameURLs release];
    NSArray *managedObjects = [self getManagedObjectsForEntity:URL_ENTITY];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[managedObjects count]];
    for (URL *obj in managedObjects) {
        [result setObject:obj forKey:[obj url]];
    }
    _managedGameURLs = [[NSMutableDictionary alloc] initWithDictionary:result];
    return [_managedGameURLs allKeys];
}

-(void)writeGameURL:(NSString *)url {
    [self getGameURLs];
    NSArray *urls = [_managedGameURLs allKeys];
    if ([urls containsObject:url]) {
        NSLog(@"story already written. local store unchanged.");
        return;
    }

    URL *obj = (URL *)[NSEntityDescription insertNewObjectForEntityForName:URL_ENTITY 
                                                        inManagedObjectContext:self.managedObjectContext];
    [obj setUrl:url];
    [self commitChanges];
    [_managedGameURLs setObject:obj forKey:url];

}
-(void)removeGameURL:(NSString *)url {
    [self getGameURLs];
    URL *rm = [_managedGameURLs objectForKey:url];
    [self.managedObjectContext deleteObject:rm];
    [_managedGameURLs removeObjectForKey:url];
    [self commitChanges];
}

#pragma mark - Story URLs
/*
 *Data held in _managedStoryURLs
 *Key: url (NSString *)
 *Value: Story (NSManagedObject subclass)
 */

-(NSArray *)getStoryURLs {
    if (_managedStoryURLs) [_managedStoryURLs release];
    NSArray *managedObjects = [self getManagedObjectsForEntity:STORY_ENTITY];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[managedObjects count]];
    for (Story *obj in managedObjects) {
        [result setObject:obj forKey:[obj url]];
    }
    _managedStoryURLs = [[NSMutableDictionary alloc] initWithDictionary:result];
    return [_managedStoryURLs allKeys];
}
-(void)writeStoryURL:(NSString *)url {
    [self getStoryURLs];
    NSArray *urls = [_managedStoryURLs allKeys];
    if ([urls containsObject:url]) {
        NSLog(@"story already written. local store unchanged.");
        return;
    }
    Story *obj = (Story *)[NSEntityDescription insertNewObjectForEntityForName:STORY_ENTITY 
                                                                         inManagedObjectContext:self.managedObjectContext];
    [obj setUrl:url];
    [_managedStoryURLs setObject:obj forKey:url];
    [self commitChanges];
}

-(void)removeStoryURL:(NSString *)url {
    [self getStoryURLs];
    Story *rm = [_managedStoryURLs objectForKey:url];
    if (!rm) {
        NSLog(@"story not found in local store");
        return;
    };
    NSLog(@"%@ removed", url);
    [self.managedObjectContext deleteObject:rm];
    [_managedStoryURLs removeObjectForKey:url];
    [self commitChanges];
}

#pragma mark - User Info

-(void)writeUserInfo:(SGUserInfo *)userInfo {
    if (!_userInfo) {
        _userInfo = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:USERINFO_ENTITY 
                                                              inManagedObjectContext:self.managedObjectContext];
    }
    [_userInfo setName:userInfo.player.name];
    [_userInfo setDownvotes:userInfo.downvotes];
    [_userInfo setUpvotes:userInfo.upvotes];
    [_userInfo setPlayerSince:[userInfo.playerSince timeIntervalSinceReferenceDate]];
    [_userInfo setTrophies:@"None"];
    [_userInfo setUuid:userInfo.uuid];
    [self commitChanges];
}

-(SGUserInfo *)getUserInfo {
    if (!_userInfo) {
        NSArray *managedObjects = [self getManagedObjectsForEntity:USERINFO_ENTITY];
        if ([managedObjects count] == 0)
            [NSException raise:@"UserInfo file not found." format:@"Local UserInfo file is nil"];
        _userInfo = [managedObjects objectAtIndex:0];
    }
    
    SGPlayer *player = [[SGPlayer alloc] initWithName:[_userInfo name] 
                                                 uuid:[_userInfo uuid]];
    SGUserInfo *info = [[SGUserInfo alloc] initWithPlayer:player
                                                     UUID:[_userInfo uuid]
                                               playerSince:[NSDate dateWithTimeIntervalSinceReferenceDate:[_userInfo playerSince]] 
                                                 trophies:[NSArray array] 
                                                  upvotes:[_userInfo upvotes] 
                                                downvotes:[_userInfo downvotes]];
    [player release];
    [info autorelease];
    return info;
}

#pragma mark - Private Methods

-(NSArray *)getManagedObjectsForEntity:(NSString *)entityName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSMutableArray *fetched = [[[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy] autorelease];
    [fetchRequest release];

    if (fetched == nil) {
        NSLog(@"%@", [error localizedDescription]);
        fetched = [NSArray array];
    }
    return fetched;
}


#pragma mark - Memory Management

-(void)dealloc {
    self.managedObjectContext = nil;
    if (_managedGameURLs)
        [_managedGameURLs release];
    if (_managedStoryURLs)
        [_managedStoryURLs release];
    [super dealloc];
}

@end
