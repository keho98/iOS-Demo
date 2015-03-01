//
//  KHODetailViewController.m
//  Homepwner
//
//  Created by Kevin Ho on 2/1/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHODetailViewController.h"
#import "KHOAssetTypeViewController.h"

#import "KHOItem.h"
#import "KHOImageStore.h"
#import "KHOItemStore.h"

#define LABEL_MARGIN 10.0

@interface KHODetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
@property (weak, nonatomic) UIBarButtonItem *cameraButton;

@end

@implementation KHODetailViewController


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    BOOL isNew = NO;
    if ([identifierComponents count] == 3) {
        isNew = YES;
    }
    
    return [[self alloc] initForNewItem:isNew];
}

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(updateFonts)
                              name:UIContentSizeCategoryDidChangeNotification
                            object:nil];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
{
    [NSException raise:@"Wrong initializer"
                format:@"User initForNewItem:"];
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    UIControl *mainView = [[UIControl alloc] init];
    [mainView addTarget:self action:@selector(backgroundTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = mainView;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutSubviews];
    [self addConstraints];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];
    
    KHOItem *item = self.item;
    
    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];
    
    NSString *itemKey = self.item.itemKey;
    UIImage *imageToDisplay = [[KHOImageStore sharedStore] imageForKey:itemKey];
    
    self.imageView.image = imageToDisplay;
    
    NSString *typeLabel = [self.item.assetType valueForKey:@"label"];
    if (!typeLabel) {
        typeLabel = @"None";
    }
    
    self.assetTypeButton.title = [NSString stringWithFormat:@"Type: %@", typeLabel];
    
    [self updateFonts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
    
    KHOItem *item = self.item;
    // Assume item is deleted if managed object context is nil
    if (!item.managedObjectContext == nil) {
        item.itemName = self.nameField.text;
        item.serialNumber = self.serialNumberField.text;
        item.valueInDollars = [self.valueField.text intValue];
    }
}

- (void)setItem:(KHOItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (void)takePicture:(id)sender
{
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        
        self.imagePickerPopover.delegate = self;
        
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation: toInterfaceOrientation];
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    [[KHOItemStore sharedStore] removeItem:self.item];
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:self.dismissBlock];
}

- (void)updateFonts
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.nameLabel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;
    self.dateLabel.font = font;
    
    self.nameField.font = font;
    self.serialNumberField.font = font;
    self.valueField.font = font;
}

- (void)addConstraints
{
    NSDictionary *nameMap = @{
                              @"imageView"         : self.imageView,
                              @"dateLabel"         : self.dateLabel,
                              @"toolbar"           : self.toolbar,
                              @"valueField"        : self.valueField,
                              @"serialNumberField" : self.serialNumberField,
                              @"nameField"         : self.nameField,
                              @"valueLabel"        : self.valueLabel,
                              @"serialNumberLabel" : self.serialNumberLabel
                              };
    
    // dateLabel Constraints
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:nameMap];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[valueField]-[dateLabel]-[imageView]-[toolbar(==44)]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:nameMap];
    
    // valueField Constraints
    
    horizontalConstraints = [horizontalConstraints arrayByAddingObjectsFromArray:
                             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-27-[valueLabel(==serialNumberLabel)]-[valueField(==serialNumberField)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:nameMap]];
    
    verticalConstraints = [verticalConstraints arrayByAddingObjectsFromArray:
                           [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[valueLabel]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:nameMap]];
    
    // imageView Constraints
    horizontalConstraints = [horizontalConstraints arrayByAddingObjectsFromArray:
                             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:nameMap]];
    
    horizontalConstraints = [horizontalConstraints arrayByAddingObjectsFromArray:
                             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:nameMap]];
    
    [self.view addConstraints:verticalConstraints];
    [self.view addConstraints:horizontalConstraints];
}

- (void)layoutSubviews
{
    CGFloat labelX = 25.0;
    CGFloat labelY = 80.0;
    CGFloat labelWidth = 50.0;
    CGFloat labelHeight = 30.0;
    
    CGFloat fieldX = labelX + labelWidth + LABEL_MARGIN;
    CGFloat fieldY = labelY;
    CGFloat fieldWidth = 200.0;
    CGFloat fieldHeight = labelHeight;
    
    CGRect labelFrame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    nameLabel.text = @"Name";
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    CGRect fieldFrame = CGRectMake(fieldX, fieldY, fieldWidth, fieldHeight);
    self.nameField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameField];
    
    labelFrame.origin.y = labelFrame.origin.y + labelHeight + LABEL_MARGIN;
    UILabel *serialLabel = [[UILabel alloc] initWithFrame:labelFrame];
    serialLabel.text = @"Serial";
    [self.view addSubview:serialLabel];
    self.serialNumberLabel = serialLabel;
    
    fieldFrame.origin.y = labelFrame.origin.y;
    self.serialNumberField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.serialNumberField.borderStyle = UITextBorderStyleRoundedRect;
    self.serialNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.serialNumberField];
    
    labelFrame.origin.y = labelFrame.origin.y + labelHeight + LABEL_MARGIN;
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:labelFrame];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.text = @"Value";
    [self.view addSubview:valueLabel];
    self.valueLabel = valueLabel;
    
    fieldFrame.origin.y = labelFrame.origin.y;
    self.valueField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.valueField.borderStyle = UITextBorderStyleRoundedRect;
    self.valueField.translatesAutoresizingMaskIntoConstraints = NO;
    self.valueField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.valueField];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.text = @"Label";
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dateLabel];
    
    self.imageView = [[UIImageView alloc] initWithImage:nil];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.autoresizesSubviews = NO;
    self.imageView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.imageView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar = toolbar;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                   target:self
                                                                                   action:@selector(takePicture:)];
    
    UIBarButtonItem *assetTypeButton = [[UIBarButtonItem alloc] initWithTitle:@"Type: None"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(showAssetTypePicker:)];
    
    [toolbar setItems:@[barButtonItem, assetTypeButton]];

    self.cameraButton = barButtonItem;
    self.assetTypeButton = assetTypeButton;
    [self.view addSubview:toolbar];
}

- (void)showAssetTypePicker:(id)sender
{
    [self.view endEditing:YES];
    
    KHOAssetTypeViewController *avc = [[KHOAssetTypeViewController alloc] init];
    avc.item = self.item;
    
    [self.navigationController pushViewController:avc
                                         animated:YES];
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    [self.item setThumbnailFromImage:img];
    
    [[KHOImageStore sharedStore] setImage:img forKey:self.item.itemKey];
    
    self.imageView.image = img;
    
    if (self.imagePickerPopover) {
        
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

#pragma mark State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"];
    
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text integerValue];
    
    [[KHOItemStore sharedStore] saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    
    for (KHOItem* item in [[KHOItemStore sharedStore] allItems]) {
        if ([itemKey isEqualToString:item.itemKey]) {
            self.item = item;
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
