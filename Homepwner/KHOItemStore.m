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

@import CoreData;


@interface KHOItemStore ()

@property (nonatomic) NSMutableArray *privateItems;
@property (nonatomic, strong) NSMutableArray *allAssetTypes;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;

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
        //Read in core data model
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open Failure"
                        format:[error localizedDescription]];
        }
        
        //Create context
        _context = [[NSManagedObjectContext alloc] init];
        _context.persistentStoreCoordinator = psc;
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
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (BOOL)saveChanges
{
    //NSString *path = [self itemArchivePath];
    #if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Saving changes");
    #endif
    
    //return [NSKeyedArchiver archiveRootObject:self.privateItems
    //                                   toFile:path];
    
    NSError *error;
    BOOL success = [self.context save:&error];
    if (!success) {
        [NSException raise:@"Error saving %@"
                    format:[error localizedDescription]];
    }
    return success;
}

@end
