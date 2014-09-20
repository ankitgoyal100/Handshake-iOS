//
//  UINavigationItem+Additions.h
//  Handshake
//
//  Created by Sam Ober on 2/5/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationItem (Additions)

- (void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem;
- (void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem;

@end
