//
//  AddTwitterSection.h
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"
#import "Card.h"

typedef void (^AddTwitterSuccessBlock)();

@interface AddTwitterSection : Section

- (id)initWithCard:(Card *)card successBlock:(AddTwitterSuccessBlock)successBlock viewController:(SectionBasedTableViewController *)viewController;

@end
