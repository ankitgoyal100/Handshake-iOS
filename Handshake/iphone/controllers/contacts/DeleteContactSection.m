//
//  DeleteContactSection.m
//  Handshake
//
//  Created by Sam Ober on 9/19/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "DeleteContactSection.h"
#import "DeleteCardTableViewCell.h"

@interface DeleteContactSection() <UIAlertViewDelegate>

@property (nonatomic, strong) DeleteCardTableViewCell *deleteCell;

@property (nonatomic, copy) ContactDeletedBlock contactDeletedBlock;

@end

@implementation DeleteContactSection

- (DeleteCardTableViewCell *)deleteCell {
    if (!_deleteCell) {
        _deleteCell = [[DeleteCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _deleteCell.deleteLabel.text = @"DELETE CONTACT";
    }
    return _deleteCell;
}

- (id)initWithContactDeletedBlock:(ContactDeletedBlock)contactDeletedBlock viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.contactDeletedBlock = contactDeletedBlock;
    }
    return self;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.deleteCell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting this contact will lose all of its data." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        self.contactDeletedBlock();
    }
}

@end
