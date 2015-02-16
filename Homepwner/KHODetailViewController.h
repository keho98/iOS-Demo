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

- (instancetype)initForNewItem:(BOOL)isNew;

@property (nonatomic, strong) KHOItem *item;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *serialNumberField;
@property (nonatomic, strong) UITextField *valueField;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar *toolbar;

@end
