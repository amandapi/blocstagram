//
//  DataSource.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-12.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;
typedef void (^NewItemCompletionBlock)(NSError *error);
@interface DataSource : NSObject

extern NSString *const ImageFinishedNotification;

+(instancetype) sharedInstance;
+ (NSString *) instagramClientID;

@property (nonatomic, strong, readonly) NSArray *mediaItems; // readonly= can't modify by other classes
@property (nonatomic, strong, readonly) NSString *accessToken;

- (void) deleteMediaItem:(Media *)item;
- (void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void) downloadImageForMediaItem:(Media *)mediaItem;
- (void) toggleLikeOnMediaItem:(Media *)mediaItem;
- (void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText;

@end
