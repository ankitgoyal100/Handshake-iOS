//
//  CardsViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardsViewController.h"
#import "CardTableViewCell.h"
#import "CardViewController.h"
#import "Handshake.h"
#import "MessageTableViewCell.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Card.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"
#import "NewCardViewController.h"
#import "HandshakeSession.h"
#import "UIControl+Blocks.h"
#import "CreateCardTutorialTableViewCell.h"

@interface CardsViewController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) CreateCardTutorialTableViewCell *tutorialCell;

@end

@implementation CardsViewController

- (CreateCardTutorialTableViewCell *)tutorialCell {
    if (!_tutorialCell) {
        _tutorialCell = [[CreateCardTutorialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _tutorialCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Cards";
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new.png"] style:UIBarButtonItemStylePlain target:self action:@selector(new)];
    newButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = newButton;
    
    [self updateEndCell];
    
    // fetch cards
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
    
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"cardOrder" ascending:YES]];
    
    // personal cards are children of a user
    request.predicate = [NSPredicate predicateWithFormat:@"user!=nil AND syncStatus!=%@", [NSNumber numberWithInt:CardDeleted]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:CardSyncCompleted object:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }];
}

- (void)updateEndCell {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
    request.predicate = [NSPredicate predicateWithFormat:@"user!=nil AND syncStatus!=%@", [NSNumber numberWithInt:CardDeleted]];
    
    __block NSArray *results;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        results = [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] executeFetchRequest:request error:&error];
    }];
    
    if (results && [results count] > 0) {
        if (self.endCell) self.endCell = nil;
    } else {
        if (!self.endCell) self.endCell = self.tutorialCell;
    }
}

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
            CardTableViewCell *cell = (CardTableViewCell *)[self cellForRow:(int)newIndexPath.row section:(int)newIndexPath.section];
            [self configureCell:cell row:(int)newIndexPath.row section:(int)newIndexPath.section indexPath:[self indexPathForCell:cell]];
            break;
        }
        case NSFetchedResultsChangeMove: {
            break;
        }
    }
}

- (void)update:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (int)numberOfSections {
    return (int)[[self.fetchedResultsController sections] count];
}

- (int)numberOfRowsInSection:(int)section {
    //return (int)[[HandshakeSession user].cards count];
    
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return (int)[sectionInfo numberOfObjects];
}

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    CardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardCell"];
    
    if (!cell) cell = [[CardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardCell"];
    
    [self configureCell:cell row:row section:section indexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(CardTableViewCell *)cell row:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath {
    Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
//    if (card.pictureData)
//        cell.pictureView.image = [UIImage imageWithData:card.pictureData];
//    else if ([card.picture length])
//        cell.pictureView.imageURL = [NSURL URLWithString:card.picture];
//    else
//        cell.pictureView.image = [UIImage imageNamed:@"default_picture.png"];
//    cell.nameLabel.text = [card formattedName];
//    cell.cardNameLabel.text = card.name;
//    
//    if ([card.cardOrder intValue] == 0) [cell.checkButton setImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
//    else [cell.checkButton setImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    
    __weak typeof(cell) weakCell = cell;
    
    [cell.checkButton addEventHandler:^(id sender) {
        //Account *account = [[HandshakeSession currentSession] account];
        
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        int oldRow = (int)[self indexPathForCell:weakCell].row;
        [self.tableView reloadData];
        [self moveCellAtRow:oldRow toRow:0 section:section];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    Card *card = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    CardViewController *controller = [[CardViewController alloc] initWithCard:card];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)new {
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[NewCardViewController alloc] initWithDismissBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.tableView reloadData];
    }]];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
