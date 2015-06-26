//
//  AccountEditorViewController.m
//  Handshake
//
//  Created by Sam Ober on 5/22/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "AccountEditorViewController.h"
#import "Account.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "Card.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "ContactInfoEditCell.h"
#import "AddCell.h"
#import "EmailEditCell.h"
#import "AddressEditCell.h"
#import "PhoneEditController.h"
#import "EmailEditController.h"
#import "AddressEditController.h"
#import "UIControl+Blocks.h"
#import "HeaderEditCell.h"
#import "AsyncImageView.h"
#import "NameEditController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "NameEditCell.h"
#import "PictureEditCell.h"
#import "GKImagePicker.h"
#import "AddSocialController.h"
#import "Social.h"
#import "TwitterEditController.h"
#import "SocialCell.h"
#import "InstagramEditController.h"
#import "SnapchatEditController.h"
#import "FacebookHelper.h"
#import "CardServerSync.h"
#import "NBPhoneNumberUtil.h"
#import "AddContactInfoViewController.h"

@interface AccountEditorViewController () <PhoneEditControllerDelegate, EmailEditControllerDelegate, AddressEditControllerDelegate, NameEditControllerDelegate, SocialEditDelegate, GKImagePickerDelegate, AddContactInfoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTop;

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIView *pictureBorderView;

@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) Card *card;

@property (nonatomic, strong) NSManagedObjectContext *objectContext;

@property (nonatomic, strong) GKImagePicker *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, strong) NSAttributedString *tutorialString;

@end

@implementation AccountEditorViewController

- (GKImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[GKImagePicker alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.cropSize = CGSizeMake(640, 640);
    }
    return _imagePicker;
}

- (NSAttributedString *)tutorialString {
    if (!_tutorialString) {
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        [pStyle setLineSpacing:2];
        
        NSDictionary *attrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:17], NSParagraphStyleAttributeName: pStyle, NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
        _tutorialString = [[NSAttributedString alloc] initWithString:@"Add as much or as little contact information as you want!" attributes:attrs];
    }
    return _tutorialString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pictureBorderView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    if (self.tutorialMode) {
        self.title = @"Create Profile";
        self.navigationItem.hidesBackButton = YES;
    } else
        self.title = @"Edit Profile";
    
    if (!self.tutorialMode && self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    // get user in child context
    
    self.objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", [[HandshakeSession currentSession] account].userId];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    
    [self.objectContext performBlockAndWait:^{
        NSError *error;
        results = [self.objectContext executeFetchRequest:request error:&error];
    }];
    
    if (results && [results count] == 1) {
        self.account = results[0];
        if ([self.account.cards count] > 0)
            self.card = self.account.cards[0];
        
        // set picture
        if (self.account.pictureData)
            self.pictureView.image = [UIImage imageWithData:self.account.pictureData];
        else if (self.account.picture)
            self.pictureView.imageURL = [NSURL URLWithString:self.account.picture];
        else
            self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    }
    
    if (!self.card) {
        // error
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.headerTop.constant = MIN(0, -scrollView.contentOffset.y);
    
    self.headerHeight.constant = MAX(97, 97 - scrollView.contentOffset.y);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) return nil;
//    
//    if (section == 1) return @"Phones";
//    
//    if (section == 2) return @"Emails";
//    
//    if (section == 3) return @"Addresses";
//    
//    return nil;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.tutorialMode) return 2;
    if (section == 0) return 0;
    
    if (section == 1) return self.tutorialMode ? 2 : 3;
    
    if (section == 2) return [self.card.phones count];
    
    if (section == 3) return [self.card.emails count];
    
    if (section == 4) return 2 + [self.card.addresses count];
    
    if (section == 5) return 5;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return [tableView dequeueReusableCellWithIdentifier:@"TutorialCell"];
    if (indexPath.section == 0 && indexPath.row == 1) return [tableView dequeueReusableCellWithIdentifier:@"EndSpacer"];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        PictureEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PictureEditCell"];
        
        if ([self.account cachedImage])
            cell.pictureView.image = [self.account cachedImage];
        else if (self.account.picture)
            cell.pictureView.imageURL = [NSURL URLWithString:self.account.picture];
        else {
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
            cell.label.text = @"Add a picture";
        }
        
        if (self.tutorialMode) cell.pictureView.layer.cornerRadius = 25;
        
        return cell;
    }
        //return [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (indexPath.section == 1 && indexPath.row == 1 && !self.tutorialMode) {
        NameEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameEditCell"];
        
        cell.nameLabel.text = [self.account formattedName];
        
        return cell;
    }
    
    if (indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2))
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.section == 2) {
        if (indexPath.row == [self.card.phones count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add Phone";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.phones count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        ContactInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
        
        __block Phone *phone = self.card.phones[indexPath.row];
        
        NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
        NBPhoneNumber *number = [util parse:phone.number defaultRegion:phone.countryCode error:nil];
        
        if ([phone.countryCode isEqualToString:[[util countryCodeByCarrier] uppercaseString]])
            cell.infoLabel.text = [util format:number numberFormat:NBEPhoneNumberFormatNATIONAL error:nil];
        else
            cell.infoLabel.text = [util format:number numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
        cell.labelLabel.text = [[phone.label lowercaseString] capitalizedString];
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removePhonesObject:phone];
            [self.objectContext deleteObject:phone];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.saveButton.enabled = YES;
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == [self.card.emails count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add Email";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.emails count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        ContactInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
        
        __block Email *email = self.card.emails[indexPath.row];
        
        cell.infoLabel.text = email.address;
        cell.labelLabel.text = [[email.label lowercaseString] capitalizedString];
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeEmailsObject:email];
            [self.objectContext deleteObject:email];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.saveButton.enabled = YES;
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == [self.card.addresses count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add contact information";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.addresses count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        ContactInfoEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
        
        __block Address *address = self.card.addresses[indexPath.row];
        
        NSString *addressString = [address formattedString];
        
        //cell.numberLabel.text = [addressString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        
        // if address is less than one line don't attribute
        if (![addressString containsString:@"\n"])
            cell.infoLabel.text = addressString;
        else {
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setLineSpacing:2];
            
            cell.infoLabel.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
        }
        
        cell.labelLabel.text = [[address.label lowercaseString] capitalizedString];
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeAddressesObject:address];
            [self.objectContext deleteObject:address];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            self.saveButton.enabled = YES;
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    if (indexPath.section == 5 && indexPath.row == 0) {
        // facebook
        Social *facebook = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                facebook = social;
                break;
            }
        }
        
        SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
        cell.icon.image = [UIImage imageNamed:@"facebook_icon"];
        if (facebook) {
            if ([[FacebookHelper sharedHelper] nameForUsername:facebook.username])
                cell.label.text = [NSString stringWithFormat:@"Remove %@", [[FacebookHelper sharedHelper] nameForUsername:facebook.username]];
            else
                cell.label.text = @"Remove Facebook";
        } else {
            cell.label.text = @"Add Facebook";
        }
        
        return cell;
    }
    
    if (indexPath.section == 5 && indexPath.row == 1) {
        // twitter
        Social *twitter = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                twitter = social;
                break;
            }
        }
        
        SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
        cell.icon.image = [UIImage imageNamed:@"twitter_icon"];
        if (twitter) {
            cell.label.text = [NSString stringWithFormat:@"Remove @%@", twitter.username];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.label.text = @"Add Twitter";
        }
        
       
        return cell;
    }
    if (indexPath.section == 5 && indexPath.row == 2) {
        // instagram
        Social *instagram = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"instagram"]) {
                instagram = social;
                break;
            }
        }
        
        SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
        cell.icon.image = [UIImage imageNamed:@"instagram_icon"];
        if (instagram) {
            cell.label.text = [NSString stringWithFormat:@"Remove @%@", instagram.username];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.label.text = @"Add Instagram";
        }
        
        return cell;
    }
    
    if (indexPath.section == 5 && indexPath.row == 3) {
        // snapchat
        Social *snapchat = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"snapchat"]) {
                snapchat = social;
                break;
            }
        }
        
        SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
        cell.icon.image = [UIImage imageNamed:@"snapchat_icon"];
        if (snapchat) {
            cell.label.text = [NSString stringWithFormat:@"Remove %@", snapchat.username];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.label.text = @"Add Snapchat";
        }
        
        return cell;
    }
    
    if (indexPath.section == 5 && indexPath.row == 4) return [tableView dequeueReusableCellWithIdentifier:@"EndSpacer"];
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        CGRect frame = [self.tutorialString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 48, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        return frame.size.height + 48;
    }
    if (indexPath.section == 0 && indexPath.row == 1) return 20;
    
    //if (indexPath.section == 0 && indexPath.row == 0) return 97;
    if (indexPath.section == 1 && indexPath.row == 0) return self.tutorialMode ? 76 : 58;
    if (indexPath.section == 1 && indexPath.row == 1) return self.tutorialMode ? 20 : 46;
    if (indexPath.section == 1 && indexPath.row == 2) return 20;
    
    if (indexPath.section == 2) {
        if (indexPath.row == [self.card.phones count]) return 46;
        if (indexPath.row == [self.card.phones count] + 1) return 20;
        return 57;
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == [self.card.emails count]) return 46;
        if (indexPath.row == [self.card.emails count] + 1) return 20;
        return 57;
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == [self.card.addresses count]) return 46;
        if (indexPath.row == [self.card.addresses count] + 1) return 20;
        //return 46;
        NSString *address = [self.card.addresses[indexPath.row] formattedString];
        
        // if address is one line return 72
        if (![address containsString:@"\n"])
            return 57;
        
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:2];
        
        NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSParagraphStyleAttributeName: paragrahStyle };
        CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 54, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
        return 23 + 15 + frame.size.height + 3;
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 4) return 20;
        return 46;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:nil];
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
        NameEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"NameEditController"];
        
        controller.user = self.account;
        controller.delegate = self;
        
        nav.viewControllers = @[controller];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 2 && indexPath.row != [self.card.phones count] + 1) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
        PhoneEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneEditController"];
        
        Phone *phone;
        
        if (indexPath.row == [self.card.phones count]) {
            phone = [[Phone alloc] initWithEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addPhonesObject:phone];
        } else
            phone = self.card.phones[indexPath.row];
        
        controller.phone = phone;
        controller.delegate = self;
        
        nav.viewControllers = @[controller];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 3 && indexPath.row != [self.card.emails count] + 1) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
        EmailEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailEditController"];
        
        Email *email;
        
        if (indexPath.row == [self.card.emails count]) {
            email = [[Email alloc] initWithEntity:[NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addEmailsObject:email];
        } else
            email = self.card.emails[indexPath.row];
        
        controller.email = email;
        controller.delegate = self;
        
        nav.viewControllers = @[controller];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 4 && indexPath.row == [self.card.addresses count]) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactInfoViewController"];
        
        AddContactInfoViewController *controller = nav.viewControllers[0];
        
        controller.card = self.card;
        controller.delegate = self;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 4 && indexPath.row < [self.card.addresses count]) {
        UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
        AddressEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressEditController"];
        
        Address *address;
        
        if (indexPath.row == [self.card.addresses count]) {
            address = [[Address alloc] initWithEntity:[NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addAddressesObject:address];
        } else
            address = self.card.addresses[indexPath.row];
        
        controller.address = address;
        controller.delegate = self;
        
        nav.viewControllers = @[controller];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if (indexPath.section == 5 && indexPath.row == 0) {
        Social *facebook = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                facebook = social;
                break;
            }
        }
        
        if (!facebook) {
            SocialCell *cell = (SocialCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.label.text = @"Loading...";
            
            [[FacebookHelper sharedHelper] loadFacebookAccountWithSuccessBlock:^(NSString *username, NSString *name) {
                Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
                social.username = username;
                social.network = @"facebook";
                [self.card addSocialsObject:social];
                self.saveButton.enabled = YES;
                cell.label.text = [NSString stringWithFormat:@"Remove %@", name];
            } errorBlock:^(NSError *error) {
                [[FacebookHelper sharedHelper] loginWithSuccessBlock:^(NSString *username, NSString *name) {
                    Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
                    social.username = username;
                    social.network = @"facebook";
                    [self.card addSocialsObject:social];
                    self.saveButton.enabled = YES;
                    cell.label.text = [NSString stringWithFormat:@"Remove %@", name];
                } errorBlock:^(NSError *error) {
                    cell.label.text = @"Add Facebook";
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to Facebook account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }];
        } else {
            [self.card removeSocialsObject:facebook];
            [self.objectContext deleteObject:facebook];
            self.saveButton.enabled = YES;
            SocialCell *cell = (SocialCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.label.text = @"Add Facebook";
        }
    }
    
    if (indexPath.section == 5 && indexPath.row == 1) {
        Social *twitter = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                twitter = social;
                break;
            }
        }
        
        if (!twitter) {
            twitter = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
            TwitterEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterEditController"];
            controller.delegate = self;
            controller.social = twitter;
            nav.viewControllers = @[controller];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [self.card removeSocialsObject:twitter];
            [self.objectContext deleteObject:twitter];
            self.saveButton.enabled = YES;
            SocialCell *cell = (SocialCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.label.text = @"Add Twitter";
        }
    }
    
    if (indexPath.section == 5 && indexPath.row == 2) {
        Social *instagram = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"instagram"]) {
                instagram = social;
                break;
            }
        }
        
        if (!instagram) {
            instagram = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
            InstagramEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"InstagramEditController"];
            controller.delegate = self;
            controller.social = instagram;
            nav.viewControllers = @[controller];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [self.card removeSocialsObject:instagram];
            [self.objectContext deleteObject:instagram];
            self.saveButton.enabled = YES;
            SocialCell *cell = (SocialCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.label.text = @"Add Instagram";
        }
    }
    
    if (indexPath.section == 5 && indexPath.row == 3) {
        Social *snapchat = nil;
        
        for (Social *social in self.card.socials) {
            if ([[social.network lowercaseString] isEqualToString:@"snapchat"]) {
                snapchat = social;
                break;
            }
        }
        
        if (!snapchat) {
            snapchat = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NavController"];
            SnapchatEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SnapchatEditController"];
            controller.delegate = self;
            controller.social = snapchat;
            nav.viewControllers = @[controller];
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [self.card removeSocialsObject:snapchat];
            [self.objectContext deleteObject:snapchat];
            self.saveButton.enabled = YES;
            SocialCell *cell = (SocialCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.label.text = @"Add Snapchat";
        }
    }
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image {
    // remove cached picture in AsyncImageView
    [[AsyncImageLoader defaultCache] removeObjectForKey:[NSURL URLWithString:self.account.picture]];
    
    self.account.picture = nil;
    self.account.pictureData = UIImageJPEGRepresentation(image, 1);
    
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nameEdited:(NSString *)first last:(NSString *)last {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)phoneEdited:(Phone *)phone {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)phoneDeleted:(Phone *)phone {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)phoneEditCancelled:(Phone *)phone {
    if (!phone.number || [phone.number isEqualToString:@""]) {
        // phone empty - delete
        [self.card removePhonesObject:phone];
        [self.objectContext deleteObject:phone];
        [self.tableView reloadData];
    }
}

- (void)emailEdited:(Email *)email {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)emailDeleted:(Email *)email {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)emailEditCancelled:(Email *)email {
    if (!email.address || [email.address isEqualToString:@""]) {
        [self.card removeEmailsObject:email];
        [self.objectContext deleteObject:email];
        [self.tableView reloadData];
    }
}

- (void)addressEdited:(Address *)address {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)addressDeleted:(Address *)address {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)addressEditCancelled:(Address *)address {
    if (!address.street1 && !address.street2 && !address.city && !address.state && !address.zip) {
        // empty address - delete
        [self.card removeAddressesObject:address];
        [self.card.managedObjectContext deleteObject:address];
        [self.tableView reloadData];
    }
}

- (void)socialEdited:(Social *)social {
    if (!social.card)
        [self.card addSocialsObject:social];
    
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)socialDeleted:(Social *)social {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (void)socialEditCancelled:(Social *)social {
    if (!social.username || !social.network) {
        [self.objectContext deleteObject:social];
        [self.tableView reloadData];
    }
}

- (void)addContactInfoViewControllerDidFinish {
    self.saveButton.enabled = YES;
    [self.tableView reloadData];
}

- (IBAction)save:(id)sender {
    [self save];
    
    [self cancel:nil];
}

- (void)save {
    // save context
    
    self.account.syncStatus = [NSNumber numberWithInt:AccountUpdated];
    self.card.syncStatus = [NSNumber numberWithInt:CardUpdated];
    
    [self.objectContext performBlockAndWait:^{
        [self.objectContext save:nil];
    }];
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    // sync
    [Account sync];
    [CardServerSync sync];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setTutorialMode:(BOOL)tutorialMode {
    _tutorialMode = tutorialMode;
    
    if (tutorialMode) {
        self.navigationItem.rightBarButtonItems = @[];
        self.navigationItem.leftBarButtonItems = @[];
    }
    
    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
