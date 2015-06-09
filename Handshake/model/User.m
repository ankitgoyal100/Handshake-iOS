//
//  User.m
//  Handshake
//
//  Created by Sam Ober on 4/4/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "User.h"
#import "Card.h"
#import "Contact.h"
#import "GroupMember.h"
#import "DateConverter.h"

@interface User()

@property (nonatomic, strong) UIImage *loadedImage;

@end

@implementation User

@dynamic createdAt;
@dynamic firstName;
@dynamic lastName;
@dynamic picture;
@dynamic pictureData;
@dynamic updatedAt;
@dynamic userId;
@dynamic contacts;
@dynamic mutual;
@dynamic cards;
@dynamic contact;
@dynamic groups;

@synthesize loadedImage;

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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"pictureData"]) {
        self.loadedImage = nil;
    }
}

- (void)willTurnIntoFault {
    [self removeObserver:self forKeyPath:@"pictureData"];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.userId = dictionary[@"id"];
    self.createdAt = [DateConverter convertToDate:dictionary[@"created_at"]];
    self.updatedAt = [DateConverter convertToDate:dictionary[@"updated_at"]];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    // if no picture or picture is different - update
    if (!dictionary[@"picture"] || (dictionary[@"picture"] && !self.picture)) {
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
    if (self.firstName && self.lastName)
        return [self.firstName stringByAppendingString:[@" " stringByAppendingString:self.lastName]];
    if (self.firstName) return self.firstName;
    return self.lastName;
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
