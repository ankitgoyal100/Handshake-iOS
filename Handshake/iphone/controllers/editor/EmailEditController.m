//
//  EmailEditController.m
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "EmailEditController.h"
#import "EmailAddressCell.h"
#import "LabelCell.h"
#import "Card.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"

@interface EmailEditController ()

@property (nonatomic, strong) IBOutlet UITextField *addressField;

@property (nonatomic) int selectedLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation EmailEditController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedLabel = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.email)
        self.email = self.email;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 2 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.email.address || [self.email.address isEqualToString:@""])
        [self.addressField becomeFirstResponder];
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emailEditCancelled:)])
        [self.delegate emailEditCancelled:self.email];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 2 || indexPath.row == 5) return;
    
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 2 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedLabel = indexPath.row - 2;
    
    [self updateSaveButton];
}

- (NSString *)labelForIndex:(int)index {
    if (index == 0) return @"Home";
    if (index == 1) return @"Work";
    return @"Other";
}

- (void)updateSaveButton {
    if ([self.addressField.text length] > 0 && (![self.email.address isEqualToString:self.addressField.text] || ![[self.email.label lowercaseString] isEqualToString:[[self labelForIndex:self.selectedLabel] lowercaseString]]))
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self updateSaveButton];
    
    return NO;
}

- (void)setEmail:(Email *)email {
    _email = email;
    
    if (!self.addressField) return;
    
    if (!email.address || [email.address isEqualToString:@""]) {
        // new email
        self.title = @"Add Email";
        self.deleteButton.hidden = YES;
    } else {
        self.title = @"Edit Email";
        self.addressField.text = email.address;
        
        if ([[email.label lowercaseString] isEqualToString:@"home"])
            self.selectedLabel = 0;
        else if ([[email.label lowercaseString] isEqualToString:@"work"])
            self.selectedLabel = 1;
        else
            self.selectedLabel = 2;
    }
}

- (IBAction)save:(id)sender {
    self.email.address = self.addressField.text;
    self.email.label = [self labelForIndex:self.selectedLabel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emailEdited:)])
        [self.delegate emailEdited:self.email];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)delete:(id)sender {
    if (self.email) {
        [self.email.card removeEmailsObject:self.email];
        [self.email.managedObjectContext deleteObject:self.email];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(emailDeleted:)])
            [self.delegate emailDeleted:self.email];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
