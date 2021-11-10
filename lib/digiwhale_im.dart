/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-11-09 16:29:01
 * @LastEditor: weiguoqing
 */
import 'dart:async';
import 'dart:io';

import 'package:digiwhale_im/enums/nim_message_type.dart';
import 'package:digiwhale_im/enums/nim_message_type_extension.dart';
import 'package:digiwhale_im/enums/nim_session_type.dart';
import 'package:digiwhale_im/enums/nim_session_type_extension.dart';
import 'package:digiwhale_im/models/nim_message_model.dart';
import 'package:digiwhale_im/models/nim_message_receipt_model.dart';
import 'package:digiwhale_im/models/nim_message_revoke_model.dart';
import 'package:digiwhale_im/models/nim_team_member_model.dart';
import 'package:digiwhale_im/models/nim_team_message_read_info_model.dart';
import 'package:digiwhale_im/models/nim_team_message_receipt_model.dart';
import 'package:digiwhale_im/models/nim_team_model.dart';
import 'package:digiwhale_im/models/nim_user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'models/nim_session_model.dart';

/// 收到了聊天消息回调
typedef MessagesUpdateCallback = void Function(List<NIMMessage> messageList);

/// 更新最近会话 包括添加最近会话 回调
typedef SessionsUpdateCallback = void Function(
    List<NIMSession> sessionList, bool isAdd);

/// 撤回消息回调
typedef MessageRevokeCallback = void Function(NIMMessageRevoke messageRevoke);

/// 监听P2P已读消息回执回调
typedef MessagesReceiptCallback = void Function(
    List<NIMMessageReceipt> messageReceiptList);

/// 监听群组消息已读回执
typedef TeamMessagesReceiptCallback = void Function(
    List<NIMTeamMessageReceipt> teamMessageReceiptList);

/// 数据同步回调
typedef NIMSyncOKCallback = void Function(Map status);

///用来标记是否同步完成，同步完成后才去请求会话列表，同步未完成则等待同步完成
bool SyncStatus = false;

class DigiwhaleIm {
  MethodChannel _methodChannel = const MethodChannel('digiwhale_im_flutter');
  EventChannel _eventChannel = const EventChannel('digiwhale_im_native');

  MessagesUpdateCallback messagesUpdateCallback;
  SessionsUpdateCallback sessionsUpdateCallback;
  MessageRevokeCallback messageRevokeCallback;
  MessagesReceiptCallback messagesReceiptCallback;
  TeamMessagesReceiptCallback teamMessagesReceiptCallback;
  NIMSyncOKCallback syncOKCallBack;

  ///static _instance，保证了只被创建一次  (整个项目只需要创建一次)
  static final DigiwhaleIm _instance = DigiwhaleIm._internal();

  ///提供一个工厂方法来获取该类的实例
  factory DigiwhaleIm() {
    return _instance;
  }

  ///通过私有方法_internal()隐藏了构造方法，防止被误创建
  DigiwhaleIm._internal() {
    // 初始化
    init();
  }

  ///初始化
  void init() {
    print("这里初始化");
    _methodChannel.setMethodCallHandler(handleMethod);
    _eventChannel
        .receiveBroadcastStream()
        .listen(handleMethod, onError: _onError);
  }

  ///Native回调Flutter监听
  ///接收消息
  void doMessagesUpdate(List receiveMessages) {
    if (messagesUpdateCallback != null) {
      List<NIMMessage> nimMessageList = [];
      receiveMessages.forEach((message) {
        nimMessageList
            .add(NIMMessage.fromJson(new Map<String, dynamic>.from(message)));
      });
      messagesUpdateCallback(nimMessageList);
    }
  }

  ///更新最近会话
  Future<dynamic> doSessionsUpdate(List sessions) async {
    if (sessionsUpdateCallback != null) {
      List<NIMSession> nimSessionList = [];
      sessions.forEach((session) {
        nimSessionList
            .add(NIMSession.fromJson(new Map<String, dynamic>.from(session)));
      });
      sessionsUpdateCallback(nimSessionList, false);
    }
    return null;
  }

  ///增加最近会话
  Future<dynamic> doSessionsAdd(List sessions) async {
    if (sessionsUpdateCallback != null) {
      List<NIMSession> nimSessionList = [];
      sessions.forEach((session) {
        nimSessionList
            .add(NIMSession.fromJson(new Map<String, dynamic>.from(session)));
      });
      sessionsUpdateCallback(nimSessionList, true);
    }
  }

  ///撤回消息监听
  void doMessageRevoke(Map messageRevoke) {
    if (messageRevokeCallback != null) {
      NIMMessageRevoke nimMessageRevoke = NIMMessageRevoke.fromJson(
          new Map<String, dynamic>.from(messageRevoke));
      messageRevokeCallback(nimMessageRevoke);
    }
  }

  ///P2P消息已读回执监听
  void doMessagesReceipt(List nimMessageReceipts) {
    if (messagesReceiptCallback != null) {
      List<NIMMessageReceipt> nimMessageReceiptList = [];
      nimMessageReceipts.forEach((messageReceipt) {
        nimMessageReceiptList.add(NIMMessageReceipt.fromJson(
            new Map<String, dynamic>.from(messageReceipt)));
      });
      messagesReceiptCallback(nimMessageReceiptList);
    }
  }

  ///群组消息已读回执监听
  void doTeamMessagesReceipt(List nimTeamMessageReceipts) {
    if (teamMessagesReceiptCallback != null) {
      List<NIMTeamMessageReceipt> nimTeamMessageReceiptList = [];
      nimTeamMessageReceipts.forEach((messageReceipt) {
        nimTeamMessageReceipts.add(NIMTeamMessageReceipt.fromJson(
            new Map<String, dynamic>.from(messageReceipt)));
      });
      teamMessagesReceiptCallback(nimTeamMessageReceiptList);
    }
  }

  ///云信数据同步完毕 （数据同步完毕后再请求会话列表）
  void doNIMSyncOK(Map status) {
    SyncStatus = true;
    syncOKCallBack(status);
  }

  ///接收Native回调
  Future<dynamic> handleMethod(dynamic call) async {
    print(call);
    String methodName = "";
    if (Platform.isIOS) {
      methodName = call.method;
    } else {
      Map map = call;
      methodName = map["eventName"];
    }

    dynamic params;
    if (Platform.isIOS) {
      params = call.arguments;
    } else {
      Map map = call;
      params = call['data'];
    }
    switch (methodName) {
      case 'onMessagesUpdate':
        //消息监听
        doMessagesUpdate(params);
        break;
      case 'onSessionsUpdate':
        //会话更新监听
        doSessionsUpdate(params);
        break;
      case 'onSessionsAdd':
        //会话新增监听(目前只有iOS会有)
        doSessionsAdd(params);
        break;
      case 'onMessageRevoke':
        //消息撤回监听
        doMessageRevoke(params);
        break;
      case 'onMessagesReceipt':
        //P2P消息已读回执
        doMessagesReceipt(params);
        break;
      case 'onTeamMessagesReceipt':
        //群组消息已读回执
        doTeamMessagesReceipt(params);
        break;
      case 'onNIMSyncOK':
        //云信数据同步回调
        doNIMSyncOK(params);
        break;
      default:
        print("回调类型有误：" + methodName);
    }
    return null;
  }

  void _onError(dynamic error) {
    print("监听出错：" + error);
  }

  ///初始化(安卓 iOS --注册监听)
  void nimClientInit() {
    _methodChannel.invokeMethod("nimClientInit");
  }

  ///登录
  Future<bool> login(String account, String token) async {
    Map<String, String> map = {"account": account, "token": token};
    return await _methodChannel.invokeMethod("nimLogin", map);
  }

  ///登出
  void loginOut() {
    _methodChannel.invokeMethod("loginOut");
  }

  ///登录状态
  Future<String> loginStatus() async {
    return await _methodChannel.invokeMethod("loginStatus");
  }

  ///发送消息
  ///sessionID: 聊天对象ID(单聊为账号id，群聊为群组ID)
  ///sessionType: 会话类型(单聊为0，群聊为1)
  ///text:  文本消息内容
  Future<bool> sendMessage(
      {@required String sessionId,
      @required NIMSessionType sessionType,
      @required String text,
      NIMMessageType messageType = NIMMessageType.Text,
      Map<String, Object> teamNotificationData}) async {
    Map<String, Object> map = {
      "sessionId": sessionId,
      "sessionType": NIMSessionTypeExtension.getValue(sessionType),
      "messageType": NIMMessageTypeExtension.getValue(messageType),
      "text": text,
    };
    if (teamNotificationData != null) {
      map["teamNotificationData"] = teamNotificationData;
    }
    dynamic isSendSuccess =
        await _methodChannel.invokeMethod("sendMessage", map);
    return isSendSuccess;
  }

  ///最近会话
  Future<List<NIMSession>> getAllSessions() async {
    List sessions = await _methodChannel.invokeMethod("getAllSessions");
    List<NIMSession> nimSessionList = [];
    sessions.forEach((session) {
      nimSessionList
          .add(NIMSession.fromJson(new Map<String, dynamic>.from(session)));
    });
    return nimSessionList;
  }

  ///删除最近会话
  void deleteSession(
      {@required String sessionId, @required NIMSessionType sessionType}) {
    Map<String, Object> map = {
      "sessionId": sessionId,
      "sessionType": NIMSessionTypeExtension.getValue(sessionType)
    };
    _methodChannel.invokeMethod("deleteSession", map);
  }

  ///本地聊天记录
  ///sessionType 会话类型
  ///sessionId  会话id
  ///messageId  锚点消息id,从这条往前查找（如果为空或无此消息，则从最新一条消息开始查找）（返回结果不包含此消息）
  ///limit  最多拿多少条消息
  Future<List<NIMMessage>> fetchLocalMessageHistory({
    @required NIMSessionType sessionType,
    @required String sessionId,
    @required int limit,
    String messageId,
  }) async {
    Map<String, Object> map = {
      "sessionType": NIMSessionTypeExtension.getValue(sessionType),
      "sessionId": sessionId,
      "limit": limit,
      "messageId": messageId
    };
    List messages =
        await _methodChannel.invokeMethod("fetchLocalMessageHistory", map);
    List<NIMMessage> nimMessageList = [];
    messages.forEach((message) {
      nimMessageList
          .add(NIMMessage.fromJson(new Map<String, dynamic>.from(message)));
    });
    return nimMessageList;
  }

  ///云端聊天记录
  ///sessionType 会话类型
  ///sessionId  会话id
  ///messageId  锚点消息id,从这条往前查找（如果为空或无此消息，则从最新一条消息开始查找）（返回结果不包含此消息）
  ///limit  最多拿多少条消息
  Future<List<NIMMessage>> fetchMessageHistory({
    @required NIMSessionType sessionType,
    @required String sessionId,
    @required int toTime,
    @required int limit,
    String messageId,
  }) async {
    Map<String, Object> map = {
      "sessionType": NIMSessionTypeExtension.getValue(sessionType),
      "sessionId": sessionId,
      "toTime": toTime,
      "limit": limit,
      "messageId": messageId
    };
    List messages =
        await _methodChannel.invokeMethod("fetchMessageHistory", map);
    List<NIMMessage> nimMessageList = [];
    messages.forEach((message) {
      nimMessageList
          .add(NIMMessage.fromJson(new Map<String, dynamic>.from(message)));
    });
    return nimMessageList;
  }

  ///消息已读
  ///messageId  消息id，本条及之前的消息都会被设置已读
  void sendMessageReceipt(
      {@required String sessionId,
      @required NIMSessionType sessionType,
      @required String messageId}) {
    Map<String, Object> map = {
      "sessionId": sessionId,
      "sessionType": NIMSessionTypeExtension.getValue(sessionType),
      "messageId": messageId
    };
    _methodChannel.invokeMethod("sendMessageReceipt", map);
  }

  ///设置某一个会话消息全部已读
  void markAllMessagesReadInSession(
      {@required String sessionId, @required NIMSessionType sessionType}) {
    _methodChannel.invokeMethod('markAllMessagesReadInSession', {
      'sessionId': sessionId,
      "sessionType": NIMSessionTypeExtension.getValue(sessionType),
    });
  }

  ///消息撤回
  Future<bool> revokeMessage({@required String messageId}) async {
    Map<String, Object> map = {"messageId": messageId};
    bool result = await _methodChannel.invokeMethod("revokeMessage", map);
    return result;
  }

  ///获取人员信息
  ///返回Map，key为用户id，value为详细信息
  Future<Map<String, NIMUser>> getUserInfoList(
      {@required List<String> accounts}) async {
    Map<String, Object> map = {"accounts": accounts};
    List users =
        await _methodChannel.invokeMethod<List>("getUserInfoList", map);
    List<NIMUser> nimUserList = [];
    users.forEach((user) {
      nimUserList.add(NIMUser.fromJson(new Map<String, dynamic>.from(user)));
    });
    Map<String, NIMUser> userMap = {};
    if (nimUserList != null && nimUserList.length > 0) {
      for (NIMUser user in nimUserList) {
        userMap.putIfAbsent(user.accId, () => user);
      }
    }
    return userMap;
  }

  ///获取当前登录人员信息
  Future<NIMUser> getCurrentUserInfo() async {
    Map user =
        await _methodChannel.invokeMethod<Map>("getCurrentUserInfo", null);
    NIMUser nimUser = NIMUser();
    if (user != null) {
      nimUser = NIMUser.fromJson(new Map<String, dynamic>.from(user));
    }
    return nimUser;
  }

  ///创建群组
  ///name:群名称
  ///accounts:群成员账号列表
  Future<NIMTeam> createTeam(
      {@required String name, @required List<String> accounts}) async {
    Map<String, Object> map = {"name": name, "accounts": accounts};
    Map team = await _methodChannel.invokeMethod<Map>("createTeam", map);
    NIMTeam nimTeam = NIMTeam();
    if (team != null) {
      nimTeam = NIMTeam.fromJson(new Map<String, dynamic>.from(team));
    }
    return nimTeam;
  }

  ///获取群基本信息
  ///teamId:群id
  Future<NIMTeam> getTeam({@required String teamId}) async {
    Map<String, Object> map = {"teamId": teamId};
    Map team = await _methodChannel.invokeMethod<Map>("getTeam", map);
    NIMTeam nimTeam = NIMTeam();
    if (team != null) {
      nimTeam = NIMTeam.fromJson(new Map<String, dynamic>.from(team));
    }
    return nimTeam;
  }

  ///获取群成员列表
  ///teamId:群id
  Future<List<NIMTeamMember>> getTeamMemberList(
      {@required String teamId}) async {
    Map<String, Object> map = {"teamId": teamId};
    List members =
        await _methodChannel.invokeMethod<List>("getTeamMemberList", map);
    List<NIMTeamMember> nimTeamMemberList = [];
    members.forEach((member) {
      nimTeamMemberList
          .add(NIMTeamMember.fromJson(new Map<String, dynamic>.from(member)));
    });
    return nimTeamMemberList;
  }

  ///获取群消息已读未读信息
  Future<NIMTeamMessageReadInfo> getTeamMessageReadInfo(
      {@required String messageId}) async {
    Map<String, Object> map = {"messageId": messageId};
    Map readInfo =
        await _methodChannel.invokeMethod<Map>("getTeamMessageReadInfo", map);
    NIMTeamMessageReadInfo messageReadInfo = NIMTeamMessageReadInfo();
    if (readInfo != null) {
      messageReadInfo =
          NIMTeamMessageReadInfo.fromJson(Map<String, dynamic>.from(readInfo));
    }
    return messageReadInfo;
  }
}
