//
//  NameEditController.h
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol NameEditControllerDelegate <NSObject>

- (void)nameEdited:(NSString *)first last:(NSString *)last;

@end

@interface NameEditController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) id <NameEditControllerDelegate> delegate;

@end
