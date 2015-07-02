//
//  PhoneEditController.h
//  Handshake
//
//  Created by Sam Ober on 4/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Phone.h"

@protocol PhoneEditControllerDelegate <NSObject>

@optional
- (void)phoneEdited:(Phone *)phone;
- (void)phoneEditCancelled:(Phone *)phone;
- (void)phoneDeleted:(Phone *)phone;

@end

@interface PhoneEditController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Phone *phone;

@property (nonatomic, strong) id<PhoneEditControllerDelegate> delegate;

@end
