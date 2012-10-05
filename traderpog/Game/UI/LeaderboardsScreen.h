//
//  LeaderboardsScreen.h
//  traderpog
//
//  Created by Aaron Khoo on 9/24/12.
//  Copyright (c) 2012 GeoloPigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpCallbackDelegate.h"

@interface LeaderboardsScreen : UIViewController<HttpCallbackDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITableView *lbtable;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end
