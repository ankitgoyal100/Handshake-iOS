//
//  DeleteCardSection.h
//  Handshake
//
//  Created by Sam Ober on 9/14/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"

typedef void (^CardDeletedSuccessBlock)();

@interface DeleteCardSection : Section

- (id)initWithDeletedBlock:(CardDeletedSuccessBlock)cardDeleted viewController:(SectionBasedTableViewController *)viewController;

@end
