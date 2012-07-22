//
//  TradePostCalloutView.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/21/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalloutAnnotationView.h"

extern NSString* const kTradePostCalloutViewReuseId;

@interface TradePostCalloutView : CalloutAnnotationView
- (IBAction)didPressGo:(id)sender;

@end
