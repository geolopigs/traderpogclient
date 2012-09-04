//
//  WheelBubble.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 6/30/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WheelBubble : UIView
{
    UILabel* _labelView;
    UIImageView* _imageView;
}
@property (nonatomic,strong) UILabel* labelView;
@property (nonatomic,strong) UIImageView* imageView;
@end
