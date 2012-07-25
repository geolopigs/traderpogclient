//
//  TradePostMgr.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/13/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "HttpCallbackDelegate.h"
#import "MapControl.h"

static NSString* const kTradePostMgr_ReceivePosts = @"TradePostMgr_ReceivePosts";

@class TradePost;
@class TradeItemType;
@interface TradePostMgr : NSObject<HttpCallbackDelegate>
{
    NSDate* _lastUpdate;
    
    // Delegate for callbacks to inform interested parties of completion
    __weak NSObject<HttpCallbackDelegate>* _delegate;
}
@property (nonatomic,weak) NSObject<HttpCallbackDelegate>* delegate;

// Public methods
- (BOOL) needsRefresh;
- (void) retrievePostsFromServer;
- (NSInteger) postsCount;
- (void) annotatePostsOnMap;
- (TradePost*) newNPCTradePostAtCoord:(CLLocationCoordinate2D)coord
                          sellingItem:(TradeItemType*)itemType;
- (BOOL) newTradePostAtCoord:(CLLocationCoordinate2D)coord 
                              sellingItem:(TradeItemType*)itemType;
- (TradePost*) getTradePostWithId:(NSString*)postId;
- (TradePost*) getFirstTradePost;
- (void) setTempPostToActive;
- (NSMutableArray*) getTradePostsAtCoord:(CLLocationCoordinate2D)coord 
                                  radius:(float)radius 
                                  maxNum:(unsigned int)maxNum;

// singleton
+(TradePostMgr*) getInstance;
+(void) destroyInstance;


@end
