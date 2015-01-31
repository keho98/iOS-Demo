//
//  KHOItemStore.m
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOItemStore.h"
#import "KHOItem.h"

@interface KHOItemStore ()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation KHOItemStore

+ (instancetype)sharedStore
{
    static KHOItemStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[KHOItemStore sharedStore]"];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _privateItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (KHOItem *)createItem
{
    KHOItem *item = [KHOItem randomItem];
    [self.privateItems addObject:item];
    
    return item;
}

@end
