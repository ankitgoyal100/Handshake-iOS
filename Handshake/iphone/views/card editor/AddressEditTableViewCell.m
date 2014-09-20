//
//  AddressEditTableView.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddressEditTableViewCell.h"

@implementation AddressEditTableViewCell

- (UITextField *)street1Field {
    if (!_street1Field) {
        _street1Field = [[UITextField alloc] initWithFrame:CGRectZero];
        _street1Field.backgroundColor = [UIColor clearColor];
        _street1Field.textColor = [UIColor blackColor];
        _street1Field.font = [UIFont systemFontOfSize:15];
        _street1Field.placeholder = @"Street 1";
        _street1Field.clearButtonMode = UITextFieldViewModeWhileEditing;
        _street1Field.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _street1Field;
}

- (UITextField *)street2Field {
    if (!_street2Field) {
        _street2Field = [[UITextField alloc] initWithFrame:CGRectZero];
        _street2Field.backgroundColor = [UIColor clearColor];
        _street2Field.textColor = [UIColor blackColor];
        _street2Field.font = [UIFont systemFontOfSize:15];
        _street2Field.placeholder = @"Street 2";
        _street2Field.clearButtonMode = UITextFieldViewModeWhileEditing;
        _street2Field.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _street2Field;
}

- (UITextField *)cityField {
    if (!_cityField) {
        _cityField = [[UITextField alloc] initWithFrame:CGRectZero];
        _cityField.backgroundColor = [UIColor clearColor];
        _cityField.textColor = [UIColor blackColor];
        _cityField.font = [UIFont systemFontOfSize:15];
        _cityField.placeholder = @"City";
        _cityField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _cityField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _cityField;
}

- (UITextField *)stateField {
    if (!_stateField) {
        _stateField = [[UITextField alloc] initWithFrame:CGRectZero];
        _stateField.backgroundColor = [UIColor clearColor];
        _stateField.textColor = [UIColor blackColor];
        _stateField.font = [UIFont systemFontOfSize:15];
        _stateField.placeholder = @"State";
        _stateField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _stateField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _stateField;
}

- (UITextField *)zipField {
    if (!_zipField) {
        _zipField = [[UITextField alloc] initWithFrame:CGRectZero];
        _zipField.backgroundColor = [UIColor clearColor];
        _zipField.textColor = [UIColor blackColor];
        _zipField.font = [UIFont systemFontOfSize:15];
        _zipField.placeholder = @"Zip Code";
        _zipField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _zipField.autocorrectionType = UITextAutocorrectionTypeNo;
        _zipField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _zipField;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.street1Field];
        [self addSubview:self.street2Field];
        [self addSubview:self.cityField];
        [self addSubview:self.stateField];
        [self addSubview:self.zipField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.street1Field.frame = CGRectMake(107, 15, self.bounds.size.width - 117, 20);
    self.street2Field.frame = CGRectMake(107, 45, self.bounds.size.width - 117, 20);
    self.cityField.frame = CGRectMake(107, 75, self.bounds.size.width - 117, 20);
    self.stateField.frame = CGRectMake(107, 105, (self.bounds.size.width - 117) / 2 - 10, 20);
    self.zipField.frame = CGRectMake(self.stateField.frame.origin.x + self.stateField.frame.size.width + 10, 105, self.stateField.frame.size.width, 20);
}

- (float)preferredHeight {
    return 140;
}

@end
