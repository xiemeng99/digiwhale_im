import 'nim_session_type.dart';

extension NIMSessionTypeExtension on NIMSessionType {
  static NIMSessionType getTypeValue(int value) {
    switch (value) {
      case 0:
        return NIMSessionType.P2P;
      case 1:
        return NIMSessionType.Team;
      default:
        return NIMSessionType.None;
    }
  }

  static int getValue(NIMSessionType sessionType) {
    switch (sessionType) {
      case NIMSessionType.P2P:
        return 0;
      case NIMSessionType.Team:
        return 1;
      default:
        return -1;
    }
  }
}
