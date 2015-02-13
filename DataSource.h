//
//  DataSource.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-12.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject
+(instancetype) sharedInstance;
@property (nonatomic, strong, readonly) NSArray *mediaItems; // readonly= can't modify by other classes
@end
