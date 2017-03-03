//
//  HorizontalCollectionViewLayout.m
//  iBeacon_TMobile
//
//  Created by Ram Venugopal on 24/09/16.
//  Copyright © 2016 Rajasekaran Sagadevan. All rights reserved.
//

#import "HorizontalCollectionViewLayout.h"

@implementation HorizontalCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    NSInteger verticalItemsCount = (NSInteger)floorf(self.collectionView.bounds.size.height / self.itemSize.height);
    NSInteger horizontalItemsCount = (NSInteger)floorf(self.collectionView.bounds.size.width / self.itemSize.width);
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
    
    for (NSInteger i = 0; i < attributesArray.count; i++) {
        UICollectionViewLayoutAttributes *attributes = attributesArray[i];
        NSInteger currentPage = (NSInteger)floor((double)i / (double)itemsPerPage);
        NSInteger currentRow = (NSInteger)floor((double)(i - currentPage * itemsPerPage) / (double)horizontalItemsCount);
        NSInteger currentColumn = i % horizontalItemsCount;
        CGRect frame = attributes.frame;
        frame.origin.x = self.itemSize.width * currentColumn + currentPage * self.collectionView.bounds.size.width;
        frame.origin.y = self.itemSize.height * currentRow;
        attributes.frame = frame;
    }
    return attributesArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
