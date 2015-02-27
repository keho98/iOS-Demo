//
//  KHOImageTransformer.m
//  Homepwner
//
//  Created by Kevin Ho on 2/26/15.
//  Copyright (c) 2015 kho. All rights reserved.
//

#import "KHOImageTransformer.h"

@implementation KHOImageTransformer

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:value];
}

@end
