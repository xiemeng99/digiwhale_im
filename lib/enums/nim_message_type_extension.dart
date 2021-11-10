/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-10-22 13:48:09
 * @LastEditor: ----Athena----
 */
import 'nim_message_type.dart';

extension NIMMessageTypeExtension on NIMMessageType {
  static NIMMessageType getTypeValue(int value) {
    switch (value) {
      case 0:
        return NIMMessageType.Text;
        break;
      case 1:
        return NIMMessageType.Image;
        break;
      case 2:
        return NIMMessageType.Audio;
        break;
      case 3:
        return NIMMessageType.Video;
        break;
      case 4:
        return NIMMessageType.Location;
        break;
      case 5:
        return NIMMessageType.Notification;
        break;
      case 6:
        return NIMMessageType.File;
        break;
      case 10:
        return NIMMessageType.Tip;
        break;
      case 11:
        return NIMMessageType.Robot;
        break;
      case 100:
        return NIMMessageType.Custom;
        break;
      case 1001:
        return NIMMessageType.Revoke_me;
      case 1002:
        return NIMMessageType.Revoke_other;
      default:
        return NIMMessageType.None;
    }
  }

  static int getValue(NIMMessageType sessionType) {
    switch (sessionType) {
      case NIMMessageType.Text:
        return 0;
      case NIMMessageType.Image:
        return 1;
      case NIMMessageType.Audio:
        return 2;
      case NIMMessageType.Video:
        return 3;
      case NIMMessageType.Location:
        return 4;
      case NIMMessageType.Notification:
        return 5;
      case NIMMessageType.File:
        return 6;
      case NIMMessageType.Tip:
        return 10;
      case NIMMessageType.Robot:
        return 11;
      case NIMMessageType.Custom:
        return 100;
      case NIMMessageType.Revoke_me:
        return 1001;
      case NIMMessageType.Revoke_other:
        return 1002;
      default:
        return -1;
    }
  }
}
