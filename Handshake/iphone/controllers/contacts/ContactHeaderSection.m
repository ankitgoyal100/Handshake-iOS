//
//  ContactHeaderSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactHeaderSection.h"
#import "ContactHeaderTableViewCell.h"

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
    if ([self.contact.card.picture length])
        self.headerCell.pictureView.imageURL = [NSURL URLWithString:self.contact.card.picture];
    else
        self.headerCell.pictureView.image = [UIImage imageNamed:@"default_picture.png"];
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

@end
