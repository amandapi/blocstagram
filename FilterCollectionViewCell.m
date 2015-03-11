//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-10.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell ()
@end

@implementation FilterCollectionViewCell

- (id) initWithFrame: (CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.thumbnailEdgeSize, self.thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.clipsToBounds = YES;
        
        [self.contentView addSubview:self.thumbnail];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.thumbnailEdgeSize, self.thumbnailEdgeSize, 20)];  //0, 0, 0, 20
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (CGFloat) thumbnailEdgeSize {
    return self.bounds.size.width;
}

@end


