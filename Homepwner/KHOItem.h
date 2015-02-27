//
//  KHOItem.h
//  Homepwner
//
//  Created by Kevin Ho on 2/27/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

@import UIKit;
@import CoreData;


@interface KHOItem : NSManagedObject

@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic) double * orderingValue;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic) int *valueInDollars;
@property (nonatomic, strong) NSManagedObject *assetType;
@property (nonatomic, strong) NSString *itemKey;

- (void)setThumbnailFromImage:(UIImage *)image;

@end
