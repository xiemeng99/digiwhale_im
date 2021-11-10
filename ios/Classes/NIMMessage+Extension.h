//
//  NIMMessage+Extension.h
//  digiwin_im
//
//  Created by zmm on 2021/8/27.
//

#import <NIMSDK/NIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMMessage (Extension)
- (NSMutableDictionary *)messageToDictionary;

@end

NS_ASSUME_NONNULL_END


@interface NIMUser (CustomNIMUser)
-(NSMutableDictionary *)userToDictionary;
@end


@interface NIMRecentSession (CustomNIMRecentSession)
-(NSMutableDictionary*)recentSessionToDictionary;
@end
