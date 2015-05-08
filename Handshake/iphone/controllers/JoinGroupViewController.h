//
//  JoinGroupViewController.h
//  Handshake
//
//  Created by Sam Ober on 5/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol JoinGroupViewControllerDelegate <NSObject>

- (void)groupJoined:(Group *)group;

@end

@interface JoinGroupViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) id <JoinGroupViewControllerDelegate> delegate;

@end
