/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 19:14:32
 * @LastEditTime: 2021-10-12 09:58:19
 * @LastEditor: weiguoqing
 */

import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im_example/digiwin_chat_page.dart';
import 'package:digiwhale_im_example/digiwin_chat_provider.dart';
import 'package:digiwhale_im_example/digiwin_chat_setting_widget.dart';
import 'package:digiwhale_im_example/digiwin_team_setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DigiwinChatSetting extends StatefulWidget {
  @override
  _DigiwinChatSettingState createState() => _DigiwinChatSettingState();
}

class _DigiwinChatSettingState extends State<DigiwinChatSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_sharp,
                color: Color(0xFF333333),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // [
            //   InkWell(
            //     onTap: () {
            //       print("点击了设置");
            //     },
            //     child: Text("设置"),
            //   )
            // ],
            title: Container(
              child: Text(
                "聊天设置",
                style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333)),
              ),
            ),
            backgroundColor: Color(0xFFFFFFFF),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 1.sw,
                  color: Colors.white,
                  child: addUserWidget(),
                ),
                DigiwinChatSettingWidget(
                    labelName: "查看聊天记录", isSwitch: false, topMargin: 10),
                DigiwinChatSettingWidget(
                    labelName: "消息免打扰", isSwitch: true, topMargin: 10),
                DigiwinChatSettingWidget(
                    labelName: "置顶聊天", isSwitch: true, topMargin: 1),
                //开启群聊  测试代码
                InkWell(
                  onTap: () {
                    createTeam();
                  },
                  child: Text("开启群聊（测试用）"),
                ),
              ],
            ),
          )),
    );
  }

  ///创建群聊
  void createTeam() {
    List<String> account = ["710", "711", "712"];
    DigiwhaleIm()
        .createTeam(name: "群聊" + account.length.toString(), accounts: account)
        .then((team) {
      print(team);
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DigiwinChatPage(
              sessionID: team.teamId,
              sessionType: 1,
              chatShareData: DigiwinChatProvider(),
            ),
          ));
    });
  }

  ///添加用户组件
  Widget addUserWidget() {
    Widget addUsers = Wrap(
      // direction: Axis.vertical, //设置水平局部还是垂直布局
      alignment: WrapAlignment.start,
      spacing: 30,
      children: userWidget(),
    );
    return Container(
      padding: EdgeInsets.all(20),
      child: addUsers,
    );
  }

  ///用户头像组件
  List<Widget> userWidget() {
    List<Widget> users = [];
    List icons = [];

    for (var i = 0; i < icons.length + 1; i++) {
      if (i == icons.length + 1) {
        Widget user = Column(
          children: [
            Container(
                padding: EdgeInsets.only(right: 10),
                // 图片宽高
                width: 50,
                height: 50,
                // 描述图片的圆形，需要使用背景图来做
                child: Center(
                  child: Text("+"),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                  // image: DecorationImage(
                  //     fit: BoxFit.cover,
                  //     image: NetworkImage(
                  //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
                )),
            Text("无名")
          ],
        );
        users.add(user);
      } else {
        Widget user = InkWell(
          onTap: () {
            //点击了加号按钮 创建群聊 需要跳转到选择好友页面
            print("点击了加号按钮 创建群聊 需要跳转到选择好友页面");
            // Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (context) => DigiwinTeamSetting(),
            //     ));
          },
          child: Container(
              padding: EdgeInsets.only(right: 10),
              // 图片宽高
              width: 50,
              height: 50,
              // 描述图片的圆形，需要使用背景图来做
              child: Center(
                child: Text("+"),
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(50),
                // image: DecorationImage(
                //     fit: BoxFit.cover,
                //     image: NetworkImage(
                //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
              )),
        );
        users.add(user);
      }
    }
    return users;
  }
}
