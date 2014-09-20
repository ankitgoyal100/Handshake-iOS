//
//  ContactTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "AsyncImageView.h"

@interface ContactTableViewCell : BaseTableViewCell

@property (nonatomic) AsyncImageView *pictureView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *timeLabel;

@end
