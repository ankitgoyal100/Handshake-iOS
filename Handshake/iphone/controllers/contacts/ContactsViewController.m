//
//  ContactsViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactsViewController.h"
#import "HandshakeCoreDataStore.h"
#import "ContactCell.h"
#import "UserViewController.h"
#import "UserRequestCell.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "SectionHeaderCell.h"
#import "ContactServerSync.h"

@interface ContactsViewController() <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *requestFetchController;

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
    
    self.title = @"Contacts";
    
    CGRect rect = self.searchView.frame;
    rect.size.height = 0;//48;
    self.searchView.frame = rect;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidMove:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.managedObjectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [self fetch];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@", @(YES)];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetterOfName" cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    // requests
    //request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
    //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    //self.requestFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    //self.requestFetchController.delegate = self;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        //[self.requestFetchController performFetch:&error];
    }];
}

- (void)refresh {
    [ContactServerSync syncWithCompletionBlock:^{
        [self.refreshControl endRefreshing];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width - 24, view.frame.size.height)];
    
    //label.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
    //label.font = [UIFont fontWithName:@"HelveticaNeue-BOLD" size:12];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor colorWithWhite:0.64 alpha:1];
    
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
    
    //if (section != 0) {
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)];
        sep.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
        [view addSubview:sep];
    //}
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.searchField.text length] > 0) return 0;
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.searchField.text length] > 0) return 1;
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) return 1;
    
    return [[self.fetchedResultsController sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
    
    //    if ([self.searchField.text length] > 0) return nil;
    //
    //    return @[UITableViewIndexSearch, @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
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
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) return 1;
    
    NSArray *sections = [self.fetchedResultsController sections];
    
    // if there is a '#' section
    if ([[sections[0] name] isEqualToString:@"#"]) {
        // if last section return '#', else add 1
        if (section == [sections count] - 1)
            return [((id<NSFetchedResultsSectionInfo>)sections[0]) numberOfObjects] + 1;
        //else if (section == 0)
            //return [((id<NSFetchedResultsSectionInfo>)sections[section + 1]) numberOfObjects] + 1;
        else
            return [((id<NSFetchedResultsSectionInfo>)sections[section + 1]) numberOfObjects] + 1;
    //} else if (section == 0) {
       // return [((id<NSFetchedResultsSectionInfo>)sections[section]) numberOfObjects] + 1;
    } else
        return [((id<NSFetchedResultsSectionInfo>)sections[section]) numberOfObjects] + 1;
}

- (NSString *)titleForSection:(int)section {
    NSArray *sections = [self.fetchedResultsController sections];
    // if there is a '#' section
    if ([[sections[0] name] isEqualToString:@"#"]) {
        // if last section return '#', else add 1
        if (section == [sections count] - 1)
            return @"#";
        else
            return [[[self.fetchedResultsController sections][section + 1] name] uppercaseString];
    } else
        return [[[self.fetchedResultsController sections][section] name] uppercaseString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
    
    if (indexPath.row == 0) {
        SectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionHeaderCell"];
        cell.label.text = [self titleForSection:(int)indexPath.section];
        return cell;
    }
    
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    User *contact;
    
    if ([self.searchField.text length] > 0) {
        contact = self.searchResults[indexPath.row];
    } else {
        NSArray *sections = [self.fetchedResultsController sections];
        
        // if there is a '#' section add 1 to indexPath
        if ([[sections[0] name] isEqualToString:@"#"]) {
            if (indexPath.section == [sections count] - 1)
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
           // else if (indexPath.section == 0)
              //  contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section + 1]];
            else
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section + 1]];
       // } else if (indexPath.section == 0)
          //  contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
        } else
            contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    }
    
    cell.user = contact;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0 && indexPath.row == 0) return 1;
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) return 60;
    
    if (indexPath.row == 0) return 30;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ////if (indexPath.section == 0 && indexPath.row == 0) return;
    
    if (indexPath.row == 0) return;
    
    User *contact;
    
    if ([self.searchField.text length] > 0) {
        contact = self.searchResults[indexPath.row];
    } else {
        NSArray *sections = [self.fetchedResultsController sections];
        
        // if there is a '#' section add 1 to indexPath
        if ([[sections[0] name] isEqualToString:@"#"]) {
            if (indexPath.section == [sections count] - 1)
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
            //else if (indexPath.section == 0)
              //  contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section + 1]];
            else
                contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section + 1]];
       // } else if (indexPath.section == 0)
          //  contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
        }else
            contact = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]];
    }
    
    UserViewController *controller = (UserViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    
    controller.user = contact;
    
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
    
    for (User *contact in [self.fetchedResultsController fetchedObjects]) {
        NSComparisonResult firstName = [contact.firstName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult lastName = [contact.lastName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult name = [[contact formattedName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if ((contact.firstName && [contact.firstName length] > 0 && firstName == NSOrderedSame) || (contact.lastName && [contact.lastName length] > 0 && lastName == NSOrderedSame) || name == NSOrderedSame) {
            [self.searchResults addObject:contact];
        }
    }
    
    [self.tableView reloadData];
}

@end
