//
//  NewFacebookSection.h
//  Handshake
//
//  Created by Sam Ober on 9/12/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"
#import "Card.h"

typedef void (^AddFacebookSuccess)();

@interface AddFacebookSection : Section

- (id)initWithCard:(Card *)card successBlock:(AddFacebookSuccess)successBlock viewController:(SectionBasedTableViewController *)viewController;

@end
