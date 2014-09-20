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
#import "HandshakeContact.h"
#import "HandshakeAPI.h"
#import "LoadingTableViewCell.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"
#import "Contact.h"

@interface ContactsViewController() <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) SearchView *searchView;

@property (nonatomic, strong) MessageTableViewCell *meetPeopleCell;

//@property (nonatomic, strong) NSMutableArray *contacts;
//
//@property (nonatomic) int page;
//@property (nonatomic) BOOL loadingMoreContacts;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

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

//- (NSMutableArray *)contacts {
//    if (!_contacts) _contacts = [[NSMutableArray alloc] init];
//    return _contacts;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Contact sync];
    
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
    
    self.endCell = self.meetPeopleCell;
    
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
    return (int)[[self.fetchedResultsController sections] count];
}

- (int)numberOfRowsInSection:(int)section {
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
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
    if ([contact.card.picture length])
        cell.pictureView.imageURL = [NSURL URLWithString:contact.card.picture];
    else
        cell.pictureView.image = [UIImage imageNamed:@"default_picture.png"];
    cell.nameLabel.text = [contact.card formattedName];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] - [contact.shake.time timeIntervalSince1970];
    if (time < 60) {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time] stringValue] stringByAppendingString:@" seconds ago"];
    } else if (time < 3600) {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time / 60] stringValue] stringByAppendingString:@" minutes ago"];
    } else if (time < 86400) {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time / 3600] stringValue] stringByAppendingString:@" hours ago"];
    } else if (time < 2630000) {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time / 86400] stringValue] stringByAppendingString:@" days ago"];
    } else if (time < 31560000) {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time / 2630000] stringValue] stringByAppendingString:@" months ago"];
    } else {
        cell.timeLabel.text = [[[NSNumber numberWithInt:time / 31560000] stringValue] stringByAppendingString:@" years ago"];
    }
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
    ContactViewController *controller = [[ContactViewController alloc] initWithContact:contact];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.searchView.searching = YES;
    self.endCell = nil;
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)cancelSearch {
    self.searchView.searching = NO;
    [self.searchView.searchField resignFirstResponder];
    
    self.endCell = self.meetPeopleCell;
}

//- (void)scrolled:(UIScrollView *)scrollView {
//    if (self.page == -1 || self.loadingMoreContacts || self.loading || [self.contacts count] == 0) return;
//    
//    // check if scrollview is less than 2 screen heights away from end of content
//    if (scrollView.contentOffset.y > scrollView.contentSize.height - (2 * self.view.bounds.size.height)) {
//        [self loadContacts];
//    }
//}

@end
