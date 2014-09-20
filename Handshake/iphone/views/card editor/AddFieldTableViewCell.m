//
//  AddFieldTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddFieldTableViewCell.h"

@interface AddFieldTableViewCell()

@property (nonatomic) UIImageView *addIcon;

@end

@implementation AddFieldTableViewCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor lightGrayColor];
        _label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    }
    return _label;
}

- (UIImageView *)addIcon {
    if (!_addIcon) {
        _addIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _addIcon.contentMode = UIViewContentModeCenter;
        _addIcon.image = [UIImage imageNamed:@"add.png"];
    }
    return _addIcon;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.addIcon];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.addIcon.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
    self.label.frame = CGRectMake(50, 0, self.bounds.size.width - 60, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
