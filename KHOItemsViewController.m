//
//  KHOItemsViewController.m
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOItemsViewController.h"
#import "KHOItemStore.h"
#import "KHOItem.h"

@interface KHOItemsViewController () <UITableViewDataSource>

@end

@implementation KHOItemsViewController

const NSInteger KHOItemsViewControllerNumberItems = 5;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    for (int i = 0; i < KHOItemsViewControllerNumberItems; i++) {
        [[KHOItemStore sharedStore] createItem];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[KHOItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:@"UITableViewCell"];
    
    NSArray *items = [[KHOItemStore sharedStore] allItems];
    KHOItem *item = items[indexPath.row];
    
    cell.textLabel.text = [item description];
    return cell;
}

@end
