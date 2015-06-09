//
//  NameEditController.m
//  Handshake
//
//  Created by Sam Ober on 4/24/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "NameEditController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

@interface NameEditController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation NameEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Edit Name";
    
    if (self.user) {
        self.firstNameField.text = self.user.firstName;
        self.lastNameField.text = self.user.lastName;
    }
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.firstNameField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self updateSaveButton];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameField)
        [self.lastNameField becomeFirstResponder];
    else if (self.saveButton.enabled)
        [self save:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    
    [self updateSaveButton];
    
    return NO;
}

- (void)updateSaveButton {
    if ([self.firstNameField.text length] > 0 && (![self.firstNameField.text isEqualToString:self.user.firstName] || ![self.lastNameField.text isEqualToString:self.user.lastName]))
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
}

- (void)setUser:(User *)user {
    _user = user;
    
    if (!self.firstNameField) return;
    
    self.firstNameField.text = user.firstName;
    self.lastNameField.text = user.lastName;
}

- (IBAction)save:(id)sender {
    self.user.firstName = self.firstNameField.text;
    self.user.lastName = self.lastNameField.text;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nameEdited:last:)] && self.user)
        [self.delegate nameEdited:self.user.firstName last:self.user.lastName];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
