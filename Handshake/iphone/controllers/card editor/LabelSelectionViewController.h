//
//  LabelSelectionViewController.h
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewController.h"

typedef void (^SelectedBlock)(NSString *);

@interface LabelSelectionViewController : BaseTableViewController

- (id)initWithOptions:(NSArray *)options selectedOption:(NSString *)option selected:(SelectedBlock)selected;

@end