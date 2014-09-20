//
//  CardViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardViewController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "CardHeaderSection.h"
#import "CardNameSection.h"
#import "BasicInfoSection.h"
#import "CardSocialSection.h"
#import "CardEditorViewController.h"
#import "Handshake.h"
#import <CoreData/CoreData.h>
#import "HandshakeCoreDataStore.h"

@interface CardViewController()

@property (nonatomic, strong) Card *card;

@end

@implementation CardViewController

- (id)initWithCard:(Card *)card {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.card = card;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Card";
    
    [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    editButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = editButton;
    
    [self reloadView];
}

- (void)reloadView {
    if ([self.card.syncStatus intValue] == CardDeleted) [self.navigationController popViewControllerAnimated:NO];
    
    [self.sections removeAllObjects];
    
    [self.sections addObject:[[CardHeaderSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[CardNameSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[BasicInfoSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[CardSocialSection alloc] initWithCard:self.card viewController:self]];
    
    [self.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)edit {
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[[CardEditorViewController alloc] initWithCard:self.card dismissBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self reloadView];
    }]];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
