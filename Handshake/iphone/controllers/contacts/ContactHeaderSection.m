//
//  ContactHeaderSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactHeaderSection.h"
#import "ContactHeaderTableViewCell.h"
#import "ImageViewController.h"

@interface ContactHeaderSection()

@property (nonatomic, strong) ContactHeaderTableViewCell *headerCell;

@property (nonatomic, strong) Contact *contact;

@end

@implementation ContactHeaderSection

- (id)initWithContact:(Contact *)contact viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.contact = contact;
    }
    return self;
}

- (ContactHeaderTableViewCell *)headerCell {
    if (!_headerCell) {
        _headerCell = [[ContactHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _headerCell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (self.contact.card.pictureData) {
        [self.headerCell.pictureButton setImage:[UIImage imageWithData:self.contact.card.pictureData] forState:UIControlStateNormal];
        [self.headerCell.pictureButton addTarget:self action:@selector(viewPicture) forControlEvents:UIControlEventTouchUpInside];
    } else if ([self.contact.card.picture length]) {
        [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:self.contact.card.picture] target:self action:@selector(imageLoaded:)];
    } else {
        [self.headerCell.pictureButton setImage:[UIImage imageNamed:@"default_picture.png"] forState:UIControlStateNormal];
        [self.headerCell.pictureButton removeTarget:self action:@selector(viewPicture) forControlEvents:UIControlEventTouchUpInside];
    }
    self.headerCell.nameLabel.text = [self.contact.card formattedName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d h:mm a"];
    self.headerCell.timeLabel.text = [[formatter stringFromDate:self.contact.shake.time] lowercaseString];
    
    if (self.contact.shake.location)
        self.headerCell.locationLabel.text = self.contact.shake.location;
    else
        self.headerCell.locationLabel.text = [NSString stringWithFormat:@"%.5f, %.5f", [self.contact.shake.latitude doubleValue], [self.contact.shake.longitude doubleValue]];
    
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
