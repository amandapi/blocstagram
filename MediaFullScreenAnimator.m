//
//  MediaFullScreenAnimator.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-28.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MediaFullScreenAnimator.h"
#import "MediaFullScreenViewController.h"

@implementation MediaFullScreenAnimator


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;  // specify animation is 0.2s long
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {  // self.presenting == YES
        
        MediaFullScreenViewController *fullScreenVC = (MediaFullScreenViewController *)toViewController;
        
        fromViewController.view.userInteractionEnabled = NO; // fromViewController points to table view controller
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect endFrame = fromViewController.view.frame;
        
        toViewController.view.frame = startFrame;  // toViewController points to full screen image controller, set full screen controller's frame to be directly over the tapped image
        fullScreenVC.imageView.frame = toViewController.view.bounds; // set image view's frame to fill frame
        
        // configure looks when animation starts
        [UIView animateWithDuration:/*how long the animation takes */ [self transitionDuration:transitionContext]
                         animations:^{ /* configure looks when animation ends */
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fullScreenVC.view.frame = endFrame; // animate the frame to endFrame (entire screen)
            [fullScreenVC centerScrollView];
        }               completion:^(BOOL finished) { /* transition has completed */
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        MediaFullScreenViewController *fullScreenVC = (MediaFullScreenViewController *)fromViewController;
        
        CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect imageStartFrame = [fullScreenVC.view convertRect:fullScreenVC.imageView.frame fromView:fullScreenVC.scrollView];
        CGRect imageEndFrame = [transitionContext.containerView convertRect:endFrame toView:fullScreenVC.view];
        
        imageEndFrame.origin.y = 0;
        
        [fullScreenVC.view addSubview:fullScreenVC.imageView];
        fullScreenVC.imageView.frame = imageStartFrame;
        fullScreenVC.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fullScreenVC.view.frame = endFrame;
            fullScreenVC.imageView.frame = imageEndFrame;
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
