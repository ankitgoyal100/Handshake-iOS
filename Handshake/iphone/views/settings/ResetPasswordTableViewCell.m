//
//  ResetPasswordTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ResetPasswordTableViewCell.h"

@interface ResetPasswordTableViewCell()

@property (nonatomic) UILabel *resetPasswordLabel;

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation ResetPasswordTableViewCell

- (UILabel *)resetPasswordLabel {
    if (!_resetPasswordLabel) {
        _resetPasswordLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resetPasswordLabel.backgroundColor = [UIColor clearColor];
        _resetPasswordLabel.textColor = [UIColor lightGrayColor];
        _resetPasswordLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _resetPasswordLabel.textAlignment = NSTextAlignmentCenter;
        _resetPasswordLabel.text = @"RESET PASSWORD";
    }
    return _resetPasswordLabel;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.resetPasswordLabel];
        
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.resetPasswordLabel.frame = self.bounds;
    
    self.loadingView.frame = self.bounds;
}

- (float)preferredHeight {
    return 57;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.resetPasswordLabel.hidden = YES;
        [self.loadingView startAnimating];
    } else {
        self.resetPasswordLabel.hidden = NO;
        [self.loadingView stopAnimating];
    }
}

@end
