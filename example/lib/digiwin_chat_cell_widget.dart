/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-10-11 11:22:16
 * @LastEditor: ----Athena----
 */
import 'package:digiwhale_im/enums/nim_session_type.dart';
import 'package:digiwhale_im/enums/nim_session_type_extension.dart';
import 'package:digiwhale_im/models/nim_session_model.dart';
import 'package:digiwhale_im_example/digiwin_chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'digiwin_chat_provider.dart';
import 'package:digiwhale_im/models/nim_team_member_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DigiwinChatCellWidget extends StatefulWidget {
  NIMSession entity;
  List receiptsMessage; // 已读消息回执
  List<NIMTeamMember> teamMemberList; // 群成员列表

  DigiwinChatProvider chatShareData;
  DigiwinChatCellWidget(
      {this.entity,
      this.chatShareData,
      this.receiptsMessage,
      this.teamMemberList});

  @override
  _DigiwinChatCellWidgetState createState() => _DigiwinChatCellWidgetState();
}

class _DigiwinChatCellWidgetState extends State<DigiwinChatCellWidget> {
  Widget iconWidget(bool isP2P) {
    if (isP2P) {
      return Container(
        padding: EdgeInsets.only(right: 10),
        // 图片宽高
        width: 50,
        height: 50,
        // 描述图片的圆形，需要使用背景图来做
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
      );
    } else {
      return Container(
          padding: EdgeInsets.only(right: 10),
          // 图片宽高
          width: 50,
          height: 50,
          // 描述图片的圆形，需要使用背景图来做
          child: Center(
            child: Text("群聊"),
          ),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(50),
            // image: DecorationImage(
            //     fit: BoxFit.cover,
            //     image: NetworkImage(
            //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //点击进入聊天详情页面
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => DigiwinChatPage(
                sessionID: widget.entity.sessionId,
                chatShareData: widget.chatShareData,
                sessionType:
                    NIMSessionTypeExtension.getValue(widget.entity.sessionType),
              ),
            ));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Container(
          child: Row(
            children: [
              Stack(
                children: [
                  iconWidget(widget.entity.sessionType == NIMSessionType.P2P),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                      child: Text(
                        widget.entity.unreadCount.toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  // Text(widget.entity.message.fromName ?? ""),
                  getNameWidget(),
                  Text(widget.entity.message.text == null
                      ? "null"
                      : widget.entity.message.text)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  ///名字组件  处理群聊和单聊
  Widget getNameWidget() {
    if (widget.entity.sessionType == NIMSessionType.Team) {
      if (widget.teamMemberList == null) {
        return Container();
      } else {
        // return Text(getNameList());
        return Container(
          width: 1.sw - 100,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  getNameList(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      }
    } else {
      return Text(widget.entity.message.fromName ?? "");
    }
  }

  /// 组装群聊时多个名字
  String getNameList() {
    String name = "";
    for (var i = 0; i < widget.teamMemberList.length; i++) {
      NIMTeamMember item = widget.teamMemberList[i];
      if (i == widget.teamMemberList.length - 1) {
        name += item.name == null ? "" : item.name;
      } else {
        name += item.name == null ? "" : (item.name + "、");
      }
    }
    return name;
  }
}
