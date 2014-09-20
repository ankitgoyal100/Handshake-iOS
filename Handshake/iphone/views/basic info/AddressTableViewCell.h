//
//  AddressTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface AddressTableViewCell : BaseTableViewCell

@property (nonatomic) UILabel *addressLabel;
@property (nonatomic) UILabel *labelLabel;

@property (nonatomic, strong) NSString *address;

@end
