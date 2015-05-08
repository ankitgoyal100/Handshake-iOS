//
//  EditGroupViewController.h
//  Handshake
//
//  Created by Sam Ober on 5/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@protocol EditGroupViewControllerDelegate <NSObject>

- (void)groupEdited:(Group *)group;
- (void)groupEditCancelled:(Group *)group;

@end

@interface EditGroupViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Group *group;

@property (nonatomic, strong) id <EditGroupViewControllerDelegate> delegate;

@end
