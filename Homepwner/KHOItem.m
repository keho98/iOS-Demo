//
//  KHOItem.m
//  RandomItems
//
//  Created by Kevin Ho on 1/27/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOItem.h"

@implementation KHOItem

+ (instancetype)randomItem
{
    
    NSArray *randomAdjectiveList = @[@"Red", @"Blue", @"Green"];
    NSArray *randomNounList = @[@"Bear", @"Spork", @"Mac"];
    
    NSInteger adjectiveIndex = arc4random() % [randomAdjectiveList count];
    NSInteger nounIndex = arc4random() % [randomNounList count];
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                           randomAdjectiveList[adjectiveIndex],
                           randomNounList[nounIndex]];
    
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%d%d",
                                    arc4random() % 10,
                                    arc4random() % 10];
    
    int randomValue = arc4random() % 100;
    
    KHOItem *newItem = [[self alloc] initWithItemName:randomName
                                       valueInDollars:randomValue
                                         serialNumber:randomSerialNumber];
    
    return newItem;
}

- (instancetype)initWithItemName:(NSString *)name
                  valueInDollars:(int)value
                    serialNumber:(NSString *)sNumber
{
    self = [super init];
    
    if (self) {
        _itemName = name;
        _serialNumber = sNumber;
        _valueInDollars = value;
        _dateCreated = [NSDate new];
    }
    
    return self;
}

- (instancetype)initWithItemName:(NSString *)name
{
    return [self initWithItemName:name
                   valueInDollars:0
                     serialNumber:@""];
}

- (instancetype)init
{
    return [self initWithItemName:@"Item"];
}

- (void)setContainedItem:(KHOItem *)containedItem
{
    _containedItem = containedItem;
    self.containedItem.container = self;
}

@end
