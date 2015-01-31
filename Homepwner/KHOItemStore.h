//
//  KHOItemStore.h
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

@class KHOItem;

#import <Foundation/Foundation.h>

@interface KHOItemStore : NSObject

@property (nonatomic, readonly, copy) NSArray *allItems;

+ (instancetype)sharedStore;
- (KHOItem *)createItem;

@end
