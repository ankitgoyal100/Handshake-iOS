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
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "UIControl+Blocks.h"
#import "Card.h"
#import "UserRequestCell.h"
#import "Request.h"
#import "Contact.h"
#import "ContactCell.h"
#import "UserViewController.h"

@interface SearchViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *searchBar;
@property (nonatomic, strong) UILabel *placeholder;

@property (nonatomic) BOOL loading;
@property (nonatomic) int loadCount;
@property (nonatomic, strong) NSArray *results;

@property (nonatomic, strong) AFHTTPRequestOperation *searchOperation;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL typed;

@end

@implementation SearchViewController

- (NSArray *)results {
    if (!_results) _results = [[NSArray alloc] init];
    return _results;
}

- (UILabel *)placeholder {
    if (!_placeholder) {
        _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 200, 32)];
        _placeholder.backgroundColor = [UIColor clearColor];
        _placeholder.textColor = self.navigationController.navigationBar.barTintColor;
        _placeholder.font = [UIFont fontWithName:@"Roboto" size:16];
        _placeholder.text = @"Search Handshake ...";
        _placeholder.userInteractionEnabled = NO;
    }
    return _placeholder;
}

- (UITextField *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(72, 6, self.view.frame.size.width - 16, 32)];
        _searchBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _searchBar.layer.cornerRadius = 6;
        _searchBar.textColor = [UIColor whiteColor];
        _searchBar.font = [UIFont fontWithName:@"Roboto" size:16];
        //_searchBar.placeholder = @"Search Handshake ...";
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        leftView.backgroundColor = [UIColor clearColor];
        _searchBar.leftView = leftView;
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        _searchBar.clearButtonMode = UITextFieldViewModeAlways;
        _searchBar.delegate = self;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.returnKeyType = UIReturnKeySearch;
        _searchBar.enablesReturnKeyAutomatically = YES;
        
        [_searchBar addSubview:self.placeholder];
    }
    return _searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadCount = 0;
    self.typed = NO;
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    self.navigationItem.titleView = self.searchBar;
    
    self.timer = [[NSTimer alloc] initWithFireDate:nil interval:1 target:self selector:@selector(search) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [self.searchBar becomeFirstResponder];
}

- (void)back {
    if (self.timer) [self.timer invalidate];
    
    // delete all untagged search results
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tag == nil"];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error;
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
    }];
    
    for (SearchResult *result in results) {
        if (result.request && result.request.user.userId == [[HandshakeSession currentSession] account].userId) {
            [result.managedObjectContext deleteObject:result.request]; // delete outgoing requests
        }
        
        [result.managedObjectContext deleteObject:result];
    }
    
    // save context
    
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchBar.text length] == 0) return 0;
    
    if (self.loading || [self.results count] == 0) return 1;
    
    return 2 + [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loading) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"]; // loading cell
        [((UIActivityIndicatorView *)[cell viewWithTag:5]) startAnimating];
        return cell;
    }
    
    if ([self.results count] == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"]; // no results cell
    
    if (indexPath.row == 0 || indexPath.row == [self.results count] + 1)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    __block SearchResult *result = self.results[indexPath.row - 1];
    
    if (result.contact) {
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
        
        cell.pictureView.image = nil;
        if (result.pictureData)
            cell.pictureView.image = [UIImage imageWithData:result.pictureData];
        else if (result.picture)
            cell.pictureView.imageURL = [NSURL URLWithString:result.picture];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
        
        cell.nameLabel.text = [result formattedName];
        
        return cell;
    }
    
    if (result.request && result.request.user.userId != [[HandshakeSession currentSession] account].userId) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        
        cell.pictureView.image = nil;
        if (result.pictureData)
            cell.pictureView.image = [UIImage imageWithData:result.pictureData];
        else if (result.picture)
            cell.pictureView.imageURL = [NSURL URLWithString:result.picture];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
        
        cell.nameLabel.text = [result formattedName];
        
        if ([result.mutual intValue] == 1)
            cell.mutualFriendsLabel.text = @"1 mutual contact";
        else
            cell.mutualFriendsLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [result.mutual intValue]];
        
        cell.acceptButton.hidden = NO;
        cell.declineButton.hidden = NO;
        
        __block Request *oldRequest = result.request;
        
        [cell.acceptButton addEventHandler:^(id sender) {
            cell.acceptButton.hidden = YES;
            cell.declineButton.hidden = YES;
            
            cell.mutualFriendsLabel.text = @"Request accepted";
            
            [result.request acceptWithSuccessBlock:^(Contact *contact) {
                result.contact = contact;
            } failedBlock:^{
                result.request = oldRequest;
                [self.tableView reloadData];
                
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not accept request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
            
            result.request = nil;
        } forControlEvents:UIControlEventTouchUpInside];
        
        [cell.declineButton addEventHandler:^(id sender) {
            cell.acceptButton.hidden = YES;
            cell.declineButton.hidden = YES;
            
            cell.mutualFriendsLabel.text = @"Request declined";
            
            [result.request deleteWithSuccessBlock:^{
                
            } failedBlock:^{
                result.request = oldRequest;
                [self.tableView reloadData];
                
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not decline request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
            
            result.request = nil;
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    
    cell.pictureView.image = nil;
    if (result.pictureData)
        cell.pictureView.image = [UIImage imageWithData:result.pictureData];
    else if (result.picture)
        cell.pictureView.imageURL = [NSURL URLWithString:result.picture];
    else
        cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    cell.nameLabel.text = [result formattedName];
    
    if ([result.mutual intValue] == 1)
        cell.mutualLabel.text = @"1 mutual contact";
    else
        cell.mutualLabel.text = [NSString stringWithFormat:@"%d mutual contacts", [result.mutual intValue]];
    
    if (result.request) {
        cell.sentButton.hidden = NO;
        cell.sendButton.hidden = YES;
    } else {
        cell.sentButton.hidden = YES;
        cell.sendButton.hidden = NO;
    }
    
    [cell.sentButton addEventHandler:^(id sender) {
        if (!result.request || !result.request.requestId) return;
        
        cell.sentButton.hidden = YES;
        cell.sendButton.hidden = NO;
        
        __block Request *oldRequest = result.request;
        
        [result.request deleteWithSuccessBlock:^{
            // do nothing
        } failedBlock:^{
            result.request = oldRequest;
            [self.tableView reloadData];
        }];
        
        result.request = nil;
    } forControlEvents:UIControlEventTouchUpInside];
    
    [cell.sendButton addEventHandler:^(id sender) {
        if (result.request) return;
        
        cell.sentButton.hidden = NO;
        cell.sendButton.hidden = YES;
        
        result.request = [[Request alloc] initWithEntity:[NSEntityDescription entityForName:@"Request" inManagedObjectContext:result.managedObjectContext] insertIntoManagedObjectContext:result.managedObjectContext];
        result.request.user = [[HandshakeSession currentSession] account];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
        params[@"recipient_id"] = result.userId;
        params[@"card_ids"] = @[((Card *)[[HandshakeSession currentSession] account].cards[0]).cardId];
        [[HandshakeClient client] POST:@"/requests" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [result.request updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"request"]]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([[operation response] statusCode] == 401)
                [[HandshakeSession currentSession] invalidate];
            else {
                result.request = nil;
                [self.tableView reloadData];
            }
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loading) return 72;
    
    if ([self.results count] == 0) return 72;
    
    if (indexPath.row == 0 || indexPath.row == [self.results count] + 1)
        return 8;
    
//    SearchResult *result = self.results[indexPath.row - 1];
//    
//    if (result.contact) return 56;
    
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.loading || [self.results count] == 0) return;
    
    if (indexPath.row == 0 || indexPath.row == [self.results count] + 1) return;
    
    SearchResult *result = self.results[indexPath.row - 1];
    
    if (result.contact) {
        UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
        controller.user = result.contact.user;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int length = (int)[textField.text length];
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.text length] > 0) {
        self.placeholder.hidden = YES;
        
        if (!self.loading && (length == 0 || [self.results count] == 0)) {
            self.loading = YES; // only show loader at start of typing or if there were no results
            [self.tableView reloadData];
        }
        
        self.typed = YES;
    } else {
        self.placeholder.hidden = NO;
        [self.tableView reloadData];
    }
    
    return NO;
}

- (void)search {
    if (!self.typed)
        return;
    
    self.typed = NO;
    
    if (self.searchOperation) [self.searchOperation cancel];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
    params[@"q"] = self.searchBar.text;
    self.searchOperation = [[HandshakeClient client] GET:@"/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (self.searchOperation == operation) {
            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in responseObject[@"results"]) {
                NSDictionary *resultDict = [HandshakeCoreDataStore removeNullsFromDictionary:dict];
                // find or create SearchResult
                
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
                request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", resultDict[@"id"]];
                request.fetchLimit = 1;
                
                __block NSArray *results;
                
                [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
                    NSError *error;
                    results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
                }];
                
                SearchResult *searchResult;
                
                if (results && [results count] == 1) {
                    searchResult = results[0];
                } else {
                    searchResult = [[SearchResult alloc] initWithEntity:[NSEntityDescription entityForName:@"SearchResult" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]] insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
                }
                
                [searchResult updateFromDictionary:resultDict];
                
                [searchResults addObject:searchResult];
            }
            
            self.results = searchResults;
            self.loading = NO;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([[operation response] statusCode] == 401)
            [[HandshakeSession currentSession] invalidate];
        else if (self.searchOperation == operation) {
            self.loading = NO;
        }
    }];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.loading = NO;
    self.loadCount++;
    self.results = nil;
    
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
