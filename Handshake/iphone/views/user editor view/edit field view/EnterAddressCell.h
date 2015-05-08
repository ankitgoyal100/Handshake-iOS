//
//  AddressCell.h
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterAddressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *street1Field;
@property (weak, nonatomic) IBOutlet UITextField *street2Field;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;

@end
