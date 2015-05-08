//
//  GroupViewController.h
//  Handshake
//
//  Created by Sam Ober on 5/6/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface GroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Group *group;

@end
