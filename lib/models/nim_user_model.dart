///用户信息
class NIMUser {
  ///在云信系统中的id
  String accId;

  ///姓名
  String name;

  ///头像url
  String avatarUrl;

  /// eocId
  String eocId;

  NIMUser({this.accId, this.name, this.avatarUrl, this.eocId});

  NIMUser.fromJson(Map<String, dynamic> json) {
    //改为accId，跟原来名称统一下
    accId = json['acctId'];
    name = json['name'];
    avatarUrl = json['avatarUrl'];
    eocId = json['eocId'];
  }
}
