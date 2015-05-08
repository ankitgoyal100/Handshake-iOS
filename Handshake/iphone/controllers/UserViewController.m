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
#import "PhoneEditCell.h"
#import "EmailCell.h"
#import "EmailEditCell.h"
#import "AddressCell.h"
#import "AddressEditCell.h"
#import "FacebookCell.h"
#import "FacebookEditCell.h"
#import "TwitterCell.h"
#import "TwitterEditCell.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"
#import "Social.h"
#import "AddCell.h"
#import "UIControl+Blocks.h"
#import "PhoneEditController.h"
#import "EmailEditController.h"
#import "AddressEditController.h"
#import "AddSocialController.h"
#import "TwitterEditController.h"
#import "GKImagePicker.h"
#import "NameEditController.h"
#import "UINavigationItem+Additions.h"
#import "UIBarButtonItem+DefaultBackButton.h"
#import "FXBlurView.h"

@interface UserViewController() <NSFetchedResultsControllerDelegate, PhoneEditControllerDelegate, EmailEditControllerDelegate, AddressEditControllerDelegate, SocialEditControllerDelegate, GKImagePickerDelegate, NameEditControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nameEditIcon;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AsyncImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *changePictureButton;
@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIButton *nameEditButton;

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
    
    self.blurView.tintColor = [UIColor clearColor];
    self.blurView.updateInterval = 1.0 / 30.0;
    
    self.pictureView.showActivityIndicator = NO;
    
    self.nameLabelConstraint.constant = self.view.frame.size.width - 70;
    self.imageViewHeight.constant = self.view.frame.size.width;
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
        [self.navigationItem addLeftBarButtonItem:[[[UIBarButtonItem alloc] init] backButtonWith:@"" tintColor:[UIColor whiteColor] target:self andAction:@selector(back)]];
    
    if (self.user)
        self.user = self.user;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.blurView.hidden = YES;
    //self.blurView.blurEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //self.pictureView.hidden = NO;
    self.blurView.blurEnabled = YES;
    if (self.blurView.blurRadius == 0)
        self.blurView.hidden = YES;
    else
        self.blurView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.blurView.blurEnabled = NO;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.card == nil) return 1;
    
    if (self.editing)
        return 6 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count];
    else
        return 2 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    int row = (int)indexPath.row - 1;
    
    if (self.editing) {
        if (row < [self.card.phones count]) {
            __block Phone *phone = self.card.phones[row];
            PhoneEditCell *cell = (PhoneEditCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
            
            cell.numberLabel.text = phone.number;
            cell.labelLabel.text = phone.label;
            
            [cell.deleteButton addEventHandler:^(id sender) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:1 + [self.card.phones indexOfObject:phone] inSection:0];
                [self.card removePhonesObject:phone];
                [self.card.managedObjectContext deleteObject:phone];
                [UIView animateWithDuration:0.3 animations:^{
                    [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
                    [self scrollViewDidScroll:self.tableView];
                    [self.view layoutSubviews];
                }];
                
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        if (row == [self.card.phones count]) {
            AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            cell.actionLabel.text = @"ADD PHONE";
            return cell;
        }
        
        row -= [self.card.phones count] + 1;
        
        if (row < [self.card.emails count]) {
            __block Email *email = self.card.emails[row];
            EmailEditCell *cell = (EmailEditCell *)[tableView dequeueReusableCellWithIdentifier:@"EmailEditCell"];
            
            cell.addressLabel.text = email.address;
            cell.labelLabel.text = email.label;
            
            [cell.deleteButton addEventHandler:^(id sender) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:2 + [self.card.phones count] + [self.card.emails indexOfObject:email] inSection:0];
                [self.card removeEmailsObject:email];
                [self.card.managedObjectContext deleteObject:email];
                [UIView animateWithDuration:0.3 animations:^{
                    [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
                    [self scrollViewDidScroll:self.tableView];
                    [self.view layoutSubviews];
                }];
                
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        if (row == [self.card.emails count]) {
            AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            cell.actionLabel.text = @"ADD EMAIL";
            return cell;
        }
        
        row -= [self.card.emails count] + 1;
        
        if (row < [self.card.addresses count]) {
            __block Address *address = self.card.addresses[row];
            AddressEditCell *cell = (AddressEditCell *)[tableView dequeueReusableCellWithIdentifier:@"AddressEditCell"];
            
            NSString *addressString = [address formattedString];
            
            // if address is less than one line don't attribute
            if (![addressString containsString:@"\n"])
                cell.addressLabel.text = addressString;
            else {
                NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
                [paragrahStyle setMinimumLineHeight:26];
                
                cell.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
            }
            
            cell.labelLabel.text = address.label;
            
            [cell.deleteButton addEventHandler:^(id sender) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:3 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses indexOfObject:address] inSection:0];
                [self.card removeAddressesObject:address];
                [self.card.managedObjectContext deleteObject:address];
                [UIView animateWithDuration:0.3 animations:^{
                    [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
                    [self scrollViewDidScroll:self.tableView];
                    [self.view layoutSubviews];
                }];
            } forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        if (row == [self.card.addresses count]) {
            AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            cell.actionLabel.text = @"ADD ADDRESS";
            return cell;
        }
        
        row -= [self.card.addresses count] + 1;
        
        if (row < [self.card.socials count]) {
            __block Social *social = self.card.socials[row];
            
            if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                FacebookEditCell *cell = (FacebookEditCell *)[tableView dequeueReusableCellWithIdentifier:@"FacebookEditCell"];
                
                [cell.deleteButton addEventHandler:^(id sender) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:4 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials indexOfObject:social] inSection:0];
                    [self.card removeSocialsObject:social];
                    [self.card.managedObjectContext deleteObject:social];
                    [UIView animateWithDuration:0.3 animations:^{
                        [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
                        [self scrollViewDidScroll:self.tableView];
                        [self.view layoutSubviews];
                    }];
                } forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            } else if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                TwitterEditCell *cell = (TwitterEditCell *)[tableView dequeueReusableCellWithIdentifier:@"TwitterEditCell"];
                
                cell.usernameLabel.text = [@"@" stringByAppendingString:social.username];
                
                [cell.deleteButton addEventHandler:^(id sender) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:4 + [self.card.phones count] + [self.card.emails count] + [self.card.addresses count] + [self.card.socials indexOfObject:social] inSection:0];
                    [self.card removeSocialsObject:social];
                    [self.card.managedObjectContext deleteObject:social];
                    [UIView animateWithDuration:0.3 animations:^{
                        [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
                        [self scrollViewDidScroll:self.tableView];
                        [self.view layoutSubviews];
                    }];
                } forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
        }
        
        if (row == [self.card.socials count]) {
            AddCell *cell = (AddCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            cell.actionLabel.text = @"ADD SOCIAL ACCOUNT";
            return cell;
        }
    } else {
        if (row < [self.card.phones count]) {
            Phone *phone = self.card.phones[row];
            PhoneCell *cell = (PhoneCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
            
            cell.numberLabel.text = phone.number;
            cell.labelLabel.text = phone.label;
            
            return cell;
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            Email *email = self.card.emails[row];
            EmailCell *cell = (EmailCell *)[tableView dequeueReusableCellWithIdentifier:@"EmailCell"];
            
            cell.addressLabel.text = email.address;
            cell.labelLabel.text = email.label;
            
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
                [paragrahStyle setMinimumLineHeight:26];
                
                cell.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
            }
            
            cell.labelLabel.text = address.label;
            
            return cell;
        }
        
        row -= [self.card.addresses count];
        
        if (row < [self.card.socials count]) {
            Social *social = self.card.socials[row];
            
            if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                return [tableView dequeueReusableCellWithIdentifier:@"FacebookCell"];
            } else if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                TwitterCell *cell = (TwitterCell *)[tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
                
                cell.usernameLabel.text = [@"@" stringByAppendingString:social.username];
                
                return cell;
            }
        }
    }
    
    return [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return self.view.frame.size.width + 31;
    
    int row = (int)indexPath.row - 1;
    
    if (self.editing) {
        if (row < [self.card.phones count])
            return 72;
        
        if (row == [self.card.phones count])
            return 56;
        
        row -= [self.card.phones count] + 1;
        
        if (row < [self.card.emails count])
            return 72;
        
        if (row == [self.card.emails count])
            return 56;
        
        row -= [self.card.emails count] + 1;
        
        if (row < [self.card.addresses count]) {
            NSString *address = [self.card.addresses[row] formattedString];
            
            // if address is one line return 72
            if (![address containsString:@"\n"])
                return 72;
            
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setMinimumLineHeight:26];
            
            NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:16], NSParagraphStyleAttributeName: paragrahStyle };
            CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 142, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
            return 28 + 22 + frame.size.height + 6;
        }
        
        if (row == [self.card.addresses count])
            return 56;
        
        row -= [self.card.addresses count] + 1;
        
        if (row < [self.card.socials count])
            return 56;
        
        if (row == [self.card.socials count])
            return 56;
    } else {
        if (row < [self.card.phones count]) {
            return 72;
        }
        
        row -= [self.card.phones count];
        
        if (row < [self.card.emails count]) {
            return 72;
        }
        
        row -= [self.card.emails count];
        
        if (row < [self.card.addresses count]) {
            NSString *address = [self.card.addresses[row] formattedString];
            
            // if address is one line return 72
            if (![address containsString:@"\n"])
                return 72;
            
            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            [paragrahStyle setMinimumLineHeight:26];
            
            NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:16], NSParagraphStyleAttributeName: paragrahStyle };
            CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 88, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
            return 28 + 22 + frame.size.height + 6;
        }
        
        row -= [self.card.addresses count];
        
        if (row < [self.card.socials count]) {
            return 56;
        }
    }
    
    return 8;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.nameLabelConstraint.constant = MAX(0, MIN(self.view.frame.size.width - self.tableView.contentOffset.y - 70, self.view.frame.size.width - 70));
    self.imageViewHeight.constant = MAX(70, MIN(self.view.frame.size.width - self.tableView.contentOffset.y, self.view.frame.size.width));
    
    self.blurView.blurRadius = MAX(0, MIN(1, (self.tableView.contentOffset.y - (self.view.frame.size.width / 2)) / ((self.view.frame.size.width / 2) - 70.0))) * 30.0;
    if (self.blurView.blurRadius == 0)
        self.blurView.hidden = YES;
    else
        self.blurView.hidden = NO;
    
    if (self.editing) {
        if (self.changePictureButton.alpha == 1 && self.tableView.contentOffset.y > 40) {
            [UIView animateWithDuration:0.2 animations:^{
                self.changePictureButton.alpha = 0;
            }];
        } else if (self.changePictureButton.alpha == 0 && self.tableView.contentOffset.y <= 40) {
            [UIView animateWithDuration:0.2 animations:^{
                self.changePictureButton.alpha = 1;
            }];
        }
    }
}

- (void)setUser:(User *)user {
    _user = user;
    
    if ([self.user.cards count] > 0)
        self.card = self.user.cards[0];
    
    if (self.userFetchController)
        self.userFetchController.delegate = nil;
    
    self.nameLabel.text = [_user formattedName];
    
    // set picture
    if (self.user.pictureData)
        self.pictureView.image = [UIImage imageWithData:self.user.pictureData];
    else if (self.user.picture)
        self.pictureView.imageURL = [NSURL URLWithString:self.user.picture];
    else
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
        // set button to edit
        
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"edit_button"] forState:UIControlStateNormal];
        
        self.title = @"You";
    } else {
        // set button to save
        
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"sync_button"] forState:UIControlStateNormal];
        
        self.title = @"Contact";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int row = (int)indexPath.row - 1;
    
    if (self.editing) {
        if (row <= [self.card.phones count]) {
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneEditController"];
            
            PhoneEditController *controller = (PhoneEditController *)nav.viewControllers[0];
            controller.delegate = self;
            
            if (row < [self.card.phones count])
                controller.phone = self.card.phones[row];
            else {
                Phone *phone = [[Phone alloc] initWithEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
                [self.card addPhonesObject:phone];
                controller.phone = phone;
            }
            
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
        
        row -= [self.card.phones count] + 1;
        
        if (row <= [self.card.emails count]) {
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailEditController"];
            
            EmailEditController *controller = (EmailEditController *)nav.viewControllers[0];
            controller.delegate = self;
            
            if (row < [self.card.emails count])
                controller.email = self.card.emails[row];
            else {
                Email *email = [[Email alloc] initWithEntity:[NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
                [self.card addEmailsObject:email];
                controller.email = email;
            }
            
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
        
        row -= [self.card.emails count] + 1;
        
        if (row <= [self.card.addresses count]) {
            UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressEditController"];
            
            AddressEditController *controller = (AddressEditController *)nav.viewControllers[0];
            controller.delegate = self;
            
            if (row < [self.card.addresses count])
                controller.address = self.card.addresses[row];
            else {
                Address *address = [[Address alloc] initWithEntity:[NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
                [self.card addAddressesObject:address];
                controller.address = address;
            }
            
            [self presentViewController:nav animated:YES completion:nil];
            
            return;
        }
        
        row -= [self.card.addresses count] + 1;
        
        if (row <= [self.card.socials count]) {
            if (row < [self.card.socials count]) {
                Social *social = self.card.socials[row];
                
                if ([[social.network lowercaseString] isEqualToString:@"facebook"]) {
                    
                } else if ([[social.network lowercaseString] isEqualToString:@"twitter"]) {
                    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"AddSocialController"];
                    
                    TwitterEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterEditController"];
                    
                    nav.viewControllers = @[controller];
                    
                    controller.social = social;
                    controller.delegate = self;
                    
                    [self presentViewController:nav animated:YES completion:nil];
                }
            } else {
                UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"AddSocialController"];
                
                AddSocialController *controller = (AddSocialController *)nav.viewControllers[0];
                
                controller.delegate = self;
                
                Social *social = [[Social alloc] initWithEntity:[NSEntityDescription entityForName:@"Social" inManagedObjectContext:self.card.managedObjectContext] insertIntoManagedObjectContext:self.card.managedObjectContext];
                [self.card addSocialsObject:social];
                
                controller.social = social;
                
                [self presentViewController:nav animated:YES completion:nil];
            }
            
            return;
        }
    } else {
        
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([self.user.cards count] > 0)
        self.card = self.user.cards[0];
    
    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)action:(id)sender {
    if (self.editing) {
        self.editing = NO;
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"edit_button"] forState:UIControlStateNormal];
        self.nameEditButton.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.changePictureButton.alpha = 0;
            self.nameEditIcon.alpha = 0;
        } completion:^(BOOL finished) {
            self.changePictureButton.hidden = YES;
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
        
        [self.actionButton setBackgroundImage:[UIImage imageNamed:@"save_button"] forState:UIControlStateNormal];
        self.nameEditButton.userInteractionEnabled = YES;
        
        self.changePictureButton.hidden = NO;
        // update button alpha
        [self scrollViewDidScroll:self.tableView];
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
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.tableView endUpdates];
        [CATransaction commit];
    } else {
        // save to contacts
    }
}

- (IBAction)editName:(id)sender {
    if (!self.editing)
        return;
    
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"NameEditController"];
    
    NameEditController *controller = (NameEditController *)nav.viewControllers[0];
    controller.delegate = self;
    controller.user = self.user;
    
    [self presentViewController:nav animated:YES completion:nil];
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

@end
