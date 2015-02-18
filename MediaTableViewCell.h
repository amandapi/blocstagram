//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-14.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;


+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end

