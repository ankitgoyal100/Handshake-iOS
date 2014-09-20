//
//  CardHeaderTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "AsyncImageView.h"

@interface CardHeaderTableViewCell : BaseTableViewCell

@property (nonatomic) AsyncImageView *pictureView;
@property (nonatomic) UILabel *nameLabel;

@end
