//
//  LogInView.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LogInView.h"
#import "Handshake.h"

@interface LogInView()

@property (nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation LogInView

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
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, 210);
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
        self.emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailField.returnKeyType = UIReturnKeyNext;
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
        self.passwordField.returnKeyType = UIReturnKeyDone;
        [self.scrollView addSubview:self.passwordField];
        
        self.forgotButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 140, self.bounds.size.width - 40, 50)];
        self.forgotButton.backgroundColor = [UIColor clearColor];
        self.forgotButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
        [self.forgotButton setTitle:@"I forgot my password." forState:UIControlStateNormal];
        [self.forgotButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.forgotButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:self.forgotButton];
        
        [self addSubview:self.loadingView];
        
        UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
        [self addSubview:bar];
        bar.barTintColor = LOGO_COLOR;
        bar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor whiteColor] };
        self.navigationItem = [[UINavigationItem alloc] initWithTitle:@"Log In"];
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
