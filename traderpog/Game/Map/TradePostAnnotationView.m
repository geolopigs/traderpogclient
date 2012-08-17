//
//  TradePostAnnotationView.m
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/15/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import "TradePostAnnotationView.h"
#import "TradePostCallout.h"
#import "ImageManager.h"
#import "TradePost.h"
#import "PlayerPostCallout.h"

NSString* const kTradePostAnnotationViewReuseId = @"PostAnnotationView";

@interface TradePostAnnotationView ()
{
    NSObject<MKAnnotation,MapAnnotationProtocol>* _calloutAnnotation;
}
@end

@implementation TradePostAnnotationView

- (id) initWithAnnotation:(NSObject<MKAnnotation>*)annotation
{
    self = [super initWithAnnotation:annotation reuseIdentifier:kTradePostAnnotationViewReuseId];
    if(self)
    {
        // handle our own callout
        self.canShowCallout = NO;
        
        // set size of view
        CGRect myFrame = self.frame;
        myFrame.size = CGSizeMake(120.0f, 120.0f);
        self.frame = myFrame;
        
        // setup tradepost image
        TradePost* tradePost = (TradePost*)annotation;
        UIImage* annotationImage = nil;
        if([tradePost isOwnPost])
        {
            annotationImage = [[ImageManager getInstance] getImage:[tradePost imgPath]
                                                     fallbackNamed:@"HomeBase.png"];
        }
        else
        {
            annotationImage = [[ImageManager getInstance] getImage:[tradePost imgPath]
                                                     fallbackNamed:@"TradePost.png"];
        }
        CGRect resizeRect = CGRectMake(0.0f, 0.0f, 120.0f, 120.0f);
        UIGraphicsBeginImageContext(resizeRect.size);
        [annotationImage drawInRect:resizeRect];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.opaque = NO;
        
        // annotation-view anchor is at the center of the view;
        // so, shift the image so that its bottom is at the coordinate
        UIView* contentView = [[UIView alloc] initWithFrame:myFrame];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:resizedImage];
        [imageView setFrame:CGRectMake(myFrame.origin.x, 
                                       myFrame.origin.y, 
                                       resizeRect.size.width, resizeRect.size.height)];
        [contentView addSubview:imageView];
        
        [self addSubview:contentView];
        
        _calloutAnnotation = nil;
    }
    return self;
}

#pragma mark - MKAnnotationView
- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    if(_calloutAnnotation) 
    {
        [_calloutAnnotation setCoordinate:annotation.coordinate];
    }
    [super setAnnotation:annotation];
    self.enabled = YES;
}

#pragma mark - PogMapAnnotationViewProtocol
- (void)didSelectAnnotationViewInMap:(MKMapView*) mapView;
{    
    if(!_calloutAnnotation)
    {
        TradePost* tradePost = (TradePost*) [self annotation];
        if([tradePost isOwnPost])
        {
            // show player-post callout if own post
            PlayerPostCallout* callout = [[PlayerPostCallout alloc] initWithTradePost:tradePost];
            callout.parentAnnotationView = self;
            _calloutAnnotation = callout;
        }
        else
        {
            // otherwise, show tradepost callout
            TradePostCallout* callout = [[TradePostCallout alloc] initWithTradePost:tradePost];
            callout.parentAnnotationView = self;
            _calloutAnnotation = callout;
        }
        [mapView addAnnotation:_calloutAnnotation];
    }
}

- (void)didDeselectAnnotationViewInMap:(MKMapView*) mapView;
{
    if(_calloutAnnotation)
    {
        [mapView removeAnnotation:_calloutAnnotation];
        _calloutAnnotation = nil;
    }
}

@end
