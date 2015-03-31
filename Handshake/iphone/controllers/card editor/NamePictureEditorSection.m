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
#import "GKImagePicker.h"

@interface NamePictureEditorSection() <UITextFieldDelegate, GKImagePickerDelegate>

@property (nonatomic, strong) NamePictureEditorTableViewCell *cell;

@property (nonatomic, strong) Card *card;

@property (nonatomic, strong) GKImagePicker *imagePicker;

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
        
        [_cell.pictureButton addTarget:self action:@selector(updateImage) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.card.pictureData)
            [self.cell setPicture:[UIImage imageWithData:self.card.pictureData]];
        else if (self.card.picture)
            [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:self.card.picture] target:self action:@selector(imageLoaded:)];
        else {
            [self.cell setPicture:[UIImage imageNamed:@"add_picture.png"]];
            self.cell.showsEditMask = NO;
        }
    }
    return _cell;
}

- (GKImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[GKImagePicker alloc] init];
        _imagePicker.cropSize = CGSizeMake(200, 200);
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (void)updateImage {
//    self.card.picture = nil;
//    self.card.pictureData = UIImageJPEGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://lh6.googleusercontent.com/-kRb3j_cLwRM/AAAAAAAAAAI/AAAAAAAAACs/QyUFHYE39lk/s180-c-k-no/photo.jpg"]]], 1);
//    [self.cell.pictureButton setImage:[UIImage imageWithData:self.card.pictureData] forState:UIControlStateNormal];
    
    [self.imagePicker showActionSheetOnViewController:self.viewController onPopoverFromView:nil];
}

- (int)rows {
    return 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return self.cell;
}

- (void)imageLoaded:(UIImage *)image {
    [self.cell setPicture:image];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)text);
    
    if (textField == self.cell.firstNameField) self.card.firstName = text;
    if (textField == self.cell.lastNameField) self.card.lastName = text;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.cell.firstNameField) self.card.firstName = @"";
    if (textField == self.cell.lastNameField) self.card.lastName = @"";
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.cell.firstNameField) [self.cell.lastNameField becomeFirstResponder];
    
    return NO;
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image {
    self.card.picture = nil;
    self.card.pictureData = UIImageJPEGRepresentation(image, 1);
    [self.cell setPicture:image];
    self.cell.showsEditMask = YES;
}

- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
