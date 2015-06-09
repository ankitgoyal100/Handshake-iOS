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
#import "PhoneEditCell.h"
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

@interface AccountEditorViewController () <PhoneEditControllerDelegate, EmailEditControllerDelegate, AddressEditControllerDelegate, NameEditControllerDelegate, GKImagePickerDelegate>

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pictureBorderView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.title = @"Edit Profile";
    
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0)
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
    return 4;
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
    if (section == 0) return 3;
    
    if (section == 1) return 2 + [self.card.phones count];
    
    if (section == 2) return 2 + [self.card.emails count];
    
    if (section == 3) return 2 + [self.card.addresses count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        PictureEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PictureEditCell"];
        
        if ([self.account cachedImage])
            cell.pictureView.image = [self.account cachedImage];
        else if (self.account.picture)
            cell.pictureView.imageURL = [NSURL URLWithString:self.account.picture];
        else
            cell.pictureView.image = [UIImage imageNamed:@"default_picture"];
        
        return cell;
    }
        //return [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        NameEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameEditCell"];
        
        cell.nameLabel.text = [self.account formattedName];
        
        return cell;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2)
        return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
    
    if (indexPath.section == 1) {
        if (indexPath.row == [self.card.phones count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add Phone";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.phones count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        PhoneEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneEditCell"];
        
        __block Phone *phone = self.card.phones[indexPath.row];
        
        cell.numberLabel.text = phone.number;
        cell.labelLabel.text = [[phone.label lowercaseString] capitalizedString];
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == [self.card.emails count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add Email";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.emails count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        EmailEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmailEditCell"];
        
        __block Email *email = self.card.emails[indexPath.row];
        
        cell.addressLabel.text = email.address;
        cell.labelLabel.text = [[email.label lowercaseString] capitalizedString];
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeEmailsObject:email];
            [self.objectContext deleteObject:email];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == [self.card.addresses count]) {
            AddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
            
            cell.actionLabel.text = @"Add Address";
            
            return cell;
        }
        
        if (indexPath.row == [self.card.addresses count] + 1)
            return [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        
        AddressEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressEditCell"];
        
        __block Address *address = self.card.addresses[indexPath.row];
        
        NSString *addressString = [address formattedString];
        
        cell.addressLabel.text = [addressString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        
//        // if address is less than one line don't attribute
//        if (![addressString containsString:@"\n"])
//            cell.addressLabel.text = addressString;
//        else {
//            NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//            [paragrahStyle setMinimumLineHeight:20];
//            
//            cell.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:addressString attributes:@{ NSParagraphStyleAttributeName: paragrahStyle }];
//        }
        
        cell.labelLabel.text = [[address.label lowercaseString] capitalizedString];
        
        [cell.deleteButton addEventHandler:^(id sender) {
            [self.card removeAddressesObject:address];
            [self.objectContext deleteObject:address];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0 && indexPath.row == 0) return 97;
    if (indexPath.section == 0 && indexPath.row == 0) return 58;
    if (indexPath.section == 0 && indexPath.row == 1) return 46;
    if (indexPath.section == 0 && indexPath.row == 2) return 20;
    
    if (indexPath.section == 1) {
        if (indexPath.row == [self.card.phones count]) return 46;
        if (indexPath.row == [self.card.phones count] + 1) return 20;
        return 46;
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == [self.card.emails count]) return 46;
        if (indexPath.row == [self.card.emails count] + 1) return 20;
        return 46;
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == [self.card.addresses count]) return 46;
        if (indexPath.row == [self.card.addresses count] + 1) return 20;
        return 46;
//        NSString *address = [self.card.addresses[indexPath.row] formattedString];
//        
//        // if address is one line return 72
//        if (![address containsString:@"\n"])
//            return 50;
//        
//        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//        [paragrahStyle setMinimumLineHeight:20];
//        
//        NSDictionary *attributesDictionary = @{ NSFontAttributeName: [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName: paragrahStyle };
//        CGRect frame = [address boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 66, 10000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributesDictionary context:nil];
//        return 30 + 18 + frame.size.height + 3;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:nil];
    }
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        NameEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"NameEditController"];
        
        controller.user = self.account;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.section == 1 && indexPath.row != [self.card.phones count] + 1) {
        PhoneEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PhoneEditController"];
        
        Phone *phone;
        
        if (indexPath.row == [self.card.phones count]) {
            phone = [[Phone alloc] initWithEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addPhonesObject:phone];
        } else
            phone = self.card.phones[indexPath.row];
        
        controller.phone = phone;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.section == 2 && indexPath.row != [self.card.emails count] + 1) {
        EmailEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"EmailEditController"];
        
        Email *email;
        
        if (indexPath.row == [self.card.emails count]) {
            email = [[Email alloc] initWithEntity:[NSEntityDescription entityForName:@"Email" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addEmailsObject:email];
        } else
            email = self.card.emails[indexPath.row];
        
        controller.email = email;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (indexPath.section == 3 && indexPath.row != [self.card.addresses count] + 1) {
        AddressEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressEditController"];
        
        Address *address;
        
        if (indexPath.row == [self.card.addresses count]) {
            address = [[Address alloc] initWithEntity:[NSEntityDescription entityForName:@"Address" inManagedObjectContext:self.objectContext] insertIntoManagedObjectContext:self.objectContext];
            [self.card addAddressesObject:address];
        } else
            address = self.card.addresses[indexPath.row];
        
        controller.address = address;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:YES];
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

- (IBAction)save:(id)sender {
    // save context
    
    self.account.syncStatus = [NSNumber numberWithInt:AccountUpdated];
    self.card.syncStatus = [NSNumber numberWithInt:CardUpdated];
    
    [self.objectContext performBlockAndWait:^{
        [self.objectContext save:nil];
    }];
    [[HandshakeCoreDataStore defaultStore] saveMainContext];
    
    // sync
    [Account sync];
    [Card sync];
    
    [self cancel:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
