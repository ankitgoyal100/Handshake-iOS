//
//  LabelTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface LabelTableViewCell : BaseTableViewCell

- (void)setSelectedOption:(BOOL)selected;

@property (nonatomic, strong) NSString *label;

@end
