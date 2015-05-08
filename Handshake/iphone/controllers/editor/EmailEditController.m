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

@interface EmailEditController ()

@property (nonatomic, strong) EmailAddressCell *addressCell;

@property (nonatomic) int selectedLabel;
@property (nonatomic, strong) NSArray *labels;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation EmailEditController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedLabel = 0;
        self.labels = @[ @"home", @"work", @"other" ];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.addressCell.addressField becomeFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4 + [self.labels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.row == 1) {
        if (!self.addressCell) {
            self.addressCell = (EmailAddressCell *)[tableView dequeueReusableCellWithIdentifier:@"EmailAddressCell"];
            if (self.email)
                self.addressCell.addressField.text = self.email.address;
        }
        return self.addressCell;
    }
    
    if (indexPath.row == 2) {
        return [tableView dequeueReusableCellWithIdentifier:@"LabelHeaderCell"];
    }
    
    if (indexPath.row < 3 + [self.labels count]) {
        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
        
        cell.labelLabel.text = self.labels[indexPath.row - 3];
        
        if (indexPath.row - 3 == self.selectedLabel)
            cell.checkIcon.hidden = NO;
        else
            cell.checkIcon.hidden = YES;
        
        return cell;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return 8;
    
    if (indexPath.row == 1)
        return 56;
    
    if (indexPath.row == 2)
        return 48;
    
    if (indexPath.row < 3 + [self.labels count])
        return 56;
    
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 3 || indexPath.row - 3 == self.selectedLabel || indexPath.row == 3 + [self.labels count])
        return;
    
    [self.view endEditing:YES];
    
    NSIndexPath *oldSelected = [NSIndexPath indexPathForRow:self.selectedLabel + 3 inSection:0];
    
    self.selectedLabel = (int)indexPath.row - 3;
    
    [self.tableView reloadRowsAtIndexPaths:@[ oldSelected, indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] == 0)
        self.saveButton.enabled = NO;
    else
        self.saveButton.enabled = YES;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (void)setEmail:(Email *)email {
    _email = email;
    
    if (!email.address || [email.address isEqualToString:@""]) {
        // new email
        self.title = @"Add Email";
        self.saveButton.enabled = NO;
        return;
    }
    
    if (self.addressCell)
        self.addressCell.addressField.text = email.address;
    
    for (NSString *label in self.labels) {
        if ([label isEqualToString:email.label]) {
            self.selectedLabel = (int)[self.labels indexOfObject:label];
            [self.tableView reloadData];
            break;
        }
    }
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emailEdited:)]) {
        [self.delegate emailEdited:self.email];
    }
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.email) {
        if (self.addressCell)
            self.email.address = self.addressCell.addressField.text;
        
        self.email.label = self.labels[self.selectedLabel];
    }
    
    [self cancel:nil];
}

@end
