//
//  SignUpView.h
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpView : UIView

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UITextField *emailField;
@property (nonatomic) UITextField *passwordField;
@property (nonatomic) UITextField *passwordConfirmField;

@property (nonatomic) UIButton *termsButton;

@property (nonatomic, strong) UINavigationItem *navigationItem;

@property (nonatomic) BOOL loading;

@end
