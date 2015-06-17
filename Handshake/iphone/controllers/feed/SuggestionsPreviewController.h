//
//  FeedSuggestionsSection.h
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Suggestion.h"

@class SuggestionsPreviewController;

@protocol SuggestionsPreviewControllerDelegate <NSObject>

@optional

- (void)suggestionsControllerDidUpdate:(SuggestionsPreviewController *)controller;
- (void)showSuggestions;

@end

@interface SuggestionsPreviewController : NSObject

- (id)initWithShowCount:(int)showCount;

- (NSInteger)numberOfRows;

- (UITableViewCell *)cellAtIndex:(NSInteger)index tableView:(UITableView *)tableView;
- (CGFloat)heightForRowAtIndex:(NSInteger)index;

- (void)cellWasSelectedAtIndex:(NSInteger)index handler:(void (^)(Suggestion *suggestion))handler;

@property (nonatomic, strong) id <SuggestionsPreviewControllerDelegate> delegate;

@end
