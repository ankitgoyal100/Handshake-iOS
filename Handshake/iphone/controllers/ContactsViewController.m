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
#import "LoadingTableViewCell.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"
#import "Contact.h"
#import "ContactCell.h"
#import "UserViewController.h"

@interface ContactsViewController() <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end

@implementation ContactsViewController

- (NSMutableArray *)searchResults {
    if (!_searchResults) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return _searchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.searchView.frame;
    rect.size.height = 64;
    self.searchView.frame = rect;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidMove:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.managedObjectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    
    [self fetch];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"user.firstName" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"syncStatus != %@", [NSNumber numberWithInt:ContactDeleted]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetter" cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }];
}

- (void)keyboardDidMove:(NSNotification *)notification {
    CGRect rect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = MAX(self.view.window.frame.size.height - rect.origin.y - self.tabBarController.tabBar.frame.size.height, 0);
    //self.tableView.contentInset = insets;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26)];
    
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, view.frame.size.height)];
    
    label.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
    
    NSArray *sections = [self.fetchedResultsController sections];
    // if there is a '#' section
    if ([[sections[0] name] isEqualToString:@"#"]) {
        // if last section return '#', else add 1
        if (section == [sections count] - 1)
            label.text = @"#";
        else
            label.text = [[[self.fetchedResultsController sections][section + 1] name] uppercaseString];
    } else
        label.text = [[[self.fetchedResultsController sections][section] name] uppercaseString];
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.searchField.text length] > 0) return 0;
    
    return 26;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.searchField.text length] > 0) return 1;
    
    return [[self.fetchedResultsController sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.searchField.text length] > 0) return nil;
    
    return @[UITableViewIndexSearch, @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        self.tableView.contentOffset = CGPointMake(0, 0); // scroll to top if search
        return NSNotFound;
    }
    
    // if '#" and '#' section exists
    NSArray *sections = [self.fetchedResultsController sections];
    BOOL numbers = [[sections[0] name] isEqualToString:@"#"];
    if (index == 27)
        return [sections count] - 1;
    
    NSMutableArray *distances;
    if (numbers)
        distances = [NSMutableArray arrayWithCapacity:[sections count] - 1];
    else
        distances = [NSMutableArray arrayWithCapacity:[sections count]];
    
    char titleChar = [title characterAtIndex:0];
    
    for (NSObject <NSFetchedResultsSectionInfo> *section in sections) {
        if ([[section name] isEqualToString:@"#"])
            continue;
    
        char sectionChar = [[section name] characterAtIndex:0];
        int distance = ABS((int)sectionChar - (int)titleChar);
        
        if (numbers)
            distances[[sections indexOfObject:section] - 1] = [NSNumber numberWithInt:distance];
        else
            distances[[sections indexOfObject:section]] = [NSNumber numberWithInt:distance];
    }
    
    int shortest = 0;
    for (NSNumber *distance in distances) {
        if ([distance intValue] < [distances[shortest] intValue])
            shortest = (int)[distances indexOfObject:distance];
    }
    
    return shortest;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchField.text length] > 0)
        return [self.searchResults count] + 1;
    
    NSArray *sections = [self.fetchedResultsController sections];
    
    // if there is a '#' section
    if ([[sections[0] name] isEqualToString:@"#"]) {
        // if last section return '#', else add 1
        if (section == [sections count] - 1)
            return [((id<NSFetchedResultsSectionInfo>)sections[0]) numberOfObjects] + 1; // add 1 for spacer
        else
            return [((id<NSFetchedResultsSectionInfo>)sections[section + 1]) numberOfObjects];
    } else {
        // if last section add spacer row
        if (section == [sections count] - 1)
            return [((id<NSFetchedResultsSectionInfo>)sections[section]) numberOfObjects] + 1;
        else
            return [((id<NSFetchedResultsSectionInfo>)sections[section]) numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    Contact *contact;
    
    if ([self.searchField.text length] > 0) {
        if (indexPath.row == [self.searchResults count])
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        contact = self.searchResults[indexPath.row];
    } else {
        NSArray *sections = [self.fetchedResultsController sections];
        
        // if last section and last row return a spacer
        if (indexPath.section == [sections count] - 1) {
            if ([[sections[0] name] isEqualToString:@"#"] && indexPath.row == [sections[0] numberOfObjects])
                return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
            else if (indexPath.row == [sections[indexPath.section] numberOfObjects])
                return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        }
        
        // if there is a '#' section add 1 to indexPath
        if ([[sections[0] name] isEqualToString:@"#"]) {
            if (indexPath.section == [sections count] - 1)
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            else
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]];
        } else
            contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.pictureView.crossfadeDuration = 0;
    cell.pictureView.showActivityIndicator = NO;
    
    cell.pictureView.image = nil;
    if (contact.user.pictureData)
        cell.pictureView.image = [UIImage imageWithData:contact.user.pictureData];
    else
        cell.pictureView.imageURL = [NSURL URLWithString:contact.user.picture];
    cell.nameLabel.text = [contact.user formattedName];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.fetchedResultsController sections];
    
    // if searching and last row return 8
    if ([self.searchField.text length] > 0 && indexPath.row == [self.searchResults count])
        return 8;
    else if ([self.searchField.text length] > 0)
        return 56;
    
    // if last section and last row return 8
    if (indexPath.section == [sections count] - 1) {
        if ([[sections[0] name] isEqualToString:@"#"] && indexPath.row == [sections[0] numberOfObjects])
            return 8;
        else if (indexPath.row == [sections[indexPath.section] numberOfObjects])
            return 8;
    }
    
    return 56;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Contact *contact;
    
    if ([self.searchField.text length] > 0) {
        if (indexPath.row == [self.searchResults count])
            return; // do nothing
        
        contact = self.searchResults[indexPath.row];
    } else {
        NSArray *sections = [self.fetchedResultsController sections];
        
        // if last section and last row don't do anything
        if (indexPath.section == [sections count] - 1) {
            if ([[sections[0] name] isEqualToString:@"#"] && indexPath.row == [sections[0] numberOfObjects])
                return;
            else if (indexPath.row == [sections[indexPath.section] numberOfObjects])
                return;
        }
        
        // if there is a '#' section add 1 to indexPath
        if ([[sections[0] name] isEqualToString:@"#"]) {
            if (indexPath.section == [sections count] - 1)
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            else
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1]];
        } else
            contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    
    controller.user = contact.user;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self search:textField.text];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = @"";
    
    [self search:@""];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    
    return NO;
}

- (void)search:(NSString *)searchText {
    [self.searchResults removeAllObjects];
    
    for (Contact *contact in [self.fetchedResultsController fetchedObjects]) {
        NSComparisonResult firstName = [contact.user.firstName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult lastName = [contact.user.lastName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult name = [[contact.user formattedName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if ((contact.user.firstName && [contact.user.firstName length] > 0 && firstName == NSOrderedSame) || (contact.user.lastName && [contact.user.lastName length] > 0 && lastName == NSOrderedSame) || name == NSOrderedSame) {
            [self.searchResults addObject:contact];
        }
    }
    
    [self.tableView reloadData];
}

@end
