/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-09-29 10:28:52
 * @LastEditor: ----Athena----
 */
///P2P消息已读回执
class NIMMessageReceipt {
  //P2P聊天对象的账号
  String sessionId;
  //该会话最后一条已读消息的时间，比该时间早的消息都视为已读
  int timestamp;

  NIMMessageReceipt({this.sessionId, this.timestamp});

  NIMMessageReceipt.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    timestamp = json['timestamp'];
  }
}
