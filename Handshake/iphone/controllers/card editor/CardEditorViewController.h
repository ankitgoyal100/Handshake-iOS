//
//  CardEditorViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"
#import "Card.h"

typedef void (^DismissBlock)();

@interface CardEditorViewController : SectionBasedTableViewController

- (id)initWithCard:(Card *)card dismissBlock:(DismissBlock)dismissBlock;

@end
