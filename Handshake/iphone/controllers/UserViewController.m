//
//  UserViewController.m
//  Handshake
//
//  Created by Sam Ober on 4/3/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "UserViewController.h"
#import "AsyncImageView.h"
#import "Card.h"
#import "HandshakeSession.h"
#import "HandshakeCoreDataStore.h"
#import "PhoneCell.h"
#import "EmailCell.h"
#import "AddressCell.h"
#import "SocialCell.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "Social.h"
#import "AddCell.h"
#import "UIControl+Blocks.h"
#import "GKImagePicker.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "Handshake.h"
#import "ContactsCell.h"
#import "ContactsViewController.h"
#import "OptionsCell.h"
#import "Contact.h"
#import "AccountOptionsCell.h"
#import "FeedItem.h"
#import "AccountEditorViewController.h"
#import "UserHeaderCell.h"
#import "MutualContactsViewController.h"
#import "UserContactsViewController.h"
#import "FacebookHelper.h"
#import "SaveCell.h"
#import "ContactSync.h"

@interface UserViewController() <NSFetchedResultsControllerDelegate, GKImagePickerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundPictureTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureViewBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureBorderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nameEditIcon;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *editButtonView;

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundPictureView;
@property (weak, nonatomic) IBOutlet UIView *pictureViewBorder;
@property (weak, nonatomic) IBOutlet AsyncImageView *blurBackgroundPictureView;

@property (weak, nonatomic) IBOutlet UIButton *changePictureButton;

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIButton *nameEditButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;

@property (nonatomic, strong) NSFetchedResultsController *userFetchController;

@property (nonatomic, strong) Card *card;

@property (nonatomic) BOOL editing;

@property (nonatomic, retain) GKImagePicker *imagePicker;

@end

@implementation UserViewController

- (GKImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[GKImagePicker alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.cropSize = CGSizeMake(640, 640);
    }
    return _imagePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editing = NO;
    
    self.blurView.underlyingView = self.blurBackgroundPictureView;
    
    self.pictureViewBorder.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(-32, 0, 0, 0);
    
    [self.navBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [[UIImage alloc] init];
     
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    if (self.user)
        self.user = self.user;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    self.headerView.backgroundColor = self.navigationController.navigationBar.barTintColor;
//    
//    [UIView animateWithDuration:0.2 animations:^{
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.235 alpha:1];
//        self.headerView.backgroundColor = self.navigationController.navigationBar.barTintColor;
//    }];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self != [self.navigationController.viewControllers lastObject] && ![self.navigationController.visibleViewController isKindOfClass:[self class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
//        [UIView animateWithDuration:0.2 animations:^{
//            self.navigationController.navigationBar.barTintColor = LOGO_COLOR;
//        }];
    }
}

- (void)back {
    [ContactSync sync];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) return nil;
//    
//    if (section == 1 && [self tableView:tableView numberOfRowsInSection:1] != 0) return @"Contact Information";
//    
//    if (section == 2 && [self tableView:tableView numberOfRowsInSection:2] != 0) return @"Linked Accounts";
//    
//    return nil;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 0) return nil;
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    
//    view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width - 24, view.frame.size.height)];
//    
//    //label.font = [UIFont fontWithName:@"Roboto-Medium" size:14];
//    //label.font = [UIFont fontWithName:@"HelveticaNeue-BOLD" size:12];
//    label.font = [UIFont boldSystemFontOfSize:14];
//    label.textColor = [UIColor colorWithWhite:0.2 alpha:1];
//    
//    if (section == 1) label.text = @"Contact Information";
//    if (section == 2) label.text = @"Linked Accounts";
//    
//    //[view addSubview:label];
//    
//    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 1, view.frame.size.width, 1)];
//    sep.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
//    [view addSubview:sep];
//    
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0 || [self tableView:tableView numberOfRowsInSection:section] == 0) return 0;
//    
//    return 20;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.user == [[HandshakeSession currentSession] account]) return 1;
    
    if (section == 0 && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"][@"enabled"] boolValue] && self.user.contact) return 3;
    if (section == 0) return 2;
    
    if (self.card == nil) return 0;
    
    if (section == 1 && [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] == 0) return 0;
    
    if (section == 1) return 1 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count];
    
    if (section == 2 && [self.card.socials count] == 0) return 0;
    
    if (section == 2) return 1 + [self.card.socials count];
    
    if (section == 3) return 1;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UserHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        
        cell.nameLabel.text = [self.user formattedName];
        
        if (self.user == [[HandshakeSession currentSession] account]) {
            [cell.primaryButton setBackgroundImage:[UIImage imageNamed:@"edit_profile_button"] forState:UIControlStateNormal];
            
            [cell.primaryButton addEventHandler:^(id sender) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Edit" bundle:nil];
                [self presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:nil];
            } forControlEvents:UIControlEventTouchUpInside];
            
            [cell.secondaryButton setBackgroundImage:[UIImage imageNamed:@"settings_button"] forState:UIControlStateNormal];
            
            [cell.secondaryButton addEventHandler:^(id sender) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
                [self presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:nil];
            } forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.primaryButton addEventHandler:^(id sender) {
                [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure? You and %@ will no longer be contacts.", [self.user formattedName]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil] showInView:self.view];
            } forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    }
    
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        UserHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
//        
//        cell.nameLabel.text = [self.user formattedName];
//        
//        if (self.user.pictureData)
//            cell.pictureView.image = [UIImage imageWithData:self.user.pictureData];
//        else if (self.user.picture)
//            cell.pictureView.imageURL = [NSURL URLWithString:self.user.picture];
//        else
//            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
//        
//        return cell;
//    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        SaveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
        
        cell.saveSwitch.on = [self.user.contact.savesToPhone boolValue];
        
        [cell.saveSwitch addEventHandler:^(id sender) {
            UISwitch *saveSwitch = sender;
            self.user.contact.savesToPhone = @(saveSwitch.on);
        } forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        if (self.user == [[HandshakeSession currentSession] account]) {
            AccountOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountOptionsCell"];
            
            [cell.editButton addEventHandler:^(id sender) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Edit" bundle:nil];
                [self.navigationController pushViewController:[storyboard instantiateInitialViewController] animated:YES];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        } else {
            OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionsCell"];
            
            [cell.contactsButton addEventHandler:^(id sender) {
                if (self.user.contact) {
                    [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"You will no longer be contacts with %@", [self.user formattedName]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil] showInView:self.view];
                }
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.user == [[HandshakeSession currentSession] account]) {
            ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountContactsCell"];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"300 Contacts"];
            
            [string setAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15] } range:[@"300 Contacts" rangeOfString:@"300"]];
            
            cell.contactsLabel.attributedText = string;
            
            return cell;
        } else {
            ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactsCell"];
            
            NSString *contactsString = [NSString stringWithFormat:@"%d CONTACTS", [self.user.contacts intValue]];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:contactsString];
            
            [string setAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.14 alpha:1] } range:[contactsString rangeOfString:[NSString stringWithFormat:@"%d", [self.user.contacts intValue]]]];
            [string setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.64 alpha:1] } range:[contactsString rangeOfString:@"CONTACTS"]];
            
            cell.contactsLabel.attributedText = string;
            
            [cell.contactsButton addEventHandler:^(id sender) {
                UserContactsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"UserContactsViewController"];
                controller.user = self.user;
                [self.navigationController pushViewController:controller animated:YES];
            } forControlEvents:UIControlEventTouchUpInside];
            
            NSString *mutualString = [NSString stringWithFormat:@"%d MUTUAL", [self.user.mutual intValue]];
            string = [[NSMutableAttributedString alloc] initWithString:mutualString];
            
            [string setAttributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.14 alpha:1] } range:[mutualString rangeOfString:[NSString stringWithFormat:@"%d", [self.user.mutual intValue]]]];
            [string setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor colorWithWhite:0.64 alpha:1] } range:[mutualString rangeOfString:@"MUTUAL"]];
            
            cell.mutualLabel.attributedText = string;
            
            [cell.mutualButton addEventHandler:^(id sender) {
                MutualContactsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MutualContactsViewController"];
                controller.user = self.user;
                [self.navigationController pushViewController:controller animated:YES];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
    
    if ((indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.section == 3)
        return [tableView dequeueReusableCellWithIdentifier:@"EndSpacer"];
    
    int row = (int)indexPath.row - 1;
    
    if (indexPath.section == 1) {
        if (row < [self.card.phones count]) {
            Phone *phone = self.card.phones[row];
            PhoneCell *cell = (PhoneCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
            
            cell.numberLabel.text = phone.number;
            cell.labelLabel.text = [[phone.label lowercaseString] capitalizedString];
            
            [cell.callButton addEventHandler:^(id sender) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
            } forControlEvents:UIControlEventTouchUpInside];
            
            [cell.messageButton addEventHandler:^(id sender) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            Email *email = self.card.emails[row];
            EmailCell *cell = (EmailCell *)[tableView dequeueReusableCellWithIdentifier:@"EmailCell"];
            
            cell.addressLabel.text = email.address;
            cell.labelLabel.text = [[email.label lowercaseString] capitalizedString];
            
            [cell.emailButton addEventHandler:^(id sender) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", email.address]]];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        row -= [self.card.emails count];
        
        if (row < [self.card.addresses count]) {
            Address *address = self.card.addresses[row];
            AddressCell *cell = (AddressCell *)[tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
            
            NSString *addressString = [address formattedString];
            
            // if address is less than one line don't attribute
            if (![addressString containsString:@"\n"])
                cell.addressLabel.text = addressString;
            else {
                NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                [paragrahStyle setMinimumLineHeight:18];
                
                cell.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
            }
            
            cell.labelLabel.text = [[address.label lowercaseString] capitalizedString];
            
            [cell.mapsButton addEventHandler:^(id sender) {
                NSString *addressString = [[[address formattedString] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", addressString]]];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    } else if (indexPath.section == 2) {
        if (row < [self.card.socials count]) {
            Social *social = self.card.socials[row];
            
            if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
                
                cell.icon.image = [UIImage imageNamed:@"facebook_icon"];
                if ([[FacebookHelper sharedHelper] nameForUsername:social.username])
                    cell.label.text = [[FacebookHelper sharedHelper] nameForUsername:social.username];
                else {
                    cell.label.text = @"Facebook";
                    [[FacebookHelper sharedHelper] nameForUsername:social.username successBlock:^(NSString *name) {
                        [self.tableView reloadData];
                    } errorBlock:^(NSError *error) {
                        
                    }];
                }
                
                return cell;
            } else if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
                
                cell.icon.image = [UIImage imageNamed:@"twitter_icon"];
                cell.label.text = [@"@" stringByAppendingString:social.username];
                
                return cell;
            } else if ([[social.network lowercaseString] isEqualToString:@"instagram"]) {
                SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
                
                cell.icon.image = [UIImage imageNamed:@"instagram_icon"];
                cell.label.text = [@"@" stringByAppendingString:social.username];
                
                return cell;
            } else if ([[social.network lowercaseString] isEqualToString:@"snapchat"]) {
                SocialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SocialCell"];
                
                cell.icon.image = [UIImage imageNamed:@"snapchat_icon"];
                cell.label.text = social.username;
                
                return cell;
            }
            
            return [tableView dequeueReusableCellWithIdentifier:@"EndSpacer"];
        }
    }
    
    return [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) return 201;
    //if (indexPath.section == 0 && indexPath.row == 1) return 56;
    if (indexPath.section == 0 && indexPath.row == 1) return 46;
    if (indexPath.section == 0 && indexPath.row == 2) return 46;
    
    if ((indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 0) return 20;
    
    if (indexPath.section == 3) return 20;
    
    int row = (int)indexPath.row - 1;
    
    if (indexPath.section == 1) {
        if (row < [self.card.phones count]) {
            return 60;
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            return 60;
        }
        
        row -= [self.card.emails count];
        
        if (row < [self.card.addresses count]) {
            NSString *address = [self.card.addresses[row] formattedString];
            
            // if address is one line return 72
            if (![address containsString:@"\n"])
                return 60;
            
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setMinimumLineHeight:18];
            
            NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName: paragrahStyle };
            CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 28, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
            return 24 + 18 + frame.size.height + 3;
        }
    } else if (indexPath.section == 2) {
        return 53;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) return;
    
    int row = (int)indexPath.row - 1;
    
    if (indexPath.section == 1) {
        if (row < [self.card.phones count]) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message", @"Call", nil];
            sheet.tag = row;
            [sheet showInView:self.view];
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            Email *email = self.card.emails[row];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", email.address]]];
        }
        
        row -= [self.card.emails count];
        
        if (row < [self.card.addresses count]) {
            Address *address = self.card.addresses[row];
            NSString *addressString = [[[address formattedString] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", addressString]]];
        }
    }
    
    if (indexPath.section == 2) {
        Social *social = self.card.socials[row];
        
        if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", social.username]];
            if ([[UIApplication sharedApplication] canOpenURL:url])
                [[UIApplication sharedApplication] openURL:url];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://facebook.com/%@", social.username]]];
        } else if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", social.username]];
            if ([[UIApplication sharedApplication] canOpenURL:url])
                [[UIApplication sharedApplication] openURL:url];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", social.username]]];
        } else if ([[social.network lowercaseString] isEqualToString:@"instagram"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", social.username]];
            if ([[UIApplication sharedApplication] canOpenURL:url])
                [[UIApplication sharedApplication] openURL:url];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://instagram.com/%@", social.username]]];
        } else if ([[social.network lowercaseString] isEqualToString:@"snapchat"]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"snapchat://?u=%@", social.username]];
            if ([[UIApplication sharedApplication] canOpenURL:url])
                [[UIApplication sharedApplication] openURL:url];
            else {
                // maybe direct to download snapchat?
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //self.headerTop.constant = MAX(-44, MIN(0, -scrollView.contentOffset.y));
    self.headerTop.constant = MIN(0, -scrollView.contentOffset.y);
    //self.headerTop.constant = -scrollView.contentOffset.y;
    
    //self.pictureViewBottom.constant = MIN(31, 31 - (scrollView.contentOffset.y - 44));
    
    self.backgroundPictureTop.constant = MAX(-42, self.headerTop.constant);
    
    self.headerHeight.constant = MAX(106, 106 - scrollView.contentOffset.y);
    //self.pictureView.alpha = MAX(0, MIN(1, 1 - (scrollView.contentOffset.y / 44)));
    
    //self.navBar.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:157.0/255.0 blue:82.0/255.0 alpha:MAX(0, MIN(1, (scrollView.contentOffset.y / 20)))];
    
//    self.pictureBorderHeight.constant = MIN(80, MAX(48, 80 - (scrollView.contentOffset.y / 42) * 32));
//    //self.pictureViewBorder.layer.cornerRadius = self.pictureBorderHeight.constant / 2;
//    
//    self.pictureViewHeight.constant = self.pictureBorderHeight.constant - 8;
//    //self.pictureView.layer.cornerRadius = self.pictureViewHeight.constant / 2;
//    
    self.blurView.blurRadius = MAX(0, MIN(1, ((scrollView.contentOffset.y) / 20))) * 30.0;
    if (self.blurView.blurRadius < 2)
        self.blurView.hidden = YES;
    else
        self.blurView.hidden = NO;
    
//    if (scrollView.contentOffset.y > 44)
//        self.blurView.hidden = NO;
//    else
//        self.blurView.hidden = YES;
    
    if (scrollView.contentOffset.y > 44)
        self.navItem.title = [self.user formattedName];
    else
        self.navItem.title = @"";
    
    //self.blurView.alpha = MAX(0, MIN(1, (scrollView.contentOffset.y / 26)));
}

- (void)setUser:(User *)user {
    _user = user;
    
    if ([self.user.cards count] > 0)
        self.card = self.user.cards[0];
    
//    if (!self.nameLabel)
//        return;
    
    if (self.userFetchController)
        self.userFetchController.delegate = nil;
    
    self.nameLabel.text = [_user formattedName];
    
    // set picture
    if ([self.user cachedImage]) {
        self.pictureView.image = [self.user cachedImage];
        self.backgroundPictureView.image = [self.user cachedImage];
        self.blurBackgroundPictureView.image = [self.user cachedImage];
    } else if (self.user.picture) {
        self.pictureView.imageURL = [NSURL URLWithString:self.user.picture];
        self.backgroundPictureView.imageURL = self.pictureView.imageURL;
        self.blurBackgroundPictureView.imageURL = self.pictureView.imageURL;
    } else
        self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", user.userId];
    request.fetchLimit = 1;
    request.sortDescriptors = @[];
    
    self.userFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    self.userFetchController.delegate = self;
    
    [[[HandshakeCoreDataStore defaultStore] mainManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        [self.userFetchController performFetch:&error];
    }];
    
    if (_user == [[HandshakeSession currentSession] account]) {
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"edit_button"] forState:UIControlStateNormal];
        
        self.title = @"You";
    } else {
        self.title = @"Contact";
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    self.user = self.user;
    
    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)action:(id)sender {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AccountEditorViewController"] animated:YES completion:nil];
    
    return;
    
    if (self.editing) {
        self.editing = NO;
        
        self.nameEditButton.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.changePictureButton.alpha = 0;
            self.nameEditIcon.alpha = 0;
        } completion:^(BOOL finished) {
            self.changePictureButton.hidden = YES;
            self.nameLabelRight.constant = 0;
        }];
        
        // animate out add cells, reload other cells
        
        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        
        NSArray *removeIndexPaths = @[[NSIndexPath indexPathForRow:1 + [self.card.phones count] inSection:0], [NSIndexPath indexPathForRow:2 + [self.card.phones count] + [self.card.emails count] inSection:0], [NSIndexPath indexPathForRow:3 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] inSection:0], [NSIndexPath indexPathForRow:4 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] inSection:0]];
        
        NSMutableArray *updateIndexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count]; i++) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:i + 1 inSection:0]];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
            [self scrollViewDidScroll:self.tableView];
            [self.view layoutSubviews];
        } completion:^(BOOL finished) {
            if (!self.editing)
                [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        ((Account *)self.user).syncStatus = [NSNumber numberWithInt:AccountUpdated];
        self.card.syncStatus = [NSNumber numberWithInteger:CardUpdated];
        
        // save context
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
        
        // sync
        [Account sync];
        [Card sync];
        
        return;
    }
    
    if (self.user == [[HandshakeSession currentSession] account]) {
        // edit
        self.editing = YES;
        
        // move over for edit icon
        self.nameLabelRight.constant = 30;
        self.nameEditButton.userInteractionEnabled = YES;
        
        self.changePictureButton.hidden = NO;
        // update button alpha
        [UIView animateWithDuration:0.2 animations:^{
            self.nameEditIcon.alpha = 1;
        }];
        
        // animate in add cells, reload current cells
        
        NSArray *addIndexPaths = @[[NSIndexPath indexPathForRow:1 + [self.card.phones count] inSection:0], [NSIndexPath indexPathForRow:2 + [self.card.phones count] + [self.card.emails count] inSection:0], [NSIndexPath indexPathForRow:3 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] inSection:0], [NSIndexPath indexPathForRow:4 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] inSection:0]];
        
        NSMutableArray *updateIndexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.card.phones count]; i++) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:1 + i inSection:0]];
        }
        for (int i = 0; i < [self.card.emails count]; i++) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:2 + [self.card.phones count] + i inSection:0]];
        }
        for (int i = 0; i < [self.card.addresses count]; i++) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:3 + [self.card.phones count] + [self.card.emails count] + i inSection:0]];
        }
        for (int i = 0; i < [self.card.socials count]; i++) {
            [updateIndexPaths addObject:[NSIndexPath indexPathForRow:4 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + i inSection:0]];
        }
        
        [CATransaction begin];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [CATransaction setCompletionBlock:^{
            if (self.editing)
                [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.tableView endUpdates];
        [CATransaction commit];
    } else {
        // save to contacts
    }
}

- (void)nameEdited:(NSString *)first last:(NSString *)last {
    self.nameLabel.text = [self.user formattedName];
    //[self.nameLabel sizeToFit];
}

- (IBAction)changePicture:(id)sender {
    [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:nil];
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image {
    self.user.picture = nil;
    self.user.pictureData = UIImageJPEGRepresentation(image, 1);
    self.pictureView.image = image;
}

- (void)imagePickerDidCancel:(GKImagePicker *)imagePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)phoneEdited:(Phone *)phone {
    if (!phone.number || [phone.number isEqualToString:@""]) {
        // empty phone - delete
        [self.card removePhonesObject:phone];
        [self.card.managedObjectContext deleteObject:phone];
    }
    
    [self.tableView reloadData];
}

- (void)emailEdited:(Email *)email {
    if (!email.address || [email.address isEqualToString:@""]) {
        // empty email - delete
        [self.card removeEmailsObject:email];
        [self.card.managedObjectContext deleteObject:email];
    }
    
    [self.tableView reloadData];
}

- (void)addressEdited:(Address *)address {
    if (!address.street1 && !address.street2 && !address.city && !address.state && !address.zip) {
        // empty address - delete
        [self.card removeAddressesObject:address];
        [self.card.managedObjectContext deleteObject:address];
    }
    
    [self.tableView reloadData];
}

- (void)socialEdited:(Social *)social {
    if (!social.username || !social.network) {
        // empty social - delete
        [self.card removeSocialsObject:social];
        [self.card.managedObjectContext deleteObject:social];
    }
    
    [self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Contact"]) {
        self.user.contact.syncStatus = [NSNumber numberWithInt:ContactDeleted];
        for (FeedItem *item in self.user.contact.feedItems)
            [self.user.managedObjectContext deleteObject:item];
        [self.navigationController popViewControllerAnimated:YES];
        [Contact sync];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
        Phone *phone = self.card.phones[actionSheet.tag];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Message"]) {
        Phone *phone = self.card.phones[actionSheet.tag];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
    }
}

@end
