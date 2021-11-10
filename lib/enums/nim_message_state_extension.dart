import 'nim_message_state.dart';

extension NIMMessageStateExtension on NIMMessageState {
  static NIMMessageState getTypeValue(int value) {
    switch (value) {
      case -1:
        return NIMMessageState.draft;
      case 0:
        return NIMMessageState.sending;
      case 1:
        return NIMMessageState.success;
      case 2:
        return NIMMessageState.fail;
      case 3:
        return NIMMessageState.read;
      case 4:
        return NIMMessageState.unread;
      default:
        return NIMMessageState.None;
    }
  }
}
