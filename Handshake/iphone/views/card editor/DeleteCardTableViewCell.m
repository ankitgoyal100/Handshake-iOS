//
//  DeleteCardTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/14/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "DeleteCardTableViewCell.h"
#import "Handshake.h"

@interface DeleteCardTableViewCell()

@end

@implementation DeleteCardTableViewCell

- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deleteLabel.backgroundColor = [UIColor clearColor];
        _deleteLabel.textColor = RED;
        _deleteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        _deleteLabel.textAlignment = NSTextAlignmentCenter;
        _deleteLabel.alpha = 0.8;
        _deleteLabel.text = @"DELETE CARD";
    }
    return _deleteLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.deleteLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.deleteLabel.frame = self.bounds;
}

- (float)preferredHeight {
    return 50;
}

@end
