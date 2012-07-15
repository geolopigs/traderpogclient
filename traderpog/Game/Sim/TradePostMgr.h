//
//  TradePostMgr.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/13/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class TradePost;
@class TradeItemType;
@interface TradePostMgr : NSObject

- (TradePost*) newTradePostAtCoord:(CLLocationCoordinate2D)coord 
                       sellingItem:(TradeItemType*)itemType
                        isHomebase:(BOOL)isHomebase;
- (TradePost*) getTradePostWithId:(NSString*)postId;
- (TradePost*) getHomebase;
- (NSArray*) getItemTypesForTier:(unsigned int)tier;


// singleton
+(TradePostMgr*) getInstance;
+(void) destroyInstance;


@end
