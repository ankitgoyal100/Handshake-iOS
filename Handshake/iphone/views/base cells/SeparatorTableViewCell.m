//
//  SeparatorTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SeparatorTableViewCell.h"

@implementation SeparatorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (float)preferredHeight {
    return 0.5;
}

@end
