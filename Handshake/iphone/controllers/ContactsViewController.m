//
//  ContactsViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactsViewController.h"
#import "Handshake.h"
#import "SearchView.h"
#import "ContactTableViewCell.h"
#import "MessageTableViewCell.h"
#import "ContactViewController.h"
#import "NewContactViewController.h"
#import "LoadingTableViewCell.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"
#import "Contact.h"
#import "ShakeTutorialTableViewCell.h"

@interface ContactsViewController() <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) SearchView *searchView;

@property (nonatomic, strong) MessageTableViewCell *meetPeopleCell;
@property (nonatomic, strong) ShakeTutorialTableViewCell *tutorialCell;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation ContactsViewController

- (SearchView *)searchView {
    if (!_searchView) _searchView = [[SearchView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 51)];
    return _searchView;
}

- (MessageTableViewCell *)meetPeopleCell {
    if (!_meetPeopleCell) _meetPeopleCell = [[MessageTableViewCell alloc] initWithMessage:@"Go meet more people!" reuseIdentifier:nil];
    return _meetPeopleCell;
}

- (ShakeTutorialTableViewCell *)tutorialCell {
    if (!_tutorialCell) {
        _tutorialCell = [[ShakeTutorialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _tutorialCell;
}

- (NSMutableArray *)searchResults {
    if (!_searchResults) _searchResults = [[NSMutableArray alloc] init];
    return _searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = self.tableView;
//    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    tableViewController.refreshControl = self.refreshControl;
    
    self.navigationItem.title = @"Contacts";
    
    self.searchView.searchField.delegate = self;
    [self.searchView.cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top += 50;
    self.tableView.contentInset = insets;
    
    insets = self.tableView.scrollIndicatorInsets;
    insets.top += 50;
    self.tableView.scrollIndicatorInsets = insets;
    
    [self updateEndCell];
    
    [self.view addSubview:self.searchView];
    [self.view bringSubviewToFront:self.searchView];
    
    //self.loading = YES;
    //self.page = 1;
    //[self loadContacts];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"syncStatus != %@", [NSNumber numberWithInt:ContactDeleted]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }];
}

- (void)updateEndCell {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"syncStatus != %@", [NSNumber numberWithInt:ContactDeleted]];
    
    __block NSArray *results;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:request error:&error];
    }];
    
    if (results && [results count] > 0) {
        self.endCell = self.meetPeopleCell;
    } else {
        self.endCell = self.tutorialCell;
    }
}

//- (void)loadContacts {
//    self.loadingMoreContacts = YES;
//    
//    [[HandshakeAPI client] contactsOnPage:self.page success:^(NSArray *contacts) {
//        //check if number of contacts is less than 50 (end of pages)
//        if ([contacts count] < 50) {
//            self.page = -1;
//            self.endCell = self.meetPeopleCell;
//        } else
//            self.page++;
//        
//        [self.contacts addObjectsFromArray:contacts];
//        [self.contacts setArray:[[NSSet setWithArray:self.contacts] allObjects]];
//        
//        [self.refreshControl endRefreshing];
//        self.loading = NO;
//        self.loadingMoreContacts = NO;
//    } failure:^(HandshakeError error) {
//        if (error != NOT_LOGGED_IN)
//            [self loadContacts];
//    }];
//}
//
//- (void)refresh {
//    [self.contacts removeAllObjects];
//    self.page = 1;
//    [self loadContacts];
//}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self updateEndCell];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self insertRowAtRow:(int)newIndexPath.row section:(int)newIndexPath.section];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self removeRowAtRow:(int)indexPath.row section:(int)indexPath.section];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            ContactTableViewCell *cell = (ContactTableViewCell *)[self cellForRow:(int)newIndexPath.row section:(int)newIndexPath.section];
            [self configureCell:cell row:(int)newIndexPath.row section:(int)newIndexPath.section indexPath:[self indexPathForCell:cell]];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self removeRowAtRow:(int)indexPath.row section:(int)indexPath.section];
            [self insertRowAtRow:(int)newIndexPath.row section:(int)newIndexPath.section];
            break;
        }
    }
}

- (int)numberOfSections {
    return 1;
}

- (int)numberOfRowsInSection:(int)section {
    if (self.searchView.searching && [self.searchView.searchField.text length] > 0) return (int)[self.searchResults count];
    
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return (int)[sectionInfo numberOfObjects];
}

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    if (!cell) cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"];
    
    [self configureCell:cell row:row section:section indexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ContactTableViewCell *)cell row:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath {
    Contact *contact;
    
    if (self.searchView.searching && [self.searchView.searchField.text length] > 0)
        contact = self.searchResults[row];
    else
        contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
    if (contact.card.pictureData)
        cell.pictureView.image = [UIImage imageWithData:contact.card.pictureData];
    else if ([contact.card.picture length])
        cell.pictureView.imageURL = [NSURL URLWithString:contact.card.picture];
    else
        cell.pictureView.image = [UIImage imageNamed:@"default_picture.png"];
    cell.nameLabel.text = [contact.card formattedName];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] - [contact.shake.time timeIntervalSince1970];
    if (time < 60) {
        if ((int)time == 1)
            cell.timeLabel.text = @"1 second ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time] stringValue] stringByAppendingString:@" seconds ago"];
    } else if (time < 3600) {
        if ((int)(time / 60) == 1)
            cell.timeLabel.text = @"1 minute ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time / 60] stringValue] stringByAppendingString:@" minutes ago"];
    } else if (time < 86400) {
        if ((int)(time / 86400) == 1)
            cell.timeLabel.text = @"1 hour ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time / 3600] stringValue] stringByAppendingString:@" hours ago"];
    } else if (time < 2630000) {
        if ((int)(time / 2630000) == 1)
            cell.timeLabel.text = @"1 day ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time / 86400] stringValue] stringByAppendingString:@" days ago"];
    } else if (time < 31560000) {
        if ((int)(time / 31560000) == 1)
            cell.timeLabel.text = @"1 month ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time / 2630000] stringValue] stringByAppendingString:@" months ago"];
    } else {
        if ((int)(time / 31560000) == 1)
            cell.timeLabel.text = @"1 year ago";
        else
            cell.timeLabel.text = [[[NSNumber numberWithInt:time / 31560000] stringValue] stringByAppendingString:@" years ago"];
    }
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    Contact *contact;
    
    if (self.searchView.searching && [self.searchView.searchField.text length] > 0)
        contact = self.searchResults[row];
    else
        contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
    ContactViewController *controller = [[ContactViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.searchView.searching = YES;
    self.endCell = nil;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self search:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = text;

    [self search:text];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self search:@""];
    
    return YES;
}

- (void)cancelSearch {
    self.searchView.searching = NO;
    [self.searchView.searchField resignFirstResponder];
    
    [self updateEndCell];
    
    [self.searchResults removeAllObjects];
    
    [self.tableView reloadData];
}

- (void)search:(NSString *)searchText {
    [self.searchResults removeAllObjects];
    
    for (Contact *contact in [self.fetchedResultsController fetchedObjects]) {
        NSComparisonResult firstName = [contact.card.firstName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult lastName = [contact.card.lastName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult name = [[contact.card formattedName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if (firstName == NSOrderedSame || lastName == NSOrderedSame || name == NSOrderedSame) {
            [self.searchResults addObject:contact];
        }
    }
    
    [self.tableView reloadData];
}

@end
