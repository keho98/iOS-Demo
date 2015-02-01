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

#import "KHOItemsHeaderView.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *header = (UIView *)self.headerView;
    
    self.tableView.tableHeaderView = header;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)addNewItem:(id)sender
{
    NSLog(@"Add");
    return;
}

- (void)toggleEditingMode:(id)sender
{
    NSLog(@"Edit");
    return;
}

- (KHOItemsHeaderView *)headerView
{
    if (!_headerView) {
        CGRect frame = CGRectMake(0, 0, 0, 0);
        frame.size.width = self.view.bounds.size.width;
        frame.size.height = 100;
        
        KHOItemsHeaderView *view = [[KHOItemsHeaderView alloc] initWithFrame:frame];
        [view.addItemButton addTarget:self
                               action:@selector(addNewItem:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [view.editItemButton addTarget:self
                                action:@selector(toggleEditingMode:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        _headerView = view;
    }
    return _headerView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[KHOItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSArray *items = [[KHOItemStore sharedStore] allItems];
    KHOItem *item = items[indexPath.row];
    
    cell.textLabel.text = [item description];
    return cell;
}

@end
