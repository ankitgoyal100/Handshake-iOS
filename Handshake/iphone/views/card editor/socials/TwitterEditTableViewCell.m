//
//  TwitterEditTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "TwitterEditTableViewCell.h"

@interface TwitterEditTableViewCell()

@property (nonatomic) UIImageView *twitterIcon;
@property (nonatomic) UILabel *usernameLabel;

@end

@implementation TwitterEditTableViewCell

- (UIImageView *)twitterIcon {
    if (!_twitterIcon) {
        _twitterIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _twitterIcon.contentMode = UIViewContentModeCenter;
        _twitterIcon.image = [UIImage imageNamed:@"twitter.png"];
    }
    return _twitterIcon;
}

- (UILabel *)usernameLabel {
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.textColor = [UIColor blackColor];
        _usernameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _usernameLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.twitterIcon];
        [self addSubview:self.usernameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.twitterIcon.frame = CGRectMake(50, 0, 27, self.bounds.size.height);
    self.usernameLabel.frame = CGRectMake(88, 0, self.bounds.size.width - 98, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

- (void)setUsername:(NSString *)username {
    _username = username;
    
    self.usernameLabel.text = [@"@" stringByAppendingString:username];
}

@end
