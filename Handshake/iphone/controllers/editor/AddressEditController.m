//
//  AddressEditController.m
//  Handshake
//
//  Created by Sam Ober on 4/20/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AddressEditController.h"
#import "EnterAddressCell.h"
#import "LabelCell.h"

@interface AddressEditController ()

@property (nonatomic, strong) EnterAddressCell *addressCell;

@property (nonatomic) int selectedLabel;
@property (nonatomic, strong) NSArray *labels;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation AddressEditController

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
    
    [self.addressCell.street1Field becomeFirstResponder];
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
            self.addressCell = (EnterAddressCell *)[tableView dequeueReusableCellWithIdentifier:@"EnterAddressCell"];
            if (self.address) {
                self.addressCell.street1Field.text = self.address.street1;
                self.addressCell.street2Field.text = self.address.street2;
                self.addressCell.cityField.text = self.address.city;
                self.addressCell.stateField.text = self.address.state;
                self.addressCell.zipField.text = self.address.zip;
            }
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
        return 224;
    
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
    
    if ([self.addressCell.street1Field.text length] == 0 && [self.addressCell.street2Field.text length] == 0 && [self.addressCell.cityField.text length] == 0 && [self.addressCell.stateField.text length] == 0 && [self.addressCell.zipField.text length] == 0)
        self.saveButton.enabled = NO;
    else
        self.saveButton.enabled = YES;
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.addressCell.street1Field)
        [self.addressCell.street2Field becomeFirstResponder];

    if (textField == self.addressCell.street2Field)
        [self.addressCell.cityField becomeFirstResponder];
    
    if (textField == self.addressCell.cityField)
        [self.addressCell.stateField becomeFirstResponder];
    
    if (textField == self.addressCell.stateField)
        [self.addressCell.zipField becomeFirstResponder];
    
    return NO;
}

- (void)setAddress:(Address *)address {
    _address = address;
    
    if (!address.street1 && !address.street2 && !address.city && !address.state && !address.zip) {
        // new address
        self.title = @"Add Address";
        self.saveButton.enabled = NO;
        return;
    }
    
    if (self.addressCell) {
        self.addressCell.street1Field.text = address.street1;
        self.addressCell.street2Field.text = address.street2;
        self.addressCell.cityField.text = address.city;
        self.addressCell.stateField.text = address.state;
        self.addressCell.zipField.text = address.zip;
    }
    
    for (NSString *label in self.labels) {
        if ([label isEqualToString:address.label]) {
            self.selectedLabel = (int)[self.labels indexOfObject:label];
            [self.tableView reloadData];
            break;
        }
    }
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressEdited:)]) {
        [self.delegate addressEdited:self.address];
    }
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.address) {
        if (self.addressCell) {
            self.address.street1 = self.addressCell.street1Field.text;
            self.address.street2 = self.addressCell.street2Field.text;
            self.address.city = self.addressCell.cityField.text;
            self.address.state = self.addressCell.stateField.text;
            self.address.zip = self.addressCell.zipField.text;
        }
        
        self.address.label = self.labels[self.selectedLabel];
    }
    
    [self cancel:nil];
}

@end
