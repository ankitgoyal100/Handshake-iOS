//
//  CardHeaderSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardHeaderSection.h"
#import "CardHeaderTableViewCell.h"

@interface CardHeaderSection()

@property (nonatomic, strong) CardHeaderTableViewCell *headerCell;

@property (nonatomic, strong) Card *card;

@end

@implementation CardHeaderSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (CardHeaderTableViewCell *)headerCell {
    if (!_headerCell) {
        _headerCell = [[CardHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _headerCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if ([self.card.picture length])
        self.headerCell.pictureView.imageURL = [NSURL URLWithString:self.card.picture];
    else
        self.headerCell.pictureView.image = [UIImage imageNamed:@"default_picture.png"];
    self.headerCell.nameLabel.text = [self.card formattedName];
    
    return self.headerCell;
}

@end
