//
//  NSArray+Extension.h
//  digiwin_im
//
//  Created by zmm on 2021/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extension)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
- (NSMutableDictionary *)messageToDictionary;

@end

NS_ASSUME_NONNULL_END
