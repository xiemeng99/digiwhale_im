/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-11-09 14:04:46
 * @LastEditor: ----Athena----
 */
import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im/models/nim_message_model.dart';
import 'package:digiwhale_im/models/nim_message_receipt_model.dart';
import 'package:digiwhale_im/models/nim_session_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 只负责用来监听聊天相关数据 不做其他用途
class DigiwinChatProvider with ChangeNotifier {
  // static _instance，保证了只被创建一次  (整个项目只需要创建一次)
  static final DigiwinChatProvider _instance = DigiwinChatProvider._internal();

  //提供一个工厂方法来获取该类的实例
  factory DigiwinChatProvider() {
    return _instance;
  }

  // 通过私有方法_internal()隐藏了构造方法，防止被误创建
  DigiwinChatProvider._internal() {
    // 初始化
    init();
  }

  // 会话消息未读数 （总的消息未读数  用来显示到 底部导航上面哦）
  int _badgeNumber = 0;
  bool allSelect = false;

  // 最近会话列表  内部使用
  List<NIMSession> _recentSessions = [];

  // 最近会话
  NIMSession recentSession;

  // 聊天消息
  List<NIMMessage> recentMessage = [];

  // 撤回消息
  NIMMessage recvMessage;
  // 消息已读回执
  List<NIMMessageReceipt> receiptsMessage = [];

  // 最近会话列表  对外暴露 外部使用
  List<NIMSession> get recentSessions => _recentSessions;

  ///更新全选或者 全不选状态
  updateSelfMessage() {
    recentMessage = [];
  }

  void init() {
    // 用来监听 聊天相关数据
    DigiwhaleIm().messagesUpdateCallback = (message) {
      recentMessage = message;
      notifyListeners();
    };

    // 更新 最近会话 回调
    DigiwhaleIm().sessionsUpdateCallback = (recent, isAdd) {
      print(recentMessage);
      if (recent != null) {
        recentSession = recent.last;
      }
      notifyListeners();
    };

    // 数据同步完毕回调
    DigiwhaleIm().syncOKCallBack = (status) {
      notifyListeners();
    };

    // //撤回消息回调 回调
    // DigiwhaleIm().recvCallBack = (recvCallMessage) {
    //   // print(recvMessage);
    //   Map json = recvCallMessage["NIMMessage"];
    //   recvMessage = MessageEntity.fromJson(json);
    //   notifyListeners();
    // };

    //已读消息回执 回调
    DigiwhaleIm().messagesReceiptCallback =
        (List<NIMMessageReceipt> receiptsCallMessage) {
      receiptsMessage = [];
      receiptsMessage.addAll(receiptsCallMessage);
      // 目前只有点对点消息  所以type 暂时不解析
      notifyListeners();
    };
  }
}
