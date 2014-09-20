//
//  ContactViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "SectionBasedTableViewController.h"
#import "Contact.h"

@interface ContactViewController : SectionBasedTableViewController

- (id)initWithContact:(Contact *)contact;

@end
