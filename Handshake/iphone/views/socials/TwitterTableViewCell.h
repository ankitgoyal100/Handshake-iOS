//
//  TwitterTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface TwitterTableViewCell : BaseTableViewCell

@property (nonatomic, strong) NSString *username;

@property (nonatomic) UIButton *followButton;
@property (nonatomic) BOOL showsFollowButton;

@end
