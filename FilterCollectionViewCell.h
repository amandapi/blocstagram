//
//  FilterCollectionViewCell.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-10.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

- (CGFloat) thumbnailEdgeSize;

@end
