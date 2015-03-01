//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-28.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> // added this line to accomoodate UIImageView

@interface MediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, weak) UIImageView *cellImageView;

@end

