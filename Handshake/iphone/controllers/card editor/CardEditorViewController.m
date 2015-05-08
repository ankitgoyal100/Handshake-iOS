//
//  CardEditorViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardEditorViewController.h"
#import "NamePictureEditorSection.h"
#import "PhoneEditorSection.h"
#import "EmailEditorSection.h"
#import "AddressEditorSection.h"
#import "CardNameEditorSection.h"
#import "SocialsEditorSection.h"
#import "DeleteCardSection.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"

@interface CardEditorViewController()

@property (nonatomic, strong) Card *oldCard;
@property (nonatomic, strong) Card *card;

@property (nonatomic, copy) DismissBlock dismissBlock;

@end

@implementation CardEditorViewController

- (id)initWithCard:(Card *)card dismissBlock:(DismissBlock)dismissBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        self.card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        [self.card updateFromCard:card];
        self.oldCard = card;
        
        self.dismissBlock = dismissBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Edit Card";
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    saveButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.sections addObject:[[NamePictureEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[CardNameEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[PhoneEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[EmailEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[AddressEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[SocialsEditorSection alloc] initWithCard:self.card viewController:self]];
    [self.sections addObject:[[DeleteCardSection alloc] initWithDeletedBlock:^{
        // delete and keep old card data
        self.oldCard.syncStatus = [NSNumber numberWithInt:CardDeleted];
        
        // destroy temp card
        [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] deleteObject:self.card];
        
        // save the context
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        [Card sync];
        
        [self.view endEditing:YES];
        if (self.dismissBlock) self.dismissBlock();
    } viewController:self]];
    [self.sections addObject:[[Section alloc] init]];
}

- (void)cancel {
    // destroy temp card
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] deleteObject:self.card];
    
    // save the context
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    [self.view endEditing:YES];
    if (self.dismissBlock) self.dismissBlock();
}

- (void)save {
    
    if (self.card.name.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please name your card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    // clean up new card
    [self.card cleanEmptyFields];
    
    // set old card to new card
    [self.oldCard updateFromCard:self.card];
    // set updated flag
    self.oldCard.syncStatus = [NSNumber numberWithInt:CardUpdated];
    
    // destroy temp card
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] deleteObject:self.card];
    
    // save the context
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    [Card sync];
    
    [self.view endEditing:YES];
    if (self.dismissBlock) self.dismissBlock();
}

@end
