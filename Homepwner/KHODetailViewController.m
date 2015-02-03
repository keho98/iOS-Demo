//
//  KHODetailViewController.m
//  Homepwner
//
//  Created by Kevin Ho on 2/1/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHODetailViewController.h"

#define LABEL_MARGIN 10.0

@interface KHODetailViewController ()

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
    CGFloat labelY = 100.0;
    CGFloat labelWidth = 50.0;
    CGFloat labelHeight = 35.0;
    
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
