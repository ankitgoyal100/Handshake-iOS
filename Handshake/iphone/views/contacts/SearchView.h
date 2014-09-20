//
//  SearchTableViewCell.h
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView

@property (nonatomic) UITextField *searchField;
@property (nonatomic) UIButton *cancelButton;

@property (nonatomic) BOOL searching;

@end
