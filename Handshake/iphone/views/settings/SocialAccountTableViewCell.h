//
//  SocialAccountTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/22/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface SocialAccountTableViewCell : BaseTableViewCell

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, strong) UIImageView *iconView;

@end
