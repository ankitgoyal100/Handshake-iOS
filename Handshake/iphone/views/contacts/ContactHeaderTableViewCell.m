//
//  ContactHeaderTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactHeaderTableViewCell.h"

@implementation ContactHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.pictureView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        self.pictureView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        self.pictureView.layer.cornerRadius = 40;
        self.pictureView.layer.masksToBounds = YES;
        self.pictureView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.pictureView.layer.borderWidth = 1;
        self.pictureView.crossfadeDuration = 0;
        self.pictureView.showActivityIndicator = NO;
        [self addSubview:self.pictureView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
        [self addSubview:self.nameLabel];
        
        UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(100, 50, 11.5, 12.5)];
        timeIcon.image = [UIImage imageNamed:@"time.png"];
        [self addSubview:timeIcon];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor lightGrayColor];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.timeLabel];
        
        UIImageView *locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(100.5, 69.5, 10, 14.5)];
        locationIcon.image = [UIImage imageNamed:@"location"];
        [self addSubview:locationIcon];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.locationLabel.backgroundColor = [UIColor clearColor];
        self.locationLabel.textColor = [UIColor lightGrayColor];
        self.locationLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.locationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(100, 16, self.bounds.size.width - 110, 27);
    self.timeLabel.frame = CGRectMake(116, 48, self.bounds.size.width - 126, 15);
    self.locationLabel.frame = CGRectMake(116, 68, self.bounds.size.width - 126, 15);
}

- (float)preferredHeight {
    return 100;
}

@end
