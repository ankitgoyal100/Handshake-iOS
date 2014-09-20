//
//  ContactBasicInfoSection.h
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"
#import "Card.h"

@interface BasicInfoSection : Section

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController;

@end
