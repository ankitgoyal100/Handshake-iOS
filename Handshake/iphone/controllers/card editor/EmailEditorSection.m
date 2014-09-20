//
//  EmailEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EmailEditorSection.h"
#import "EmailEditTableViewCell.h"
#import "AddFieldTableViewCell.h"
#import "LabelSelectionViewController.h"
#import "UIControl+Blocks.h"
#import "Email.h"

@interface EmailEditorSection() <UITextFieldDelegate>

@property (nonatomic, strong) AddFieldTableViewCell *addEmailCell;

@property (nonatomic, strong) Card *card;

@end

@implementation EmailEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (AddFieldTableViewCell *)addEmailCell {
    if (!_addEmailCell) {
        _addEmailCell = [[AddFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addEmailCell.label.text = @"ADD EMAIL";
    }
    return _addEmailCell;
}

- (int)rows {
    return (int)[self.card.emails count] + 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (row == [self.card.emails count]) return self.addEmailCell;
    
    EmailEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmailEditCell"];
    
    if (!cell) cell = [[EmailEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmailEditCell"];
    
    Email *email = self.card.emails[row];
    
    __weak typeof(cell) weakCell = cell;
    
    [cell.deleteButton addEventHandler:^(id sender) {
        [self.card removeEmailsObject:email];
        [self.card.managedObjectContext deleteObject:email];
        [self removeRowAtIndexPath:[tableView indexPathForCell:weakCell] tableView:tableView];
    } forControlEvents:UIControlEventTouchUpInside];
    
    cell.label = email.label;
    cell.emailField.text = email.address;
    cell.emailField.delegate = self;
    
    [cell.labelButton addEventHandler:^(id sender) {
        LabelSelectionViewController *labelSelectionController = [[LabelSelectionViewController alloc] initWithOptions:@[@"home", @"work", @"main", @"other"] selectedOption:email.label selected:^(NSString *label) {
            email.label = label;
            [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForCell:weakCell]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:labelSelectionController];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.viewController presentViewController:controller animated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    Email *email = self.card.emails[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    email.address = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    Email *email = self.card.emails[[self.viewController indexPathForCell:(BaseTableViewCell *)textField.superview].row];
    email.address = @"";
    
    return YES;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == [self.card.emails count]) {
        [self.viewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        Email *email = [[Email alloc] initWithEntity:[NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        email.address = @"";
        email.label = @"home";
        [self.card addEmailsObject:email];
        
        [self insertRowAtIndexPath:indexPath tableView:self.viewController.tableView];
    }
}

@end
