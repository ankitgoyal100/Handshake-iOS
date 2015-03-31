//
//  CardHeaderTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardHeaderTableViewCell.h"

@implementation CardHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.pictureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        self.pictureButton.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        self.pictureButton.layer.cornerRadius = 40;
        self.pictureButton.layer.masksToBounds = YES;
        self.pictureButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.pictureButton.layer.borderWidth = 1;
        [self addSubview:self.pictureButton];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(100, 0, self.bounds.size.width - 110, self.bounds.size.height);
}

- (float)preferredHeight {
    return 100;
}

@end
