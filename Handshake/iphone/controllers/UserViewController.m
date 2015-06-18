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
#import "FeedItem.h"
#import "AccountEditorViewController.h"
#import "UserHeaderCell.h"
#import "MutualContactsViewController.h"
#import "UserContactsViewController.h"
#import "FacebookHelper.h"
#import "SaveCell.h"
#import "ContactSync.h"
#import "MessageCell.h"
#import "HandshakeClient.h"
#import "ContactServerSync.h"
#import "RequestServerSync.h"
#import "NBPhoneNumberUtil.h"

@interface UserViewController() <NSFetchedResultsControllerDelegate, GKImagePickerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundPictureTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureViewBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureBorderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundPictureView;
@property (weak, nonatomic) IBOutlet UIView *pictureViewBorder;
@property (weak, nonatomic) IBOutlet AsyncImageView *blurBackgroundPictureView;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *blurShadowView;

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
    
    [self.navBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [[UIImage alloc] init];
     
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoaded:) name:AsyncImageLoadDidFinish object:nil];
    
    if (self.user)
        self.user = self.user;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self != [self.navigationController.viewControllers lastObject] && ![self.navigationController.visibleViewController isKindOfClass:[self class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)back {
    [ContactSync sync];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] == 0) return 2;
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && self.user == [[HandshakeSession currentSession] account]) return 1;
    
    if (section == 0 && (![[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_sync"][@"enabled"] boolValue] || ![self.user.isContact boolValue])) return 3;
    if (section == 0) return 2;
    
    if (self.user != [[HandshakeSession currentSession] account] && ![self.user.isContact boolValue]) return 0;
    
    if ([self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] == 0) return 1;
    
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
        
        cell.primaryButton.hidden = NO;
        cell.secondaryButton.hidden = NO;
        
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
        } else if ([self.user.requestReceived boolValue]) {
            [cell.primaryButton setBackgroundImage:[UIImage imageNamed:@"accept_button"] forState:UIControlStateNormal];
            
            [cell.primaryButton addEventHandler:^(id sender) {
                cell.primaryButton.hidden = YES;
                cell.secondaryButton.hidden = YES;
                
                [RequestServerSync acceptRequest:self.user successBlock:^(User *user) {
                    [self.tableView reloadData];
                } failedBlock:^{
                    [self.tableView reloadData];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not accept request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            } forControlEvents:UIControlEventTouchUpInside];
            
            [cell.secondaryButton setBackgroundImage:[UIImage imageNamed:@"decline_button"] forState:UIControlStateNormal];
            
            [cell.secondaryButton addEventHandler:^(id sender) {
                cell.primaryButton.hidden = YES;
                cell.secondaryButton.hidden = YES;
                
                [RequestServerSync declineRequest:self.user successBlock:^(User *user) {
                    [self.tableView reloadData];
                } failedBlock:^{
                    [self.tableView reloadData];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not decline request at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            } forControlEvents:UIControlEventTouchUpInside];
        } else if ([self.user.requestSent boolValue]) {
            cell.secondaryButton.hidden = YES;
            
            [cell.primaryButton setBackgroundImage:[UIImage imageNamed:@"requested_button"] forState:UIControlStateNormal];
            
            [cell.primaryButton addEventHandler:^(id sender) {
                [RequestServerSync deleteRequest:self.user successBlock:^(User *user) {
                    
                } failedBlock:^{
                    [self.tableView reloadData];
                }];
                
                [self.tableView reloadData];
            } forControlEvents:UIControlEventTouchUpInside];
        } else if (![self.user.isContact boolValue]) {
            cell.secondaryButton.hidden = YES;
            
            [cell.primaryButton setBackgroundImage:[UIImage imageNamed:@"add_button"] forState:UIControlStateNormal];
            
            [cell.primaryButton addEventHandler:^(id sender) {
                [RequestServerSync sendRequest:self.user successBlock:^(User *user) {
                    
                } failedBlock:^{
                    [self.tableView reloadData];
                }];
                
                [self.tableView reloadData];
            } forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.primaryButton setBackgroundImage:[UIImage imageNamed:@"contacts_button"] forState:UIControlStateNormal];
            [cell.secondaryButton setBackgroundImage:[UIImage imageNamed:@"notifications_button"] forState:UIControlStateNormal];
            
            [cell.primaryButton addEventHandler:^(id sender) {
                [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure? You and %@ will no longer be contacts.", [self.user formattedName]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil] showInView:self.view];
            } forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
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
    
    if (indexPath.section == 0 && indexPath.row == 2 && [self.user.isContact boolValue]) {
        SaveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
        
        cell.saveSwitch.on = [self.user.savesToPhone boolValue];
        
        [cell.saveSwitch addEventHandler:^(id sender) {
            UISwitch *saveSwitch = sender;
            self.user.savesToPhone = @(saveSwitch.on);
        } forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2) {
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        
        if ([self.user.requestReceived boolValue]) {
            cell.messageLabel.text = [NSString stringWithFormat:@"Know %@? Accept the request!", self.user.firstName];
        } else if ([self.user.requestSent boolValue]) {
            cell.messageLabel.text = @"Your request is pending.";
        } else {
            cell.messageLabel.text = [NSString stringWithFormat:@"Know %@? Send a request!", self.user.firstName];
        }
        
        return cell;
    }
    
    if ([self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
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
            
            NBPhoneNumberUtil *util = [[NBPhoneNumberUtil alloc] init];
            NBPhoneNumber *number = [util parse:phone.number defaultRegion:phone.countryCode error:nil];
            
            if ([phone.countryCode isEqualToString:[[util countryCodeByCarrier] uppercaseString]])
                cell.numberLabel.text = [util format:number numberFormat:NBEPhoneNumberFormatNATIONAL error:nil];
            else
                cell.numberLabel.text = [util format:number numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
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
                [paragrahStyle setLineSpacing:2];
                
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
    if (indexPath.section == 0 && indexPath.row == 2 && [self.user.isContact boolValue]) return 46;
    if (indexPath.section == 0 && indexPath.row == 2) return 100;
    
    if ([self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count] == 0) return 60;
    
    if ((indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 0) return 20;
    
    if (indexPath.section == 3) return 20;
    
    int row = (int)indexPath.row - 1;
    
    if (indexPath.section == 1) {
        if (row < [self.card.phones count]) {
            return 57;
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            return 57;
        }
        
        row -= [self.card.emails count];
        
        if (row < [self.card.addresses count]) {
            NSString *address = [self.card.addresses[row] formattedString];
            
            // if address is one line return 72
            if (![address containsString:@"\n"])
                return 57;
            
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setLineSpacing:2];
            
            NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14], NSParagraphStyleAttributeName: paragrahStyle };
            CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 80, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
            return 23 + 15 + frame.size.height + 3;
        }
    } else if (indexPath.section == 2) {
        return 46;
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
    if (self.blurView.blurRadius < 2 || !self.backgroundPictureView.image)
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
        
        self.shadowView.hidden = NO;
        self.blurShadowView.hidden = NO;
        self.navBar.backgroundColor = [UIColor clearColor];
    } else {
        if (!self.backgroundPictureView.image) {
            self.shadowView.hidden = YES;
            self.blurShadowView.hidden = YES;
            self.navBar.backgroundColor = self.navigationController.navigationBar.barTintColor;
        }
        
        if (self.user.picture) {
            self.pictureView.imageURL = [NSURL URLWithString:self.user.picture];
            self.backgroundPictureView.imageURL = [NSURL URLWithString:self.user.picture];
            self.blurBackgroundPictureView.imageURL = [NSURL URLWithString:self.user.picture];
            
            [[AsyncImageLoader sharedLoader] loadImageWithURL:[NSURL URLWithString:self.user.picture] target:self success:@selector(imageDidLoad:withURL:) failure:nil];
        } else
            self.pictureView.image = [UIImage imageNamed:@"default_picture"];
    }
    
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
        self.title = @"You";
        
        UIBarButtonItem *contactsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contacts_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(contacts)];
        contactsButton.tintColor = [UIColor whiteColor];
        self.navItem.rightBarButtonItem = contactsButton;
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Contact"]) {
        [ContactServerSync deleteContact:self.user];
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
        Phone *phone = self.card.phones[actionSheet.tag];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Message"]) {
        Phone *phone = self.card.phones[actionSheet.tag];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@", [[phone.number componentsSeparatedByString:@" "] componentsJoinedByString:@""]]]];
    }
}

- (void)contacts {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"] animated:YES];
}

- (void)imageDidLoad:(UIImage *)image withURL:(NSURL *)url {
    self.shadowView.hidden = NO;
    self.blurShadowView.hidden = NO;
    self.navBar.backgroundColor = [UIColor clearColor];
}
@end
