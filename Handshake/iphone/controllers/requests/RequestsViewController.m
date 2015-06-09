//
//  RequestsViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "RequestsViewController.h"
#import "UserRequestCell.h"
#import "Request.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "User.h"
#import "UIControl+Blocks.h"
#import "SearchResult.h"
#import "SearchResultCell.h"
#import "FeedItem.h"
#import "Handshake-Swift.h"
#import "UserViewController.h"

@interface RequestsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSFetchedResultsController *suggestionsController;

@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) OutlineButton *searchBar;

@end

@implementation RequestsViewController

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

- (OutlineButton *)searchBar {
    if (!_searchBar) {
        _searchBar = [[OutlineButton alloc] initWithFrame:CGRectMake(0, 6, self.view.frame.size.width, 30)];
        _searchBar.bgColor = [UIColor colorWithWhite:0 alpha:0.2];
        _searchBar.borderColor = [UIColor clearColor];
        _searchBar.bgColorHighlighted = [UIColor colorWithWhite:0 alpha:0.3];
        _searchBar.borderColorHighlighted = [UIColor clearColor];
        _searchBar.layer.cornerRadius = 6;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_searchBar addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
        
        [_searchBar addSubview:self.placeholder];
    }
    return _searchBar;
}

- (void)search {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.searchBar;
    
    [self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // delete all accepted/deleted requests
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(accepted == %@ OR removed == %@) AND requestId == nil", @(YES), @(YES)];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:nil];
    }];
    
    if (results) {
        for (Request *r in results) {
            [r.managedObjectContext deleteObject:r];
        }
    }
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Request"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"user.userId != %@", [[HandshakeSession currentSession] account].userId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [self.fetchController.managedObjectContext performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
    
    request = [[NSFetchRequest alloc] initWithEntityName:@"SearchResult"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tag == %@ AND request == nil", @"suggestion"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.mutual" ascending:NO]];
    
    self.suggestionsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.suggestionsController.delegate = self;
    
    [self.suggestionsController.managedObjectContext performBlockAndWait:^{
        [self.suggestionsController performFetch:nil];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    
    if (controller == self.suggestionsController)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [[self.fetchController fetchedObjects] count] == 0) return 1;
    if (section == 0) return [[self.fetchController fetchedObjects] count] + 1;
    
    if (section == 1 && [[self.suggestionsController fetchedObjects] count] == 0) return 0;
    if (section == 1) return [[self.suggestionsController fetchedObjects] count] + 1;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width - 24, view.frame.size.height)];
    
    //label.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
    //label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    //label.textColor = [UIColor colorWithWhite:0.50 alpha:1];
    
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = [UIColor colorWithWhite:0.64 alpha:1];
    
    if (section == 0)
        label.text = @"Pending Approval";
    else
        label.text = @"People You May Know";
    
    [view addSubview:label];
    
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)];
    sep.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    [view addSubview:sep];
    
//    if (section == 0) {
//        sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
//        sep.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
//        [view addSubview:sep];
//    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
//    if (section == 0 && [[self.fetchController fetchedObjects] count] == 0) return 0;
//    if (section == 1 && [[self.suggestionsController fetchedObjects] count] == 0) return 0;
//    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"RequestsHeader"];
    
    if (indexPath.section == 0 && [[self.fetchController fetchedObjects] count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
    
    if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    if (indexPath.section == 0) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        cell.request = [self.fetchController fetchedObjects][indexPath.row - 1];
        return cell;
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"SuggestionsHeader"];
    
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.result = [self.suggestionsController fetchedObjects][indexPath.row - 1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [[self.fetchController fetchedObjects] count] == 0) return 70;
    
    if (indexPath.section == 0 && indexPath.row == 0) return 1;
    
    //if (indexPath.section == 0 && indexPath.row == 0) return 40;
    if (indexPath.section == 1 && indexPath.row == 0) return 60;
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) return;
    if (indexPath.section == 1 && indexPath.row == 0) return;
    
    User *user;
    
    if (indexPath.section == 0)
        user = ((Request *)[self.fetchController fetchedObjects][indexPath.row - 1]).user;
    else if (indexPath.section == 1)
        user = ((SearchResult *)[self.suggestionsController fetchedObjects][indexPath.row - 1]).user;
    
    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)contacts:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"] animated:YES];
}


@end
