//
//  User.m
//  Handshake
//
//  Created by Sam Ober on 4/4/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "User.h"
#import "Card.h"
#import "GroupMember.h"
#import "DateConverter.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeClient.h"
#import "HandshakeSession.h"
#import "ContactSync.h"

@interface User()

@property (nonatomic, strong) UIImage *loadedImage;
@property (nonatomic, strong) UIImage *loadedThumb;

@end

@implementation User

@dynamic userId;
@dynamic updatedAt;
@dynamic createdAt;

@dynamic contactUpdated;

@dynamic firstName;
@dynamic lastName;

@dynamic thumb;
@dynamic thumbData;

@dynamic picture;
@dynamic pictureData;

@dynamic isContact;
@dynamic requestSent;
@dynamic requestReceived;

@dynamic contacts;
@dynamic mutual;

@dynamic syncStatus;
@dynamic saved;
@dynamic savesToPhone;

@dynamic cards;
@dynamic groups;
@dynamic feedItems;
@dynamic suggestion;

@synthesize loadedImage;
@synthesize loadedThumb;

- (UIImage *)cachedImage {
    if (!self.pictureData) return nil;
    
    if (!self.loadedImage) {
        UIImage *image = [[UIImage alloc] initWithData:self.pictureData];
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        self.loadedImage = UIGraphicsGetImageFromCurrentImageContext(); // huge performance increase - no deferred decompression
        UIGraphicsEndImageContext();
    }
    
    return self.loadedImage;
}

- (UIImage *)cachedThumb {
    if (!self.thumbData) return nil;
    
    if (!self.loadedThumb) {
        UIImage *image = [[UIImage alloc] initWithData:self.thumbData];
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        self.loadedThumb = UIGraphicsGetImageFromCurrentImageContext(); // huge performance increase - no deferred decompression
        UIGraphicsEndImageContext();
    }
    
    return self.loadedThumb;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self observePictureData];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self observePictureData];
}

- (void)observePictureData {
    [self addObserver:self forKeyPath:@"pictureData"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
    [self addObserver:self forKeyPath:@"thumbData"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"pictureData"]) {
        self.loadedImage = nil;
    } else if ([keyPath isEqualToString:@"thumbData"]) {
        self.loadedThumb = nil;
    }
}

- (void)willTurnIntoFault {
    [self removeObserver:self forKeyPath:@"pictureData"];
    [self removeObserver:self forKeyPath:@"thumbData"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.userId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    
    self.isContact = dictionary[@"is_contact"];
    self.requestSent = dictionary[@"request_sent"];
    self.requestReceived = dictionary[@"request_received"];
    self.notifications = dictionary[@"notifications"];
    
    // if no thumb or thumb is different - update
    if (!dictionary[@"thumb"] || !self.thumb || ![dictionary[@"thumb"] isEqualToString:self.thumb]) {
        self.thumb = dictionary[@"thumb"];
        self.thumbData = nil;
    }
    
    // if no picture or picture is different - update
    if (!dictionary[@"picture"] || !self.picture || ![dictionary[@"picture"] isEqualToString:self.picture]) {
        self.picture = dictionary[@"picture"];
        self.pictureData = nil;
    }
    
    self.contacts = dictionary[@"contacts"];
    self.mutual = dictionary[@"mutual"];
    
    for (NSDictionary *cardDict in dictionary[@"cards"]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cardId == %@", cardDict[@"id"]];
        
        request.predicate = predicate;
        request.fetchLimit = 1;
        
        NSError *error;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results) {
            if ([results count] > 0) {
                Card *card = (Card *)results[0];
                [card updateFromDictionary:cardDict];
                card.user = self;
            } else {
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
                Card *card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                
                [card updateFromDictionary:cardDict];
                
                [self addCardsObject:card];
            }
        } else {
            // error - ignore
        }
    }
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.firstName)
        dict[@"first_name"] = self.firstName;
    if (self.lastName)
        dict[@"last_name"] = self.lastName;
    return dict;
}

- (NSString *)formattedName {
    if (self.lastName && [self.lastName length] > 0)
        return [self.firstName stringByAppendingString:[@" " stringByAppendingString:self.lastName]];
    return self.firstName;
}

- (NSString *)firstLetterOfName {
    [self willAccessValueForKey:@"firstLetterOfName"];
    NSString *letter = [[self.firstName substringToIndex:1] uppercaseString];
    [self didAccessValueForKey:@"firstLetterOfName"];
    if ([[NSCharacterSet letterCharacterSet] characterIsMember:[letter characterAtIndex:0]])
        return letter;
    else
        return @"#";
}

+ (User *)findOrCreateById:(NSNumber *)userId inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    request.fetchLimit = 1;
    
    __block NSArray *results;
    
    [context performBlockAndWait:^{
        results = [context executeFetchRequest:request error:nil];
    }];
    
    if (results && [results count] == 1) return results[0];
    
    User *user = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    user.userId = userId;
    return user;
}

/// FIXES

- (void)addCardsObject:(Card *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"cards"];
    [tempSet addObject:value];
}

- (void)removeCardsObject:(Card *)value {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"cards"];
    [tempSet removeObject:value];
}

- (void)addPhones:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"cards"];
    [tempSet addObjectsFromArray:[values array]];
}

- (void)removePhones:(NSOrderedSet *)values {
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"cards"];
    [tempSet removeObjectsInArray:[values array]];
}

@end
