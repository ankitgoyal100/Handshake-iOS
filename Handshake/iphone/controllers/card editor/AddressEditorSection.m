//
//  AddressEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddressEditorSection.h"
#import "AddressEditTableViewCell.h"
#import "AddFieldTableViewCell.h"
#import "LabelSelectionViewController.h"
#import "UIControl+Blocks.h"
#import "Address.h"

@interface AddressEditorSection() <UITextFieldDelegate>

@property (nonatomic, strong) AddFieldTableViewCell *addAddressField;

@property (nonatomic, strong) Card *card;

@end

@implementation AddressEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (AddFieldTableViewCell *)addAddressField {
    if (!_addAddressField) {
        _addAddressField = [[AddFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addAddressField.label.text = @"ADD ADDRESS";
    }
    return _addAddressField;
}

- (int)rows {
    return (int)[self.card.addresses count] + 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (row == [self.card.addresses count]) return self.addAddressField;
    
    AddressEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressEditCell"];
    
    if (!cell) cell = [[AddressEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressEditCell"];
    
    Address *address = self.card.addresses[row];
    
    __weak typeof(cell) weakCell = cell;
    
    [cell.deleteButton addEventHandler:^(id sender) {
        [self.card removeAddressesObject:address];
        [self.card.managedObjectContext deleteObject:address];
        [self removeRowAtIndexPath:[tableView indexPathForCell:weakCell] tableView:tableView];
    } forControlEvents:UIControlEventTouchUpInside];
    
    cell.label = address.label;
    cell.street1Field.text = address.street1;
    cell.street2Field.text = address.street2;
    cell.cityField.text = address.city;
    cell.stateField.text = address.state;
    cell.zipField.text = address.zip;
    cell.street1Field.tag = 1;
    cell.street2Field.tag = 2;
    cell.cityField.tag = 3;
    cell.stateField.tag = 4;
    cell.zipField.tag = 5;
    cell.street1Field.delegate = cell.street2Field.delegate = cell.cityField.delegate = cell.stateField.delegate = cell.zipField.delegate = self;
    
    [cell.labelButton addEventHandler:^(id sender) {
        LabelSelectionViewController *labelSelectionController = [[LabelSelectionViewController alloc] initWithOptions:@[@"home", @"work", @"main", @"other"] selectedOption:address.label selected:^(NSString *label) {
            address.label = label;
            [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForCell:weakCell]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:labelSelectionController];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.viewController presentViewController:controller animated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    Address *address = self.card.addresses[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    
    if (textField.tag == 5) address.zip = text;
    if (textField.tag == 4) address.state = text;
    if (textField.tag == 3) address.city = text;
    if (textField.tag == 2) address.street2 = text;
    if (textField.tag == 1) address.street1 = text;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    Address *address = self.card.addresses[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    
    if (textField.tag == 5) address.zip = @"";
    if (textField.tag == 4) address.state = @"";
    if (textField.tag == 3) address.city = @"";
    if (textField.tag == 2) address.street2 = @"";
    if (textField.tag == 1) address.street1 = @"";
    
    return YES;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == [self.card.addresses count]) {
        [self.viewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        Address *address = [[Address alloc] initWithEntity:[NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        address.label = @"home";
        [self.card addAddressesObject:address];
        
        [self insertRowAtIndexPath:indexPath tableView:self.viewController.tableView];
    }
}

@end
