//
//  FlyerAnnotation.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/22/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "MapProtocols.h"

@class Flyer;
@interface FlyerAnnotation : NSObject<MKAnnotation, MapAnnotationProtocol>
{
    Flyer* _flyer;
}
@property (nonatomic,readonly) Flyer* flyer;
- (id) initWithFlyer:(Flyer*)flyer;
@end
