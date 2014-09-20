//
//  PhoneEditTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "PhoneEditTableViewCell.h"
#import "Handshake.h"

@implementation PhoneEditTableViewCell

- (UITextField *)numberField {
    if (!_numberField) {
        _numberField = [[UITextField alloc] initWithFrame:CGRectZero];
        _numberField.backgroundColor = [UIColor clearColor];
        _numberField.textColor = [UIColor blackColor];
        _numberField.font = [UIFont systemFontOfSize:15];
        _numberField.keyboardType = UIKeyboardTypePhonePad;
        _numberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _numberField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.numberField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.numberField.frame = CGRectMake(107, 0, self.bounds.size.width - 117, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
