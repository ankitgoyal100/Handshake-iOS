//
//  CardNameSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardNameSection.h"
#import "CardNameTableViewCell.h"

@interface CardNameSection()

@property (nonatomic, strong) CardNameTableViewCell *nameCell;

@property (nonatomic, strong) Card *card;

@end

@implementation CardNameSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (CardNameTableViewCell *)nameCell {
    if (!_nameCell) {
        _nameCell = [[CardNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _nameCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    self.nameCell.nameLabel.text = self.card.name;
    
    return self.nameCell;
}

@end
