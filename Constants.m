//
//  Constants.m
//  Guava
//
//  Created by Shoumik Palkar on 10/10/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

int const kPlayPointValue = 2;
int const kSharePointValue = 4;
int const kNewGamePointValue = 1;
int const kUpvotePointValue = 5;
int const kDownvotePointValue = -3;


int const kUpvotesNeededForPoints = 5;
int const kDownvotesNeededForPoints = 5;

float const kShortAlertTime = 1.0;
float const kLongAlertTime = 2.0;



NSString * const GAME_ID = @"Guava";
int const MAX_CHARACTER_LIMIT = 100;
int const MIN_CHARACTER_LIMIT = 30;

int const kNumTurns = 6;
int const kMaxCircularPlayers = 3;

float const RGBA_BAR_COLORS[4] = {0.52549f, 0.4902f, 0.3961f, 1.0f};

NSString * const AMAZON_ACCESS_KEY = @"PUT SOMETHING HERE";
NSString * const AMAZON_SECRET_KEY = @"PUT SOMETHING HERE";

NSString * const FACEBOOK_APP_ID = @"PUT SOMETHING HERE";
NSString * const FACEBOOK_APP_SECRET = @"PUT SOMETHING HERE";


NSString * const DEV_MAIN_BUCKET_NAME = @"PUBLIC-blurbit-games";
NSString * const DEV_STORY_BUCKET_NAME = @"PUBLIC-blurbit-stories";
NSString * const DEV_USER_BUCKET_NAME = @"PUBLIC-blurbit-userinfo";
NSString * const METADATA_NUM_TURNS = @"num_turns_blurbit_core";


NSString * const kSGGameTypeSingle = @"Local";
NSString * const kSGGameTypeBluetooth = @"Bluetooth";
NSString * const kSGGameTypeServer = @"Server";

NSString * const kSGGameTypeSingleLabel = @"Local Game";
NSString * const kSGGameTypeBluetoothLabel = @"Bluetooth Game";
NSString * const kSGGameTypeServerLabel = @"Online Game";

NSString * const kSGGameTypeSingleDescription = @"A play-and-pass mode for you and friends.";
NSString * const kSGGameTypeBluetoothDescription = @"A local game played over Bluetooth.";
NSString * const kSGGameTypeServerDescription = @"A standard game played online.";

//Erors Messages

//between MIN_CHARACTER_LIMIT and MAX_CHARACTER_LIMIT. Static string to make it compile-time initializable
NSString * const kSGErrorOutOfBounds = @"The Blurb must be between 30 and 100 characters long";
NSString * const kSGErrorPeriodNeeded = @"This Blurb has to finish the preceding sentence.";

//must be at least MAX_CHARACTER_LIMIT/2 characters long.
NSString * const kSGErrorShortEndSentence = @"A Blurb that ends a sentence must be at least 50 characters long";


NSString * const ERROR_ID = @"#314BLURBIT%%&";
NSString * const SUCCESS_ID = @"HohoSUCESS!!";

//Error Codes

int const NETWORK_ERROR = 1;

//View Tags

int const SEND_ALERT_VIEW_TAG = 298347;

//Functions


NSString* getPostFixedNumber(unsigned int x) {
    unsigned tmp = x;
    
    while(tmp >= 10)
        tmp /= 10;
    
    NSString *postfix = nil;
    if (tmp >= 10 && tmp < 20)
        postfix = @"th";
    if (tmp == 1)
        postfix = @"st";
    else if (tmp == 2)
        postfix = @"nd";
    else if (tmp == 3)
        postfix = @"rd";
    else
        postfix = @"th";
    
    return [NSString stringWithFormat:@"%u%@", x, postfix];
}

