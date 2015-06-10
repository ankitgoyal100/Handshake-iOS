//
//  InstagramEditController.h
//  Handshake
//
//  Created by Sam Ober on 6/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Social.h"
#import "AddSocialController.h"

@interface InstagramEditController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Social *social;

@property (nonatomic, strong) id <SocialEditDelegate> delegate;

@end
