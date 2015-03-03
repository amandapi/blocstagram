//
//  DataSource.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-12.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h> // "" when import local files, <> external files
#import <AFNetworking/AFNetworking.h>

@interface DataSource (){
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation DataSource

+ (NSString *) instagramClientID {
    return @"b79d6da1f4304dbe86ac997c0bf8a130";
}

+ (instancetype) sharedInstance {   // only run once
    static dispatch_once_t once;   // stores completion staus of dispatch_once
    static id sharedInstance;    // stores created shared instance
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    // Initialize AFHTTPRequestOperationManager
    
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    // baseURL is automatically prepended to following relative URLs
    
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    // AFImageResponseSerializer has scale set to 100%
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    // AFCompoundResponseSerializer automatically figures out whichtype of object is returned
    
    self.instagramOperationManager.responseSerializer = serializer;
    
    
    if (self) {
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            // Read the file at launch: first queue to background
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
            // update changes to main queue
                dispatch_async(dispatch_get_main_queue(), ^{
            // Assignment: at launch, if cached images are found on disk, fetch newer contents from API
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy]; // make a mutable copy cuz the copy stored to disk is immutable.
                        [self populateDataWithParameters:nil completionHandler:nil]; // populate data
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    return self;
}

- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
          [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}

- (NSString *) pathForFilename:(NSString *) filename {
    // To create a string containing an absolute path to the user's doc directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

- (id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

- (void) deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma mark - Request Items

- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO;
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        
        // Assignment
        // Parameters might be null (if there is no parameter, eg, all items have been deleted) so make sure object exists
       
        NSDictionary *parameters = nil;
        if (minID != nil)
        parameters = @{@"min_id" : minID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
    }


- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {

    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};

    [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    }
}

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
 
        //  to create a parameters dictionary for the access token, and add other parameters being passed in, eg, min_id or max_id.
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        // Get requestOperationManager to get resource, and if successful, send to parseDataFromFeedDictionary for parsing
        [self.instagramOperationManager
                GET:@"users/self/feed"
         parameters:mutableParameters
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                if (completionHandler) {
                                                completionHandler(nil);
                                }
                            }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
     }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
    //        [self downloadImageForMediaItem:mediaItem];
        }
    }

    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    if (tmpMediaItems.count > 0) {
        // Write the changes to disk: first, dispatch_async to background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // then make an array containing first 50 items
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            // then convert array to NSData to save to disk
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            // When save to disk we should always pass 2 options:
            // NSDataWritingAtomic ensures a complete file is saved, and NSDataWritingFileProtectionCompleteUnlessOpen protects user privacy.
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
    }
}


- (void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        [self.instagramOperationManager
               GET:mediaItem.mediaURL.absoluteString
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if ([responseObject isKindOfClass:[UIImage class]]) {
                                mediaItem.image = responseObject;
                                mediaItem.downloadState = MediaDownloadStateHasImage;
                                NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                            } else {
                                mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
             
             mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
             
             if ([error.domain isEqualToString:NSURLErrorDomain]) {
                 // A networking problem
                 if (error.code == NSURLErrorTimedOut ||
                     error.code == NSURLErrorCancelled ||
                     error.code == NSURLErrorCannotConnectToHost ||
                     error.code == NSURLErrorNetworkConnectionLost ||
                     error.code == NSURLErrorNotConnectedToInternet ||
                     error.code == kCFURLErrorInternationalRoamingOff ||
                     error.code == kCFURLErrorCallIsActive ||
                     error.code == kCFURLErrorDataNotAllowed ||
                     error.code == kCFURLErrorRequestBodyStreamExhausted) {
                     
                     // It might work if we try again
                     mediaItem.downloadState = MediaDownloadStateNeedsImage;
                 }
             }
        }];
    }
}

@end
