//
//  SGAWSUtility.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGAWSUtility.h"
#import "SGAWSGame.h"
#import "SGAWSStory.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <AWSiOSSDK/SimpleDB/AmazonSimpleDBClient.h>
#import "SGAppDelegate.h"
#import "SGUserInfo.h"


static const int FAILURE = 0;
static const int SUCCESS = 1;
static const int PENDING = 2;

@interface SGAWSUtility(Private)
+(NSString *)getGamesQuery;
+(NSString *)getPaddedScore:(long long)theScore;
+(NSMutableArray *)fetchGamesWithURLs:(NSArray *)urls limit:(NSUInteger)limit;
+(void)addAttributes:(NSDictionary *)attributes forDomain:(NSString *)domain withItemName:(NSString *)name;
+(NSMutableArray *)fetchFromDomain:(NSString *)domain withQuery:(NSString *)query;
@end

@implementation SGAWSUtility

#define NO_TOKEN @"#$#$#$#$"
#define NO_QUERY @"$%$%$%$%"

#define MAX_GAMES           99999

//Game Attributes
#define NAME_ATTRIBUTE      @"game_name"
#define TURNS_ATTRIBUTE     @"game_turns"
#define URL_ATTRIBUTE       @"game_url"
#define HASH_ATTRIBUTE      @"game_hash"

#define GAMES_DOMAIN @"games_domain_name"
#define STORY_DOMAIN @"story_domain_name"
#define USER_DOMAIN @"user_domain_name"

//Story Attributes
#define STORY_TITLE_ATTRIBUTE     @"story_title"
#define STORY_VOTES_ATTRIBUTE     @"story_votes"
#define STORY_URL_ATTRIBUTE       @"story_url"
#define STORY_DATE_ATTRIBUTE      @"story_date"

static NSString *nextToken = NO_TOKEN;
static NSString *lastQuery = @"";

static unsigned short getHash();

const SGStoryQuery LOCAL_QUERY = @"no real query";
const SGStoryQuery VOTE_QUERY = @"select * from story_domain_name where story_votes != '9000000000000000000000000000000000000000000000000000000000000000' order by story_votes desc limit 10";
const SGStoryQuery TITLE_QUERY = @"";
const SGStoryQuery NEWEST_QUERY  = @"select * from story_domain_name where story_date >= '0000000000000000000000000000000000000000000000000000000000000000' order by story_date desc limit 10";

+(NSString *)pushUserInfo:(SGUserInfo *)userInfo {
    @try {
        NSString *key = userInfo.uuid;
        NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
        AmazonS3Client *s3 = [[[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY] autorelease];
        
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:key inBucket:DEV_USER_BUCKET_NAME] autorelease];
        por.data = binaryData;
        por.contentType = @"data/binary";
        [s3 putObject:por]; 
        return SUCCESS_ID;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return ERROR_ID;
    }
}

+(SGUserInfo *)fetchInfoWithUsername:(NSString *)uname password:(NSString *)password {
    return (SGUserInfo *)[NSNull null];
}

+(SGUserInfo *)fetchUserInfo:(NSString *)aURL {
    @try {
        NSString *url = aURL;
        if (!url)
            url = [SGAppDelegate getUniqueDeviceID];
        SGUserInfo *info;
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY];
            S3GetObjectRequest *objectRequest = [[S3GetObjectRequest alloc] initWithKey:url withBucket:DEV_USER_BUCKET_NAME];
            S3GetObjectResponse *objectResponse = [s3 getObject:objectRequest];
            NSData *binaryData = objectResponse.body;
             info = (SGUserInfo *)[NSKeyedUnarchiver unarchiveObjectWithData:binaryData];
            [objectRequest release];        
        [s3 release];
        return info;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return [[[SGUserInfo alloc] initWithPlayer:nil UUID:ERROR_ID playerSince:nil trophies:nil upvotes:0 downvotes:0] autorelease];
    }
}


+(NSString *)pushStory:(SGAWSStory *)story {
    @try {
        NSString *key = story.url;
        NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:story];
        AmazonS3Client *s3 = [[[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY] autorelease];
        
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:key inBucket:DEV_STORY_BUCKET_NAME] autorelease];
        por.data = binaryData;
        por.contentType = @"data/binary";
        [s3 putObject:por];      
        
        //Add story to database
        /*
        NSLog(@"int formatted votes (expected:0): %d", [story votes]);
        NSLog(@"signed long long formatted votes (expected:0): %lli", [[NSNumber numberWithInt:[story votes]] longLongValue]);
        NSLog(@"date description: %@", [story.date description]);
        NSLog(@"date seconds since 1970 (double): %f", [story.date timeIntervalSince1970]);
        NSLog(@"date seconds since 1970 (double): %lli", [[NSNumber numberWithDouble:[story.date timeIntervalSince1970]] longLongValue]);
        */
        
        NSString *votes = [SGAWSUtility getPaddedScore:[[NSNumber numberWithInt:[story votes]] longLongValue]];
        NSString *date = [SGAWSUtility getPaddedScore:[[NSNumber numberWithDouble:[story.date timeIntervalSince1970]] longLongValue]];
        /*
        NSLog(@"padded votes: %@", votes);
        NSLog(@"padded date: %@", date);
        */

        
        NSArray *keys = [NSArray arrayWithObjects:STORY_TITLE_ATTRIBUTE, STORY_URL_ATTRIBUTE, STORY_VOTES_ATTRIBUTE, STORY_DATE_ATTRIBUTE, nil];
        NSArray *vals = [NSArray arrayWithObjects:story.title, story.url, votes, date, nil];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
        [SGAWSUtility addAttributes:attrs forDomain:STORY_DOMAIN withItemName:story.url];
        
        return SUCCESS_ID;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return ERROR_ID;
    }
}

+(NSString *)pushGame:(SGAWSGame *)game {
    @try {
        NSString *key = game.url;
        NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:game];
        AmazonS3Client *s3 = [[[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY] autorelease];
        
        S3PutObjectRequest *por = [[[S3PutObjectRequest alloc] initWithKey:key inBucket:DEV_MAIN_BUCKET_NAME] autorelease];
        por.data = binaryData;
        por.contentType = @"data/binary";
        [s3 putObject:por];
        
        //Add the Data to the Database
        NSString *turns = [SGAWSUtility getPaddedScore:((signed long long)[game.turns count])];
        NSString *hashKey = [NSString stringWithFormat:@"%hu", getHash()];
        
        NSArray *keys = [NSArray arrayWithObjects:NAME_ATTRIBUTE, TURNS_ATTRIBUTE, URL_ATTRIBUTE, HASH_ATTRIBUTE, nil];
        NSArray *vals = [NSArray arrayWithObjects:game.name, turns, game.url, hashKey, nil];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjects:vals forKeys:keys]; 
        [SGAWSUtility addAttributes:attrs forDomain:GAMES_DOMAIN withItemName:[NSString stringWithFormat:@"%@%@", hashKey, game.url]];
                
        return SUCCESS_ID;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return ERROR_ID;
    }
}

+(NSMutableArray *)fetchStoriesByQuery:(SGStoryQuery)query {
    @try {
        NSMutableArray *attributes = [SGAWSUtility fetchAttributesFromDomain:STORY_DOMAIN withQuery:query];
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[attributes count]];
        for (SimpleDBItem *item in attributes) {
            for (SimpleDBAttribute *attribute in item.attributes) {
                if ([attribute.name isEqualToString:STORY_URL_ATTRIBUTE]) {
                    [urls addObject:attribute.value];
                }
            }
        }
        return [SGAWSUtility fetchStoriesWithURLs:urls];
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return [NSMutableArray arrayWithObject:ERROR_ID];
    }
}

+(NSMutableArray *)fetchGamesWithURLs:(NSArray *)urls {
    return [self fetchGamesWithURLs:urls limit:MAX_GAMES];
}

+(NSMutableArray *)fetchGames {
    @try {
        NSMutableArray *attributes = [SGAWSUtility fetchAttributesFromDomain:GAMES_DOMAIN withQuery:[SGAWSUtility getGamesQuery]];
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[attributes count]];
        for (SimpleDBItem *item in attributes) {
            for (SimpleDBAttribute *attribute in item.attributes) {
                if ([attribute.name isEqualToString:URL_ATTRIBUTE]) {
                    [urls addObject:attribute.value];
                }
            }
        }
        return [SGAWSUtility fetchGamesWithURLs:urls limit:MAX_GAMES];    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return [NSMutableArray arrayWithObject:ERROR_ID];
    }
}

+(NSMutableArray *)fetchStoriesWithURLs:(NSArray *)urls {
    @try {
        if ([urls count] == 0) {
            return [NSMutableArray array];
        }
        NSMutableArray *stories = [NSMutableArray array];
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY];
        for (NSString *url in urls) {
            S3GetObjectRequest *objectRequest = [[S3GetObjectRequest alloc] initWithKey:url withBucket:DEV_STORY_BUCKET_NAME];
            S3GetObjectResponse *objectResponse = [s3 getObject:objectRequest];
            NSData *binaryData = objectResponse.body;
            SGAWSStory *story = (SGAWSStory *)[NSKeyedUnarchiver unarchiveObjectWithData:binaryData];
            [stories addObject:story];
            [objectRequest release];
        }
        
        [s3 release];
        return stories;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return [NSMutableArray arrayWithObject:ERROR_ID];
    }
}

+(void)resetQuery {
    if (nextToken)
        [nextToken release];
    nextToken = [NO_TOKEN copy];
    
    if (lastQuery)
        [lastQuery release];
    lastQuery = [NO_QUERY copy];
}

#pragma mark - Private Functions

+(NSMutableArray *)fetchGamesWithURLs:(NSArray *)urls limit:(NSUInteger)limit {
    @try {
        if ([urls count] == 0) {
            return [NSMutableArray array];
        }
        NSMutableArray *games = [NSMutableArray array];
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY];
        for (NSString *url in urls) {
            S3GetObjectRequest *objectRequest = [[S3GetObjectRequest alloc] initWithKey:url withBucket:DEV_MAIN_BUCKET_NAME];
            S3GetObjectResponse *objectResponse = [s3 getObject:objectRequest];
            NSData *binaryData = objectResponse.body;
            SGAWSGame *game = (SGAWSGame *)[NSKeyedUnarchiver unarchiveObjectWithData:binaryData];
            [games addObject:game];
            [objectRequest release];
            if ([games count] >= limit) {
                break;
            }
        }
        
        [s3 release];
        return games;
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@", [exception message]);
        return [NSMutableArray arrayWithObject:ERROR_ID];
    }
    
}

static unsigned short getHash() {
    unsigned short hash = arc4random();
    return hash;
}

+(NSString *)getGamesQuery {
    //Parameters: Domain Name, Turns attribute, Max Turns, Order by Attribute, Limit
    unsigned short hash = getHash();
    NSString *rangeSpecifier;
    if (hash > UINT16_MAX/2)
        rangeSpecifier = @"<=";
    else {
        rangeSpecifier = @">";
    }
    NSString *queryExp =  [NSString stringWithFormat:@"select * from %@ where game_turns <= %@ and game_hash %@ '%hu' order by game_hash desc limit 10", 
                GAMES_DOMAIN,
                [NSString stringWithFormat:@"'%@'", [SGAWSUtility getPaddedScore:kNumTurns-1]],
                rangeSpecifier,
                hash];    
    return queryExp;
}

+(void)addAttributes:(NSDictionary *)attributes forDomain:(NSString *)domain withItemName:(NSString *)name {
    NSArray *keys = [attributes allKeys];
    NSMutableArray *sdbAttrs = [NSMutableArray arrayWithCapacity:[keys count]];
    for (NSString *attributeType in keys) {
        NSString *attributeValue = [attributes objectForKey:attributeType];
        SimpleDBReplaceableAttribute *sdbAttr = [[[SimpleDBReplaceableAttribute alloc] initWithName:attributeType 
                                                                                           andValue:attributeValue 
                                                                                         andReplace:YES] autorelease];
        [sdbAttrs addObject:sdbAttr];
    }
    AmazonSimpleDBClient *sdbClient = [[[AmazonSimpleDBClient alloc] initWithAccessKey:AMAZON_ACCESS_KEY 
                                                                         withSecretKey:AMAZON_SECRET_KEY] autorelease];
    SimpleDBPutAttributesRequest *putAttributesRequest = [[[SimpleDBPutAttributesRequest alloc] initWithDomainName:domain 
                                                                                                       andItemName:name 
                                                                                                     andAttributes:sdbAttrs] autorelease];
    [sdbClient putAttributes:putAttributesRequest];
}

+(NSMutableArray *)fetchAttributesFromDomain:(NSString *)domain withQuery:(NSString *)query {
    @try {
        if (![lastQuery isEqualToString:query]) {
            if (nextToken)
                [nextToken release];
            nextToken = [NO_TOKEN copy];
        }
        
        if (lastQuery)
            [lastQuery release];
        lastQuery = [query copy];
        AmazonSimpleDBClient *sdbClient = [[[AmazonSimpleDBClient alloc] initWithAccessKey:AMAZON_ACCESS_KEY withSecretKey:AMAZON_SECRET_KEY] autorelease];
        
        SimpleDBSelectRequest *selectRequest = [[[SimpleDBSelectRequest alloc] initWithSelectExpression:query] autorelease];
        selectRequest.consistentRead = YES;
        
        if (![nextToken isEqualToString:NO_TOKEN]) {
            selectRequest.nextToken = nextToken;
        }
        
        SimpleDBSelectResponse *selectResponse = [sdbClient select:selectRequest];
        if (nextToken)
            [nextToken release];
        
        nextToken = [selectResponse.nextToken copy];
        
        return selectResponse.items;
    }
    @catch (AmazonClientException *exception) {
        return [NSMutableArray array];
    }

}

+(NSString *)getPaddedScore:(long long )theScore {
    NSString *pad;
    if (theScore >= 0) {
        pad = @"5000000000000000000000000000000000000000000000000000000000000000";
    }
    else {
        long long offset = 999999999;
        pad = @"0000000000000000000000000000000000000000000000000000000000000000";
        theScore = llabs(theScore);
        theScore = offset - theScore;
    }
    
    NSString *scoreValue = [NSString stringWithFormat:@"%lli", theScore];
    
    NSRange  range;
    
    range.location = [pad length] - [scoreValue length];
    range.length = [scoreValue length];
    
    NSString *result = [pad stringByReplacingCharactersInRange:range withString:scoreValue];
    return result;
}


@end
