//
//  BaseTableViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/8/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BaseTableViewController.h"
#import "Handshake.h"
#import "SeparatorTableViewCell.h"
#import "SectionSeparatorTableViewCell.h"
#import "LoadingTableViewCell.h"

@interface BaseTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) LoadingTableViewCell *loadingCell;

@end

@implementation BaseTableViewController

- (LoadingTableViewCell *)loadingCell {
    if (!_loadingCell) {
        _loadingCell = [[LoadingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    return _loadingCell;
}

- (void)setEndCell:(BaseTableViewCell *)endCell {
    _endCell = endCell;
    [self.tableView reloadData];
}

- (void)setMessageCell:(MessageTableViewCell *)messageCell {
    _messageCell = messageCell;
    [self.tableView reloadData];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = LOGO_COLOR;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    self.view.backgroundColor = SUPER_LIGHT_GRAY;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = SUPER_LIGHT_GRAY;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (int)numberOfSections {
    return 1;
}

- (int)numberOfRowsInSection:(int)section {
    return 0;
}

- (BaseTableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.messageCell || self.loading) return 1;
    
    int rows = 0;
    int sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        int numRows = [self numberOfRowsInSection:i];
        rows += numRows * 2 + 1;
        if (i + 1 < sections)
            rows++;
    }
    
    if (self.endCell)
        rows++;
    
    return rows;
}

- (BaseTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.loading) return self.loadingCell;
    
    if (self.messageCell) return self.messageCell;
    
    if (indexPath.row % 2 == 0) {
        // separator cell
        SeparatorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SeparatorCell"];
        if (!cell) cell = [[SeparatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SeparatorCell"];
        return cell;
    }
    
    int row = (int)indexPath.row / 2;
    int sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (row < 0)
            break;
        
        int rows = [self numberOfRowsInSection:i];
        if (row < rows) {
            return [self cellAtRow:row section:i indexPath:indexPath tableView:tableView];
        } else if (row == rows && i + 1 != sections) {
            // section separator cell
            SectionSeparatorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SectionSeparatorCell"];
            if (!cell) cell = [[SectionSeparatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SectionSeparatorCell"];
            return cell;
        }
        row -= rows + 1;
    }
    
    return self.endCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messageCell) return 100;
    
    // if empty section return 0
    int row = (int)indexPath.row;
    int sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (row < 0)
            break;
        
        int rows = [self numberOfRowsInSection:i];
        
        if (row == rows && rows == 0) return 0;
        
        row -= rows * 2 + 2;
    }
    
    return [(BaseTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] preferredHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messageCell || self.loading) return;
    
    if (indexPath.row % 2 == 0)
        return;
    
    int row = (int)indexPath.row / 2;
    int sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (row < 0)
            break;
        
        int rows = [self numberOfRowsInSection:i];
        if (row < rows) {
            [self cellWasSelectedAtRow:row section:i indexPath:indexPath tableView:tableView];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        row -= rows + 1;
    }
}

- (BaseTableViewCell *)cellAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    return nil;
}

- (void)cellWasSelectedAtRow:(int)row section:(int)section indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets content = self.tableView.contentInset;
    UIEdgeInsets scrollBar = self.tableView.scrollIndicatorInsets;
    content.bottom = scrollBar.bottom = MAX(self.view.frame.size.height - keyboardRect.origin.y, self.tabBarController.tabBar.frame.size.height);
    self.tableView.contentInset = content;
    self.tableView.scrollIndicatorInsets = scrollBar;
}

- (NSIndexPath *)indexPathForCell:(BaseTableViewCell *)cell {
    NSIndexPath *realPath = [self.tableView indexPathForCell:cell];
    
    if (self.messageCell || self.loading) return nil;
    
    if (realPath.row % 2 == 0)
        return nil;
    
    int row = (int)realPath.row / 2;
    int sections = [self numberOfSections];
    for (int i = 0; i < sections; i++) {
        if (row < 0)
            break;
        
        int rows = [self numberOfRowsInSection:i];
        if (row < rows) {
            return [NSIndexPath indexPathForRow:row inSection:i];
        }
        row -= rows + 1;
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForRow:(int)row section:(int)section {
    int realRow = row * 2 + 1;
    
    for (int i = 0; i < section; i++) realRow += 2 * [self numberOfRowsInSection:section] + 1;
    
    return [NSIndexPath indexPathForRow:realRow inSection:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self scrolled:scrollView];
}

- (void)scrolled:(UIScrollView *)scrollView {
    
}

- (BaseTableViewCell *)cellForRow:(int)row section:(int)section {
    int realRow = row * 2 + 1;
    
    for (int i = 0; i < section; i++) realRow += 2 * [self numberOfRowsInSection:section] + 1;
    
    return (BaseTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:realRow inSection:0]];
}

- (void)insertRowAtRow:(int)row section:(int)section {
    [self insertRowAtRow:row section:section animation:UITableViewRowAnimationFade];
}

- (void)removeRowAtRow:(int)row section:(int)section {
    [self removeRowAtRow:row section:section animation:UITableViewRowAnimationFade];
}

- (void)insertRowAtRow:(int)row section:(int)section animation:(UITableViewRowAnimation)animation {
    int realRow = row * 2 + 1;
    
    for (int i = 0; i < section; i++) realRow += 2 * [self numberOfRowsInSection:section] + 1;
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:realRow inSection:0], [NSIndexPath indexPathForRow:realRow + 1 inSection:0]] withRowAnimation:animation];
}

- (void)removeRowAtRow:(int)row section:(int)section animation:(UITableViewRowAnimation)animation {
    int realRow = row * 2 + 1;
    
    for (int i = 0; i < section; i++) realRow += 2 * [self numberOfRowsInSection:section] + 1;
    
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:realRow inSection:0], [NSIndexPath indexPathForRow:realRow + 1 inSection:0]] withRowAnimation:animation];
}

- (void)moveCellAtRow:(int)row toRow:(int)toRow section:(int)section {
    [self.tableView beginUpdates];
    
    NSIndexPath *path = [self indexPathForRow:row section:section];
    NSIndexPath *toPath = [self indexPathForRow:toRow section:section];
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:path.row - 1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toPath.row - 1 inSection:0]];
    [self.tableView moveRowAtIndexPath:path toIndexPath:toPath];
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:path.row + 1 inSection:0] toIndexPath:[NSIndexPath indexPathForRow:toPath.row + 1 inSection:0]];
    
    if (toRow < row) {
        for (int i = toRow; i < row; i++)
            [self.tableView moveRowAtIndexPath:[self indexPathForRow:i section:section] toIndexPath:[self indexPathForRow:i + 1 section:section]];
    } else {
        for (int i = row; i < toRow; i++)
            [self.tableView moveRowAtIndexPath:[self indexPathForRow:i + 1 section:section] toIndexPath:[self indexPathForRow:i section:section]];
    }
    
    [self.tableView endUpdates];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
