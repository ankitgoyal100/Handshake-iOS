//
//  UserViewController.h
//  Handshake
//
//  Created by Sam Ober on 4/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) User *user;

@end
