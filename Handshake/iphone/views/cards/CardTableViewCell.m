//
//  MainCardTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardTableViewCell.h"

@implementation CardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.pictureView = [[AsyncImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
        self.pictureView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        self.pictureView.layer.cornerRadius = 37.5;
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
        
        self.cardNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.cardNameLabel.backgroundColor = [UIColor clearColor];
        self.cardNameLabel.textColor = [UIColor lightGrayColor];
        self.cardNameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.cardNameLabel];
        
        self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
        [self addSubview:self.checkButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(95, 25, self.bounds.size.width - 105, 26);
    self.cardNameLabel.frame = CGRectMake(95, 57, self.bounds.size.width - 105, 15);
    
    self.checkButton.frame = CGRectMake(self.bounds.size.width - self.checkButton.frame.size.width - 15, (self.bounds.size.height - self.checkButton.frame.size.height) / 2, self.checkButton.frame.size.width, self.checkButton.frame.size.height);
}

- (float)preferredHeight {
    return 95;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    
    if (checked)
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    else
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
}

@end
