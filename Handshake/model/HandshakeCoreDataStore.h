//
//  HandshakeCoreDataStore.h
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface HandshakeCoreDataStore : NSObject

+ (HandshakeCoreDataStore *)defaultStore;

- (void)deleteAllData;

- (NSURL *)applicationDocumentsDirectory;

- (NSManagedObjectContext *)mainManagedObjectContext;
- (NSManagedObjectContext *)childObjectContext;
- (void)saveMainContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

+ (NSDictionary *)removeNullsFromDictionary:(id)dictionary;

@end
