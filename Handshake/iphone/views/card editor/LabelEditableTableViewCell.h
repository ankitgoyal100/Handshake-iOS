//
//  LabelEditableTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EditableTableViewCell.h"

@interface LabelEditableTableViewCell : EditableTableViewCell

@property (nonatomic) UIButton *labelButton;

@property (nonatomic, strong) NSString *label;

@end
