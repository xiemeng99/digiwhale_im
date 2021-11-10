import 'nim_user_model.dart';

///群消息已读、未读详情信息
class NIMTeamMessageReadInfo {
  //群组id
  String teamId;
  //消息id
  String messageId;
  //已读用户的账号
  List<NIMUser> readUserList;
  //未读用户的账号
  List<NIMUser> unReadUserList;

  NIMTeamMessageReadInfo(
      {this.teamId, this.messageId, this.readUserList, this.unReadUserList});

  NIMTeamMessageReadInfo.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    messageId = json['messageId'];
    List readList = json['readUserList'];
    readUserList = [];
    if (readList != null && readList.length > 0) {
      readList.forEach((user) {
        readUserList.add(NIMUser.fromJson(new Map<String, dynamic>.from(user)));
      });
    }
    List unReadList = json['unReadUserList'];
    unReadUserList = [];
    if (unReadList != null && unReadList.length > 0) {
      readList.forEach((user) {
        unReadUserList
            .add(NIMUser.fromJson(new Map<String, dynamic>.from(user)));
      });
    }
  }
}
