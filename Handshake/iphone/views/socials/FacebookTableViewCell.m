//
//  FacebookTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "FacebookTableViewCell.h"

@implementation FacebookTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *facebookIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 30, 57)];
        facebookIcon.image = [UIImage imageNamed:@"facebook.png"];
        facebookIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:facebookIcon];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
        
        UIImage *friendButtonImage = [UIImage imageNamed:@"friend_button.png"];
        self.friendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, friendButtonImage.size.width, friendButtonImage.size.height)];
        [self.friendButton setBackgroundImage:friendButtonImage forState:UIControlStateNormal];
        [self addSubview:self.friendButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.friendButton.frame = CGRectMake(self.bounds.size.width - 10 - self.friendButton.frame.size.width, (self.bounds.size.height - self.friendButton.frame.size.height) / 2, self.friendButton.frame.size.width, self.friendButton.frame.size.height);
    
    if (self.friendButton.hidden)
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - 60, 57);
    else
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - self.friendButton.frame.size.width - 20, self.bounds.size.height);
}

- (void)setShowsFriendButton:(BOOL)showsFriendButton {
    _showsFriendButton = showsFriendButton;
    
    if (showsFriendButton)
        self.friendButton.hidden = NO;
    else
        self.friendButton.hidden = YES;
    
    [self setNeedsLayout];
}

- (void)setUsername:(NSString *)username {
    _username = username;
}

- (float)preferredHeight {
    return 57;
}

@end
