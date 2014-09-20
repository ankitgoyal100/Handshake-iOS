//
//  AddTwitterSection.m
//  Handshake
//
//  Created by Sam Ober on 9/13/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "AddTwitterSection.h"
#import "AddSocialTableViewCell.h"
#import "NewTwitterViewController.h"
#import "TwitterTableViewCell.h"
#import "Social.h"

@interface AddTwitterSection()

@property (nonatomic, strong) Card *card;

@property (nonatomic, strong) AddSocialTableViewCell *addTwitterCell;

@property (nonatomic, copy) AddTwitterSuccessBlock successBlock;

@end

@implementation AddTwitterSection

- (AddSocialTableViewCell *)addTwitterCell {
    if (!_addTwitterCell) {
        _addTwitterCell = [[AddSocialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _addTwitterCell.iconView.image = [UIImage imageNamed:@"twitter.png"];
        _addTwitterCell.label.text = @"ADD TWITTER";
    }
    return _addTwitterCell;
}

- (id)initWithCard:(Card *)card successBlock:(AddTwitterSuccessBlock)successBlock viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
        self.successBlock = successBlock;
    }
    return self;
}

- (int)rows {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return (int)[[defaults objectForKey:@"recent_twitters"] count] + 1;
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *twitters = [defaults objectForKey:@"recent_twitters"];
    
    if (row == [twitters count]) return self.addTwitterCell;
    
    TwitterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
    
    if (!cell) cell = [[TwitterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwitterCell"];
    
    cell.username = twitters[row];
    cell.showsFollowButton = NO;
    
    return cell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *twitters = [defaults objectForKey:@"recent_twitters"];
    
    if (row == [twitters count]) {
        NewTwitterViewController *controller = [[NewTwitterViewController alloc] initWithCard:self.card successBlock:^{
            self.successBlock();
        }];
        [self.viewController.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
    social.username = twitters[row];
    social.network = @"twitter";
    [self.card addSocialsObject:social];
    
    self.successBlock();
}

@end
