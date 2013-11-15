//
//  SGRulebook.h
//  RulebookTest
//
//  Created by Shoumik Palkar on 10/31/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSGRulebookTypeDefault
} SGRulebookType;

@interface SGRulebook : NSObject <NSCoding> {
    NSString *previousTurn;
    NSString *errorString;
}
@property(nonatomic, copy) NSString *previousTurn;
@property(nonatomic, copy) NSString *errorString;

+(BOOL)producedError:(NSString *)str;
-(NSString *)applyRules:(NSString *)str;

@end
