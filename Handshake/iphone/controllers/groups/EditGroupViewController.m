//
//  EditGroupViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "EditGroupViewController.h"

@interface EditGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation EditGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.group)
        self.group = self.group;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    self.groupNameField.text = group.name;
    
    if (!group.name || [group.name isEqualToString:@""]) {
        // new group
        self.navigationItem.title = @"New Group";
        self.saveButton.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0)
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] > 0)
        [self save:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupEditCancelled:)])
        [self.delegate groupEditCancelled:self.group];
    
    [self dismiss];
}

- (IBAction)save:(id)sender {
    self.group.name = self.groupNameField.text;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupEdited:)])
        [self.delegate groupEdited:self.group];
    
    [self dismiss];
}

- (void)dismiss {
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
