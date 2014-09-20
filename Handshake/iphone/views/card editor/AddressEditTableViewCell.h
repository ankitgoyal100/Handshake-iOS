//
//  AddressEditTableView.h
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LabelEditableTableViewCell.h"

@interface AddressEditTableViewCell : LabelEditableTableViewCell

@property (nonatomic) UITextField *street1Field;
@property (nonatomic) UITextField *street2Field;
@property (nonatomic) UITextField *cityField;
@property (nonatomic) UITextField *stateField;
@property (nonatomic) UITextField *zipField;

@end
