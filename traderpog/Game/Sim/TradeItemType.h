//
//  TradeItemType.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/15/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TradeItemType : NSObject
{
    NSString* _typeId;
    NSString* _name;
    NSString* _desc;
    NSInteger _price;
    NSInteger _supplymax;
    NSInteger _supplyrate;
    NSInteger _multiplier;
}
@property (nonatomic,strong) NSString* itemId;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* desc;

- (id) initWithItemId:(NSString*)itemId name:(NSString*)name desc:(NSString*)desc;
- (id) initWithDictionary:(NSDictionary*)dict;

// convenience methods
+ (TradeItemType*) itemWithId:(NSString*)itemId name:(NSString*)name desc:(NSString*)desc;
@end
