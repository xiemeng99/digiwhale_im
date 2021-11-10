import 'package:digiwhale_im/models/nim_message_model.dart';

///消息撤回
class NIMMessageRevoke {
  NIMMessage message;
  String revokeAcctId;

  NIMMessageRevoke({this.message, this.revokeAcctId});

  NIMMessageRevoke.fromJson(Map<String, dynamic> json) {
    message =
        json['message'] != null ? NIMMessage.fromJson(json['message']) : null;
    revokeAcctId = json['revokeAcctId'];
  }
}
