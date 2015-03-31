//
//  ForgotPasswordView.m
//  Handshake
//
//  Created by Sam Ober on 10/1/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ForgotPasswordView.h"

@interface ForgotPasswordView()

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation ForgotPasswordView

- (UITextField *)emailField {
    if (!_emailField) {
        _emailField = [[UITextField alloc] initWithFrame:CGRectZero];
        _emailField.backgroundColor = [UIColor whiteColor];
        _emailField.font = [UIFont systemFontOfSize:17];
        _emailField.layer.cornerRadius = 10;
        _emailField.layer.masksToBounds = YES;
        _emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _emailField.leftViewMode = UITextFieldViewModeAlways;
        _emailField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        _emailField.rightViewMode = UITextFieldViewModeUnlessEditing;
        _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _emailField.returnKeyType = UIReturnKeyDone;
        _emailField.enablesReturnKeyAutomatically = YES;
        _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _emailField;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.emailField];
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.emailField.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
    self.loadingView.frame = self.bounds;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.emailField.hidden = YES;
        [self.loadingView startAnimating];
    } else {
        self.emailField.hidden = NO;
        [self.loadingView stopAnimating];
    }
}

@end
