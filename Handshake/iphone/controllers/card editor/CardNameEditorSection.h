//
//  CardNameEditorSection.h
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"
#import "Card.h"

@interface CardNameEditorSection : Section

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController;

@end
