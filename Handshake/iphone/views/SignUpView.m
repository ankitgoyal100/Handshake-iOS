//
//  SignUpView.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SignUpView.h"
#import "Handshake.h"

@interface SignUpView()

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation SignUpView

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SUPER_LIGHT_GRAY;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 0)];
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, 270);
        self.scrollView.contentInset = self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0);
        [self addSubview:self.scrollView];
        
        self.emailField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, self.bounds.size.width - 40, 50)];
        self.emailField.backgroundColor = [UIColor whiteColor];
        self.emailField.placeholder = @"email";
        self.emailField.font = [UIFont systemFontOfSize:17];
        self.emailField.layer.cornerRadius = 10;
        self.emailField.layer.masksToBounds = YES;
        self.emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.emailField.leftViewMode = UITextFieldViewModeAlways;
        self.emailField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.emailField.rightViewMode = UITextFieldViewModeUnlessEditing;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.returnKeyType = UIReturnKeyNext;
        self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.scrollView addSubview:self.emailField];
        
        self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, self.bounds.size.width - 40, 50)];
        self.passwordField.backgroundColor = [UIColor whiteColor];
        self.passwordField.placeholder = @"password";
        self.passwordField.secureTextEntry = YES;
        self.passwordField.font = [UIFont systemFontOfSize:17];
        self.passwordField.layer.cornerRadius = 10;
        self.passwordField.layer.masksToBounds = YES;
        self.passwordField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.passwordField.leftViewMode = UITextFieldViewModeAlways;
        self.passwordField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.passwordField.rightViewMode = UITextFieldViewModeUnlessEditing;
        self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.passwordField.returnKeyType = UIReturnKeyNext;
        [self.scrollView addSubview:self.passwordField];
        
        self.passwordConfirmField = [[UITextField alloc] initWithFrame:CGRectMake(20, 140, self.bounds.size.width - 40, 50)];
        self.passwordConfirmField.backgroundColor = [UIColor whiteColor];
        self.passwordConfirmField.placeholder = @"confirm password";
        self.passwordConfirmField.secureTextEntry = YES;
        self.passwordConfirmField.font = [UIFont systemFontOfSize:17];
        self.passwordConfirmField.layer.cornerRadius = 10;
        self.passwordConfirmField.layer.masksToBounds = YES;
        self.passwordConfirmField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.passwordConfirmField.leftViewMode = UITextFieldViewModeAlways;
        self.passwordConfirmField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
        self.passwordConfirmField.rightViewMode = UITextFieldViewModeUnlessEditing;
        self.passwordConfirmField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.passwordConfirmField.returnKeyType = UIReturnKeyDone;
        [self.scrollView addSubview:self.passwordConfirmField];
        
        self.termsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, self.bounds.size.width - 40, 50)];
        self.termsButton.backgroundColor = [UIColor clearColor];
        self.termsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
        [self.termsButton setTitle:@"By pressing 'Done' you agree to our\nTerms and Conditions." forState:UIControlStateNormal];
        [self.termsButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.termsButton.titleLabel.numberOfLines = 2;
        self.termsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:self.termsButton];
        
        [self addSubview:self.loadingView];
        
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
        [self addSubview:bar];
        bar.barTintColor = LOGO_COLOR;
        bar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
        self.navigationItem = [[UINavigationItem alloc] initWithTitle:@"Sign Up"];
        bar.items = @[self.navigationItem];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.loadingView.center = CGPointMake(self.bounds.size.width / 2, 120);
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (loading) {
        self.scrollView.hidden = YES;
        [self.loadingView startAnimating];
    } else {
        self.scrollView.hidden = NO;
        [self.loadingView stopAnimating];
    }
}

@end
