//
//  ContactViewController.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactHeaderSection.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "BasicInfoSection.h"
#import "ContactSocialSection.h"
#import <AddressBook/AddressBook.h>
#import "AsyncImageView.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "Social.h"
#import "DeleteContactSection.h"
#import "HandshakeCoreDataStore.h"

@interface ContactViewController()

@property (nonatomic, strong) Contact *contact;

@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIActivityIndicatorView *savingView;

@end

@implementation ContactViewController

- (UIBarButtonItem *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
        _saveButton.tintColor = [UIColor whiteColor];
    }
    return _saveButton;
}

- (UIActivityIndicatorView *)savingView {
    if (!_savingView) {
        _savingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_savingView startAnimating];
    }
    return _savingView;
}

- (id)initWithContact:(Contact *)contact {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.contact = contact;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Contact";
    
    [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    [self.navigationItem addRightBarButtonItem:self.saveButton];
    
    [self.sections addObject:[[ContactHeaderSection alloc] initWithContact:self.contact viewController:self]];
    
    [self.sections addObject:[[BasicInfoSection alloc] initWithCard:self.contact.card viewController:self]];
    
    [self.sections addObject:[[ContactSocialSection alloc] initWithCard:self.contact.card viewController:self]];
    
    [self.sections addObject:[[DeleteContactSection alloc] initWithContactDeletedBlock:^{
        // set sync status
        self.contact.syncStatus = [NSNumber numberWithInt:ContactDeleted];
        
        // save the context
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        [Contact sync];
        
        [self.navigationController popViewControllerAnimated:YES];
    } viewController:self]];
    
    [self.sections addObject:[[Section alloc] init]];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    [self.navigationItem addRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.savingView]];
    
    CFErrorRef error = NULL;
    
    __block ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error != NULL) {
        [self.navigationItem addRightBarButtonItem:self.saveButton];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not save to contacts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CFErrorRef error = NULL;
                
                ABRecordRef contact = ABPersonCreate();
                
                UIImage *picture = [[AsyncImageLoader defaultCache] objectForKey:[NSURL URLWithString:self.contact.card.picture]];
                if (picture)
                    ABPersonSetImageData(contact, (__bridge CFDataRef)(UIImagePNGRepresentation(picture)), &error);
                else
                    ABPersonSetImageData(contact, (__bridge CFDataRef)(UIImagePNGRepresentation([UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.contact.card.picture]]])), &error);
                
                if ([self.contact.card.firstName length] > 0) ABRecordSetValue(contact, kABPersonFirstNameProperty, (__bridge CFTypeRef)(self.contact.card.firstName), &error);
                if ([self.contact.card.lastName length] > 0) ABRecordSetValue(contact, kABPersonLastNameProperty, (__bridge CFTypeRef)(self.contact.card.lastName), &error);
                
                if ([self.contact.card.phones count] > 0) {
                    ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                    // loop through phones
                    for (Phone *phone in self.contact.card.phones) {
                        if ([phone.number length] == 0) continue;
                        CFStringRef type = (__bridge CFStringRef)(phone.label);
                        if ([phone.label isEqualToString:@"home"]) type = kABHomeLabel;
                        if ([phone.label isEqualToString:@"cell"] || [phone.label isEqualToString:@"mobile"]) type = kABPersonPhoneMobileLabel;
                        if ([phone.label isEqualToString:@"work"] || [phone.label isEqualToString:@"office"]) type = kABWorkLabel;
                        if ([phone.label length] == 0) type = kABOtherLabel;
                        ABMultiValueAddValueAndLabel(phones, (__bridge CFTypeRef)(phone.number), type, NULL);
                    }
                    ABRecordSetValue(contact, kABPersonPhoneProperty, phones, &error);
                    CFRelease(phones);
                }
                
                if ([self.contact.card.emails count] > 0) {
                    ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                    // loop through emails
                    for (Email *email in self.contact.card.emails) {
                        if ([email.address length] == 0) continue;
                        CFStringRef type = (__bridge CFStringRef)(email.label);
                        if ([email.label isEqualToString:@"home"]) type = kABHomeLabel;
                        if ([email.label isEqualToString:@"work"] || [email.label isEqualToString:@"office"]) type = kABWorkLabel;
                        if ([email.label length] == 0) type = kABOtherLabel;
                        ABMultiValueAddValueAndLabel(emails, (__bridge CFTypeRef)(email.address), type, NULL);
                    }
                    ABRecordSetValue(contact, kABPersonEmailProperty, emails, &error);
                    CFRelease(emails);
                }
                
                if ([self.contact.card.socials count] > 0) {
                    ABMutableMultiValueRef socials = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                    // loop through socials
                    for (Social *social in self.contact.card.socials) {
                        if ([social.network length] == 0 || [social.username length] == 0) continue;
                        CFStringRef type = (__bridge CFStringRef)(social.network);
                        if ([[social.network uppercaseString] isEqualToString:@"TWITTER"]) type = kABPersonSocialProfileServiceTwitter;
                        if ([[social.network uppercaseString] isEqualToString:@"FACEBOOK"]) type = kABPersonSocialProfileServiceFacebook;
                        if ([[social.network uppercaseString] isEqualToString:@"FLICKR"]) type = kABPersonSocialProfileServiceFlickr;
                        if ([[social.network uppercaseString] isEqualToString:@"GAME CENTER"] || [[social.network uppercaseString] isEqualToString:@"GAMECENTER"]) type = kABPersonSocialProfileServiceGameCenter;
                        if ([[social.network uppercaseString] isEqualToString:@"LINKEDIN"]) type = kABPersonSocialProfileServiceLinkedIn;
                        if ([[social.network uppercaseString] isEqualToString:@"MYSPACE"]) type = kABPersonSocialProfileServiceMyspace;
                        
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        [dict setObject:social.username forKey:(NSString *)kABPersonSocialProfileUsernameKey];
                        [dict setObject:(__bridge id)(type) forKey:(NSString *)kABPersonSocialProfileServiceKey];
                        
                        ABMultiValueAddValueAndLabel(socials, (__bridge CFTypeRef)(dict), type, NULL);
                    }
                    ABRecordSetValue(contact, kABPersonSocialProfileProperty, socials, &error);
                    CFRelease(socials);
                }
                
                if ([self.contact.card.addresses count] > 0) {
                    ABMutableMultiValueRef addresses = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                    // loop through addresses
                    for (Address *address in self.contact.card.addresses) {
                        CFStringRef type = (__bridge CFStringRef)(address.label);
                        if ([address.label isEqualToString:@"home"]) type = kABHomeLabel;
                        if ([address.label isEqualToString:@"work"] || [address.label isEqualToString:@"office"]) type = kABWorkLabel;
                        if ([address.label length] == 0) type = kABOtherLabel;
                        
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        if ([address.street1 length] > 0 && [address.street2 length] > 0) [dict setObject:[NSString stringWithFormat:@"%@\n%@", address.street1, address.street2] forKey:(NSString *)kABPersonAddressStreetKey];
                        //if ([address.street1 length] > 0 && [address.street2 length] == 0) [dict setObject:address.street1 forKey:(NSString *)kABPersonAddressStreetKey];
                        //if ([address.street1 length] == 0 && [address.street2 length] > 0) [dict setObject:address.street2 forKey:(NSString *)kABPersonAddressStreetKey];
                        //if ([address.street2 length] > 0) [dict setObject:address.street2 forKey:(NSString *)kABPersonAddressStreetKey];
                        if ([address.city length] > 0) [dict setObject:address.city forKey:(NSString *)kABPersonAddressCityKey];
                        if ([address.state length] > 0) [dict setObject:address.state forKey:(NSString *)kABPersonAddressStateKey];
                        if ([address.zip length] > 0) [dict setObject:address.zip forKey:(NSString *)kABPersonAddressZIPKey];
                        //if ([address.country length] > 0) [dict setObject:address.country forKey:(NSString *)kABPersonAddressCountryKey];
                        
                        ABMultiValueAddValueAndLabel(addresses, (__bridge CFTypeRef)(dict), type, NULL);
                    }
                    ABRecordSetValue(contact, kABPersonAddressProperty, addresses, &error);
                    CFRelease(addresses);
                }
                
                ABAddressBookAddRecord(book, contact, &error);
                ABAddressBookSave(book, &error);
                
                if (error != NULL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationItem addRightBarButtonItem:self.saveButton];
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not save to contacts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationItem addRightBarButtonItem:self.saveButton];
                        [[[UIAlertView alloc] initWithTitle:@"Saved" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    });
                }
            });
        } else {
            [self.navigationItem addRightBarButtonItem:self.saveButton];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to access your contacts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    });
}

@end
