#import "DigiwhaleImPlugin.h"
#import <NIMSDK/NIMSDK.h>
#import "NSArray+Extension.h"
#import "NIMMessage+Extension.h"
#import "DigiwhaleTeamPlugin.h"

@interface DigiwhaleImPlugin()<NIMChatManagerDelegate,NIMChatManager,NIMConversationManagerDelegate,NIMLoginManagerDelegate>
@property FlutterMethodChannel * channel;
@property(nonatomic,assign)int times;
@end

@implementation DigiwhaleImPlugin

//在.m文件中声明静态的类实例，不放在.h中是为了让instance私有
static DigiwhaleImPlugin* instance = nil;

//提供的类唯一实例的全局访问点
//跟C++中思路相似，判断instance是否为空
//如果为空，则创建，如果不是，则返回已经存在的instance
//不能保证线程安全
+(DigiwhaleImPlugin *) getInstance{
    if (instance == nil) {
        instance = [[DigiwhaleImPlugin alloc] init];//调用自己改写的”私有构造函数“
        instance.times = 0;
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


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"digiwhale_im_flutter"
            binaryMessenger:[registrar messenger]];
  DigiwhaleImPlugin *instance = [DigiwhaleImPlugin getInstance];
    instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
    // 初始化FlutterEventChannel对象
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"digiwhale_im_native" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

// MARK: - FlutterStreamHandler
- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink
{
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments
{
    return nil;
}

//重写copy方法中会调用的copyWithZone方法，确保单例实例复制时不会重新创建
-(id) copyWithZone:(struct _NSZone *)zone
{
    return instance;
}


/*
 * 网易云信收到消息  此方法由云信提供  具体参考云信官方文档
 */
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages{
//    NSLog(@"收到消息了 %@",messages);
    NSLog(@"网易云信收到消息  此方法由云信提供  具体参考云信官方文档");
    NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NIMMessage *message = obj;
        return [message messageToDictionary];
    }];
    
//    NSArray *messageDicArr = @[@(messages)];
    [_channel invokeMethod:@"onMessagesUpdate" arguments: messageDicArr];
}

/*
 * 更新最近会话列表
 */
-(void)didUpdateRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount{
    NSLog(@"---更新最近会话列表");
    NIMRecentSession *session = recentSession;
    [_channel invokeMethod:@"onSessionsUpdate" arguments: @[[recentSession recentSessionToDictionary]]];
}


/**
 *  增加最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
 */
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    NIMRecentSession *session = recentSession;
    [_channel invokeMethod:@"onSessionsAdd" arguments: @[[recentSession recentSessionToDictionary]]];
}

-(void)onLogin:(NIMLoginStep)step{
    NSLog(@"step == %zd",step);
    if (step == NIMLoginStepSyncOK) {
        //数据同步完毕
        [_channel invokeMethod:@"onNIMSyncOK" arguments: @{}];
    }
    
}



/*
 * Flutter 调用方法
 */
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"call == %@",call);
    
    if ([@"nimClientInit" isEqualToString:call.method]){
        //初始化云信SDK
        // [self nimClientInit];
    }else if ([@"nimLogin" isEqualToString:call.method]){
        //云信登录
        [self nimLogin:call result:result];
    }else if ([@"getAllSessions" isEqualToString:call.method]) {
        // 获取所有的会话列表
        [self getAllSessions:call result:result];
    }
    else if ([@"loginOut" isEqualToString:call.method]) {
      //云信登出
      [self loginOut:call result:result];
    }
    else if ([@"getUserInfo" isEqualToString:call.method]) {
      // 获取用户信息
//      [self getUserInfo:call result:result];
  }else if ([@"sendMessage" isEqualToString:call.method]) {
      //发送消息
      [self sendMessage:call result:result];
  }else if ([@"getUserInfoList" isEqualToString:call.method]) {
      // @desc: 获取所有的会话用户资料
      [self getUsersInfo:call result:result];
  }else if ([@"fetchMessageHistory" isEqualToString:call.method]) {
      // 获取云端历史聊天记录
      [self fetchMessageHistory:call result:result];
  }else if ([@"fetchLocalMessageHistory" isEqualToString:call.method]) {
      // 获取本地历史聊天记录
      [self fetchLocalMessageHistory:call result:result];
  }
  else if ([@"markAllMessagesReadInSession" isEqualToString:call.method]) {
      // 设置会话已读
      [self markAllMessagesReadInSession:call result:result];
  }
  else if ([@"markAllMessagesRead" isEqualToString:call.method]) {
      //设置所有会话消息已读
      [self markAllMessagesRead:call result:result];
  }
      else if ([@"revokeMessage" isEqualToString:call.method]) {
      //撤回消息
      [self revokeMessage:call];
  }else if ([@"sendMessageReceipt" isEqualToString:call.method]) {
      //单条消息已读回执
      [self sendMessageReceipt:call];
  }else if ([@"getCurrentUserInfo" isEqualToString:call.method]) {
      //获取当前登录用户的资料  主要是用来获取EOCID
      [self getCurrentUserInfo:call result:result];
  }else if ([@"deleteSession" isEqualToString:call.method]) {
      //删除最近会话
      [self deleteSession:call result:result];
  }
    /////// 群相关方法
    else if ([@"createTeam" isEqualToString:call.method]) {
      //获取当前登录用户的资料  主要是用来获取EOCID
      [[DigiwhaleTeamPlugin getInstance] createTeam:call result:result];
    }else if ([@"getTeamMemberList" isEqualToString:call.method]) {
      //获取群成员列表
      [[DigiwhaleTeamPlugin getInstance] getTeamAccount:call result:result];
    }else if ([@"getTeam" isEqualToString:call.method]) {
        //获取群成员列表
        [[DigiwhaleTeamPlugin getInstance] getTeam:call result:result];
      }
    //////
  else {
      // 未实现方法
    result(FlutterMethodNotImplemented);
  }
}

/*
 * 删除最近会话
 */
- (void)deleteSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSString *account = param[@"sessionId"];
    // 构造出具体会话
    NIMSession *session = [NIMSession session:account type:[param[@"sessionType"] integerValue]];
    NIMRecentSession *recentSession = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    [[NIMSDK sharedSDK].conversationManager deleteRecentSession:recentSession];
}

/*
 * @desc: 获取当前登录用户的资料  主要是用来获取EOCID
 */
- (void)getCurrentUserInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
     NSString *account = [userDefault objectForKey:@"account"];
    NSMutableArray * userIds = [NSMutableArray array];
    [userIds addObject:account ? account : @""];
    [[[NIMSDK sharedSDK] userManager] fetchUserInfos:userIds completion:^(NSArray<NIMUser *> * __nullable users,NSError * __nullable error){
        if(error == nil){
            NSArray *usersInfoDicArr = [users mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                NIMUser *userInfo = obj;
                NSDictionary *eocId = [self turnStringToDictionary:userInfo.userInfo.ext];
                return @{
                    @"acctId":userInfo.userId ? userInfo.userId : @"" ,
                    @"name":userInfo.userInfo.nickName ? userInfo.userInfo.nickName : @"" ,
                    @"avatarUrl":userInfo.userInfo.avatarUrl ? userInfo.userInfo.avatarUrl : @"",
                    @"eocId":eocId[@"eocId"]
                };
            }];
            if (usersInfoDicArr.count > 0) {
                result(usersInfoDicArr[0]);
            }else{
                result(@{});
            }
//            result(usersInfoDicArr);
        }else{
            result(@{});
            NSLog(@"%@",error.localizedDescription);
//            result(@[]);
        }
    }];
}

// /*
//  * 网易云信sdk初始化
//  */
// -(void)nimClientInit{
//     //网易云信sdk初始化
//     NSString *appKey        = @"ac515da7f9e2de44780dca84b0bda586";
//     NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
// //    option.apnsCername      = @"IM01.mobileprovision";
//     option.apnsCername      = @"Athena_Atn_Development";
//     [[NIMSDK sharedSDK] registerWithOption:option];
//     [NIMSDKConfig sharedConfig].shouldSyncUnreadCount = YES;
// }


/*
 * 网易云信登录
 */
- (void)nimLogin:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    [NIMSDKConfig sharedConfig].asyncLoadRecentSessionEnabled = YES;
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString *token = @"";
    if (param[@"account"]) {
        account = param[@"account"];
    }
    if (param[@"token"]) {
        token = param[@"token"];
    }
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
        if(error){
//            result([error flutterError]);
            result(@NO);
        }else{
            NSLog(@"登录成功");
            result(@YES);
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:account forKey:@"account"];
            [userDefault setObject:token forKey:@"token"];
            [userDefault synchronize];
//            [self registerPushService];
        }
    }];
}

/*
 * @desc: 获取所有的会话用户资料
 */
- (void)getUsersInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSArray<NSString *>* userIds = param[@"accounts"];
    
    [[[NIMSDK sharedSDK] userManager] fetchUserInfos:userIds completion:^(NSArray<NIMUser *> * __nullable users,NSError * __nullable error){
        if(error == nil){
            NSArray *usersInfoDicArr = [users mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                NIMUser *userInfo = obj;
                NSDictionary *eocId = [self turnStringToDictionary:userInfo.userInfo.ext];
                return @{
                    @"acctId":userInfo.userId ? userInfo.userId : @"",
                    @"name":userInfo.userInfo.nickName ? userInfo.userInfo.nickName : @"" ,
                    @"avatarUrl":userInfo.userInfo.avatarUrl ? userInfo.userInfo.avatarUrl : @"",
                    @"eocId":eocId[@"eocId"] ? eocId[@"eocId"] : @""
                };
            }];
            result(usersInfoDicArr);
        }else{
            NSLog(@"%@",error.localizedDescription);
            result(@[]);
        }
    }];
}

/*
 * 字符串转字典（NSString转Dictionary）
 *   parameter
 *     turnString : 需要转换的字符串
 */
- (NSDictionary *)turnStringToDictionary:(NSString *)turnString
{
    if (!turnString) {
        return  @{};
    }
    NSData *turnData = [turnString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *turnDic = [NSJSONSerialization JSONObjectWithData:turnData options:NSJSONReadingMutableLeaves error:nil];
    return turnDic;
}

/**
 * @desc: 登出
 */
- (void)loginOut:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        if(error){
//            result([error flutterError]);
            NSLog(@"登出失败");
        }else{
            NSLog(@"登出成功");
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault removeObjectForKey:@"account"];
            [userDefault removeObjectForKey:@"token"];
            result(nil);
        }
    }];
}


/*
 * @desc: 获取所有的会话列表
 */
- (void)getAllSessions:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"---获取所有的会话列表");
    __weak typeof(self) weakSelf = self;
    NSArray<NIMRecentSession *>* allRecentSessions = [[[NIMSDK sharedSDK] conversationManager] allRecentSessions];
    NSMutableArray<NSDictionary<NSString *,id> *> *recentSessionsDicArr = [NSMutableArray array];
    for (NIMRecentSession *obj in allRecentSessions) {
        NIMRecentSession *session = obj;
        if (session.session.sessionType == -1) {
            continue;
        }
        [recentSessionsDicArr addObject:[session recentSessionToDictionary]];
//        }
    }
    if (recentSessionsDicArr.count == 0 && ![[NIMSDK sharedSDK].loginManager isLogined] && self.times<3) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
         NSString *account = [userDefault objectForKey:@"account"];
        NSString *token = [userDefault objectForKey:@"token"];
        [[[NIMSDK sharedSDK] loginManager] login:account
                                           token:token
                                      completion:^(NSError *error) {
            self.times++;
            if(error){
                result(@{@"ERROR":@"ERROR"});
            }else{
                [weakSelf getAllSessions:call result:result];
            }
        }];
    }else{
        self.times = 0;
        result(recentSessionsDicArr);
    }
}

-(NSString *)arrayToJSON:(NSArray *)data{
    NSError *error = nil ;
    NSData *jsonData = [ NSJSONSerialization dataWithJSONObject :data
                                                       options : kNilOptions
                                                         error :&error];
    NSString *jsonString = [[ NSString alloc ] initWithData :jsonData
                                                 encoding : NSUTF8StringEncoding];
    return  jsonString;
}


/**
 * @desc: 发送文本、图片、音频消息
 */
- (void)sendMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString * type = @"";
    NSString * messageFlag = @"";
    if(param[@"sessionId"]){
        account = param[@"sessionId"];
    }
    if(param[@"sessionType"]){
        type = param[@"sessionType"];
    }
    if(param[@"messageFlag"]){
        messageFlag = param[@"messageFlag"];
    }
    // 构造出具体会话
    NIMSession *session = [NIMSession session:account type:[param[@"sessionType"] integerValue]];
    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];
    message.apnsContent = param[@"message"];
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.shouldBeCounted = YES;
    setting.apnsWithPrefix = YES;           //不需要前缀
    message.setting = setting;
    setting.teamReceiptEnabled = YES;
    [message setValue:param[@"messageType"] forKey:@"messageType"];
    if (param[@"teamNotificationData"]) {
        //群聊用到的相关信息
        message.remoteExt = param[@"teamNotificationData"];
    }
    message.messageSubType = 0;
    message.localExt = @{@"messageFlag":messageFlag};
    message.text        = param[@"text"];
//    if([[NSString stringWithFormat:@"%d",[param[@"sessionType"] intValue]] isEqualToString:@"0"]){
//        if(param[@"text"]){
//            message.text        = param[@"text"];
//        }
//    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
     NSString *sessionID = [userDefault objectForKey:@"account"];
    message.apnsPayload = @{@"sessionID":[[param[@"sessionType"] stringValue] isEqualToString:@"0"] ? sessionID :account,@"name":[[NIMSDK sharedSDK].userManager userInfo:sessionID].userInfo.nickName,@"avatarUrl":@"",@"sessionType":param[@"sessionType"]};//测试数据

    // 错误反馈对象
    NSError *error = nil;
    // 发送消息
    BOOL sendState = [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];

    if(sendState){
        NSLog(@"发送成功");
        NSArray *messageDicArr = [@[message] mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            NIMMessage *newMessage = obj;
            newMessage.timestamp = message.timestamp;
            return [message messageToDictionary];
        }];
        [_channel invokeMethod:@"onMessagesUpdate" arguments: messageDicArr];
//        result([message messageToDictionary]);

    }else{
        NSLog(@"发送失败");
        result(nil);
    }
    
}


/*
 * @desc: 获取云端历史聊天数据
 */
- (void)fetchMessageHistory:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    
    NIMSession* session = [NIMSession  session:param[@"sessionId"] type:((NIMSessionType)[param[@"sessionType"] intValue])];
    
    NIMHistoryMessageSearchOption* option = [[NIMHistoryMessageSearchOption alloc]init];
    
    option.limit = [param[@"limit"] integerValue];
    option.limit = 30;
//    option.endTime = _message.timestamp;
    option.order = NIMMessageSearchOrderDesc;//查询方向，NIMMessageSearchOrderDesc表示从新消息往旧消息查(并且查询结果按照新消息到旧消息的顺序排列)，设置为NIMMessageSearchOrderAsc表示从旧消息往新消息查(并且查询结果按照旧消息到新消息的顺序排列)。此参数对聊天室会话无效
    [[[NIMSDK sharedSDK] conversationManager] fetchMessageHistory:session option:option result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
        if(error){
//            result([error flutterError]);
        }else{
            if(messages.count>0){
//                self.message = messages[messages.count -1];
                NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                    NIMMessage *message = obj;
                    return [message messageToDictionary];
                }];
                result([[messageDicArr reverseObjectEnumerator] allObjects]);
            }else{
                result(@[]);
            }
            
        }
    }];
}

/*
 * @desc: 获取本地历史聊天数据
 */
- (void)fetchLocalMessageHistory:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NIMSession* session = [NIMSession  session:param[@"sessionId"] type:((NIMSessionType)[param[@"sessionType"] intValue])];
    NIMMessage *message;
    NSArray<NIMMessage *> *arrays = @[];
    if (param[@"messageId"]) {
        arrays = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session messageIds:@[param[@"messageId"]]];
        message = arrays.lastObject;
    }
    NSArray<NIMMessage *> * messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session message:message limit:[param[@"limit"] integerValue]];
    NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NIMMessage *message = obj;
        return [message messageToDictionary];
    }];
    result(messageDicArr);
}

/*
 * @desc: 设置会话已读
 */
- (void)markAllMessagesReadInSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NIMSession* nimSession = [NIMSession  session:param[@"sessionId"] type:((NIMSessionType)[param[@"sessionType"] intValue])];
    [[[NIMSDK sharedSDK] conversationManager] markAllMessagesReadInSession:nimSession];
}


/*
* @desc: 设置所有会话已读
*/
- (void)markAllMessagesRead:(FlutterMethodCall*)call result:(FlutterResult)result {
   [[[NIMSDK sharedSDK] conversationManager] markAllMessagesRead];
   //在这个方法里输入如下清除方法
   [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //清除角标
   [[UIApplication sharedApplication] cancelAllLocalNotifications];//清除APP所有通知消息
}

/**
* 撤回消息
*/
- (void)revokeMessage:(FlutterMethodCall*)call{
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString * type = @"";
    NSString * messageFlag = @"";
    if(param[@"account"]){
        account = param[@"account"];
    }
    if(param[@"type"]){
        type = param[@"type"];
    }
    if(param[@"messageFlag"]){
        messageFlag = param[@"messageFlag"];
    }
    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];
    message.localExt = @{@"messageFlag":messageFlag};
    [message setValue:param[@"messageId"] forKey:@"messageId"];

    if([type isEqualToString:@"NIMMessageTypeText"]){
        if(param[@"message"]){
            message.text        = param[@"message"];
        }
    }
    
    NIMSession *nimSession = [[NIMSession alloc] init];
    [nimSession setValue:param[@"session"][@"sessionId"] forKey:@"sessionId"];
    
    NSArray<NIMMessage *> *arrays = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:nimSession messageIds:@[param[@"messageId"]]];
    for (int i = 0; i<arrays.count; i++) {
        NIMMessage *mess = arrays[i];
        [[NIMSDK sharedSDK].chatManager revokeMessage:mess completion:^(NSError * _Nullable error) {
            //撤回了消息
            if (error) {
                NSLog(@"撤回失败了一条消息 %@",error);
            }else{
                NSLog(@"撤回成功了一条消息 %@",error);
                //撤回后 保存一条消息到本地数据库
                NSLog(@"撤回后 保存一条消息到本地数据库");
                NIMMessage *revokeMessage = [[NIMMessage alloc] init];
                revokeMessage.setting.historyEnabled = YES;
                  revokeMessage.setting.roamingEnabled = YES;
                  revokeMessage.setting.syncEnabled = YES;
                revokeMessage.setting.shouldBeCounted = NO;
                revokeMessage.setting.apnsEnabled = YES;
                revokeMessage.setting.apnsWithPrefix = YES;
                revokeMessage.setting.routeEnabled = YES;
                revokeMessage.setting.teamReceiptEnabled = YES;
                revokeMessage.setting.persistEnable = YES;
                revokeMessage.setting.scene = @"chat";
                revokeMessage.setting.isSessionUpdate = YES;
                revokeMessage.timestamp = mess.timestamp;
                revokeMessage.text = @"撤回了一条消息";
                [revokeMessage setValue:mess.messageId forKey:@"messageId"];
                revokeMessage.messageSubType = 10000;
                [revokeMessage setValue:@(100) forKey:@"messageType"];
                
//                NIMSession *nimSession = [[NIMSession alloc] init];
//                [nimSession setValue:param[@"session"][@"sessionId"] forKey:@"sessionId"];
                [[NIMSDK sharedSDK].conversationManager saveMessage:revokeMessage forSession:mess.session completion:^(NSError * _Nullable error) {
                    NSLog(@"error == %@",error);
                    if (!error) {
    //                    [self->_channel invokeMethod:@"onMessageRevoke" arguments:nil];
                    }
                }];
            }
        }];
    //
    }
    
}

/**
*  单聊消息已读回执
*/
- (void)sendMessageReceipt:(FlutterMethodCall*)call{
    NSDictionary *param = call.arguments;
//    NSString *account = @"";
//    NSString * type = @"";
//    NSString * messageFlag = @"";
//    if(param[@"sessionId"]){
//        account = param[@"sessionId"];
//    }
//    if(param[@"type"]){
//        type = param[@"type"];
//    }
//    if(param[@"messageFlag"]){
//        messageFlag = param[@"messageFlag"];
//    }
//    // 构造出具体消息
//    NIMMessage *message = [[NIMMessage alloc] init];
//    message.localExt = @{@"messageFlag":messageFlag};
//    [message setValue:param[@"messageId"] forKey:@"messageId"];
//
//    if([type isEqualToString:@"NIMMessageTypeText"]){
//        if(param[@"message"]){
//            message.text        = param[@"message"];
//        }
//    }
//    // 构造出具体消息
//    message.localExt = @{@"messageFlag":messageFlag};
//    [message setValue:param[@"messageId"] forKey:@"messageId"];
//
//    if([type isEqualToString:@"NIMMessageTypeText"]){
//        if(param[@"message"]){
//            message.text        = param[@"message"];
//        }
//    }
    
    NIMSession *nimSession = [[NIMSession alloc] init];
    [nimSession setValue:param[@"sessionId"] forKey:@"sessionId"];
    if (![param[@"sessionType"] isKindOfClass:[NSNull class]]) {
        [nimSession setValue:param[@"sessionType"] forKey:@"sessionType"];
    }

    
    NSArray<NIMMessage *> *arrays = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:nimSession messageIds:@[param[@"messageId"]]];
    NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:arrays.lastObject];
    if ([[param[@"sessionType"] stringValue] isEqualToString:@"0"]) {
        [[NIMSDK sharedSDK].chatManager sendMessageReceipt:receipt completion:^(NSError * _Nullable error) {
            NSLog(@"单聊消息已读回执");
        }];
    } else {
        NSMutableArray *receiptsArray = [NSMutableArray array];
        for (NIMMessage *item in arrays) {
            NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:item];
            [receiptsArray addObject:receipt];
        }
        [[NIMSDK sharedSDK].chatManager sendTeamMessageReceipts:receiptsArray completion:^(NSError * _Nullable error, NSArray<NIMMessageReceipt *> * _Nullable failedReceipts) {
            NSLog(@"error == %@",error);
            if (error) {
                NSLog(@"有点问题");
            }
        }];
    }
    
    
}

/**
*  监听已读回执
*/
- (void)onRecvMessageReceipts:(NSArray<NIMMessageReceipt *> *)receipts{
    
    NSLog(@" 监听已读回执---- %@",receipts);
    NSArray *messageDicArr = [receipts mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NIMMessageReceipt *message = obj;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        dict[@"timestamp"] = @(message.timestamp);
        dict[@"timestamp"] = @([[NSNumber numberWithDouble:message.timestamp] integerValue]);
        dict[@"sessionId"] = message.session.sessionId;
        dict[@"sessionType"] = @(NIMSessionTypeP2P);
        return dict;
    }];
    [_channel invokeMethod:@"onMessagesReceipt" arguments: messageDicArr];
}



- (void)refreshTeamMessageReceipts:(NSArray<NIMMessage *> *)messages{
    NSLog(@"messages == %@",messages);
}



@end
