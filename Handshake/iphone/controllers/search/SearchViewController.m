//
//  SearchViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/11/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SearchViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "SearchResultCell.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "UIControl+Blocks.h"
#import "UserRequestCell.h"
#import "ContactCell.h"
#import "UserViewController.h"
#import "UserServerSync.h"

@interface SearchViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITextField *searchBar;
@property (nonatomic, strong) UILabel *placeholder;

@property (nonatomic, strong) NSArray *localResults;
@property (nonatomic, strong) NSMutableDictionary *serverResults;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL typed;

@property (nonatomic, strong) NSFetchedResultsController *contactsFetcher;

@end

@implementation SearchViewController

- (NSMutableDictionary *)serverResults {
    if (!_serverResults) _serverResults = [[NSMutableDictionary alloc] init];
    return _serverResults;
}

- (NSArray *)localResults {
    if (!_localResults) _localResults = [[NSArray alloc] init];
    return _localResults;
}

- (UILabel *)placeholder {
    if (!_placeholder) {
        _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 30)];
        _placeholder.backgroundColor = [UIColor clearColor];
        _placeholder.textColor = self.navigationController.navigationBar.barTintColor;
        _placeholder.font = [UIFont systemFontOfSize:16];
        _placeholder.text = @"Search...";
        _placeholder.userInteractionEnabled = NO;
    }
    return _placeholder;
}

- (UITextField *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(0, 6, self.view.frame.size.width, 30)];
        _searchBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _searchBar.layer.cornerRadius = 6;
        _searchBar.textColor = [UIColor whiteColor];
        _searchBar.font = [UIFont systemFontOfSize:16];
        //_searchBar.placeholder = @"Search Handshake ...";
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        leftView.backgroundColor = [UIColor clearColor];
        _searchBar.leftView = leftView;
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        _searchBar.clearButtonMode = UITextFieldViewModeAlways;
        _searchBar.delegate = self;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.enablesReturnKeyAutomatically = YES;
        _searchBar.tintColor = [UIColor whiteColor];
        
        [_searchBar addSubview:self.placeholder];
    }
    return _searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typed = NO;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.titleView = self.searchBar;
    
    self.timer = [[NSTimer alloc] initWithFireDate:nil interval:1 target:self selector:@selector(search) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.searchBar becomeFirstResponder];
    
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"isContact == %@", @(YES)];
    request.sortDescriptors = @[];
    
    NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] mainManagedObjectContext];
    
    self.contactsFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:objectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.contactsFetcher.delegate = self;
    
    [objectContext performBlockAndWait:^{
        [self.contactsFetcher performFetch:nil];
    }];
}

- (IBAction)cancel:(id)sender {
    if (self.timer) [self.timer invalidate];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchBar.text length] == 0) return 0;
    
    if (section == 0 && [self.localResults count] == 0 && ![self.serverResults[[self.searchBar.text lowercaseString]] count]) return 0;
    if (section == 0 && [self.localResults count] == 0) return 1;
    if (section == 0) return [self.localResults count] + 1;

    if (section == 1 && ![self.serverResults[[self.searchBar.text lowercaseString]] count]) return 1;
    if (section == 1) return [self.serverResults[[self.searchBar.text lowercaseString]] count];

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    if (indexPath.section == 0 && indexPath.row == [self.localResults count] + 1)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.section == 0) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        cell.user = self.localResults[indexPath.row - 1];
        return cell;
    }
    
    if (!self.serverResults[[self.searchBar.text lowercaseString]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"]; // loading cell
        [((UIActivityIndicatorView *)[cell viewWithTag:5]) startAnimating];
        return cell;
    }
    
    if ([self.serverResults[[self.searchBar.text lowercaseString]] count] == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"]; // no results cell
    
    //if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
//    if (indexPath.row == 0 || indexPath.row == [self.results count] + 1)
//        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    User *result = self.serverResults[[self.searchBar.text lowercaseString]][indexPath.row];
    
    if ([result.isContact boolValue]) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        cell.user = result;
        return cell;
    }
    
    if ([result.requestReceived boolValue]) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        cell.user = result;
        return cell;
    }
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.user = result;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return 1;
    if (indexPath.section == 0 && indexPath.row == [self.localResults count] + 1) return 20;
    
    if (indexPath.section == 0) return 57;
    
    if (![self.serverResults[[self.searchBar.text lowercaseString]] count]) return 60;
    
    if ([self.serverResults count] == 0) return 60;
    
    //if (indexPath.row == 0) return 1;
    
//    if (indexPath.row == 0 || indexPath.row == [self.results count] + 1)
//        return 8;
    
//    SearchResult *result = self.results[indexPath.row - 1];
//    
//    if (result.contact) return 56;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) return;
    if (indexPath.section == 0 && indexPath.row == [self.localResults count] + 1) return;
    
    if (indexPath.section == 1 && ![self.serverResults[[self.searchBar.text lowercaseString]] count]) return;
    
    //if (indexPath.row == 0 || indexPath.row == [self.results count] + 1) return;
    
    if (indexPath.section == 0) {
        User *contact = self.localResults[indexPath.row - 1];
        UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
        controller.user = contact;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.section == 1) {
        User *result = self.serverResults[[self.searchBar.text lowercaseString]][indexPath.row];
        UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
        controller.user = result;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0) {
        self.placeholder.hidden = YES;
        self.typed = YES;
        [self searchLocal];
    } else {
        self.placeholder.hidden = NO;
        [self.tableView reloadData];
    }
    
    return NO;
}

- (void)searchLocal {
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    NSString *searchText = [self.searchBar text];

    for (User *contact in [self.contactsFetcher fetchedObjects]) {
        NSComparisonResult firstName = [contact.firstName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult lastName = [contact.lastName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSComparisonResult name = [[contact formattedName] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        if ((contact.firstName && [contact.firstName length] > 0 && firstName == NSOrderedSame) || (contact.lastName && [contact.lastName length] > 0 && lastName == NSOrderedSame) || name == NSOrderedSame) {
            [searchResults addObject:contact];
        }
    }
    
    self.localResults = searchResults;
    
    [self.tableView reloadData];
}

- (void)search {
    if (!self.typed)
        return;
    
    self.typed = NO;
    
    if (self.serverResults[[self.searchBar.text lowercaseString]]) return;
    
    NSString *searchString = [self.searchBar.text lowercaseString];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"q"] = searchString;
    [[HandshakeClient client] GET:@"/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![self.navigationController.viewControllers containsObject:self]) return; // user cancelled
        
        if (!self.serverResults[searchString]) {
            // remove results that are contacts
            NSMutableArray *results = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in responseObject[@"results"])
                if (![dict[@"is_contact"] boolValue]) [results addObject:dict];
            
            [UserServerSync cacheUsers:results completionBlock:^(NSArray *users) {
                self.serverResults[searchString] = users;
                if ([self.searchBar.text isEqualToString:searchString])
                    [self.tableView reloadData];
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
    }];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.localResults = nil;
    
    textField.text = @"";
    self.placeholder.hidden = NO;
    
    [self.tableView reloadData];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

@end
