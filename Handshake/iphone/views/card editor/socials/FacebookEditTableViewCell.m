//
//  FacebookEditTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "FacebookEditTableViewCell.h"

@interface FacebookEditTableViewCell()

@property (nonatomic) UIImageView *facebookIcon;

@end

@implementation FacebookEditTableViewCell

- (UIImageView *)facebookIcon {
    if (!_facebookIcon) {
        _facebookIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _facebookIcon.contentMode = UIViewContentModeCenter;
        _facebookIcon.image = [UIImage imageNamed:@"facebook.png"];
    }
    return _facebookIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _nameLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.facebookIcon];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.facebookIcon.frame = CGRectMake(50, 0, 27, self.bounds.size.height);
    self.nameLabel.frame = CGRectMake(88, 0, self.bounds.size.width - 98, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
