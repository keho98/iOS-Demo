//
//  KHODetailViewController.m
//  Homepwner
//
//  Created by Kevin Ho on 2/1/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHODetailViewController.h"
#import "KHOItem.h"

#define LABEL_MARGIN 10.0

@interface KHODetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation KHODetailViewController

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
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    CGRect fieldFrame = CGRectMake(fieldX, fieldY, fieldWidth, fieldHeight);
    self.nameField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameField];
    
    labelFrame.origin.y = labelFrame.origin.y + labelHeight + LABEL_MARGIN;
    UILabel *serialLabel = [[UILabel alloc] initWithFrame:labelFrame];
    serialLabel.text = @"Serial";
    [self.view addSubview:serialLabel];
    
    fieldFrame.origin.y = labelFrame.origin.y;
    self.serialNumberField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.serialNumberField.borderStyle = UITextBorderStyleRoundedRect;
    self.serialNumberField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.serialNumberField];
    
    labelFrame.origin.y = labelFrame.origin.y + labelHeight + LABEL_MARGIN;
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:labelFrame];
    valueLabel.text = @"Value";
    [self.view addSubview:valueLabel];
    
    fieldFrame.origin.y = labelFrame.origin.y;
    self.valueField = [[UITextField alloc] initWithFrame:fieldFrame];
    self.valueField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.valueField];
    
    labelFrame.origin.y = labelFrame.origin.y + labelHeight + LABEL_MARGIN;
    labelFrame.size.width = fieldFrame.origin.x + fieldFrame.size.width - labelFrame.origin.x;
    self.dateLabel = [[UILabel alloc] initWithFrame:labelFrame];
    self.dateLabel.text = @"Label";
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dateLabel];
    
    CGRect imageFrame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y + labelFrame.size.height + 10.0, labelFrame.size.width, labelFrame.size.width);
    self.imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.imageView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.imageView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 524, 324,  44.0);
    self.toolbar = toolbar;
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    [toolbar setItems:@[barButtonItem]];
    [self.view addSubview:toolbar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear first responder
    [self.view endEditing:YES];
    
    KHOItem *item = self.item;
    item.itemName = self.nameField.text;
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (void)setItem:(KHOItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (void)takePicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = img;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
