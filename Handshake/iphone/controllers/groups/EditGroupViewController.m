//
//  EditGroupViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/8/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "EditGroupViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

@interface EditGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation EditGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.group)
        self.group = self.group;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupEditCancelled:)])
        [self.delegate groupEditCancelled:self.group];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    self.groupNameField.text = group.name;
    
    if (!group.name || [group.name isEqualToString:@""]) {
        self.navigationItem.title = @"New Group";
        self.saveButton.title = @"Create";
    } else
        self.navigationItem.title = @"Edit Group";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0 && ![textField.text isEqualToString:self.group.name])
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.saveButton.enabled)
        [self save:nil];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (IBAction)save:(id)sender {
    self.group.name = self.groupNameField.text;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(groupEdited:)])
        [self.delegate groupEdited:self.group];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
