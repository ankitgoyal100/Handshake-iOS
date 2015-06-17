//
//  FeedViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/1/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedViewController.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "HandshakeClient.h"
#import "FeedItemCell.h"
#import "FeedItem.h"
#import "User.h"
#import "Group.h"
#import "UserViewController.h"
#import "GroupViewController.h"
#import "Handshake-Swift.h"
#import "ContactsViewController.h"
#import "Suggestion.h"
#import "SearchResultCell.h"
#import "FeedItemServerSync.h"
#import "FeedSection.h"
#import "FeedTutorialSection.h"
#import "FeedItemSection.h"
#import "SuggestionsPreviewController.h"
#import "SuggestionsServerSync.h"

@interface FeedViewController () <NSFetchedResultsControllerDelegate, SuggestionsPreviewControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) OutlineButton *searchBar;

@property (nonatomic, strong) SuggestionsPreviewController *suggestionsController;

@property (nonatomic, strong) NSAttributedString *tutorialString;

@end

@implementation FeedViewController

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

- (NSAttributedString *)tutorialString {
    if (!_tutorialString) {
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        [pStyle setLineSpacing:2];
        
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
        _tutorialString = [[NSAttributedString alloc] initWithString:@"See your latest contacts and updates here. Get started by finding your friends!" attributes:attrs];
    }
    return _tutorialString;
}

- (void)search {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.searchBar;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    //[FeedItem sync];
    [self fetch];
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
    
    // setup suggestions controller
    if ([[self.fetchController fetchedObjects] count] == 0)
        self.suggestionsController = [[SuggestionsPreviewController alloc] initWithShowCount:8];
    else
        self.suggestionsController = [[SuggestionsPreviewController alloc] initWithShowCount:3];
    self.suggestionsController.delegate = self;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    [self.tableView reloadData];
}

- (void)suggestionsControllerDidUpdate:(SuggestionsPreviewController *)controller {
    // reload suggestions section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showSuggestions {
    [self suggestions:nil];
}

- (void)refresh {
    [FeedItemServerSync syncWithCompletionBlock:^{
        [self.refreshControl endRefreshing];
    }];
    [SuggestionsServerSync sync];
}

//- (void)setupSections {
//    NSMutableArray *sections = [[NSMutableArray alloc] init];
//    
//    if ([[self.fetchController fetchedObjects] count] == 0) {
//        // tutorial and suggestions
//        
//        [sections addObject:[[FeedTutorialSection alloc] initWithViewController:self]];
//        
//        if ([[self.suggestionsController fetchedObjects] count] != 0) {
//            NSMutableArray *suggestions = [[NSMutableArray alloc] init];
//            for (int i = 0; i < MIN(8, [[self.suggestionsController fetchedObjects] count]); i++)
//                [suggestions addObject:[self.suggestionsController fetchedObjects][i]];
//            
//            SuggestionsPreviewController *section = [[SuggestionsPreviewController alloc] initWithViewController:self];
//            section.suggestions = suggestions;
//            [sections addObject:section];
//        }
//    } else if ([[self.suggestionsController fetchedObjects] count] == 0) {
//        FeedItemSection *section = [[FeedItemSection alloc] initWithViewController:self];
//        section.feedItems = [self.fetchController fetchedObjects];
//        [sections addObject:section];
//    } else {
//        // 5 feed items, 3 suggestions, rest of feed items
//        NSMutableArray *feedItems = [[self.fetchController fetchedObjects] mutableCopy];
//        
//        NSMutableArray *items = [[NSMutableArray alloc] init];
//        for (int i = 0; i < MIN(5, [[self.fetchController fetchedObjects] count]); i++) {
//            [items addObject:[feedItems objectAtIndex:0]];
//            [feedItems removeObjectAtIndex:0];
//        }
//        
//        FeedItemSection *section1 = [[FeedItemSection alloc] initWithViewController:self];
//        section1.feedItems = items;
//        [sections addObject:section1];
//        
//        NSMutableArray *suggestions = [[NSMutableArray alloc] init];
//        for (int i = 0; i < MIN(3, [[self.suggestionsController fetchedObjects] count]); i++)
//            [suggestions addObject:[self.suggestionsController fetchedObjects][i]];
//        
//        SuggestionsPreviewController *section2 = [[SuggestionsPreviewController alloc] initWithViewController:self];
//        section2.suggestions = suggestions;
//        [sections addObject:section2];
//        
//        // if feed items left over add them
//        if ([feedItems count] != 0) {
//            FeedItemSection *section3 = [[FeedItemSection alloc] initWithViewController:self];
//            section3.feedItems = feedItems;
//            [sections addObject:section3];
//        }
//    }
//    
//    self.sections = sections;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // if no feed items (2 sections - tutorial and suggestions)
    if ([[self.fetchController fetchedObjects] count] == 0) return 2;
    
    // if feed items (3 sections - first 5, suggestions, rest)
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if no feed items
    if ([[self.fetchController fetchedObjects] count] == 0) {
        if (section == 0) return 1; // tutorial cell
        return [self.suggestionsController numberOfRows]; // suggestions
    }
    
    // if feed items - first section is up to 3 (incude separator at top)
    if (section == 0) return MIN(3, [[self.fetchController fetchedObjects] count]) + 1;
    
    // suggestions
    if (section == 1) return [self.suggestionsController numberOfRows];
    
    // if more feed items but no suggestions, rest of feed items (no spacer)
    if ([[self.fetchController fetchedObjects] count] - 3 > 0 && [self.suggestionsController numberOfRows] == 0) return [[self.fetchController fetchedObjects] count] - 3;
    
    // else, add spacer
    if ([[self.fetchController fetchedObjects] count] - 3 > 0) return [[self.fetchController fetchedObjects] count] - 2;
    
    // else no rows
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // if no feed items
    if ([[self.fetchController fetchedObjects] count] == 0) {
        if (indexPath.section == 0) return [tableView dequeueReusableCellWithIdentifier:@"FeedTutorialCell"]; //tutorial cell
        
        return [self.suggestionsController cellAtIndex:indexPath.row tableView:tableView]; // suggestions
    }
    
    // if feed items, first section
    if (indexPath.section == 0) {
        if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"]; // separator
        
        FeedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
        FeedItem *item = [self.fetchController fetchedObjects][indexPath.row - 1];
        [self setupFeedItemCell:cell withItem:item];
        return cell;
    }
    
    // suggestions
    if (indexPath.section == 1) {
        return [self.suggestionsController cellAtIndex:indexPath.row tableView:tableView];
    }
    
    // rest of feed items
    
    // if suggestions add spacer
    NSInteger index = [self.suggestionsController numberOfRows] == 0 ? indexPath.row + 3 : indexPath.row + 2;
    
    // if index is 2 - spacer
    if (index == 2) return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    FeedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
    FeedItem *item = [self.fetchController fetchedObjects][index];
    [self setupFeedItemCell:cell withItem:item];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // no feed items
    if ([[self.fetchController fetchedObjects] count] == 0) {
        if (indexPath.section == 0) {
            // calculate height of tutorial cell
            CGRect frame = [self.tutorialString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 48, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
            return frame.size.height + 48 + 36 + 30;
        }
        
        return [self.suggestionsController heightForRowAtIndex:indexPath.row];
    }
    
    // first set of feed items
    if (indexPath.section == 0) {
        // if first row - separator
        if (indexPath.row == 0) return 1;
        
        FeedItem *item = [self.fetchController fetchedObjects][indexPath.row - 1];
        return [self heightForFeedItem:item];
    }
    
    // suggestions
    if (indexPath.section == 1) {
        return [self.suggestionsController heightForRowAtIndex:indexPath.row];
    }
    
    // rest of feed items
    
    // if suggestions add spacer
    NSInteger index = [self.suggestionsController numberOfRows] == 0 ? indexPath.row + 3 : indexPath.row + 2;
    
    // if index is 2 - spacer
    if (index == 2) return 20;
    
    FeedItem *item = [self.fetchController fetchedObjects][index];
    return [self heightForFeedItem:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // no feed items
    if ([[self.fetchController fetchedObjects] count] == 0) {
        if (indexPath.section == 0) return;
        
        [self.suggestionsController cellWasSelectedAtIndex:indexPath.row handler:^(Suggestion *suggestion) {
            if (suggestion) {
                UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
                controller.user = suggestion.user;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }];
        return;
    }
    
    // first section of feed items
    if (indexPath.section == 0) {
        if (indexPath.row == 0) return;
        
        FeedItem *item = [self.fetchController fetchedObjects][indexPath.row - 1];
        if (item.user) {
            UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
            controller.user = item.user;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (item.group) {
            GroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
            controller.group = item.group;
            [self.navigationController pushViewController:controller animated:YES];
        }
        return;
    }
    
    // suggestions
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
    
    // rest of feed items
    
    // if suggestions add spacer
    NSInteger index = [self.suggestionsController numberOfRows] == 0 ? indexPath.row + 3 : indexPath.row + 2;
    
    // if index is 2 - spacer
    if (index == 2) return;
    
    FeedItem *item = [self.fetchController fetchedObjects][index];
    if (item.user) {
        UserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserViewController"];
        controller.user = item.user;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (item.group) {
        GroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupViewController"];
        controller.group = item.group;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)setupFeedItemCell:(FeedItemCell *)cell withItem:(FeedItem *)item {
    if ([item.itemType isEqualToString:@"new_contact"] || [item.itemType isEqualToString:@"card_updated"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.user) return;
    if ([item.itemType isEqualToString:@"group_joined"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.group) return;
    
    cell.pictureView.image = nil;
    if (item.user) {
        if ([item.user cachedThumb])
            cell.pictureView.image = [item.user cachedThumb];
        else if (item.user.thumb)
            cell.pictureView.imageURL = [NSURL URLWithString:item.user.thumb];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    } else {
        Account *account = [[HandshakeSession currentSession] account];
        if ([account cachedThumb])
            cell.pictureView.image = [account cachedThumb];
        else if (account.thumb)
            cell.pictureView.imageURL = [NSURL URLWithString:account.thumb];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
    }
    
    cell.messageLabel.attributedText = [self messageForItem:item];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:item.createdAt];
    
    if (time < 60) {
        if ((int)time == 1)
            cell.dateLabel.text = @"1 second ago";
        else
            cell.dateLabel.text = [NSString stringWithFormat:@"%d seconds ago", (int)time];
    } else {
        time /= 60;
        
        if (time < 60) {
            if ((int)time == 1)
                cell.dateLabel.text = @"1 minute ago";
            else
                cell.dateLabel.text = [NSString stringWithFormat:@"%d minutes ago", (int)time];
        } else {
            time /= 60;
            
            if (time < 24) {
                if ((int)time == 1)
                    cell.dateLabel.text = @"1 hour ago";
                else
                    cell.dateLabel.text = [NSString stringWithFormat:@"%d hours ago", (int)time];
            } else {
                time /= 24;
                
                if (time < 7) {
                    if ((int)time == 1)
                        cell.dateLabel.text = @"1 day ago";
                    else
                        cell.dateLabel.text = [NSString stringWithFormat:@"%d days ago", (int)time];
                } else {
                    time /= 7;
                    
                    if (time < 4.34812) {
                        if ((int)time == 1)
                            cell.dateLabel.text = @"1 week ago";
                        else
                            cell.dateLabel.text = [NSString stringWithFormat:@"%d weeks ago", (int)time];
                    } else {
                        time /= 4.34812;
                        
                        if (time < 12) {
                            if ((int)time == 1)
                                cell.dateLabel.text = @"1 month ago";
                            else
                                cell.dateLabel.text = [NSString stringWithFormat:@"%d months ago", (int)time];
                        } else {
                            time /= 12;
                            
                            if ((int)time == 1)
                                cell.dateLabel.text = @"1 year ago";
                            else
                                cell.dateLabel.text = [NSString stringWithFormat:@"%d years ago", (int)time];
                        }
                    }
                }
            }
        }
    }
}

- (NSAttributedString *)messageForItem:(FeedItem *)item {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setMinimumLineHeight:18];
    
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle };
    NSDictionary *boldAttrs = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle };
    
    if ([item.itemType isEqualToString:@"new_contact"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ added you!", [item.user formattedName]] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"card_updated"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ got new contact information.", [item.user formattedName]] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"group_joined"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"You joined %@.", item.group.name] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:item.group.name]];
        
        return messageString;
    } else if ([item.itemType isEqualToString:@"new_group_member"]) {
        NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ joined %@.", [item.user formattedName], item.group.name] attributes:attrs];
        
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:[item.user formattedName]]];
        [messageString setAttributes:boldAttrs range:[messageString.string rangeOfString:item.group.name]];
        
        return messageString;
    }
    
    return nil;
}

- (CGFloat)heightForFeedItem:(FeedItem *)item {
    NSAttributedString *messageString = [self messageForItem:item];
    
    CGRect frame = [messageString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 80, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return MAX(67, 17 + 19 + frame.size.height + 1);
}

- (IBAction)contacts:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"] animated:YES];
}

- (IBAction)suggestions:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SuggestionsViewController"] animated:YES];
}

@end
