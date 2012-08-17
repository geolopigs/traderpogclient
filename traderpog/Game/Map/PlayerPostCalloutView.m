//
//  PlayerPostCalloutView.m
//  traderpog
//
//  Created by Shu Chiun Cheah on 8/17/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import "PlayerPostCalloutView.h"
#import "PlayerPostCallout.h"

NSString* const kPlayerPostCalloutViewReuseId = @"PlayerPostCalloutView";

@implementation PlayerPostCalloutView
- (id) initWithAnnotation:(id<MKAnnotation>)annotation
{
    self = [super initWithAnnotation:annotation reuseIdentifier:kPlayerPostCalloutViewReuseId];
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PlayerPostCalloutView" owner:self options:nil];
    }
    return self;
}

- (IBAction)didPressSetBeacon:(id)sender
{
    NSLog(@"Set Beacon");
}

- (IBAction)didPressRestock:(id)sender
{
    NSLog(@"Restock");
}

- (IBAction)didPressDestroy:(id)sender
{
    NSLog(@"Destroy");
}
@end
