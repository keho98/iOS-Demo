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

#import "KHOImageStore.h"
#import "KHOImageViewController.h"

#import "KHODetailViewController.h"

#define NUM_EXTRA_ROWS 1

@interface KHOItemsViewController () <UIDataSourceModelAssociation, UIPopoverControllerDelegate>

@property (strong,nonatomic) UIPopoverController *imagePopover;

@end

@implementation KHOItemsViewController

const NSInteger KHOItemsViewControllerNumberItems = 5;

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";
        
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        UIBarButtonItem * bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        
        navItem.rightBarButtonItem = bbi;
        
        navItem.leftBarButtonItem = self.editButtonItem;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(updateTableViewForDynamicTypeSize)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
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
    
    self.tableView.rowHeight = 44;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableView.restorationIdentifier = @"KHOItemsViewControllerTableView";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTableViewForDynamicTypeSize];
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
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navController.restorationIdentifier = NSStringFromClass([navController class]);
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    //Interrupts presentation in oldest ancestor self.definesPresentationContext = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
    
    return;
}

- (void)updateTableViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{
                                 UIContentSizeCategoryExtraSmall : @44,
                                 UIContentSizeCategorySmall      : @44,
                                 UIContentSizeCategoryMedium     : @44,
                                 UIContentSizeCategoryLarge      : @44,
                                 UIContentSizeCategoryExtraLarge : @55,
                                 UIContentSizeCategoryExtraExtraLarge : @65,
                                 UIContentSizeCategoryExtraExtraExtraLarge : @75
                                 };
    }
    
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];
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
        
        __weak KHOItemCell *weakCell = khoCell;
        
        khoCell.actionBlock = ^{
            
            KHOItemCell *strongCell = weakCell;
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                NSLog(@"Going to show image for %@", item);
                
                NSString *itemKey = item.itemKey;
                
                UIImage *img = [[KHOImageStore sharedStore] imageForKey:itemKey];
                if (!img) {
                    return;
                }
                
                CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
                                            fromView:strongCell.thumbnailView];
                
                KHOImageViewController *ivc = [[KHOImageViewController alloc] init];
                ivc.image = img;
                
                self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
                self.imagePopover.delegate = self;
                self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
                
                [self.imagePopover presentPopoverFromRect:rect
                                                   inView:self.view
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
            }
        };
        
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

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePopover = nil;
}

#pragma mark State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeBool:self.isEditing forKey:@"TableViewIsEditing"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.editing = [coder decodeBoolForKey:@"TableViewIsEditing"];
    
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark UIDataSourceModelAssociation

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx
                                            inView:(UIView *)view
{
    NSString *identifier = nil;
    if (idx && view) {
        KHOItem *item = [[KHOItemStore sharedStore] allItems][idx.row];
        identifier = item.itemKey;
    }
    return identifier;
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier
                                                 inView:(UIView *)view
{
    NSIndexPath *idx = nil;
    
    if (identifier && view) {
        NSArray *items = [[KHOItemStore sharedStore] allItems];
        for (KHOItem *item in items) {
            if ([identifier isEqualToString:item.itemKey]) {
                int row = [items indexOfObjectIdenticalTo:item];
                idx = [NSIndexPath indexPathForRow:row inSection:0];
            }
        }
    }
    
    return idx;
}

@end
