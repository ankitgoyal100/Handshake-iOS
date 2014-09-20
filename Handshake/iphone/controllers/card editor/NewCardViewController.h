//
//  AddCardViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/17/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"

typedef void (^DismissBlock)();

@interface NewCardViewController : SectionBasedTableViewController

- (id)initWithDismissBlock:(DismissBlock)dismissBlock;

@end
