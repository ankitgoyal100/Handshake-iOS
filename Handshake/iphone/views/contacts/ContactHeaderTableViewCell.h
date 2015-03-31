//
//  ContactHeaderTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "AsyncImageView.h"

@interface ContactHeaderTableViewCell : BaseTableViewCell

@property (nonatomic) UIButton *pictureButton;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *locationLabel;

@end
