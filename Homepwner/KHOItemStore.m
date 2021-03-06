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

#import "AppDelegate.h"

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
        
        [self loadAllItems];
    }
    return self;
}

- (NSArray *)allItems
{
    return [self.privateItems copy];
}

- (KHOItem *)createItem
{
    double order;
    if ([self.allItems count] == 0) {
        order = 1.0;
    } else {
        order = [[self.privateItems lastObject] orderingValue] + 1.0;
    }
    
    #if TARGET_IPHONE_SIMULATOR
    NSLog(@"Adding after %lu items, order = %.2f", (unsigned long)[self.privateItems count], order);
    #endif
    
    KHOItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"KHOItem"
                                                  inManagedObjectContext:self.context];
    item.orderingValue = order;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    item.valueInDollars = [defaults integerForKey:KHONextItemValuePrefsKey];
    item.itemName = [defaults objectForKey:KHONextItemNamePrefsKey];
    
    [self.privateItems addObject:item];
    
    return item;
}

- (void)removeItem:(KHOItem *)item
{
    NSString *key = item.itemKey;
    
    [[KHOImageStore sharedStore] deleteImageForKey:key];
    
    [self.context deleteObject:item];
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
    
    double lowerBound = 0.0;
    
    if (toIndex > 0) {
        lowerBound = [self.privateItems[(toIndex - 1)] orderingValue];
    } else {
        lowerBound = [self.privateItems[1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    if (toIndex < [self.privateItems count] - 1) {
        upperBound = [self.privateItems[(toIndex + 1)] orderingValue];
    } else {
        upperBound = [self.privateItems[(toIndex - 1)] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"moving to order %f", newOrderValue);
    item.orderingValue = newOrderValue;
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    #if TARGET_IPHONE_SIMULATOR
    NSLog(@"Archive path: %@", documentDirectory);
    #endif
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

- (void)loadAllItems
{
    if (!self.privateItems) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:@"KHOItem"
                                      inManagedObjectContext:self.context];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                             ascending:YES];
        request.sortDescriptors = @[sd];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request
                                                      error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        self.privateItems = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSArray *)allAssetTypes
{
    if (!_allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        request.entity = [NSEntityDescription entityForName:@"KHOAssetType"
                                     inManagedObjectContext:self.context];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request
                                                      error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:[error localizedDescription]];
        }
        _allAssetTypes = [result mutableCopy];
    }
    
    if ([_allAssetTypes count] == 0) {
        NSManagedObject *type;
        NSArray *initialValues = @[@"Furniture", @"Jewelry", @"Electronics"];
        
        for (NSString *value in initialValues) {
            type = [NSEntityDescription insertNewObjectForEntityForName:@"KHOAssetType"
                                                 inManagedObjectContext:self.context];
            
            [type setValue:value forKey:@"label"];
            [_allAssetTypes addObject:type];
        }
    }
    return _allAssetTypes;
}

@end
