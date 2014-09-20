//
//  CardNameEditorSection.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardNameEditorSection.h"
#import "CardNameEditTableViewCell.h"

@interface CardNameEditorSection() <UITextFieldDelegate>

@property (nonatomic, strong) CardNameEditTableViewCell *cell;

@property (nonatomic, strong) Card *card;

@end

@implementation CardNameEditorSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (CardNameEditTableViewCell *)cell {
    if (!_cell) {
        _cell = [[CardNameEditTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _cell.cardNameField.text = self.card.name;
        _cell.cardNameField.delegate = self;
    }
    return _cell;
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.cell;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.card.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.card.name = @"";
    
    return YES;
}

@end
