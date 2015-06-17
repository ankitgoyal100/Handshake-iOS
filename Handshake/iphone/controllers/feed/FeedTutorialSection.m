//
//  FeedTutorialSection.m
//  Handshake
//
//  Created by Sam Ober on 6/16/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "FeedTutorialSection.h"

@interface FeedTutorialSection()

@property (nonatomic, strong) NSAttributedString *tutorialString;

@end

@implementation FeedTutorialSection

- (NSAttributedString *)tutorialString {
    if (!_tutorialString) {
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        [pStyle setLineSpacing:2];
        
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
        _tutorialString = [[NSAttributedString alloc] initWithString:@"See your latest contacts and updates here. Get started by finding your friends!" attributes:attrs];
    }
    return _tutorialString;
}

- (NSInteger)numberOfRows {
    return 1;
}

- (UITableViewCell *)cellAtIndex:(NSInteger)index inTableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:@"FeedTutorialCell"];
}

- (CGFloat)heightForCellAtIndex:(NSInteger)index {
    CGRect frame = [self.tutorialString boundingRectWithSize:CGSizeMake(self.viewController.view.frame.size.width - 48, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return frame.size.height + 48 + 36 + 30;
}

@end
