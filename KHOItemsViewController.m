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
#import "KHOItemCell.h"

#import "KHODetailViewController.h"

#define NUM_EXTRA_ROWS 1

@interface KHOItemsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation KHOItemsViewController

const NSInteger KHOItemsViewControllerNumberItems = 5;

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
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
    
    UINib *nib = [UINib nibWithNibName:@"KHOItemCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"KHOItemCell"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)addNewItem:(id)sender
{
    KHOItem *newItem = [[KHOItemStore sharedStore] createItem];
    
//    NSInteger lastRow = [[[KHOItemStore sharedStore] allItems] indexOfObject:newItem];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
//    
//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//                          withRowAnimation:UITableViewRowAnimationTop];
    
    KHODetailViewController *detailViewController = [[KHODetailViewController alloc] initForNewItem:YES];
    detailViewController.item = newItem;
    
    detailViewController.dismissBlock = ^{
        [self.tableView reloadData];
    };
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];[self dismissViewControllerAnimated:YES completion:nil];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    //Interrupts presentation in oldest ancestor self.definesPresentationContext = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    return;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[KHOItemStore sharedStore] allItems] count] + NUM_EXTRA_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSArray *items = [[KHOItemStore sharedStore] allItems];
    if (indexPath.row < [items count]) {
        KHOItem *item = items[indexPath.row];
        
        KHOItemCell *khoCell = [tableView dequeueReusableCellWithIdentifier:@"KHOItemCell"
                                               forIndexPath:indexPath];
        khoCell.nameLabel.text = item.itemName;
        khoCell.serialNumberLabel.text = item.serialNumber;
        khoCell.valueLabel.text = [NSString stringWithFormat:@"$%d", item.valueInDollars];
        
        khoCell.thumbnailView.image = item.thumbnail;
        
        cell = khoCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                          forIndexPath:indexPath];
        cell.textLabel.text = @"No more items!";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete item from data source
        NSArray *items = [[KHOItemStore sharedStore] allItems];
        KHOItem *item = items[indexPath.row];
        [[KHOItemStore sharedStore] removeItem:item];
        
        //Remove row from table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView
    moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
           toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row < [[[KHOItemStore sharedStore] allItems] count]) {
        [[KHOItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row
                                            toIndex:destinationIndexPath.row];
    } else {
        return;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row < [[[KHOItemStore sharedStore] allItems] count]) {
        return proposedDestinationIndexPath;
    } else {
        return sourceIndexPath;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < [[[KHOItemStore sharedStore] allItems] count];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < [[[KHOItemStore sharedStore] allItems] count];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < [[[KHOItemStore sharedStore] allItems] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[[KHOItemStore sharedStore] allItems] count]) {
        KHODetailViewController *detailViewController = [[KHODetailViewController alloc] initForNewItem:NO];
        detailViewController.item = [[[KHOItemStore sharedStore] allItems] objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
