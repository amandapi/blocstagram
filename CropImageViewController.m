//
//  CropImageViewController.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-08.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CropImageViewController.h"
#import "CropBox.h"
#import "Media.h"
#import "UIImage+ImageUtilities.h"

@interface CropImageViewController ()

@property (nonatomic, strong) CropBox *cropBox;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) UIToolbar *topCropView;
@property (nonatomic, strong) UIToolbar *bottomCropView;

@end

@implementation CropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {  // create a new MediaItem from the image
        self.media = [[Media alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [CropBox new];  // init the cropBox
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds = YES; // so crop image doesn't overlap other controllers during navigation controller transitions
    
    [self.view addSubview:self.cropBox]; // add cropBox to view hierarchy
    
    // create "crop image" button in navigation bar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                    initWithTitle:NSLocalizedString(@"Crop", @"Crop command")
                            style:UIBarButtonItemStyleDone
                           target:self
                           action:@selector(cropPressed:)];
    
    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil]); // set title
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO; // disable its automatic behavior of automatically adjusting scroll view insets
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1]; // set background color
    [self createViews];
    [self addViewsToViewHierarchy];
}

- (void) createViews {
    self.topCropView = [UIToolbar new];
    self.bottomCropView = [UIToolbar new];
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topCropView.barTintColor = whiteBG;
    self.bottomCropView.barTintColor = whiteBG;
    self.topCropView.alpha = 0.5;
    self.bottomCropView.alpha = 0.5;
}

- (void) addViewsToViewHierarchy {
    NSMutableArray *views = [@[self.topCropView, self.bottomCropView] mutableCopy];
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    // sizes and centers cropBox
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topCropView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 17);
    
    CGFloat yOriginOfbottomCropView = CGRectGetMaxY(self.topCropView.frame) + width;
    CGFloat heightOfBottomCropView = CGRectGetHeight(self.view.frame) - yOriginOfbottomCropView;
    self.bottomCropView.frame = CGRectMake(0, yOriginOfbottomCropView, width, heightOfBottomCropView);
    
    // reduce scrollView's frame to same as cropBox
    self.scrollView.frame = self.cropBox.frame;
    
    // disable clipsToBounds so user can see image outside of cropBox
    self.scrollView.clipsToBounds = NO;
    
    // we have changed scrollView's frame, so recalculate zoome scale
    [self recalculateZoomScale];
    
    // on first load, zoom picture all the way out
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    
    // create rect base on scrollView's panned and zoomed location
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    // pass the rect, painlessly, to the 2 category methods we created in UIImage+ImageUtilities
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    // call delegate
    [self.delegate cropControllerFinishedWithImage:scrollViewCrop];
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
