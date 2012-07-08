//
//  ImageManager.h
//  traderpog
//
//  Created by Shu Chiun Cheah on 7/8/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject

// frontend menu
- (void) loadFrontMenuBackground;       // ok to call this repeatedly
- (void) unloadFrontMenuBackground;

// singleton
+(ImageManager*) getInstance;
+(void) destroyInstance;


@end
