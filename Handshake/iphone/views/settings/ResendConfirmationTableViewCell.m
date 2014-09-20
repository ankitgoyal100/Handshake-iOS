//
//  ResendConfirmationTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/15/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ResendConfirmationTableViewCell.h"
#import "Handshake.h"

@interface ResendConfirmationTableViewCell()

@property (nonatomic) UILabel *resendLabel;

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation ResendConfirmationTableViewCell

- (UILabel *)resendLabel {
    if (!_resendLabel) {
        _resendLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resendLabel.backgroundColor = [UIColor clearColor];
        _resendLabel.textColor = [UIColor lightGrayColor];
        _resendLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _resendLabel.textAlignment = NSTextAlignmentCenter;
        _resendLabel.text = @"RESEND CONFIRMATION LINK";
    }
    return _resendLabel;
}

- (UILabel *)timeLeftLabel {
    if (!_timeLeftLabel) {
        _timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLeftLabel.backgroundColor = [UIColor clearColor];
        _timeLeftLabel.textColor = RED;
        _timeLeftLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLeftLabel;
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
        
        [self addSubview:self.resendLabel];
        [self addSubview:self.timeLeftLabel];
        
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.resendLabel.frame = CGRectMake(0, 16, self.bounds.size.width, 16);
    self.timeLeftLabel.frame = CGRectMake(0, 40, self.bounds.size.width, 16);
    
    self.loadingView.frame = self.bounds;
}

- (float)preferredHeight {
    return 69;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.resendLabel.hidden = YES;
        self.timeLeftLabel.hidden = YES;
        [self.loadingView startAnimating];
    } else {
        self.resendLabel.hidden = NO;
        self.timeLeftLabel.hidden = NO;
        [self.loadingView stopAnimating];
    }
}

@end
