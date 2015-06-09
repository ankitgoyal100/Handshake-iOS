//
//  EmailEditController.h
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Email.h"

@protocol EmailEditControllerDelegate <NSObject>

- (void)emailEdited:(Email *)email;
- (void)emailEditCancelled:(Email *)email;
- (void)emailDeleted:(Email *)email;

@end

@interface EmailEditController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Email *email;

@property (nonatomic, strong) id <EmailEditControllerDelegate> delegate;

@end
