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
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Card.h"

@interface AddressEditController ()

@property (weak, nonatomic) IBOutlet UITextField *street1Field;
@property (weak, nonatomic) IBOutlet UITextField *street2Field;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;

@property (nonatomic) int selectedLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation AddressEditController

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
    
    if (self.address)
        self.address = self.address;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 5 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self addressEmpty])
        [self.street1Field becomeFirstResponder];
}

- (BOOL)addressEmpty {
    return !self.address.street1 && !self.address.street2 && !self.address.city && !self.address.state && !self.address.zip;
}

- (BOOL)fieldsEmpty {
    return ([self.street1Field.text length] == 0 && [self.street2Field.text length] == 0 && [self.cityField.text length] == 0 && [self.stateField.text length] == 0 && [self.zipField.text length] == 0);
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressEditCancelled:)])
        [self.delegate addressEditCancelled:self.address];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 5 || indexPath.row == 8) return;
    
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 5 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedLabel = indexPath.row - 5;
    
    [self updateSaveButton];
}

- (NSString *)labelForIndex:(int)index {
    if (index == 0) return @"Home";
    if (index == 1) return @"Work";
    return @"Other";
}

- (BOOL)addressChanged {
    return ![self.street1Field.text isEqualToString:self.address.street1] || ![self.street2Field.text isEqualToString:self.address.street2] || ![self.cityField.text isEqualToString:self.address.city] || ![self.stateField.text isEqualToString:self.address.state] || ![self.zipField.text isEqualToString:self.address.zip];
}

- (void)updateSaveButton {
    if (![self fieldsEmpty] && ([self addressChanged] || ![[self.address.label lowercaseString] isEqualToString:[[self labelForIndex:self.selectedLabel] lowercaseString]]))
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.street1Field)
        [self.street2Field becomeFirstResponder];

    if (textField == self.street2Field)
        [self.cityField becomeFirstResponder];
    
    if (textField == self.cityField)
        [self.stateField becomeFirstResponder];
    
    if (textField == self.stateField)
        [self.zipField becomeFirstResponder];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    
    [self updateSaveButton];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self updateSaveButton];
    
    return NO;
}

- (void)setAddress:(Address *)address {
    _address = address;
    
    if (!self.street1Field) return;
    
    if (!address.street1 && !address.street2 && !address.city && !address.state && !address.zip) {
        // new address
        self.title = @"Add Address";
        self.deleteButton.hidden = YES;
    } else {
        self.title = @"Edit Address";
        self.street1Field.text = address.street1;
        self.street2Field.text = address.street2;
        self.cityField.text = address.city;
        self.stateField.text = address.state;
        self.zipField.text = address.zip;
        
        if ([[address.label lowercaseString] isEqualToString:@"home"])
            self.selectedLabel = 0;
        else if ([[address.label lowercaseString] isEqualToString:@"work"])
            self.selectedLabel = 1;
        else
            self.selectedLabel = 2;
    }
}

- (IBAction)save:(id)sender {
    self.address.street1 = self.street1Field.text;
    self.address.street2 = self.street2Field.text;
    self.address.city = self.cityField.text;
    self.address.state = self.stateField.text;
    self.address.zip = self.zipField.text;
    self.address.label = [self labelForIndex:self.selectedLabel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressEdited:)])
        [self.delegate addressEdited:self.address];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)delete:(id)sender {
    if (self.address) {
        [self.address.card removeAddressesObject:self.address];
        [self.address.managedObjectContext deleteObject:self.address];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(addressDeleted:)])
            [self.delegate addressDeleted:self.address];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
