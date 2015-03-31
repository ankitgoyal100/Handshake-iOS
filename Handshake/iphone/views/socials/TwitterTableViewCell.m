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

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation TwitterTableViewCell

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView stopAnimating];
    }
    return _loadingView;
}

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
        
        self.followButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:self.followButton];
        
        [self addSubview:self.loadingView];
        
        self.showsFollowButton = YES;
        
        self.status = TwitterStatusNotFollowing;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.followButton.frame = CGRectMake(self.bounds.size.width - 10 - self.followButton.frame.size.width, 0, self.followButton.frame.size.width, self.bounds.size.height);
    
    if (self.followButton.hidden)
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - 60, 57);
    else
        self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - self.followButton.frame.size.width - 20, self.bounds.size.height);
    
    self.loadingView.frame = CGRectMake(self.bounds.size.width - self.loadingView.bounds.size.width - 10, 0, self.loadingView.frame.size.width, self.bounds.size.height);
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

- (void)setStatus:(TwitterStatus)status {
    _status = status;
    
    if (status == TwitterStatusNotFollowing) {
        [self.followButton setImage:[UIImage imageNamed:@"add_social.png"] forState:UIControlStateNormal];
    } else if (status == TwitterStatusFollowing) {
        [self.followButton setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
    } else {
        [self.followButton setImage:[UIImage imageNamed:@"requested.png"] forState:UIControlStateNormal];
    }
    
    CGRect rect = self.followButton.frame;
    rect.size.width = [self.followButton imageForState:UIControlStateNormal].size.width;
    self.followButton.frame = rect;
    
    [self setNeedsDisplay];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.followButton.hidden = YES;
        [self.loadingView startAnimating];
    } else {
        if (self.showsFollowButton)
            self.followButton.hidden = NO;
        [self.loadingView stopAnimating];
    }
}

@end
