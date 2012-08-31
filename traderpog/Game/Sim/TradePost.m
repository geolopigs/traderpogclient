//
//  TradePost.m
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/10/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import "AFClientManager.h"
#import "AsyncHttpCallMgr.h"
#import "ImageManager.h"
#include "MathUtils.h"
#import "Player.h"
#import "PogUIUtility.h"
#import "TradePost.h"
#import "TradeItemType.h"
#import "TradeItemTypes.h"
#import "TradePostAnnotationView.h"
#import "TradePostMgr.h"

static NSString* const kKeyPostId = @"id";
static NSString* const kKeyUserId = @"user_id";
static NSString* const kKeyLong = @"longitude";
static NSString* const kKeyLat = @"latitude";
static NSString* const kKeyItemId = @"item_info_id";
static NSString* const kKeyImgPath= @"img";
static NSString* const kKeySupply = @"supply";
static NSString* const kKeySupplyRateLevel = @"supplymaxlevel";
static NSString* const kKeySupplyMaxLevel = @"supplyratelevel";
static NSString* const kKeyBeacontime = @"beacontime";
static NSString* const kKeyFBId = @"fbid";

@implementation TradePost
@synthesize postId = _postId;
@synthesize itemId = _itemId;
@synthesize annotation = _annotation;
@synthesize supplyLevel = _supplyLevel;
@synthesize supplyMaxLevel = _supplyMaxLevel;
@synthesize isOwnPost = _isOwnPost;
@synthesize isNPCPost = _isNPCPost;
@synthesize beacontime = _beacontime;
@synthesize hasFlyer = _hasFlyer;
@synthesize delegate = _delegate;

// call this to create NPC posts
- (id) initWithPostId:(NSString*)postId
           coordinate:(CLLocationCoordinate2D)coordinate
                bucks:(unsigned int)bucks
{
    self = [super init];
    if(self)
    {
        NSArray* itemTypes = [[TradeItemTypes getInstance] getItemTypesForTier:kTradeItemTierMin];
        int randItemIndex = RandomWithinRange(0, [itemTypes count]-1);
        TradeItemType* itemType = [itemTypes objectAtIndex:randItemIndex];
        unsigned int supply = [self generateSupplyLevel:itemType playerBucks:bucks];
        
        _postId = postId;
        _coord = coordinate;
        if(itemType)
        {
            _itemId = [itemType itemId];
            _supplyLevel = MIN([itemType supplymax], supply);
            _supplyMaxLevel = [itemType supplymax];
            _supplyRateLevel = [itemType supplyrate];
        }
        else
        {
            // if itemType is null, make this a dummy post with 0 supply
            _itemId = nil;
            _supplyLevel = 0;
            _supplyMaxLevel = 0;
            _supplyRateLevel = 0;
        }
        _annotation = nil;
        _beacontime = nil;
        
        // NPC post
        _isOwnPost = NO;
        _isNPCPost = YES;
        
        _hasFlyer = NO;
    }
    return self;
}

// call this to create player posts
- (id) initWithCoordinates:(CLLocationCoordinate2D)coordinate 
                  itemType:(TradeItemType *)itemType
{
    self = [super init];
    if(self)
    {
        _coord = coordinate;
        _itemId = [itemType itemId];
        _annotation = nil;
        _beacontime = nil;
        
        // client can only create tradePosts for current player;
        _isOwnPost = YES;
        _isNPCPost = NO;
        
        _hasFlyer = NO;
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary*)dict
                isForeign:(BOOL)isForeign
{
    self = [super init];
    if(self)
    {
        _postId = [NSString stringWithFormat:@"%d", [[dict valueForKeyPath:kKeyPostId] integerValue]];
        _coord.latitude = [[dict valueForKeyPath:kKeyLat] doubleValue];
        _coord.longitude = [[dict valueForKeyPath:kKeyLong] doubleValue];
        _itemId = [NSString stringWithFormat:@"%d", [[dict valueForKeyPath:kKeyItemId] integerValue]];
        _imgPath = [dict valueForKeyPath:kKeyImgPath];
        _supplyMaxLevel =[[dict valueForKeyPath:kKeySupplyMaxLevel] integerValue];
        _supplyRateLevel =[[dict valueForKeyPath:kKeySupplyRateLevel] integerValue];
        _beacontime = nil;
        
        id obj = [dict valueForKeyPath:kKeyBeacontime];
        if ((NSNull *)obj != [NSNull null])
        {
            NSString* utcdate = [NSString stringWithFormat:@"%@", obj];
            if (![utcdate isEqualToString:@"<null>"])
            {
                _beacontime = [PogUIUtility convertUtcToNSDate:utcdate];
            }
        }
        
        _isNPCPost = NO;
        
        if (isForeign)
        {
            _isOwnPost = NO;
            
            // These two only matter in the context of a foreign beacon trade post
            _userId = [NSString stringWithFormat:@"%d", [[dict valueForKeyPath:kKeyUserId] integerValue]];
            _fbId = [NSString stringWithFormat:@"%@", [dict valueForKeyPath:kKeyFBId]];
            
            _supplyLevel = [self getForeignSupplyLevel];
        }
        else
        {
            _isOwnPost = YES;
            
            _supplyLevel = [[dict valueForKeyPath:kKeySupply] integerValue];
        }
        
        // transient variables
        _annotation = nil;
        _hasFlyer = NO;
    }
    return self;
}

-(unsigned int) generateSupplyLevel:(TradeItemType*)itemType playerBucks:(unsigned int)playerBucks
{
    // This function is used to generate a supply level for NPC and foreign posts
    float randPriceFactor = MAX(0.2f,0.7f - (RandomFrac() * 0.5f));
    return (playerBucks / [itemType price]) * randPriceFactor;
}

- (unsigned int) getForeignSupplyLevel
{
    // Foreign trade posts always have items to trade with
    TradeItemType* itemType = [[TradeItemTypes getInstance] getItemTypeForId:_itemId];
    unsigned int maxSupply = MAX(1, (_supplyMaxLevel - 1) * [itemType multiplier]) * [itemType supplymax];
    // Generate a random supply level roughly between 10 - 100% of allowable max supply
    return MIN(MAX(0.2f, RandomFrac()) * maxSupply, maxSupply);
}

- (void)updatePostSupply:(NSInteger)deductSupplies
{
    NSString *path = [NSString stringWithFormat:@"posts/%@", _postId];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:deductSupplies], kKeySupply,
                                nil];
    NSString* msg = [[NSString alloc] initWithFormat:@"Updating Foreign Post with %d supply change failed", deductSupplies];
    
    [[AsyncHttpCallMgr getInstance] newAsyncHttpCall:path
                                      current_params:parameters
                                     current_headers:nil
                                         current_msg:msg
                                        current_type:putType];
}

#pragma mark - server calls

- (void) createNewPostOnServer
{
    // post parameters
    NSString *userId = [NSString stringWithFormat:@"%d", [[Player getInstance] playerId]];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                userId, kKeyUserId,
                                [NSNumber numberWithDouble:_coord.longitude], kKeyLong, 
                                [NSNumber numberWithDouble:_coord.latitude], kKeyLat, 
                                _itemId, kKeyItemId,
                                nil];
    
    // make a post request
    AFHTTPClient* httpClient = [[AFClientManager sharedInstance] traderPog];
    [httpClient postPath:@"posts.json" 
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject){                     
                     _postId = [NSString stringWithFormat:@"%d", [[responseObject valueForKeyPath:kKeyPostId] integerValue]];
                     _imgPath = [responseObject valueForKeyPath:kKeyImgPath];
                     _supplyMaxLevel = [[responseObject valueForKeyPath:kKeySupplyMaxLevel] integerValue];
                     _supplyRateLevel = [[responseObject valueForKeyPath:kKeySupplyRateLevel] integerValue];
                     [self.delegate didCompleteHttpCallback:kTradePost_CreateNewPost, TRUE];
                 }
                 failure:^(AFHTTPRequestOperation* operation, NSError* error){
                     UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Server Failure"
                                                                       message:@"Unable to create post. Please try again later."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                     
                     [message show];
                     [self.delegate didCompleteHttpCallback:kTradePost_CreateNewPost, FALSE];
                 }
     ];
}

- (void) updatePost:(NSDictionary*)parameters
{
    // make a post request
    AFHTTPClient* httpClient = [[AFClientManager sharedInstance] traderPog];
    NSString *postUrl = [NSString stringWithFormat:@"posts/%@", _postId];
    [httpClient putPath:postUrl
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSLog(@"Post data updated");
                    // Update beacontime
                    id obj = [responseObject valueForKeyPath:kKeyBeacontime];
                    if ((NSNull *)obj != [NSNull null])
                    {
                        NSString* utcdate = [NSString stringWithFormat:@"%@", obj];
                        if (![utcdate isEqualToString:@"<null>"])
                        {
                            _beacontime = [PogUIUtility convertUtcToNSDate:utcdate];
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation* operation, NSError* error){
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Server Failure"
                                                                      message:@"Unable to update post. Please try again later."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                    
                    [message show];
                }
     ];
}

- (void) setBeacon
{
    if ([[TradePostMgr getInstance] isBeaconActive])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Beacon exists"
                                                          message:@"Only a single beacon can be active at a time"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    else
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM dd, yyyy HH:mm"];
        NSDate *now = [[NSDate alloc] init];
        NSString *dateString = [format stringFromDate:now];
        NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    dateString, kKeyBeacontime,
                                    nil];
        [self updatePost:parameters];
    }
}

- (bool) beaconActive
{
    return (_beacontime && ([_beacontime timeIntervalSinceNow] > 0));
}

#pragma mark - trade
- (void) deductNumItems:(unsigned int)num
{
    if (!_isOwnPost && !_isNPCPost)
    {
        // For foreign posts, rather than deduct, just randomly reassign a new value
        self.supplyLevel = [self getForeignSupplyLevel];
        
        // Update the foreign post with the amount of supplies reduced
        [self updatePostSupply:-num];
    }
    else
    {
        unsigned int numToSub = MIN([self supplyLevel], num);
        self.supplyLevel -= numToSub;
    }
}

#pragma mark - getters/setters
- (CLLocationCoordinate2D) coord
{
    return _coord;
}

- (void) setCoord:(CLLocationCoordinate2D)coord
{
    _coord = coord;
}


#pragma mark - MKAnnotation delegate
- (CLLocationCoordinate2D) coordinate
{
    return [self coord];
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.coord = newCoordinate;
}

#pragma mark - MapAnnotationProtocol
- (MKAnnotationView*) annotationViewInMap:(MKMapView *)mapView
{
    TradePostAnnotationView* annotationView = (TradePostAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kTradePostAnnotationViewReuseId];
    if(annotationView)
    {
        annotationView.annotation = self;
    }
    else
    {
        annotationView = [[TradePostAnnotationView alloc] initWithAnnotation:self];
    }
    
    if([self isOwnPost])
    {
        // own post is always enabled
        annotationView.enabled = YES;
        UIImage* image = [[ImageManager getInstance] getImage:[self imgPath]
                                            fallbackNamed:@"b_flyerlab.png"];
        [annotationView.imageView setImage:image];
    }
    else
    {
        if([self hasFlyer])
        {
            annotationView.enabled = NO;
        }
        else
        {
            annotationView.enabled = YES;
        }
        
        if([self isNPCPost])
        {
            UIImage* image = [[ImageManager getInstance] getImage:[self imgPath]
                                           fallbackNamed:@"b_tradepost.png"];
            [annotationView.imageView setImage:image];
        }
        else
        {
            UIImage* image = [[ImageManager getInstance] getImage:[self imgPath]
                                           fallbackNamed:@"b_homebase.png"];
            [annotationView.imageView setImage:image];
        }
    }

    return annotationView;
}

@end
