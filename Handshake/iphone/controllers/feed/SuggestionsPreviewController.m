//
//  FeedSuggestionsSection.m
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "SuggestionsPreviewController.h"
#import "Suggestion.h"
#import "SearchResultCell.h"
#import "UserViewController.h"
#import "HandshakeCoreDataStore.h"

@interface SuggestionsPreviewController() <NSFetchedResultsControllerDelegate>

@property (nonatomic) int showCount;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation SuggestionsPreviewController

- (id)initWithShowCount:(int)showCount {
    self = [super init];
    if (self) {
        self.showCount = showCount;
        self.showEndSpacer = NO;
        
        [self fetch];
    }
    return self;
}

- (void)fetch {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Suggestion"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"user.isContact == %@ AND user.requestSent == %@ AND user.requestReceived == %@", @(NO), @(NO), @(NO)];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"user.mutual" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"user.createdAt" ascending:NO]];
    request.fetchLimit = self.showCount;
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        [self.fetchController performFetch:nil];
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetch];
    if (self.delegate && [self.delegate respondsToSelector:@selector(suggestionsControllerDidUpdate:)])
        [self.delegate suggestionsControllerDidUpdate:self];
}

- (NSInteger)numberOfRows {
    if ([[self.fetchController fetchedObjects] count] == 0) return 0;
    
    if (self.showEndSpacer) return 3 + [[self.fetchController fetchedObjects] count];
    return 2 + [[self.fetchController fetchedObjects] count];
}

- (UITableViewCell *)cellAtIndex:(NSInteger)index tableView:(UITableView *)tableView {
    if (index == 0) return [tableView dequeueReusableCellWithIdentifier:@"SuggestionsHeader"];
    
    if (index == [[self.fetchController fetchedObjects] count] + 1) return [tableView dequeueReusableCellWithIdentifier:@"SeeAllCell"];
    
    if (index == [[self.fetchController fetchedObjects] count] + 2) return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    Suggestion *suggestion = [self.fetchController fetchedObjects][index - 1];
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    cell.user = suggestion.user;
    return cell;
}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
    if (index == 0) return 50;
    if (index == [[self.fetchController fetchedObjects] count] + 1) return 46;
    if (index == [[self.fetchController fetchedObjects] count] + 2) return 20;
    
    return 57;
}

- (void)cellWasSelectedAtIndex:(NSInteger)index handler:(void (^)(Suggestion *suggestion))handler {
    if (index == 0) return;
    
    if (index == [[self.fetchController fetchedObjects] count] + 2) return;
    
    if (index == [[self.fetchController fetchedObjects] count] + 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(showSuggestions)])
            [self.delegate showSuggestions];
    } else {
        Suggestion *suggestion = [self.fetchController fetchedObjects][index - 1];
        if (handler) handler(suggestion);
    }
}

@end
