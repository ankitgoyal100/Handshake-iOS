//
//  AddContactInfoViewController.m
//  Handshake
//
//  Created by Sam Ober on 6/18/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AddContactInfoViewController.h"
#import "PhoneEditController.h"
#import "EmailEditController.h"
#import "AddressEditController.h"

@interface AddContactInfoViewController () <PhoneEditControllerDelegate, EmailEditControllerDelegate, AddressEditControllerDelegate>

@end

@implementation AddContactInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add";
}

- (IBAction)cancel:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addContactInfoViewControllerDidFinish)])
        [self.delegate addContactInfoViewControllerDidFinish];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        PhoneEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneEditController"];
        
        controller.phone = [[Phone alloc] initWithEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        [self.card addPhonesObject:controller.phone];
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.row == 1) {
        EmailEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailEditController"];
        
        controller.email = [[Email alloc] initWithEntity:[NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        [self.card addEmailsObject:controller.email];
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.row == 2) {
        AddressEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressEditController"];
        
        controller.address = [[Address alloc] initWithEntity:[NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
        [self.card addAddressesObject:controller.address];
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)phoneEdited:(Phone *)phone {
    [self cancel:nil];
}

- (void)phoneEditCancelled:(Phone *)phone {
    [self.card removePhonesObject:phone];
}

- (void)emailEdited:(Email *)email {
    [self cancel:nil];
}

- (void)emailEditCancelled:(Email *)email {
    [self.card removeEmailsObject:email];
}

- (void)addressEdited:(Address *)address {
    [self cancel:nil];
}

- (void)addressEditCancelled:(Address *)address {
    [self.card removeAddressesObject:address];
}

@end
