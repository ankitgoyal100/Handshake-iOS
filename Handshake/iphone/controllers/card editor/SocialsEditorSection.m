//
//  SocialsEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SocialsEditorSection.h"
#import "FacebookEditTableViewCell.h"
#import "TwitterEditTableViewCell.h"
#import "AddFieldTableViewCell.h"
#import "AddSocialViewController.h"
#import "UIControl+Blocks.h"
#import "FacebookHelper.h"
#import "Social.h"

@interface SocialsEditorSection()

@property (nonatomic) AddFieldTableViewCell *addSocialCell;

@property (nonatomic, strong) Card *card;

@end

@implementation SocialsEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (AddFieldTableViewCell *)addSocialCell {
    if (!_addSocialCell) {
        _addSocialCell = [[AddFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addSocialCell.label.text = @"ADD SOCIAL";
    }
    return _addSocialCell;
}

- (int)rows {
    return (int)[self.card.socials count] + 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (row == [self.card.socials count]) return self.addSocialCell;
    
    Social *social = self.card.socials[row];
    
    if ([social.network isEqualToString:@"facebook"]) {
        FacebookEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookEditCell"];
        
        if (!cell) cell = [[FacebookEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookEditCell"];
        
        __weak typeof(cell) weakCell = cell;
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeSocialsObject:social];
            [self.card.managedObjectContext deleteObject:social];
            [self removeRowAtIndexPath:[tableView indexPathForCell:weakCell] tableView:tableView];
        } forControlEvents:UIControlEventTouchUpInside];
        
        [[FacebookHelper sharedHelper] nameForUsername:social.username successBlock:^(NSString *name) {
            cell.nameLabel.text = name;
        } errorBlock:^(NSError *error) {
            cell.nameLabel.text = social.username;
        }];
        
        return cell;
    }
    
    if ([social.network isEqualToString:@"twitter"]) {
        TwitterEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterEditCell"];
        
        if (!cell) cell = [[TwitterEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwitterEditCell"];
        
        __weak typeof(cell) weakCell = cell;
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeSocialsObject:social];
            [self.card.managedObjectContext deleteObject:social];
            [self removeRowAtIndexPath:[tableView indexPathForCell:weakCell] tableView:tableView];
        } forControlEvents:UIControlEventTouchUpInside];
        
        cell.username = social.username;
        
        return cell;
    }
    
    return nil;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    if (row == [self.card.socials count]) {
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[AddSocialViewController alloc] initWithCard:self.card successBlock:^{
            [self insertRowAtIndexPath:indexPath tableView:self.viewController.tableView];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }]];
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.viewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
