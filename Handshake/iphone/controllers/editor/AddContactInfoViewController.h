//
//  AddContactInfoViewController.h
//  Handshake
//
//  Created by Sam Ober on 6/18/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@protocol AddContactInfoViewControllerDelegate <NSObject>

@optional
- (void)addContactInfoViewControllerDidFinish;

@end

@interface AddContactInfoViewController : UITableViewController

@property (nonatomic, strong) Card *card;

@property (nonatomic, strong) id <AddContactInfoViewControllerDelegate> delegate;

@end
