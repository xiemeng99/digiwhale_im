//
//  CustomAttachment.h
//  digiwin_im
//
//  Created by zmm on 2021/8/27.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface CustomAttachment :  NSObject<NIMCustomAttachment>
@property (nonatomic,strong)    NSDictionary* value;
@end

NS_ASSUME_NONNULL_END
