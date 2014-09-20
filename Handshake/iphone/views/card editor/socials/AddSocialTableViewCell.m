//
//  AddSocialTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddSocialTableViewCell.h"

@implementation AddSocialTableViewCell

- (UIImageView *)addIcon {
    if (!_addIcon) {
        _addIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _addIcon.contentMode = UIViewContentModeCenter;
        _addIcon.image = [UIImage imageNamed:@"add.png"];
    }
    return _addIcon;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeCenter;
    }
    return _iconView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor lightGrayColor];
        _label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    }
    return _label;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.addIcon];
        [self addSubview:self.iconView];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.addIcon.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
    self.iconView.frame = CGRectMake(50, 0, 27, self.bounds.size.height);
    self.label.frame = CGRectMake(88, 0, self.bounds.size.width - 98, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
