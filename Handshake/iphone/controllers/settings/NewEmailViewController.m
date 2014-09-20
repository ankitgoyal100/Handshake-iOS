//
//  NewEmailViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/15/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NewEmailViewController.h"
#import "NewEmailView.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "HandshakeAPI.h"
#import "Handshake.h"

@interface NewEmailViewController() <UITextFieldDelegate>

@property (nonatomic) NewEmailView *emailView;

@property (nonatomic, strong) NSString *email;

@property (nonatomic, copy) EmailUpdateSuccess successBlock;

@end

@implementation NewEmailViewController

- (NewEmailView *)emailView {
    if (!_emailView) {
        _emailView = [[NewEmailView alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 50)];
    }
    return _emailView;
}

- (id)initWithEmail:(NSString *)email successBlock:(EmailUpdateSuccess)successBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.email = email;
        self.successBlock = successBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Update Email";
    self.view.backgroundColor = SUPER_LIGHT_GRAY;
    
    [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [self.view addSubview:self.emailView];
    self.emailView.emailField.text = self.email;
    self.emailView.emailField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.emailView.emailField becomeFirstResponder];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] > 0) {
        [self.view endEditing:YES];
        [self.navigationController popViewControllerAnimated:YES];
        self.successBlock(textField.text);
    }
    
    return NO;
}

@end
