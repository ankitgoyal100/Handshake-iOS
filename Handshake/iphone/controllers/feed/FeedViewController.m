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

@interface FeedViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) OutlineButton *searchBar;

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
    //[FeedItem sync];
    [self.tableView reloadData];
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FeedItem"];
    
    //request.predicate = [NSPredicate predicateWithFormat:@"((itemType ==[c] %@ OR itemType ==[c] %@) AND contact != nil) OR (itemType ==[c] %@ AND contact != nil AND group != nil) OR (itemType ==[c] %@ AND group != nil)", @"new_contact", "card_updated", @"new_group_member", @"group_joined"];
    //request.predicate = [NSPredicate predicateWithFormat:@"itemType == %@", @"new_contact"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.fetchController fetchedObjects] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) return [tableView dequeueReusableCellWithIdentifier:@"FeedTutorialCell"];
    
    if (indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"Separator"];
    
    FeedItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
    
    FeedItem *item = [self.fetchController fetchedObjects][indexPath.row - 1];
    
    if ([item.itemType isEqualToString:@"new_contact"] || [item.itemType isEqualToString:@"card_updated"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.user) return cell;
    if ([item.itemType isEqualToString:@"group_joined"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.group) return cell;
    
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.fetchController fetchedObjects] count] == 0) return 176;
    
    if (indexPath.row == 0) return 1;
    
    FeedItem *item = [self.fetchController fetchedObjects][indexPath.row - 1];
    
    if ([item.itemType isEqualToString:@"new_contact"] || [item.itemType isEqualToString:@"card_updated"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.user) return 0;
    if ([item.itemType isEqualToString:@"group_joined"] || [item.itemType isEqualToString:@"new_group_member"])
        if (!item.group) return 0;
    
    NSAttributedString *messageString = [self messageForItem:item];
    
    //NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    //[paragrahStyle setMinimumLineHeight:20];
    
    //NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName: paragrahStyle };
    CGRect frame = [messageString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 80, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return MAX(67, 17 + 19 + frame.size.height + 1);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
}

- (IBAction)contacts:(id)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"] animated:YES];
}

@end
