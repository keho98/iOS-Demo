//
//  KHOItemStore.m
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOImageStore.h"
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
        NSString *path = [self itemArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (KHOItem *)createItem
{
    KHOItem *item = [[KHOItem alloc] init];
    [self.privateItems addObject:item];
    
    return item;
}

- (void)removeItem:(KHOItem *)item
{
    NSString *key = item.itemKey;
    
    [[KHOImageStore sharedStore] deleteImageForKey:key];
    
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    
    KHOItem *item = self.privateItems[fromIndex];
    [self.privateItems removeObjectAtIndex:fromIndex];
    
    [self.privateItems insertObject:item atIndex:toIndex];
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    #if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Path %@", path);
    #endif
    
    return [NSKeyedArchiver archiveRootObject:self.privateItems
                                       toFile:path];
}

@end
