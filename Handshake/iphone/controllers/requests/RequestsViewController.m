//
//  RequestsViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/9/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "RequestsViewController.h"
#import "UserRequestCell.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "User.h"
#import "UIControl+Blocks.h"
#import "SearchResultCell.h"
#import "FeedItem.h"
#import "Handshake-Swift.h"
#import "UserViewController.h"
#import "RequestServerSync.h"
#import "Suggestion.h"
#import "SuggestionsPreviewController.h"

@interface RequestsViewController () <NSFetchedResultsControllerDelegate, SuggestionsPreviewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) OutlineButton *searchBar;

@property (nonatomic, strong) NSArray *requests;

@property (nonatomic, strong) NSAttributedString *tutorialString;

@property (nonatomic, strong) SuggestionsPreviewController *suggestionsController;

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
        [_searchBar addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
        
        [_searchBar addSubview:self.placeholder];
    }
    return _searchBar;
}

- (NSAttributedString *)tutorialString {
    if (!_tutorialString) {
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        [pStyle setLineSpacing:2];
        
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
        _tutorialString = [[NSAttributedString alloc] initWithString:@"No pending requests. Find people you know and add them!" attributes:attrs];
    }
    return _tutorialString;
}

- (NSArray *)requests {
    if (!_requests) _requests = [[NSArray alloc] init];
    return _requests;
}

- (IBAction)search:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.searchBar;
    
    self.suggestionsController = [[SuggestionsPreviewController alloc] initWithShowCount:8];
    self.suggestionsController.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetch];
    self.requests = [self.fetchController fetchedObjects];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"requestReceived = %@", @(YES)];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [self.fetchController.managedObjectContext performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
}

- (void)refresh {
    [RequestServerSync syncWithCompletionBlock:^{
        self.requests = [self.fetchController fetchedObjects];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
}

- (void)suggestionsControllerDidUpdate:(SuggestionsPreviewController *)controller {
    // reload section 1
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showSuggestions {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SuggestionsViewController"] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [self.requests count] == 0) return 1;
    if (section == 0) return [self.requests count] + 1;
    
    if (section == 1) return [self.suggestionsController numberOfRows];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"RequestsHeader"];
    
    if (indexPath.section == 0 && [self.requests count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"RequestsTutorialCell"];
    
    if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    if (indexPath.section == 0) {
        UserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserRequestCell"];
        cell.user = self.requests[indexPath.row - 1];
        return cell;
    }
    
    // suggestions
    return [self.suggestionsController cellAtIndex:indexPath.row tableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.requests count] == 0) {
        CGRect frame = [self.tutorialString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 48, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        return frame.size.height + 48 + 36 + 30;
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) return 1;
    
    if (indexPath.section == 1) return [self.suggestionsController heightForRowAtIndex:indexPath.row];
    
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) return;
    
    if (indexPath.section == 1) {
        [self.suggestionsController cellWasSelectedAtIndex:indexPath.row handler:^(Suggestion *suggestion) {
            if (suggestion) {
                UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
                controller.user = suggestion.user;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }];
        return;
    }
    
    UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
    controller.user = self.requests[indexPath.row - 1];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)contacts:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"] animated:YES];
}


@end
