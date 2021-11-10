import 'package:digiwhale_im/enums/nim_team_member_type.dart';

extension NIMTeamMemberTypeExtension on NIMTeamMemberType {
  static NIMTeamMemberType getTypeValue(int value) {
    switch (value) {
      case 0:
        return NIMTeamMemberType.Normal;
      case 1:
        return NIMTeamMemberType.Owner;
      case 2:
        return NIMTeamMemberType.Manager;
      case 3:
        return NIMTeamMemberType.Apply;
      default:
        return NIMTeamMemberType.None;
    }
  }

  static int getValue(NIMTeamMemberType sessionType) {
    switch (sessionType) {
      case NIMTeamMemberType.Normal:
        return 0;
      case NIMTeamMemberType.Owner:
        return 1;
      case NIMTeamMemberType.Manager:
        return 2;
      case NIMTeamMemberType.Apply:
        return 3;
      default:
        return -1;
    }
  }
}
