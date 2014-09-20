//
//  EmailEditTableViewCEll.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "EmailEditTableViewCell.h"

@implementation EmailEditTableViewCell

- (UITextField *)emailField {
    if (!_emailField) {
        _emailField = [[UITextField alloc] initWithFrame:CGRectZero];
        _emailField.backgroundColor = [UIColor clearColor];
        _emailField.textColor = [UIColor blackColor];
        _emailField.font = [UIFont systemFontOfSize:15];
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _emailField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.emailField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.emailField.frame = CGRectMake(107, 0, self.bounds.size.width - 117, self.bounds.size.height);
}

- (float)preferredHeight {
    return 57;
}

@end
