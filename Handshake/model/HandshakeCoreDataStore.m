//
//  HandshakeCoreDataStore.m
//  Handshake
//
//  Created by Sam Ober on 9/16/14.
//  Copyright (c) 2014 Handshake. All rights reserved.
//

#import "HandshakeCoreDataStore.h"

@interface HandshakeCoreDataStore()

@property (strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation HandshakeCoreDataStore

+ (HandshakeCoreDataStore *)defaultStore {
    static dispatch_once_t once;
    static HandshakeCoreDataStore *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSaveBackgroundQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self backgroundManagedObjectContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSaveMainQueueContext:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[self mainManagedObjectContext]];
    }
    return self;
}

- (void)contextDidSaveBackgroundQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.mainManagedObjectContext performBlock:^{
            [self.mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.backgroundManagedObjectContext performBlock:^{
            [self.backgroundManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

+ (NSDictionary *)removeNullsFromDictionary:(id)dictionary {
    if ([dictionary isKindOfClass:[NSNull class]]) return nil;
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) return dictionary;
    
    NSMutableDictionary *denulled = [[NSMutableDictionary alloc] init];
    
    for (id key in dictionary) {
        NSObject *value = dictionary[key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (id object in (NSArray *)value) {
                id checkedObject = [self removeNullsFromDictionary:object];
                if (checkedObject) [array addObject:checkedObject];
            }
            denulled[key] = array;
        } else {
            id checkedValue = [self removeNullsFromDictionary:value];
            if (checkedValue) denulled[key] = checkedValue;
        }
    }
    
    return denulled;
}

#pragma mark - Core Data stack

// Used to propegate saves to the persistent store (disk) without blocking the UI
- (NSManagedObjectContext *)mainManagedObjectContext {
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainManagedObjectContext performBlockAndWait:^{
            [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
        
    }
    return _mainManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSManagedObjectContext *masterContext = [self mainManagedObjectContext];
    if (masterContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:masterContext];
        }];
    }
    
    return _backgroundManagedObjectContext;
}

- (void)saveMainContext {
    [self.mainManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.mainManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save master context due to %@", error);
        }
    }];
}

- (void)saveBackgroundContext {
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.backgroundManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save background context due to %@", error);
        }
    }];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Handshake" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Handshake.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
