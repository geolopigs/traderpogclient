//
//  GameManager.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/9/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "ModalNavDelegate.h"
#import "HttpCallbackDelegate.h"

enum kGameStates
{
    kGameStateNew = 0,
    
    kGameStateInGameFirst,
    kGameStateGameLoop = kGameStateInGameFirst,
    kGameStateHomeSelect,
    kGameStateInGameLast,
    
    kGameStateNum = kGameStateInGameLast
};

@class Player;
@class LoadingScreen;
@class CLLocation;
@class Flyer;
@class TradePost;
@class WheelControl;
@interface GameManager : NSObject<HttpCallbackDelegate,ModalNavDelegate>
{
    int _gameState;

    __weak LoadingScreen* _loadingScreen;
}
@property (nonatomic,readonly) int gameState;
@property (nonatomic,weak) LoadingScreen* loadingScreen;
@property (nonatomic,strong) GameViewController* gameViewController;

// public methods
- (void) selectNextGameUI;
- (void) flyer:(Flyer*)flyer departForTradePost:(TradePost*)tradePost;

// in-game UI flows
- (void) showHomeSelectForFlyer:(Flyer*)flyer;
- (void) wheel:(WheelControl*)wheel commitOnTradePost:(TradePost*)tradePost;
- (void) popGameStateToLoop;

// global UI controls
- (void) haltMapAnnotationCalloutsForDuration:(NSTimeInterval)seconds;
- (BOOL) canShowMapAnnotationCallout;

+ (NSString*) documentsDirectory;

// system
- (void) applicationWillEnterForeground;

// singleton
+(GameManager*) getInstance;
+(void) destroyInstance;

@end
