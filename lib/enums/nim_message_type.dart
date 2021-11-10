///消息类型枚举
enum NIMMessageType {
  None,
  Text, // 文本类型消息 0
  Image, // 图片类型消息 1
  Audio, // 声音类型消息 2
  Video, // 视频类型消息 3
  Location, // 位置类型消息 4
  Notification, // 通知类型消息 5
  File, // 文件类型消息 6
  Tip, // 提醒类型消息 10
  Robot, // 机器人类型消息 11
  Custom, // 自定义类型消息 100
  Revoke_me, //撤回类消息，自己撤回  1001
  Revoke_other //撤回类消息，对方撤回  1002

}
