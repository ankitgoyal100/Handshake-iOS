//
//  DeleteContactSection.h
//  Handshake
//
//  Created by Sam Ober on 9/19/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "Section.h"

typedef void (^ContactDeletedBlock)();

@interface DeleteContactSection : Section

- (id)initWithContactDeletedBlock:(ContactDeletedBlock)contactDeletedBlock viewController:(SectionBasedTableViewController *)viewController;

@end
