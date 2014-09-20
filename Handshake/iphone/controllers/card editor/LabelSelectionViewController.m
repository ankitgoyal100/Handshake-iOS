//
//  LabelSelectionViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/10/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "LabelSelectionViewController.h"
#import "LabelTableViewCell.h"

@interface LabelSelectionViewController()

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *selectedOption;

@property (nonatomic, copy) SelectedBlock selected;

@end

@implementation LabelSelectionViewController

- (id)initWithOptions:(NSArray *)options selectedOption:(NSString *)option selected:(SelectedBlock)selected {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.options = options;
        self.selectedOption = option;
        self.selected = selected;
        
        self.navigationItem.title = @"Label";
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
        doneButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    return self;
}

- (int)numberOfSections {
    return 1;
}

- (int)numberOfRowsInSection:(int)section {
    return (int)[self.options count];
}

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
    
    if (!cell) cell = [[LabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LabelCell"];
    
    NSString *label = (NSString *)self.options[row];
    cell.label = label;
    
    if ([label isEqualToString:self.selectedOption])
        [cell setSelectedOption:YES];
    else
        [cell setSelectedOption:NO];
    
    return cell;
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSString *label = (NSString *)self.options[row];
    
    self.selected(label);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
