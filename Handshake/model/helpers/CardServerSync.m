//
//  CardServerSync.m
//  Handshake
//
//  Created by Sam Ober on 6/13/15.
//  Copyright (c) 2015 Handshake. All rights reserved.
//

#import "CardServerSync.h"
#import "HandshakeClient.h"
#import "HandshakeCoreDataStore.h"
#import "HandshakeSession.h"
#import "DateConverter.h"
#import "Card.h"

@implementation CardServerSync

+ (void)sync {
    [self syncWithCompletionBlock:nil];
}

+ (void)syncWithCompletionBlock:(void (^)())successBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // retrieve all cards
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"GET" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/cards"] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
        operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        operation.responseSerializer = [HandshakeClient client].responseSerializer;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // get account
            Account *account = [[HandshakeSession currentSession] account];
            
            if (!account) {
                // no current account found - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock) successBlock();
                });
                return;
            }
            
            // get account in background context
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
            request.predicate = [NSPredicate predicateWithFormat:@"userId == %@", account.userId];
            request.fetchLimit = 1;
            
            __block NSArray *results = nil;
            
            __block NSManagedObjectContext *objectContext = [[HandshakeCoreDataStore defaultStore] childObjectContext];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (![results count]) {
                // no current account found - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock) successBlock();
                });
                return;
            }
            
            account = results[0];
            
            // map cards to ids
            NSMutableDictionary *cards = [[NSMutableDictionary alloc] init];
            for (NSDictionary *cardDict in responseObject[@"cards"]) {
                cards[cardDict[@"id"]] = cardDict;
            }
            
            // get the current cards
            results = [account.cards array];
            
            // update/delete records
            for (Card *card in results) {
                // if card is new skip
                if ([card.syncStatus intValue] == CardCreated) continue;
                
                NSDictionary *cardDict = cards[card.cardId];
                
                if (!cardDict) {
                    // record doesn't exist on server - delete card
                    [account removeCardsObject:card];
                    [objectContext deleteObject:card];
                } else {
                    // update if card is newer
                    if ([card.syncStatus intValue] == CardSynced) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:cardDict]];
                    }
                }
                
                [cards removeObjectForKey:card.cardId];
            }
            
            // any remaining cards are new
            for (NSNumber *cardId in [cards allKeys]) {
                NSDictionary *cardDict = cards[cardId];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:objectContext];
                Card *card = [[Card alloc] initWithEntity:entity insertIntoManagedObjectContext:objectContext];
                
                [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:cardDict]];
                card.syncStatus = [NSNumber numberWithInt:CardSynced];
                
                [account addCardsObject:card];
            }
            
            // sync current cards with server
            
            request = [[NSFetchRequest alloc] initWithEntityName:@"Card"];
            
            request.predicate = [NSPredicate predicateWithFormat:@"syncStatus!=%@ AND user==%@", [NSNumber numberWithInt:CardSynced], account];
            
            [objectContext performBlockAndWait:^{
                NSError *error;
                results = [objectContext executeFetchRequest:request error:&error];
            }];
            
            if (!results) {
                // error - stop sync
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (successBlock) successBlock();
                });
                return;
            }
            
            NSMutableArray *operations = [[NSMutableArray alloc] init];
            
            for (Card *card in results) {
                // create, update, or delete cards
                if ([card.syncStatus intValue] == CardCreated) {
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                    [params addEntriesFromDictionary:[card dictionary]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"POST" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:@"/cards"] absoluteString] parameters:params error:nil]];
                    
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"card"]]];
                        card.syncStatus = [NSNumber numberWithInt:CardSynced];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                } else if ([card.syncStatus intValue] == CardUpdated) {
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[[HandshakeSession currentSession] credentials]];
                    [params addEntriesFromDictionary:[card dictionary]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"PUT" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/cards/%d", [card.cardId intValue]]] absoluteString] parameters:params error:nil]];
                    
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [card updateFromDictionary:[HandshakeCoreDataStore removeNullsFromDictionary:responseObject[@"card"]]];
                        card.syncStatus = [NSNumber numberWithInt:CardSynced];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                } else if ([card.syncStatus intValue] == CardDeleted) {
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[[HandshakeClient client].requestSerializer requestWithMethod:@"DELETE" URLString:[[[HandshakeClient client].baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/cards/%d", [card.cardId intValue]]] absoluteString] parameters:[[HandshakeSession currentSession] credentials] error:nil]];
                    operation.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                    operation.responseSerializer = [HandshakeClient client].responseSerializer;
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [objectContext deleteObject:card];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        // do nothing
                    }];
                    [operations addObject:operation];
                }
            }
            
            NSArray *preparedOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                // do nothing
            } completionBlock:^(NSArray *operations) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    // save
                    [objectContext performBlockAndWait:^{
                        [objectContext save:nil];
                    }];
                    [[HandshakeCoreDataStore defaultStore] saveMainContext];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // end sync
                        if (successBlock) successBlock();
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:CardSyncCompleted object:nil];
                    });
                });
            }];
            [[[NSOperationQueue alloc] init] addOperations:preparedOperations waitUntilFinished:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[operation response] statusCode] == 401) {
                    [[HandshakeSession currentSession] invalidate];
                } else {
                    // retry
                    [self syncWithCompletionBlock:successBlock];
                }
            });
        }];
        [operation start];
        //[[[NSOperationQueue alloc] init] addOperation:operation];
    });
}

@end
