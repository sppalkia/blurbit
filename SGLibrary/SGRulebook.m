//
//  SGRulebook.m
//  RulebookTest
//
//  Created by Shoumik Palkar on 10/31/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGRulebook.h"

@implementation SGRulebook
@synthesize previousTurn;
@synthesize errorString;

@interface SGRulebook(Private)
-(BOOL)fragmentOkay:(NSString *)fragment;
-(BOOL)fragmentHasPeriod:(NSString *)fragment;
-(void)updateStateWithFragment:(NSString *)fragment;
@end

-(id)init {
    if (self = [super init]) {
        self.errorString = @"NO ERROR";
        self.previousTurn = @" .";
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.previousTurn= [coder decodeObjectForKey:@"previousTurn"];
        self.errorString = [coder decodeObjectForKey:@"errorString"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.previousTurn forKey:@"previousTurn"];
    [aCoder encodeObject:self.errorString forKey:@"errorString"];
}

-(NSString *)applyRules:(NSString *)str {
    self.errorString = @"NO ERROR";
    if (str && [self fragmentOkay:str]) {
        NSRange firstChar = NSMakeRange(0, 1);
        BOOL strHasSpace = ([[str substringWithRange:firstChar] isEqualToString:@" "]) ? TRUE : FALSE;
        BOOL previousHasSpace = ([[self.previousTurn substringFromIndex:self.previousTurn.length-1] isEqualToString:@" "]) ? TRUE : FALSE;
        
        if (previousHasSpace) {
            if (strHasSpace) {
                str = [str substringFromIndex:1];
            }
        }
        else {
            if (!strHasSpace && ![self.previousTurn isEqualToString:@" ."]) {
                str = [@" " stringByAppendingString:str];
            }
        }
        //Fix capitalization if previous phrase ends with a period
        if ([[self.previousTurn substringFromIndex:self.previousTurn.length-1] isEqualToString:@"."]) {
            NSString *firstLetter = [str substringWithRange:firstChar];
            firstLetter = [firstLetter uppercaseString];
            str = [firstLetter stringByAppendingString:[str substringFromIndex:1]];
        }
        
        [self updateStateWithFragment:str];
        return str;
    }
    else {
        return [ERROR_ID stringByAppendingString:self.errorString];
    }
}

+(BOOL)producedError:(NSString *)str {
    NSRange range = [str rangeOfString:ERROR_ID];
    BOOL hasError = (range.location == NSNotFound) ? FALSE : TRUE;
    return hasError;
}

#pragma mark - Private Methods

-(BOOL)fragmentHasPeriod:(NSString *)fragment {
    NSRange range = [fragment rangeOfString:@"."];
    return (range.location == NSNotFound) ? FALSE : TRUE;
}

-(void)updateStateWithFragment:(NSString *)fragment {
    self.errorString = @"NO ERROR";
    self.previousTurn = fragment;
}

-(BOOL)fragmentOkay:(NSString *)fragment {
    if (fragment.length > MAX_CHARACTER_LIMIT || fragment.length < MIN_CHARACTER_LIMIT) {
        self.errorString  = kSGErrorOutOfBounds;
        return FALSE;
    }
    BOOL needPeriod = ![self fragmentHasPeriod:self.previousTurn];
    if (needPeriod && !([self fragmentHasPeriod:fragment])) {
        self.errorString  = kSGErrorPeriodNeeded;
        return FALSE;
    }
    
    BOOL endsWithPeriod = FALSE;
    if ([[fragment substringFromIndex:fragment.length-1] isEqualToString:@"."]) {
        endsWithPeriod = TRUE;
    }
    if (endsWithPeriod) {
        if (fragment.length < MIN_CHARACTER_LIMIT*2) {
            self.errorString  = kSGErrorShortEndSentence;
            return FALSE;
        }
    }    
    return TRUE;
}

-(void)dealloc {
    self.errorString = nil;
    self.previousTurn = nil;
    [super dealloc];
}

@end
