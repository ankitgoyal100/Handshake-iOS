//
//  CardNameTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardNameTableViewCell.h"

@implementation CardNameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *nameIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 30, 37)];
        nameIcon.image = [UIImage imageNamed:@"card_name.png"];
        nameIcon.contentMode = UIViewContentModeCenter;
        [self addSubview:nameIcon];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(50, 0, self.bounds.size.width - 60, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
