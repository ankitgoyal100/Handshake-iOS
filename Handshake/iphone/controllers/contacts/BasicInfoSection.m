//
//  ContactBasicInfoSection.m
//  Handshake
//
//  Created by Sam Ober on 9/9/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "BasicInfoSection.h"
#import "PhoneTableViewCell.h"
#import "EmailTableViewCell.h"
#import "AddressTableViewCell.h"
#import "Phone.h"
#import "Email.h"
#import "Address.h"

@interface BasicInfoSection()

@property (nonatomic, strong) Card *card;

@end

@implementation BasicInfoSection

- (id)initWithCard:(Card *)card viewController:(SectionBasedTableViewController *)viewController {
    self = [super initWithViewController:viewController];
    if (self) {
        self.card = card;
    }
    return self;
}

- (int)rows {
    return (int)[self.card.phones count] + (int)[self.card.emails count] + (int)[self.card.addresses count];
}

- (BaseTableViewCell *)cellForRow:(int)row indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    int r = row;
    
    if (r < [self.card.phones count]) {
        PhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell"];
        
        if (!cell) cell = [[PhoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhoneCell"];
        
        Phone *phone = self.card.phones[r];
        
        cell.phoneLabel.text = phone.number;
        cell.labelLabel.text = phone.label;
        
        return cell;
    }
    
    r -= [self.card.phones count];
    
    if (r < [self.card.emails count]) {
        EmailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmailCell"];
        
        if (!cell) cell = [[EmailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmailCell"];
        
        Email *email = self.card.emails[r];
        
        cell.emailLabel.text = email.address;
        cell.labelLabel.text = email.label;
        
        return cell;
    }
    
    r -= [self.card.emails count];
    
    AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    
    if (!cell) cell = [[AddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    
    Address *address = self.card.addresses[r];
    
    cell.address = [address formattedString];
    cell.labelLabel.text = address.label;
    
    return cell;
}

- (void)cellWasSelectedAtRow:(int)row indexPath:(NSIndexPath *)indexPath {
    int r = row;
    
    if (r < [self.card.phones count]) {
        Phone *phone = self.card.phones[r];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"telprompt://" stringByAppendingString:phone.number]]];
        return;
    }
    
    r -= [self.card.phones count];
    
    if (r < [self.card.emails count]) {
        Email *email = self.card.emails[r];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"mailto:" stringByAppendingString:email.address]]];
        return;
    }
    
    r -= [self.card.emails count];
    
    Address *address = self.card.addresses[r];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://maps.apple.com/?q=" stringByAppendingString:[[address formattedString] stringByReplacingOccurrencesOfString:@"\n" withString:@" "]]]];
}

@end
