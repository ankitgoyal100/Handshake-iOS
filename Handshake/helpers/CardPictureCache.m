//
//  CardPictureCache.m
//  Handshake
//
//  Created by Sam Ober on 9/21/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "CardPictureCache.h"
#import <CoreData/CoreData.h>
#import "AsyncImageView.h"
#import "HandshakeCoreDataStore.h"
#import "Card.h"

@implementation CardPictureCache

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoaded:) name:AsyncImageLoadDidFinish object:nil];
    }
    return self;
}

- (void)imageLoaded:(NSNotification *)notification {
    // run in background thread
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *urlString = [(NSURL *)[notification userInfo][AsyncImageURLKey] absoluteString];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"picture == %@", urlString];
        
        __block NSArray *results;
        
        __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
        
        [objectContext performBlockAndWait:^{
            NSError *error;
            results = [objectContext executeFetchRequest:request error:&error];
        }];
        
        if (![results count]) {
            // error or no matching card - return
            return;
        }
        
        Card *card = results[0];
        
        card.pictureData = UIImageJPEGRepresentation([notification userInfo][AsyncImageImageKey], 1);
        
        // save
        
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
    });
}

@end
