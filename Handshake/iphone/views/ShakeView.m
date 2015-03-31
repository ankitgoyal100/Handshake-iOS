//
//  ShakeView.m
//  Handshake
//
//  Created by Sam Ober on 10/5/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ShakeView.h"
#import "AsyncImageView.h"
#import "Handshake.h"

@interface ShakeView()

@property (nonatomic) UIView *tintView;

@property (nonatomic) UIActivityIndicatorView *loadingView;

@property (nonatomic) UIView *confirmView;
@property (nonatomic) AsyncImageView *pictureView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *shakeLabel;

@property (nonatomic) UIActivityIndicatorView *confirmingView;
@property (nonatomic) UILabel *waitingLabel;

@end

@implementation ShakeView

- (UIView *)tintView {
    if (!_tintView) {
        _tintView = [[UIView alloc] initWithFrame:CGRectZero];
        _tintView.alpha = 0.4;
    }
    return _tintView;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _loadingView;
}

- (UIButton *)stopShakeButton {
    if (!_stopShakeButton) {
        _stopShakeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _stopShakeButton.backgroundColor = [UIColor clearColor];
        [_stopShakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_stopShakeButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    return _stopShakeButton;
}

- (UIView *)confirmView {
    if (!_confirmView) {
        _confirmView = [[UIView alloc] initWithFrame:CGRectZero];
        _confirmView.backgroundColor = [UIColor clearColor];
    }
    return _confirmView;
}

- (AsyncImageView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
        _pictureView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        _pictureView.layer.cornerRadius = 59;
        _pictureView.layer.masksToBounds = YES;
        _pictureView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _pictureView.layer.borderWidth = 1;
        _pictureView.showActivityIndicator = NO;
        _pictureView.image = [UIImage imageNamed:@"default_picture.png"];
    }
    return _pictureView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)shakeLabel {
    if (!_shakeLabel) {
        _shakeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shakeLabel.backgroundColor = [UIColor clearColor];
        _shakeLabel.font = [UIFont systemFontOfSize:15];
        _shakeLabel.textColor = [UIColor blackColor];
        _shakeLabel.textAlignment = NSTextAlignmentCenter;
        _shakeLabel.text = @"wants to shake...";
    }
    return _shakeLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _cancelButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _cancelButton.layer.cornerRadius = 15;
        [_cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _confirmButton.backgroundColor = LOGO_COLOR;
        _confirmButton.layer.cornerRadius = 15;
        [_confirmButton setTitle:@"CONFIRM" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    }
    return _confirmButton;
}

- (UIActivityIndicatorView *)confirmingView {
    if (!_confirmingView) {
        _confirmingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _confirmingView;
}

- (UILabel *)waitingLabel {
    if (!_waitingLabel) {
        _waitingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _waitingLabel.backgroundColor = [UIColor clearColor];
        _waitingLabel.font = [UIFont systemFontOfSize:15];
        _waitingLabel.textColor = [UIColor blackColor];
        _waitingLabel.textAlignment = NSTextAlignmentCenter;
        _waitingLabel.text = @"waiting for confirmation...";
    }
    return _waitingLabel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.dynamic = NO;
        self.blurRadius = 15;
        self.iterations = 3;
        self.tintColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.tintView];
        
        [self addSubview:self.loadingView];
        [self addSubview:self.stopShakeButton];
        
        [self.confirmView addSubview:self.pictureView];
        [self.confirmView addSubview:self.nameLabel];
        [self.confirmView addSubview:self.shakeLabel];
        [self.confirmView addSubview:self.cancelButton];
        [self.confirmView addSubview:self.confirmButton];
        [self addSubview:self.confirmView];
        
        [self addSubview:self.confirmingView];
        [self addSubview:self.waitingLabel];
        
        self.shakeStatus = ShakeLoadingStatus;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tintView.frame = self.bounds;
    
    self.loadingView.frame = self.bounds;
    self.stopShakeButton.frame = CGRectMake(0, self.bounds.size.height / 2 + 50, self.bounds.size.width, 40);
    
    self.confirmView.frame = self.bounds;
    
    self.pictureView.frame = CGRectMake((self.bounds.size.width - 118) / 2, (self.bounds.size.height / 2) - 120, 118, 118);
    
    self.nameLabel.frame = CGRectMake(0, self.pictureView.frame.origin.y + self.pictureView.frame.size.height + 10  , self.bounds.size.width, 30);
    
    self.shakeLabel.frame = CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 22, self.bounds.size.width, 18);
    
    self.cancelButton.frame = CGRectMake(self.bounds.size.width / 2 - 105, self.shakeLabel.frame.origin.y + self.shakeLabel.frame.size.height + 10, 100, 30);
    self.confirmButton.frame = CGRectMake(self.bounds.size.width / 2 + 5, self.cancelButton.frame.origin.y, 100, 30);
    
    self.confirmingView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 25);
    self.waitingLabel.frame = CGRectMake(0, self.bounds.size.height / 2, self.bounds.size.width, 30);
}

- (void)setShakeStatus:(ShakeStatus)shakeStatus {
    _shakeStatus = shakeStatus;
    
    [UIView beginAnimations:nil context:NULL];
    
    if (shakeStatus == ShakeLoadingStatus) {
        [self.loadingView startAnimating];
        self.stopShakeButton.hidden = NO;
        self.confirmView.hidden = YES;
        self.tintView.backgroundColor = [UIColor blackColor];
        [self.confirmingView stopAnimating];
        self.waitingLabel.hidden = YES;
    } else if (shakeStatus == ShakeConfirmingStatus) {
        [self.loadingView stopAnimating];
        self.stopShakeButton.hidden = YES;
        self.confirmView.hidden = NO;
        self.tintView.backgroundColor = [UIColor lightGrayColor];
        [self.confirmingView stopAnimating];
        self.waitingLabel.hidden = YES;
    } else if (shakeStatus == ShakeWaitingConfirmationStatus) {
        [self.loadingView stopAnimating];
        self.stopShakeButton.hidden = YES;
        self.confirmView.hidden = YES;
        self.tintView.backgroundColor = [UIColor lightGrayColor];
        [self.confirmingView startAnimating];
        self.waitingLabel.hidden = NO;
    }
    
    [UIView commitAnimations];
}

- (void)setPicture:(NSString *)picture {
    if (!picture) return;
    self.pictureView.image = nil;
    self.pictureView.imageURL = [NSURL URLWithString:picture];
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

@end
