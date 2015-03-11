//
//  PostToInstagramViewController.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-09.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "PostToInstagramViewController.h"
#import "FilterCollectionViewCell.h"

@interface PostToInstagramViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIImage *sourceImage; //store image passed into initWithImage:
@property (nonatomic, strong) UIImageView *previewImageView;  //display image with current filter

@property (nonatomic, strong) NSOperationQueue *photoFilterOperationQueue; //store filter operations
@property (nonatomic, strong) UICollectionView *filterCollectionView; //shows all filters available

@property (nonatomic, strong) NSMutableArray *filterImages; //hold filtered images
@property (nonatomic, strong) NSMutableArray *filterTitles; //hold filtered titles

@property (nonatomic, strong) UIButton *sendButton; //big purple "send to Instagram" button
@property (nonatomic, strong) UIBarButtonItem *sendBarButton; //show on short iPhones in the navigation bar where there's no room for sendButton

@end

@implementation PostToInstagramViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.sourceImage = sourceImage; // store source image passed in
        
        self.previewImageView = [[UIImageView alloc] initWithImage:self.sourceImage]; //init preview
        
        self.photoFilterOperationQueue = [[NSOperationQueue alloc] init]; // create operation queue
        
        // define layout of filter collection view
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(44, 64);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        // init a UICollectionView, set it's delegate and dataSource properties
        self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.filterCollectionView.dataSource = self;
        self.filterCollectionView.delegate = self;
        self.filterCollectionView.showsHorizontalScrollIndicator = NO; // to hide horizontal scroll indicator
        
        // 1st object in each array represents th unfiltered image
        self.filterImages = [NSMutableArray arrayWithObject:sourceImage];
        self.filterTitles = [NSMutableArray arrayWithObject:NSLocalizedString(@"None", @"Label for when no filter is applied to a photo")];
        
        // create buttons of same target-action method
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.sendButton.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1]; /*#58516c*/
        self.sendButton.layer.cornerRadius = 5;
        
        [self.sendButton setAttributedTitle:[self sendAttributedString] forState:UIControlStateNormal];
        
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.sendBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed:)];
        
        [self addFiltersToQueue];
    }
    return self;
}

#pragma mark - Buttons

- (NSAttributedString *) sendAttributedString {
    NSString *baseString = NSLocalizedString(@"SEND TO INSTAGRAM", @"send to Instagram button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13] range:range];
    [commentString addAttribute:NSKernAttributeName value:@1.3 range:range];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1] range:range];
    
    return commentString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.previewImageView];
    [self.view addSubview:self.filterCollectionView];
    
    // if device is short, use small barButton, if enough space, use big sendButton
    if (CGRectGetHeight(self.view.frame) > 500) {
        [self.view addSubview:self.sendButton];
    } else {
        self.navigationItem.rightBarButtonItem = self.sendBarButton;
    }
    
    [self.filterCollectionView registerClass:[FilterCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];   // changed registerClass after new subclass
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.filterCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"Apply Filter", @"apply filter view title");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    self.previewImageView.frame = CGRectMake(0, self.topLayoutGuide.length, edgeSize, edgeSize);
    
    CGFloat buttonHeight = 50;
    CGFloat buffer = 10;
    
    CGFloat filterViewYOrigin = CGRectGetMaxY(self.previewImageView.frame) + buffer;
    CGFloat filterViewHeight;
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        self.sendButton.frame = CGRectMake(buffer, CGRectGetHeight(self.view.frame) - buffer - buttonHeight, CGRectGetWidth(self.view.frame) - 2 * buffer, buttonHeight);
        
        filterViewHeight = CGRectGetHeight(self.view.frame) - filterViewYOrigin - buffer - buffer - CGRectGetHeight(self.sendButton.frame);
    } else {
        filterViewHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.previewImageView.frame) - buffer - buffer;
    }
    
    self.filterCollectionView.frame = CGRectMake(0, filterViewYOrigin, CGRectGetWidth(self.view.frame), filterViewHeight);
    
    // update with correct size based on collection view's determined height
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(CGRectGetHeight(self.filterCollectionView.frame) - 20, CGRectGetHeight(self.filterCollectionView.frame));
}

#pragma mark - UICollectionView delegate and data source

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // number of items always = number of filtered images available
    return self.filterImages.count;
}

- (FilterCollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // when the cell loads, we make sure there is an image view and a label on it, and set contents from appropriate arrays
    
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
/*    static NSInteger imageViewTag = 1000;
    static NSInteger labelTag = 1001;
    
    UIImageView *thumbnail = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
*/    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;

/*    CGFloat thumbnailEdgeSize = flowLayout.itemSize.width;

    // set frames of these items based on the flow layout's itemSize property we set in viewWillLayoutSubviews
    
    if (!thumbnail) {
        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        thumbnail.tag = imageViewTag;
        thumbnail.clipsToBounds = YES;
        
        [cell.contentView addSubview:thumbnail];
    }
    
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        label.tag = labelTag;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [cell.contentView addSubview:label];
    }

  */

    if (!cell) {
        cell = [[FilterCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, flowLayout.itemSize.width, flowLayout.itemSize.height)];
    }
    
    cell.thumbnail.image = self.filterImages[indexPath.row];
    cell.label.text = self.filterTitles[indexPath.row];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // user taps on one cell, we update preview image to show the image with that filter
    self.previewImageView.image = self.filterImages[indexPath.row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Photo Filters

- (void) addCIImageToCollectionView:(CIImage *)CIImage withFilterTitle:(NSString *)filterTitle {
    
    // this method handle finished filters and add them to the collection view
    
    // convert CIImage to UIImage
    UIImage *image = [UIImage imageWithCIImage:CIImage scale:self.sourceImage.scale orientation:self.sourceImage.imageOrientation];
    
    if (image) {
        // Decompress image
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [image drawAtPoint:CGPointZero];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger newIndex = self.filterImages.count;
            
            [self.filterImages addObject:image];
            [self.filterTitles addObject:filterTitle];
            
            [self.filterCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:newIndex inSection:0]]];
        });
    }
}

- (void) addFiltersToQueue {
    CIImage *sourceCIImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    
    // Noir filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *noirFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        // with CIFilter, call filterWithName: and specify filter as NSString
        
        if (noirFilter) // always make sue it is not nil
        {
            [noirFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            // all filters share same class CIFilter, so call filter with setValue:forKey
            [self addCIImageToCollectionView:noirFilter.outputImage withFilterTitle:NSLocalizedString(@"Noir", @"Noir Filter")];
        }
    }];
    
    // Boom filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *boomFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
        
        if (boomFilter) {
            [boomFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:boomFilter.outputImage withFilterTitle:NSLocalizedString(@"Boom", @"Boom Filter")];
        }
    }];
    
    // Warm filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *warmFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
        
        if (warmFilter) {
            [warmFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:warmFilter.outputImage withFilterTitle:NSLocalizedString(@"Warm", @"Warm Filter")];
        }
    }];
    
    // Pixel filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *pixelFilter = [CIFilter filterWithName:@"CIPixellate"];
        
        if (pixelFilter) {
            [pixelFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:pixelFilter.outputImage withFilterTitle:NSLocalizedString(@"Pixel", @"Pixel Filter")];
        }
    }];
    
    // Moody filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *moodyFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
        
        if (moodyFilter) {
            [moodyFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:moodyFilter.outputImage withFilterTitle:NSLocalizedString(@"Moody", @"Moody Filter")];
        }
    }];
    
    // Assignment - Chrome filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *chromeFilter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
        
        if (chromeFilter) {
            [chromeFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [self addCIImageToCollectionView:chromeFilter.outputImage withFilterTitle:NSLocalizedString(@"Chrome", @"Chrome Filter")];
        }
    }];
    
    // Assignment - Sharpen filter compounds filters CIPhotoEffectProcess and CISharpenLuminance
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        
        CIFilter *sharpenFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
        CIFilter *fadeFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];

        
        if (sharpenFilter) {
            [sharpenFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            [sharpenFilter setValue:@0.40 forKey:kCIInputSharpnessKey];
            CIImage *result = sharpenFilter.outputImage;
            
            if (fadeFilter) {
                [fadeFilter setValue:result forKeyPath:kCIInputImageKey];
            
                result = fadeFilter.outputImage;
            }
            
            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"Sharpen", @"Sharpen Filter")];
        }
    }];
          
    
    // Drunk filter uses the CIStraightenFilter combined with CIConvolution5X5 filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *drunkFilter = [CIFilter filterWithName:@"CIConvolution5X5"];
        CIFilter *tiltFilter = [CIFilter filterWithName:@"CIStraightenFilter"];
        
        if (drunkFilter) {
            [drunkFilter setValue:sourceCIImage forKey:kCIInputImageKey];
            
            CIVector *drunkVector = [CIVector vectorWithString:@"[0.5 0 0 0 0 0 0 0 0 0.05 0 0 0 0 0 0 0 0 0 0 0.05 0 0 0 0.5]"];
            [drunkFilter setValue:drunkVector forKeyPath:@"inputWeights"];
            
            CIImage *result = drunkFilter.outputImage;
            
            if (tiltFilter) {
                [tiltFilter setValue:result forKeyPath:kCIInputImageKey];
                [tiltFilter setValue:@0.2 forKeyPath:kCIInputAngleKey];
                result = tiltFilter.outputImage;
            }
            
            [self addCIImageToCollectionView:result withFilterTitle:NSLocalizedString(@"Drunk", @"Drunk Filter")];
        }
    }];
    
    // Film filter is also a compound filter
    
    [self.photoFilterOperationQueue addOperationWithBlock:^{
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
        [sepiaFilter setValue:@1 forKey:kCIInputIntensityKey];
        [sepiaFilter setValue:sourceCIImage forKey:kCIInputImageKey];
        
        CIFilter *randomFilter = [CIFilter filterWithName:@"CIRandomGenerator"];
        
        CIImage *randomImage = [CIFilter filterWithName:@"CIRandomGenerator"].outputImage;
        CIImage *otherRandomImage = [randomImage imageByApplyingTransform:CGAffineTransformMakeScale(1.5, 25.0)];
        
        CIFilter *whiteSpecks = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, randomImage,
                                 @"inputRVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputGVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputBVector", [CIVector vectorWithX:0.0 Y:1.0 Z:0.0 W:0.0],
                                 @"inputAVector", [CIVector vectorWithX:0.0 Y:0.01 Z:0.0 W:0.0],
                                 @"inputBiasVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                 nil];
        
        CIFilter *darkScratches = [CIFilter filterWithName:@"CIColorMatrix" keysAndValues:kCIInputImageKey, otherRandomImage,
                                   @"inputRVector", [CIVector vectorWithX:3.659f Y:0.0 Z:0.0 W:0.0],
                                   @"inputGVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputAVector", [CIVector vectorWithX:0.0 Y:0.0 Z:0.0 W:0.0],
                                   @"inputBiasVector", [CIVector vectorWithX:0.0 Y:1.0 Z:1.0 W:1.0],
                                   nil];
        
        CIFilter *minimumComponent = [CIFilter filterWithName:@"CIMinimumComponent"];
        
        CIFilter *composite = [CIFilter filterWithName:@"CIMultiplyCompositing"];
        
        if (sepiaFilter && randomFilter && whiteSpecks && darkScratches && minimumComponent && composite) {
            CIImage *sepiaImage = sepiaFilter.outputImage;
            CIImage *whiteSpecksImage = [whiteSpecks.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            CIImage *sepiaPlusWhiteSpecksImage = [CIFilter filterWithName:@"CISourceOverCompositing" keysAndValues:
                                                  kCIInputImageKey, whiteSpecksImage,
                                                  kCIInputBackgroundImageKey, sepiaImage,
                                                  nil].outputImage;
            
            CIImage *darkScratchesImage = [darkScratches.outputImage imageByCroppingToRect:sourceCIImage.extent];
            
            [minimumComponent setValue:darkScratchesImage forKey:kCIInputImageKey];
            darkScratchesImage = minimumComponent.outputImage;
            
            [composite setValue:sepiaPlusWhiteSpecksImage forKey:kCIInputImageKey];
            [composite setValue:darkScratchesImage forKey:kCIInputBackgroundImageKey];
            
            [self addCIImageToCollectionView:composite.outputImage withFilterTitle:NSLocalizedString(@"Film", @"Film Filter")];
        }
    }];
}

- (void) sendButtonPressed:(id)sender { // send filtered photo to Instagram
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://location?id=1"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LOL" message:NSLocalizedString(@"Add a caption and send your image in the Instagram app.", @"send image instructions") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"cancel button") otherButtonTitles:NSLocalizedString(@"Send", @"Send button"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = NSLocalizedString(@"Caption", @"Caption");
        
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Instagram App", nil) message:NSLocalizedString(@"The Instagram app isn't installed on your device. Please install it from the App Store.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        NSData *imagedata = UIImageJPEGRepresentation(self.previewImageView.image, 0.9f);
        
        NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"blocstagram"] URLByAppendingPathExtension:@"igo"];
        
        BOOL success = [imagedata writeToURL:fileURL atomically:YES];
        
        if (!success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save image", nil) message:NSLocalizedString(@"Your cropped and filtered photo couldn't be saved. Make sure you have enough disk space and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        documentController.UTI = @"com.instagram.exclusivegram";
        
        documentController.delegate = self;
        
        NSString *caption = [alertView textFieldAtIndex:0].text;
        
        if (caption.length > 0) {
            documentController.annotation = @{@"InstagramCaption": caption};
        }
        
        if (self.sendButton.superview) {
            [documentController presentOpenInMenuFromRect:self.sendButton.bounds inView:self.sendButton animated:YES];
        } else {
            [documentController presentOpenInMenuFromBarButtonItem:self.sendBarButton animated:YES];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    // when document interactiion controller finishes, we dismiss the crop view
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
