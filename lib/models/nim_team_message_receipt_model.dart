import 'dart:core';

///群组消息已读回执
class NIMTeamMessageReceipt {
  //所属会话id(群组id)
  String sessionId;

  //消息id
  String messageId;

  //已读人数
  int readCount;

  //未读人数
  int unReadCount;

  NIMTeamMessageReceipt(
      {this.sessionId, this.messageId, this.readCount, this.unReadCount});

  NIMTeamMessageReceipt.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    messageId = json['messageId'];
    readCount = json['readCount'];
    unReadCount = json['unReadCount'];
  }
}
