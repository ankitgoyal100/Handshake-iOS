//
//  EditableTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EditableTableViewCell.h"

@implementation EditableTableViewCell

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        _deleteButton.contentMode = UIViewContentModeCenter;
    }
    return _deleteButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.deleteButton.frame = CGRectMake(0, 0, 50, self.bounds.size.height);
}

@end
