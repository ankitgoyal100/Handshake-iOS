//
//  AddressEditController.h
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"

@protocol AddressEditControllerDelegate <NSObject>

@optional
- (void)addressEdited:(Address *)address;
- (void)addressEditCancelled:(Address *)address;
- (void)addressDeleted:(Address *)address;

@end

@interface AddressEditController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Address *address;

@property (nonatomic, strong) id <AddressEditControllerDelegate> delegate;

@end
