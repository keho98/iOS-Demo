//
//  KHOItem.h
//  RandomItems
//
//  Created by Kevin Ho on 1/27/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHOItem : NSObject

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@property (nonatomic, copy) NSString *itemKey;

+ (instancetype)randomItem;

// Designated initializer for KHOItem
- (instancetype)initWithItemName:(NSString *)name
                  valueInDollars:(int)value
                    serialNumber:(NSString *)sNumber;

- (instancetype)initWithItemName:(NSString *)name;

@end
