//
//  CardHeaderTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardHeaderTableViewCell.h"

@implementation CardHeaderTableViewCell

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
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(100, 0, self.bounds.size.width - 110, self.bounds.size.height);
}

- (float)preferredHeight {
    return 100;
}

@end
