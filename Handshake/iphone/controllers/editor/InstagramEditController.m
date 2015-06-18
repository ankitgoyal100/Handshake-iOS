//
//  InstagramEditController.m
//  Handshake
//
//  Created by Sam Ober on 6/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "InstagramEditController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

@interface InstagramEditController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation InstagramEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.social)
        self.social = self.social;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.usernameLabel becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0 && ![textField.text isEqualToString:self.social.username])
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.saveButton.enabled) {
        [self save:nil];
    }
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (void)setSocial:(Social *)social {
    _social = social;
    
    self.usernameLabel.text = social.username;
    
    if (!social.username) {
        self.title = @"Add Instagram";
    }
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEditCancelled:)])
        [self.delegate socialEditCancelled:self.social];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEditCancelled:)])
        [self.delegate socialEditCancelled:self.social];
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.social) {
        self.social.username = self.usernameLabel.text;
        self.social.network = @"instagram";
    }
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(socialEdited:)])
        [self.delegate socialEdited:self.social];
}

@end
