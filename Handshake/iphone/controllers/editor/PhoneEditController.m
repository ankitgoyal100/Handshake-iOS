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
#import "RMPhoneFormat.h"

@interface PhoneEditController ()

@property (nonatomic, strong) PhoneNumberCell *numberCell;

@property (nonatomic) int selectedLabel;
@property (nonatomic, strong) NSArray *labels;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation PhoneEditController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectedLabel = 0;
        self.labels = @[ @"home", @"mobile", @"work", @"other" ];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.numberCell.numberField becomeFirstResponder];
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
        if (!self.numberCell) {
            self.numberCell = (PhoneNumberCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneNumberCell"];
            if (self.phone)
                self.numberCell.numberField.text = self.phone.number;
        }
        return self.numberCell;
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
    if ([string length] == 0) {
        while (range.location != 0 && !isnumber([textField.text characterAtIndex:range.location])) {
            range.location--;
            range.length++;
        }
        
        if (!isnumber([textField.text characterAtIndex:range.location])) {
            UITextPosition *pos = [textField positionFromPosition:textField.beginningOfDocument offset:[textField.text length]];
            UITextRange *textRange = [textField textRangeFromPosition:pos toPosition:pos];
            textField.selectedTextRange = textRange;
            
            return NO;
        }
    }
    
    int numCount = 0;
    for (int i = 0; i < range.location; i++ ) {
        if (isnumber([textField.text characterAtIndex:i]))
            numCount++;
    }
    
    textField.text = [[RMPhoneFormat instance] format:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    
    int i = 0;
    while (numCount > 0) {
        if (isnumber([textField.text characterAtIndex:i]))
            numCount--;
        i++;
    }
    
    if ([string length] != 0) {
        while (!isnumber([textField.text characterAtIndex:i]))
            i++;
        i++;
    }
    
    UITextPosition *pos = [textField positionFromPosition:textField.beginningOfDocument offset:i];
    UITextRange *textRange = [textField textRangeFromPosition:pos toPosition:pos];
    textField.selectedTextRange = textRange;
    
    if ([textField.text length] == 0)
        self.saveButton.enabled = NO;
    else
        self.saveButton.enabled = YES;
    
    return NO;
}

- (void)setPhone:(Phone *)phone {
    _phone = phone;
    
    if (!phone.number || [phone.number isEqualToString:@""]) {
        // new phone
        self.title = @"Add Phone";
        self.saveButton.enabled = NO;
        return;
    }
    
    if (self.numberCell)
        self.numberCell.numberField.text = phone.number;
    
    for (NSString *label in self.labels) {
        if ([label isEqualToString:phone.label]) {
            self.selectedLabel = (int)[self.labels indexOfObject:label];
            [self.tableView reloadData];
            break;
        }
    }
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(phoneEdited:)]) {
        [self.delegate phoneEdited:self.phone];
    }
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.phone) {
        if (self.numberCell)
            self.phone.number = self.numberCell.numberField.text;
        
        self.phone.label = self.labels[self.selectedLabel];
    }
    
    [self cancel:nil];
}

@end
