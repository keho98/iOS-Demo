//
//  KHODetailViewController.h
//  Homepwner
//
//  Created by Kevin Ho on 2/1/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KHOItem;

@interface KHODetailViewController : UIViewController

@property (nonatomic, strong) KHOItem *item;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *serialNumberField;
@property (nonatomic, strong) UITextField *valueField;
@property (nonatomic, strong) UILabel *dateLabel;

@end
