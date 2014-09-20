//
//  LogInView.h
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInView : UIView

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UITextField *emailField;
@property (nonatomic) UITextField *passwordField;

@property (nonatomic) UIButton *forgotButton;

@property (nonatomic, strong) UINavigationItem *navigationItem;

@property (nonatomic) BOOL loading;

@end
