/*
 * @Author: weiguoqing
 * @Date: 2021-10-12 09:06:26
 * @LastEditTime: 2021-10-22 14:28:21
 * @LastEditor: ----Athena----
 */
import 'package:digiwhale_im/enums/nim_message_state.dart';
import 'package:digiwhale_im/enums/nim_message_state_extension.dart';
import 'package:digiwhale_im/enums/nim_message_type.dart';
import 'package:digiwhale_im/enums/nim_message_type_extension.dart';

///消息
class NIMMessage {
  ///会话Id，群聊为群组id,单聊为用户id
  String sessionId;

  /// 消息ID,唯一标识
  String messageId;

  /// 消息发送人id
  String fromId;

  /// 消息发送人姓名
  String fromName;

  /// 消息发送时间戳，单位 ms
  int timestamp;

  /// 对端是否已读
  bool remoteRead;

  ///消息类型
  NIMMessageType messageType;

  /// 消息文本，仅文本类型消息有值
  String text;

  /// 是否是往外发的消息
  /// 由于能对自己发消息，所以并不是所有来源是自己的消息都是往外发的消息，这个字段用于判断头像排版位置（是左还是右）。
  bool outgoingMsg;

  ///消息投递状态（仅针对发送的消息）
  NIMMessageState messageState;

  ///群消息已读人数(仅群组有效)
  int readCount;

  ///群消息未读人数(仅群组有效)
  int unReadCount;

  ///群通知数据 用来实现群里显示 你邀请了A加入了和B的聊天
  Map teamNotificationData;

  NIMMessage(
      {this.messageId,
      this.sessionId,
      this.fromId,
      this.fromName,
      this.timestamp,
      this.messageType,
      this.text,
      this.outgoingMsg,
      this.messageState,
      this.readCount,
      this.unReadCount});

  NIMMessage.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    sessionId = json['sessionId'];
    fromId = json['fromId'];
    fromName = json['fromName'];
    timestamp = json['timestamp'];
    text = json['text'];
    remoteRead = json['remoteRead'];
    outgoingMsg = json['outgoingMsg'];
    readCount = json['readCount'];
    unReadCount = json['unReadCount'];
    teamNotificationData = json["teamNotificationData"];

    //消息类型
    int messageTypeValue = json["messageType"];
    messageType = NIMMessageTypeExtension.getTypeValue(messageTypeValue);

    //消息状态
    int messageStateValue = json["messageState"];
    messageState = NIMMessageStateExtension.getTypeValue(messageStateValue);
  }
}
