//
//  SearchTableViewCell.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SearchView.h"
#import "Handshake.h"

@implementation SearchView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        [self.cancelButton setTitleColor:LOGO_COLOR forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        self.cancelButton.alpha = 0;
        [self.cancelButton sizeToFit];
        [self addSubview:self.cancelButton];
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width - 20, 31)];
        self.searchField.backgroundColor = [UIColor whiteColor];
        self.searchField.layer.cornerRadius = 15.5;
        self.searchField.layer.masksToBounds = YES;
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
        searchIcon.image = [UIImage imageNamed:@"search.png"];
        searchIcon.contentMode = UIViewContentModeCenter;
        
        self.searchField.leftView = searchIcon;
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
        
        //self.searchField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
        //self.searchField.rightViewMode = UITextFieldViewModeAlways;
        
        self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        self.searchField.font = [UIFont systemFontOfSize:12];
        self.searchField.placeholder = @"Search...";
        [self addSubview:self.searchField];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 50.5, self.bounds.size.width, 0.5)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cancelButton.frame = CGRectMake(self.bounds.size.width - self.cancelButton.frame.size.width - 10, 2, self.cancelButton.frame.size.width, self.bounds.size.height - 2);
    
    [UIView beginAnimations:nil context:nil];
    if (self.searching) {
        self.searchField.frame = CGRectMake(10, 10, self.bounds.size.width - self.cancelButton.frame.size.width - 30, self.bounds.size.height - 20);
        self.cancelButton.alpha = 1;
    } else {
        self.searchField.frame = CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20);
        self.cancelButton.alpha = 0;
    }
    [UIView commitAnimations];
}

- (void)setSearching:(BOOL)searching {
    _searching = searching;
    [self setNeedsLayout];
}

@end
