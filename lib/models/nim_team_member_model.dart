import 'package:digiwhale_im/enums/nim_team_member_type.dart';
import 'package:digiwhale_im/enums/nim_team_member_type_extension.dart';

///群成员
class NIMTeamMember {
  ///所属群id
  String teamId;

  ///群成员账号
  String account;

  ///群成员类型
  NIMTeamMemberType teamMemberType;

  ///在当前群里的昵称
  String name;

  ///入群时间
  int joinTime;

  NIMTeamMember(
      {this.teamId,
      this.account,
      this.teamMemberType,
      this.name,
      this.joinTime});

  NIMTeamMember.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    account = json['account'];
    name = json['name'];
    joinTime = json['joinTime'];
    int type = json['teamMemberType'];
    teamMemberType = NIMTeamMemberTypeExtension.getTypeValue(type);
  }
}
