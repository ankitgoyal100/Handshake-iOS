//
//  TwitterTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "TwitterTableViewCell.h"

@interface TwitterTableViewCell()

@property (nonatomic) UILabel *nameLabel;

@end

@implementation TwitterTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *twitterIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 30, 57)];
        twitterIcon.image = [UIImage imageNamed:@"twitter.png"];
        twitterIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:twitterIcon];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
        
        UIImage *followButtonImage = [UIImage imageNamed:@"follow_button.png"];
        self.followButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, followButtonImage.size.width, followButtonImage.size.height)];
        [self.followButton setBackgroundImage:followButtonImage forState:UIControlStateNormal];
        [self addSubview:self.followButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.followButton.frame = CGRectMake(self.bounds.size.width - 10 - self.followButton.frame.size.width, (self.bounds.size.height - self.followButton.frame.size.height) / 2, self.followButton.frame.size.width, self.followButton.frame.size.height);
    
    if (self.followButton.hidden)
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - 60, 57);
    else
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - self.followButton.frame.size.width - 20, self.bounds.size.height);
}

- (void)setShowsFollowButton:(BOOL)showsFollowButton {
    _showsFollowButton = showsFollowButton;
    
    if (showsFollowButton)
        self.followButton.hidden = NO;
    else
        self.followButton.hidden = YES;
    
    [self setNeedsLayout];
}

- (void)setUsername:(NSString *)username {
    _username = username;
    
    self.nameLabel.text = [@"@" stringByAppendingString:username];
}

- (float)preferredHeight {
    return 57;
}

@end
