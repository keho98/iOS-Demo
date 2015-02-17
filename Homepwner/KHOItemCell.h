//
//  KHOItemCell.h
//  Homepwner
//
//  Created by Kevin Ho on 2/16/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KHOItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (copy, nonatomic) void (^actionBlock)(void);

@end
