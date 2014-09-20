//
//  FacebookTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface FacebookTableViewCell : BaseTableViewCell

@property (nonatomic) NSString *username;
@property (nonatomic) UILabel *nameLabel;

@property (nonatomic) UIButton *friendButton;
@property (nonatomic) BOOL showsFriendButton;

@end
