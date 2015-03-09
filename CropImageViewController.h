//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-08.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

// how does this controller work? another controller passes it a UIImage and set itself as the crop controller's delegate, then the user sizes and crops the image, and the controller passes back the cropped UIImage to its delegate
@interface CropImageViewController : MediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;

@end