//
//  AddSocialController.h
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Social.h"

@protocol SocialEditControllerDelegate <NSObject>

- (void)socialEdited:(Social *)social;

@end

@interface AddSocialController : UITableViewController

@property (nonatomic, strong) Social *social;

@property (nonatomic, strong) id <SocialEditControllerDelegate> delegate;

@end
