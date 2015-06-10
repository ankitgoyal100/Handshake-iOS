//
//  AddSocialController.h
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Social.h"

@protocol SocialEditDelegate <NSObject>

@optional
- (void)socialEdited:(Social *)social;
- (void)socialEditCancelled:(Social *)social;
- (void)socialDeleted:(Social *)social;

@end

@interface AddSocialController : UITableViewController

@property (nonatomic, strong) Social *social;

@property (nonatomic, strong) id <SocialEditDelegate> delegate;

@end
