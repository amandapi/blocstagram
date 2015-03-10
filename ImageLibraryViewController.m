//
//  ImageLibraryViewController.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-08.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ImageLibraryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CropImageViewController.h"
#import "FilterCollectionViewCell.h"

@interface ImageLibraryViewController () <CropImageViewControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *library; //entire collection of photos/videos
@property (nonatomic, strong) NSMutableArray *groups; //array of ALAssetsGroup objects, each album in photoLibrary is an ALAssetsGroup
@property (nonatomic, strong) NSMutableArray *arraysOfAssets; //each nested array contains ALAsset objects from the corresponding album. It and groups always have same number of objects.

@end

@implementation ImageLibraryViewController


- (instancetype) init {
    
    // from Apple: UICollectionViewLayout manages layout, subclass UICollectionViewFlowLayout organizes items into a grid with optional header and footer views for each section
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(100, 100); // will be updated once we know device's screen size
    
    self = [super initWithCollectionViewLayout:layout];
    
    if (self) {
        self.library = [[ALAssetsLibrary alloc] init];
        self.groups = [NSMutableArray array];
        self.arraysOfAssets = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // register the default classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusable view"]; //supplementaryView are headers and footers
    
    self.collectionView.backgroundColor = [UIColor whiteColor];  // set background color
    
    UIImage *cancelImage = [UIImage imageNamed:@"x"]; // make cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate imageLibraryViewController:self didCompleteWithImage:nil];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // fit as many as possible on each row but row size !< 100 pt
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat minWidth = 60; // was 100
    NSInteger divisor = width / minWidth;
    CGFloat cellSize = width / divisor;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(cellSize, cellSize);
    flowLayout.minimumInteritemSpacing = 0.5;  // 0 = no space between cells
    flowLayout.minimumLineSpacing = 6;  // 0 = no space between cells
    flowLayout.headerReferenceSize = CGSizeMake(width, 30); // header 30 pt high
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.groups removeAllObjects];
    [self.arraysOfAssets removeAllObjects];
    
    // ask library to enumerate thru all ALAssetsGroup
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [self.groups addObject:group]; // for each group, add group to self.groups
            NSMutableArray *assets = [NSMutableArray array];
            [self.arraysOfAssets addObject:assets];
            
            // enumerate through each ALAsset in each group and add them to array
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [assets addObject:result];
                }
            }];
            
            [self.collectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        // usually failure is due to a permission issue
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                            message:error.localizedRecoverySuggestion
                           delegate:nil
                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button")
                  otherButtonTitles:nil];
        
        [alert show];
        
        [self.collectionView reloadData];
    }];
}

- (void) viewWillDisappear:(BOOL)animated { // to save memory
    [super viewWillDisappear:animated];
    
    [self.groups removeAllObjects];
    [self.arraysOfAssets removeAllObjects];
    [self.collectionView reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.groups.count;  // tell the collectionView how many sections are there
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { // tell collectionView how many items are in each section
    NSArray *imagesArray = self.arraysOfAssets[section];
    
    if (imagesArray) {
        return imagesArray.count;
    }
    return 0;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // given a section and a row (index path), we produce a UICollectionViewCell to display collection view. One image view takes up entire cell.
    
    static NSInteger imageViewTag = 54321;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.tag = imageViewTag;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }
    
    ALAsset *asset = self.arraysOfAssets[indexPath.section][indexPath.row];
    CGImageRef imageRef = asset.thumbnail;
    
    UIImage *image;
    
    if (imageRef) {
        image = [UIImage imageWithCGImage:imageRef]; // put thumbnail inside the display cell
    }
    
    imageView.image = image;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // same as last method, given a section, we provide a UICollectionReusableView that represents a section header.
    
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"reusable view" forIndexPath:indexPath];
    
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        static NSInteger headerLabelTag = 2468;
        
        UILabel *label = (UILabel *)[view viewWithTag:headerLabelTag];
        
        if (!label) {
            label = [[UILabel alloc] initWithFrame:view.bounds];
            label.tag = headerLabelTag;
            label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            label.textAlignment = NSTextAlignmentCenter;
            
            label.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:235/255.0f alpha:1.0f];
            
            [view addSubview:label];
        }
        
        ALAssetsGroup *group = self.groups[indexPath.section];
        
        //Use any color you want or skip defining it
        UIColor* textColor = [UIColor colorWithWhite:0.35 alpha:1];
        
        NSDictionary *textAttributes = @{NSForegroundColorAttributeName : textColor,
                                         NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:14],
                                         NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
        
        NSAttributedString* attributedString;
        // NSAttributedString will throw an exception if it is nil.
        
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        
        if (groupName) {
            attributedString = [[NSAttributedString alloc] initWithString:groupName attributes:textAttributes];
        }
        
        label.attributedText = attributedString;
    }
    
    return view;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // when user taps thumbnail, we will get full resolution image and pass it to CropImageViewController
    ALAsset *asset = self.arraysOfAssets[indexPath.section][indexPath.row];
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    CGImageRef imageRef = representation.fullResolutionImage;
    
    UIImage *imageToCrop;
    
    if (imageRef) {
        imageToCrop = [UIImage imageWithCGImage:imageRef
                                          scale:representation.scale
                                    orientation:(UIImageOrientation)representation.orientation];
    }
    
    CropImageViewController *cropVC = [[CropImageViewController alloc] initWithImage:imageToCrop];
    cropVC.delegate = self;
    [self.navigationController pushViewController:cropVC animated:YES];
}

#pragma mark - CropImageViewControllerDelegate

- (void) cropControllerFinishedWithImage:(UIImage *)croppedImage {
    // if user crops an image, we inform the image library controller's delegate
    [self.delegate imageLibraryViewController:self didCompleteWithImage:croppedImage];
}

@end