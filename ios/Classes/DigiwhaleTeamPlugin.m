//
//  DigiwhaleTeamPlugin.m
//  digiwhale_im
//
//  Created by zmm on 2021/9/29.
//

#import "DigiwhaleTeamPlugin.h"
#import <NIMSDK/NIMSDK.h>

@implementation DigiwhaleTeamPlugin

//在.m文件中声明静态的类实例，不放在.h中是为了让instance私有
static DigiwhaleTeamPlugin* instance = nil;

//提供的类唯一实例的全局访问点
//跟C++中思路相似，判断instance是否为空
//如果为空，则创建，如果不是，则返回已经存在的instance
//不能保证线程安全
+(DigiwhaleTeamPlugin *) getInstance{
    if (instance == nil) {
        instance = [[DigiwhaleTeamPlugin alloc] init];//调用自己改写的”私有构造函数“
    }
    return instance;
}

//相当于将构造函数设置为私有，类的实例只能初始化一次
+(id) allocWithZone:(struct _NSZone*)zone
{
    if (instance == nil) {
        instance = [super allocWithZone:zone];
    }
    return instance;
}


//重写copy方法中会调用的copyWithZone方法，确保单例实例复制时不会重新创建
-(id) copyWithZone:(struct _NSZone *)zone
{
    return instance;
}

//创建群组
-(void)createTeam:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *params = call.arguments;
//    __block FlutterResult *resultTeam = result;
    NIMCreateTeamOption *option = [[NIMCreateTeamOption alloc] init];
    option.type = NIMTeamTypeAdvanced;
    option.maxMemberCountLimitation = 100;
    option.beInviteMode = NIMTeamBeInviteModeNoAuth;
//    option.name = params[@"name"];
    [[NIMSDK sharedSDK].teamManager createTeam:option users: params[@"accounts"] completion:^(NSError * _Nullable error, NSString * _Nullable teamId, NSArray<NSString *> * _Nullable failedUserIds) {
        NSLog(@"error == %@",error);
        NSLog(@"teamId == %@",teamId);
        NSLog(@"failedUserIds == %@",failedUserIds);
        NSMutableDictionary *teamDict = [NSMutableDictionary dictionary];
        teamDict[@"teamId"] = teamId;
        if (error.userInfo[@"NSLocalizedDescription"]) {
            teamDict[@"errorMsg"] = error.userInfo[@"NSLocalizedDescription"];
        }
        result(teamDict);
    }];

}


//获取群成员列表
-(void)getTeamAccount:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSDictionary *params = call.arguments;
    [[NIMSDK sharedSDK].teamManager fetchTeamMembers:params[@"teamId"] completion:^(NSError * _Nullable error, NSArray<NIMTeamMember *> * _Nullable members) {
        NSMutableArray *userIds = [NSMutableArray array];
        NSMutableDictionary *userDict = [NSMutableDictionary dictionary];

        for (NIMTeamMember *item in members) {
            [userIds addObject:item.userId];
            userDict[item.userId] = item;
        }
        [[[NIMSDK sharedSDK] userManager] fetchUserInfos:userIds completion:^(NSArray<NIMUser *> * __nullable users,NSError * __nullable error){
            if(error == nil){
                NSMutableArray *array = [NSMutableArray array];

                for (NIMUser *item in users) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    NIMTeamMember *user = userDict[item.userId];
                    dict[@"teamId"] = user.teamId;
                    dict[@"account"] = user.userId;
                    dict[@"teamMemberType"] = @(user.type);
                    dict[@"name"] = item.userInfo.nickName;
                    dict[@"joinTime"] = @([[NSNumber numberWithDouble:user.createTime] integerValue]);
                    [array addObject:dict];
                }
                result(array);
            }else{
                NSLog(@"%@",error.localizedDescription);
                result(@[]);
            }
        }];
    }];
}


//获取群基本信息
-(void)getTeam:(FlutterMethodCall*)call result:(FlutterResult)result{
//    NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:params[@"teamId"]];
//    NSLog(@"%@",team);
}


@end
