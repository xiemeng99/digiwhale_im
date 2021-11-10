///消息状态
enum NIMMessageState {
  None,
  draft, //草稿 -1
  sending, //正在发送中 0
  success, //发送成功  1
  fail, //发送失败  2
  read, //消息已读,发送消息时表示对方已看过该消息,接收消息时表示自己已读过，一般仅用于音频消息 3
  unread, //消息未读  4
}
