//
//  KHOItemsHeaderView.m
//  Homepwner
//
//  Created by Kevin Ho on 1/31/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOItemsHeaderView.h"

@implementation KHOItemsHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect addButtonFrame = CGRectMake(180, 35, 50, 30);
        self.addItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.addItemButton setTitle:@"New" forState:UIControlStateNormal];
        self.addItemButton.frame = addButtonFrame;
        
        [self addSubview:self.addItemButton];
        
        CGRect editButtonFrame = CGRectMake(80, 35, 50, 30);
        self.editItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.editItemButton setTitle:@"Edit" forState:UIControlStateNormal];
        self.editItemButton.frame = editButtonFrame;
        
        [self addSubview:self.editItemButton];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
