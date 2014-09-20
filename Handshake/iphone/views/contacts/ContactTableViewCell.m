//
//  ContactTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pictureView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        self.pictureView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        self.pictureView.layer.cornerRadius = 25;
        self.pictureView.layer.masksToBounds = YES;
        self.pictureView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.pictureView.layer.borderWidth = 1;
        self.pictureView.contentMode = UIViewContentModeScaleAspectFill;
        self.pictureView.showActivityIndicator = NO;
        self.pictureView.crossfadeDuration = 0;
        [self addSubview:self.pictureView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        //self.nameLabel.font = [UIFont systemFontOfSize:17];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        [self addSubview:self.nameLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor grayColor];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(73, 16, self.bounds.size.width - 83, 20);
    self.timeLabel.frame = CGRectMake(73, 40, self.bounds.size.width - 83, 15);
}

- (float)preferredHeight {
    return 70;
}

@end
