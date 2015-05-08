//
//  CardPictureCache.m
//  Handshake
//
//  Created by Sam Ober on 9/21/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "UserPictureCache.h"
#import <CoreData/CoreData.h>
#import "AsyncImageView.h"
#import "HandshakeCoreDataStore.h"
#import "User.h"

@implementation UserPictureCache

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
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        //request.fetchLimit = 1;
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
        
        for (User *user in results) {
            user.pictureData = UIImageJPEGRepresentation([notification userInfo][AsyncImageImageKey], 1);
        }
        
        [objectContext performBlockAndWait:^{
            [objectContext save:nil];
        }];
        [[HandshakeCoreDataStore defaultStore] saveMainContext];
    });
}

@end