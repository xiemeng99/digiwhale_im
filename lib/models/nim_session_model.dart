import 'package:digiwhale_im/enums/nim_session_type.dart';
import 'package:digiwhale_im/enums/nim_session_type_extension.dart';

import 'nim_message_model.dart';
import 'nim_user_model.dart';

///会话
class NIMSession {
  ///会话Id，群聊为群组id,单聊为用户id
  String sessionId;

  ///会话类型
  NIMSessionType sessionType;

  ///最新一条消息
  NIMMessage message;

  ///未读消息数
  int unreadCount;

  ///聊天对象信息(单聊为对方用户信息，群聊待定)
  NIMUser user;

  NIMSession(
      {this.sessionId,
      this.sessionType,
      this.message,
      this.unreadCount,
      this.user});

  NIMSession.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    int sessionTypeValue = json['sessionType'];
    sessionType = NIMSessionTypeExtension.getTypeValue(sessionTypeValue);
    Map messageJson = Map<String, dynamic>.from(json['message']);
    message = json['message'] != null ? NIMMessage.fromJson(messageJson) : null;
    unreadCount = json['unreadCount'];
    user = json['user'] != null
        ? NIMUser.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
  }
}
