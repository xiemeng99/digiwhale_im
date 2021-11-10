//
//  DigiwhaleTeamPlugin.h
//  digiwhale_im
//
//  Created by zmm on 2021/9/29.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DigiwhaleTeamPlugin : NSObject
//类方法
+(DigiwhaleTeamPlugin *)getInstance;
//创建群组
-(void)createTeam:(FlutterMethodCall*)call result:(FlutterResult)result;
//获取群成员列表
-(void)getTeamAccount:(FlutterMethodCall*)call result:(FlutterResult)result;
//获取群基本信息
-(void)getTeam:(FlutterMethodCall*)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
