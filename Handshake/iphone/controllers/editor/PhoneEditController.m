//
//  PhoneEditController.m
//  Handshake
//
//  Created by Sam Ober on 4/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "PhoneEditController.h"
#import "PhoneNumberCell.h"
#import "LabelCell.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Card.h"
#import "CountryPicker.h"
#import "NBAsYouTypeFormatter.h"
#import "NBPhoneNumberUtil.h"

@interface PhoneEditController () <CountryPickerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *numberField;

@property (nonatomic) int selectedLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, strong) UITextField *pickerField; // used to get picker like keyboard

@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *regionCode;

@property (weak, nonatomic) IBOutlet UILabel *callingCodeField;
@property (nonatomic, strong) CountryPicker *picker;

@property (nonatomic, strong) NBAsYouTypeFormatter *phoneFormatter;

@end

@implementation PhoneEditController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedLabel = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickerField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pickerField];
    
    self.picker = [[CountryPicker alloc] init];
    self.picker.delegate = self;
    self.pickerField.inputView = self.picker;
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.phone)
        self.phone = self.phone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 3 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.phone.number || [self.phone.number isEqualToString:@""])
        [self.numberField becomeFirstResponder];
}

- (void)back {
    if (self.delegate && [self.delegate respondsToSelector:@selector(phoneEditCancelled:)]) {
        [self.delegate phoneEditCancelled:self.phone];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.pickerField becomeFirstResponder];
    }
    
    if (indexPath.row < 3 || indexPath.row == 7) return;
    
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 3 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
    self.selectedLabel = indexPath.row - 3;
    
    [self updateSaveButton];
}

- (NSString *)labelForIndex:(int)index {
    if (index == 0) return @"Home";
    if (index == 1) return @"Mobile";
    if (index == 2) return @"Work";
    return @"Other";
}

- (void)updateSaveButton {
    NSString *phone = [self buildPhone];
    
    if (phone && (![self.phone.number isEqualToString:phone] || ![[self.phone.label lowercaseString] isEqualToString:[[self labelForIndex:self.selectedLabel] lowercaseString]]))
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string length] == 0)
        textField.text = [self.phoneFormatter removeLastDigit];
    else if ([string length] == 1)
        textField.text = [self.phoneFormatter inputDigit:string];
    
    [self updateSaveButton];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    [self.phoneFormatter clear];
    
    return YES;
}

- (void)setPhone:(Phone *)phone {
    _phone = phone;
    
    if (!self.numberField) return;
    
    if (!phone.number || [phone.number isEqualToString:@""]) {
        // new phone
        self.title = @"Add Phone";
        self.deleteButton.hidden = YES;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.regionCode = [defaults stringForKey:@"country_code"];
        [self updateRegion];
    } else {
        self.title = @"Edit Phone";
        
        if ([[phone.label lowercaseString] isEqualToString:@"home"])
            self.selectedLabel = 0;
        else if ([[phone.label lowercaseString] isEqualToString:@"mobile"])
            self.selectedLabel = 1;
        else if ([[phone.label lowercaseString] isEqualToString:@"work"])
            self.selectedLabel = 2;
        else
            self.selectedLabel = 3;
        
        self.regionCode = phone.countryCode;
        [self updateRegion];
        
        NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
        NBPhoneNumber *number = [util parse:phone.number defaultRegion:self.regionCode error:nil];
        
        NSCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *nationalNumber = [util format:number numberFormat:NBEPhoneNumberFormatNATIONAL error:nil];
        self.numberField.text = [self.phoneFormatter inputString:[[nationalNumber componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""]];
    }
    
    self.picker.selectedCountryCode = self.regionCode;
}

- (IBAction)save:(id)sender {
    self.phone.number = [self buildPhone];
    self.phone.label = [self labelForIndex:self.selectedLabel];
    self.phone.countryCode = self.regionCode;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(phoneEdited:)])
        [self.delegate phoneEdited:self.phone];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)delete:(id)sender {
    if (self.phone) {
        [self.phone.card removePhonesObject:self.phone];
        [self.phone.managedObjectContext deleteObject:self.phone];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(phoneDeleted:)])
            [self.delegate phoneDeleted:self.phone];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code {
    self.regionCode = code;
    
    [self updateRegion];
    
    // save default country
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.regionCode forKey:@"country_code"];
    [defaults synchronize];
    
    [self updateSaveButton];
}

- (NSString *)buildPhone {
    NSCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    NSString *phone = [[self.numberField.text componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    
    NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
    NBPhoneNumber *number = [util parse:phone defaultRegion:self.regionCode error:nil];
    
    if ([util isValidNumber:number]) return [util format:number numberFormat:NBEPhoneNumberFormatE164 error:nil];
    
    return nil;
}

- (void)updateRegion {
    self.phoneFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:self.regionCode];
    
    NSCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    self.numberField.text = [self.phoneFormatter inputString:[[self.numberField.text componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""]];
    
    self.callingCode = [NSString stringWithFormat:@"%@", [[[NBPhoneNumberUtil alloc] init] getCountryCodeForRegion:self.regionCode]];
    
    self.callingCodeField.text = [NSString stringWithFormat:@"%@ (+%@)", [CountryPicker countryNamesByCode][self.regionCode], self.callingCode];
}

@end
