//
//  NamePictureEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NamePictureEditorSection.h"
#import "NamePictureEditorTableViewCell.h"
#import "AsyncImageView.h"

@interface NamePictureEditorSection() <UITextFieldDelegate>

@property (nonatomic, strong) NamePictureEditorTableViewCell *cell;

@property (nonatomic, strong) Card *card;

@end

@implementation NamePictureEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (NamePictureEditorTableViewCell *)cell {
    if (!_cell) {
        _cell = [[NamePictureEditorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        _cell.firstNameField.text = self.card.firstName;
        _cell.firstNameField.delegate = self;
        _cell.lastNameField.text = self.card.lastName;
        _cell.lastNameField.delegate = self;
        
        [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:self.card.picture] target:self action:@selector(imageLoaded:)];
    }
    return _cell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.cell;
}

- (void)imageLoaded:(UIImage *)image {
    [self.cell.pictureButton setImage:image forState:UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.cell.firstNameField) self.card.firstName = text;
    if (textField == self.cell.lastNameField) self.card.lastName = text;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.cell.firstNameField) self.card.firstName = @"";
    if (textField == self.cell.lastNameField) self.card.lastName = @"";
    
    return YES;
}

@end
