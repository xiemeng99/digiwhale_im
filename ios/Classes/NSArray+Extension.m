//
//  NSArray+Extension.m
//  digiwin_im
//
//  Created by zmm on 2021/8/27.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
