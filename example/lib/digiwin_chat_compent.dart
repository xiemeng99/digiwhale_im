/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-10-09 19:48:37
 * @LastEditor: ----Athena----
 */

import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im/models/nim_session_model.dart';
import 'package:digiwhale_im_example/digiwin_chat_cell_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'digiwin_chat_provider.dart';

class DigiwinChatCompent extends StatefulWidget {
  List<NIMSession> sessions = [];
  // Map<String, List<NIMTeamMember>> teamMemberMap; // 群成员列表
  Map teamMemberMap; // 群成员列表

  DigiwinChatProvider chatShareData;
  DigiwinChatCompent({this.sessions, this.chatShareData, this.teamMemberMap});

  @override
  _DigiwinChatCompentState createState() => _DigiwinChatCompentState();
}

class _DigiwinChatCompentState extends State<DigiwinChatCompent> {
  @override
  void initState() {
    super.initState();
  }

  final SlidableController slidableController = SlidableController();

  @override
  void dispose() {
    super.dispose();
    print("页面销毁了");
  }

  /// 从云信获取资料
  void getAccids() async {
    List<String> accIDS = [];
    // for (var item in widget.sessions) {
    //   accIDS.add(item.session.sessionId);
    // }

    // Map accs = await DigiwhaleIm().getUserInfo(accounts: accIDS);
    // print(accs);
  }

  @override
  Widget build(BuildContext context) {
    NIMSession recentSession =
        context.watch<DigiwinChatProvider>().recentSession;
    List receiptsMessage = context.watch<DigiwinChatProvider>().receiptsMessage;

    // Map push = context.watch<DigiwinChatProvider>().pushMap;
    // if (push != null) {
    //   Timer(Duration(milliseconds: 1000), () {
    //     Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //           builder: (context) => DigiwinChatPage(
    //             sessionID: "a2",
    //             chatShareData: widget.chatShareData,
    //           ),
    //         ));
    //   });
    // }

    print(receiptsMessage);
    if (recentSession != null) {
      // print("监听到了");
      NIMSession entity;
      NIMSession recentEntity = recentSession; //变更的会话
      for (var i = 0; i < widget.sessions.length; i++) {
        NIMSession oldEntity = widget.sessions[i];
        if (oldEntity.sessionId == recentEntity.sessionId) {
          widget.sessions.removeAt(i);
          // widget.sessions.add(oldEntity);
          entity = recentEntity;
          widget.sessions.insert(0, entity);
          break;
        }
      }
      if (entity == null) {
        widget.sessions.insert(0, recentEntity);
      }
    }
    getAccids();

    return Container(
      child: ListView.builder(
          itemCount: widget.sessions.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              key: Key(widget.sessions[index].sessionId),
              actionPane: SlidableScrollActionPane(), //滑出选项的面板 动画
              actionExtentRatio: 0.16, //侧滑按钮所占的宽度
              closeOnScroll: true,
              controller: slidableController,
              secondaryActions: <Widget>[
                //右侧按钮列表
                // SlideAction(
                //   child: Text(
                //     "置顶",
                //     style: TextStyle(fontSize: 15, color: Colors.white),
                //   ),
                //   color: Color(0XFFBBBFC4),
                //   closeOnTap: true,
                // ),
                SlideAction(
                  child: Text(
                    "删除",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  color: Colors.red,
                  closeOnTap: true,
                  onTap: () {
                    DigiwhaleIm().deleteSession(
                        sessionId: widget.sessions[index].sessionId,
                        sessionType: widget.sessions[index].sessionType);
                    setState(() {
                      widget.sessions.removeAt(index);
                    });
                  },
                  // closeOnScroll:
                ),
              ],
              child: DigiwinChatCellWidget(
                entity: widget.sessions[index],
                chatShareData: widget.chatShareData,
                receiptsMessage: receiptsMessage,
                teamMemberList:
                    widget.teamMemberMap[widget.sessions[index].sessionId],
              ),
            );
          }),
    );
  }
}
