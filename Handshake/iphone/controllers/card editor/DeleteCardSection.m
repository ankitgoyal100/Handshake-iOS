//
//  DeleteCardSection.m
//  Handshake
//
//  Created by Sam Ober on 9/14/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "DeleteCardSection.h"
#import "DeleteCardTableViewCell.h"

@interface DeleteCardSection() <UIAlertViewDelegate>

@property (nonatomic, copy) CardDeletedSuccessBlock cardDeleted;

@property (nonatomic, strong) DeleteCardTableViewCell *deleteCell;

@end

@implementation DeleteCardSection

- (DeleteCardTableViewCell *)deleteCell {
    if (!_deleteCell) {
        _deleteCell = [[DeleteCardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _deleteCell;
}

- (id)initWithDeletedBlock:(CardDeletedSuccessBlock)cardDeleted viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.cardDeleted = cardDeleted;
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
    [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting this card will lose all of its data." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        self.cardDeleted();
    }
}

@end
