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
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Card.h"

@interface PhoneEditController ()

@property (nonatomic, weak) IBOutlet UITextField *numberField;

@property (nonatomic) int selectedLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

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
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.phone)
        self.phone = self.phone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 2 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
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

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 4 + [self.labels count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0)
//        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
//    
//    if (indexPath.row == 1) {
//        if (!self.numberCell) {
//            self.numberCell = (PhoneNumberCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneNumberCell"];
//            if (self.phone)
//                self.numberCell.numberField.text = self.phone.number;
//        }
//        return self.numberCell;
//    }
//    
//    if (indexPath.row == 2) {
//        return [tableView dequeueReusableCellWithIdentifier:@"LabelHeaderCell"];
//    }
//    
//    if (indexPath.row < 3 + [self.labels count]) {
//        LabelCell *cell = (LabelCell *)[tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
//        
//        cell.labelLabel.text = self.labels[indexPath.row - 3];
//        
//        if (indexPath.row - 3 == self.selectedLabel)
//            cell.checkIcon.hidden = NO;
//        else
//            cell.checkIcon.hidden = YES;
//        
//        return cell;
//    }
//    
//    return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0)
//        return 8;
//    
//    if (indexPath.row == 1)
//        return 56;
//    
//    if (indexPath.row == 2)
//        return 48;
//    
//    if (indexPath.row < 3 + [self.labels count])
//        return 56;
//    
//    return 8;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 2 || indexPath.row == 6) return;
    
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedLabel + 2 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        
    self.selectedLabel = indexPath.row - 2;
    
    [self updateSaveButton];
}

- (NSString *)labelForIndex:(int)index {
    if (index == 0) return @"Home";
    if (index == 1) return @"Mobile";
    if (index == 2) return @"Work";
    return @"Other";
}

- (void)updateSaveButton {
    if ([self.numberField.text length] > 0 && (![self.phone.number isEqualToString:self.numberField.text] || ![[self.phone.label lowercaseString] isEqualToString:[[self labelForIndex:self.selectedLabel] lowercaseString]]))
        self.saveButton.enabled = YES;
    else
        self.saveButton.enabled = NO;
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
    
    [self updateSaveButton];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.saveButton.enabled = NO;
    
    return YES;
}

- (void)setPhone:(Phone *)phone {
    _phone = phone;
    
    if (!self.numberField) return;
    
    if (!phone.number || [phone.number isEqualToString:@""]) {
        // new phone
        self.title = @"Add Phone";
        self.deleteButton.hidden = YES;
    } else {
        self.title = @"Edit Phone";
        self.numberField.text = phone.number;
        
        if ([[phone.label lowercaseString] isEqualToString:@"home"])
            self.selectedLabel = 0;
        else if ([[phone.label lowercaseString] isEqualToString:@"mobile"])
            self.selectedLabel = 1;
        else if ([[phone.label lowercaseString] isEqualToString:@"work"])
            self.selectedLabel = 2;
        else
            self.selectedLabel = 3;
    }
}

- (IBAction)save:(id)sender {
    self.phone.number = self.numberField.text;
    self.phone.label = [self labelForIndex:self.selectedLabel];
    
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

@end
