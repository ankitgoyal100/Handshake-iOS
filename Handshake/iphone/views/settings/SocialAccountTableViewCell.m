//
//  SocialAccountTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/22/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SocialAccountTableViewCell.h"

@interface SocialAccountTableViewCell()

@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *placeholderLabel;

@end

@implementation SocialAccountTableViewCell

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeCenter;
    }
    return _iconView;
}

- (UILabel *)usernameLabel {
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.font = [UIFont systemFontOfSize:15];
        _usernameLabel.textColor = [UIColor blackColor];
    }
    return _usernameLabel;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
    }
    return _placeholderLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.iconView];
        [self addSubview:self.usernameLabel];
        [self addSubview:self.placeholderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconView.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
    self.usernameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - 60, self.bounds.size.height);
    self.placeholderLabel.frame = self.usernameLabel.frame;
}

- (void)setUsername:(NSString *)username {
    _username = username;
    
    self.usernameLabel.text = username;
    self.placeholderLabel.hidden = YES;
    self.usernameLabel.hidden = NO;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    
    self.placeholderLabel.text = placeholder;
    self.placeholderLabel.hidden = NO;
    self.usernameLabel.hidden = YES;
}

- (float)preferredHeight {
    return 57;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
