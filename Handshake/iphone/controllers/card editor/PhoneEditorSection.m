//
//  PhoneEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "PhoneEditorSection.h"
#import "PhoneEditTableViewCell.h"
#import "RMPhoneFormat.h"
#import "AddFieldTableViewCell.h"
#import "LabelSelectionViewController.h"
#import "UIControl+Blocks.h"
#import "Phone.h"

@interface PhoneEditorSection() <UITextFieldDelegate>

@property (nonatomic, strong) AddFieldTableViewCell *addPhoneCell;

@property (nonatomic, strong) Card *card;

@end

@implementation PhoneEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (AddFieldTableViewCell *)addPhoneCell {
    if (!_addPhoneCell) {
        _addPhoneCell = [[AddFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addPhoneCell.label.text = @"ADD PHONE";
    }
    return _addPhoneCell;
}

- (int)rows {
    return (int)[self.card.phones count] + 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (row == [self.card.phones count]) return self.addPhoneCell;
    
    PhoneEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
    
    if (!cell) cell = [[PhoneEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneEditCell"];
    
    Phone *phone = self.card.phones[row];
    
    __weak typeof(cell) weakCell = cell;
    
    [cell.deleteButton addEventHandler:^(id sender) {
        [self.card removePhonesObject:phone];
        [self.card.managedObjectContext deleteObject:phone];
        [self removeRowAtIndexPath:[tableView indexPathForCell:weakCell] tableView:tableView];
    } forControlEvents:UIControlEventTouchUpInside];
    
    cell.label = phone.label;
    cell.numberField.text = phone.number;
    cell.numberField.delegate = self;
    
    [cell.labelButton addEventHandler:^(id sender) {
        LabelSelectionViewController *labelSelectionController = [[LabelSelectionViewController alloc] initWithOptions:@[@"mobile", @"home", @"work", @"main", @"home fax", @"work fax", @"other"] selectedOption:phone.label selected:^(NSString *label) {
            phone.label = label;
            [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForCell:weakCell]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:labelSelectionController];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.viewController presentViewController:controller animated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
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
    
    Phone *phone = self.card.phones[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    phone.number = textField.text;
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    Phone *phone = self.card.phones[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    phone.number = @"";
    
    return YES;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == [self.card.phones count]) {
        [self.viewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        Phone *phone = [[Phone alloc] initWithEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        phone.number = @"";
        phone.label = @"mobile";
        [self.card addPhonesObject:phone];
        
        [self insertRowAtIndexPath:indexPath tableView:self.viewController.tableView];
    }
}

@end
