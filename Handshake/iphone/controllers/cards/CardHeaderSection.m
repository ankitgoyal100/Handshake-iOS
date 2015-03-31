//
//  CardHeaderSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardHeaderSection.h"
#import "CardHeaderTableViewCell.h"
#import "ImageViewController.h"

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
    if (self.card.pictureData) {
        [self.headerCell.pictureButton setImage:[UIImage imageWithData:self.card.pictureData] forState:UIControlStateNormal];
        [self.headerCell.pictureButton addTarget:self action:@selector(viewPicture) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self.card.picture length]) {
        [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:self.card.picture] target:self action:@selector(imageLoaded:)];
    } else {
        [self.headerCell.pictureButton setImage:[UIImage imageNamed:@"default_picture.png"] forState:UIControlStateNormal];
        [self.headerCell.pictureButton removeTarget:self action:@selector(viewPicture) forControlEvents:UIControlEventTouchUpInside];
    }
    self.headerCell.nameLabel.text = [self.card formattedName];
    
    return self.headerCell;
}

- (void)imageLoaded:(UIImage *)image {
    [self.headerCell.pictureButton setImage:image forState:UIControlStateNormal];
    [self.headerCell.pictureButton addTarget:self action:@selector(viewPicture) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewPicture {
    ImageViewController *controller = [[ImageViewController alloc] initWithImage:[self.headerCell.pictureButton imageForState:UIControlStateNormal]];
    [self.viewController presentViewController:controller animated:YES completion:nil];
}

@end
