/*
 * @Author: weiguoqing
 * @Date: 2021-10-09 16:46:31
 * @LastEditTime: 2021-11-09 16:22:21
 * @LastEditor: ----Athena----
 */
///群组
class NIMTeam {
  ///群组id
  String teamId;

  ///群组名称
  String name;

  ///头像url
  String avatarUrl;

  ///创建人账号
  String creator;

  ///群创建时间
  int createTime;

  ///群组内成员数
  int userCount;

  ///群组成员人数上限
  int userLimit;

  ///创建群组失败信息（失败后，弹窗提示）
  String errorMsg;

  NIMTeam(
      {this.teamId,
      this.name,
      this.creator,
      this.avatarUrl,
      this.createTime,
      this.userCount,
      this.userLimit,
      this.errorMsg});

  NIMTeam.fromJson(Map<String, dynamic> json) {
    teamId = json['teamId'];
    name = json['name'];
    avatarUrl = json['avatarUrl'];
    creator = json['creator'];
    createTime = json['createTime'];
    userCount = json['userCount'];
    userLimit = json['userLimit'];
    errorMsg = json['errorMsg'];
  }
}
