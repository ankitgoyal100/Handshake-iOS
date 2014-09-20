//
//  PhoneTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "PhoneTableViewCell.h"

@implementation PhoneTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *phoneIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 37)];
        phoneIcon.image = [UIImage imageNamed:@"phone.png"];
        phoneIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:phoneIcon];
        
        self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.phoneLabel.backgroundColor = [UIColor clearColor];
        self.phoneLabel.textColor = [UIColor blackColor];
        self.phoneLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.phoneLabel];
        
        self.labelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.labelLabel.backgroundColor = [UIColor clearColor];
        self.labelLabel.textColor = [UIColor lightGrayColor];
        self.labelLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:self.labelLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.phoneLabel.frame = CGRectMake(50, 10, self.bounds.size.width - 60, 18);
    self.labelLabel.frame = CGRectMake(50, 33, self.bounds.size.width - 60, 14);
}

- (float)preferredHeight {
    return 57;
}

@end
