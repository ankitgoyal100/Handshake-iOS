//
//  AddCardViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/17/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "NewCardViewController.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"
#import "NamePictureEditorSection.h"
#import "CardNameEditorSection.h"
#import "PhoneEditorSection.h"
#import "EmailEditorSection.h"
#import "AddressEditorSection.h"
#import "SocialsEditorSection.h"
#import "HandshakeSession.h"

@interface NewCardViewController ()

@property (nonatomic, strong) Card *card;

@property (nonatomic, copy) DismissBlock dismissBlock;

@end

@implementation NewCardViewController

- (id)initWithDismissBlock:(DismissBlock)dismissBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        self.card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext]];
        
        self.dismissBlock = dismissBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Card";
    
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
    if (self.card.firstName.length == 0 && self.card.lastName.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must add your name to the card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (self.card.name.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please name your card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    // clean up new card
    [self.card cleanEmptyFields];
    
    // set created flag
    self.card.syncStatus = [NSNumber numberWithInt:CardCreated];
    
    // set card order
    self.card.cardOrder = [NSNumber numberWithInt:(int)[[HandshakeSession user].cards count]];
    
    // add card to current user
    self.card.user = [HandshakeSession user];
    
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    [Card sync];
    
    [self.view endEditing:YES];
    if (self.dismissBlock) self.dismissBlock();
}

@end
