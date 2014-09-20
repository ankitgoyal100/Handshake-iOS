//
//  ContactHeaderSection.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"
#import "Contact.h"

@interface ContactHeaderSection : Section

- (id)initWithContact:(Contact *)contact viewController:(SectionBasedTableViewController *)viewController;

@end
