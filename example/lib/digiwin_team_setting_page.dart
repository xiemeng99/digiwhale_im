/*
 * @Author: weiguoqing
 * @Date: 2021-10-09 11:35:57
 * @LastEditTime: 2021-10-12 10:14:37
 * @LastEditor: ----Athena----
 */

import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im_example/digiwin_chat_page.dart';
import 'package:digiwhale_im_example/digiwin_chat_provider.dart';
import 'package:digiwhale_im_example/digiwin_chat_setting_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:digiwhale_im/models/nim_team_member_model.dart';

class DigiwinTeamSetting extends StatefulWidget {
  String teamId;
  DigiwinTeamSetting({this.teamId});
  @override
  _DigiwinTeamSettingState createState() => _DigiwinTeamSettingState();
}

class _DigiwinTeamSettingState extends State<DigiwinTeamSetting> {
  List<NIMTeamMember> accountList = [];
  @override
  void initState() {
    super.initState();
    getAccountList();
  }

  /// 获取群成员列表
  void getAccountList() {
    DigiwhaleIm().getTeamMemberList(teamId: widget.teamId).then((value) {
      print(value);
      accountList = value;
      setState(() {});
      // teamMap[item.sessionId] = value;
      // setState(() {});
    });
  }

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
            title: Container(
              child: Text(
                "群设置",
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
                teamWidget(),
                usersWidget(),
                DigiwinChatSettingWidget(
                    labelName: "群名称", isSwitch: false, topMargin: 10),
                DigiwinChatSettingWidget(
                    labelName: "查看聊天记录", isSwitch: false, topMargin: 10),
                DigiwinChatSettingWidget(
                    labelName: "消息免打扰", isSwitch: true, topMargin: 1),
                DigiwinChatSettingWidget(
                    labelName: "置顶聊天", isSwitch: true, topMargin: 1),
                //开启群聊  测试代码
                InkWell(
                  onTap: () {
                    createTeam();
                  },
                  child: Container(
                    height: 100,
                    child: Text("开启群聊（测试用）"),
                  ),
                )
              ],
            ),
          )),
    );
  }

  ///群相关组件 群头像 群名称 公告 搜索 文件 图片 视频  具体功能待实现
  Widget teamWidget({double size = 50}) {
    Widget teamWidget = Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 30),
          child: commonWidget("未命名", 60, 36.sp, Color(0xFF999999)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            commonWidget("公告", size, 28.sp, Color(0xFF333333)),
            commonWidget("搜索", size, 28.sp, Color(0xFF333333)),
            commonWidget("文件", size, 28.sp, Color(0xFF333333)),
            commonWidget("图片/视频", size, 28.sp, Color(0xFF333333))
          ],
        ),
      ],
    );
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: teamWidget,
    );
  }

  ///群相关组件 群头像 群名称 公告 搜索 文件 图片 视频  具体功能待实现
  Widget commonWidget(
      String labelName, double size, double fontSize, Color textColor) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: size,
          width: size,
          color: Colors.grey,
        ),
        Text(labelName,
            style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  ///创建群聊
  void createTeam() {
    List<String> account = [
      "710",
      "711",
      "712",
      "713",
      "714",
      "715",
      "716"
    ]; //数据先写死 用来测试
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

  ///群成员 添加用户 踢人  组件
  Widget usersWidget() {
    return Container(
      width: 1.sh,
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.only(top: 10),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                "群成员",
                style: TextStyle(
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w400,
                    fontSize: 32.sp),
              ),
            ),
            Container(
              // margin: EdgeInsets.all(10),
              // width: 750.w,
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                // spacing: 48.w,
                // runSpacing: 48.w,
                children: userWidget(),
              ),
            ),
            lookMore()
          ],
        ),
      ),
    );
  }

  /// 查看更多组件 需要判断当前用户是否大于8个（数量暂定）如果用户数量不大于八个 则不显示查看更多
  Widget lookMore() {
    return Container(
      padding: EdgeInsets.only(bottom: 24.sp),
      child: Center(
        child: Text(
          "查看更多",
          style: TextStyle(
              color: Color(0xFF999999),
              fontWeight: FontWeight.w400,
              fontSize: 24.sp),
        ),
      ),
    );
  }

  ///群成员 添加用户 踢人  组件
  List<Widget> userWidget() {
    List<Widget> users = [];
    List<NIMTeamMember> icons = accountList;

    for (var i = 0; i < icons.length + 2; i++) {
      //加号按钮 这个版本可能先没有  后面需要再打开 加号按钮和减号按钮可以合并到一起
      if (i == icons.length + 1) {
        // Widget user = Column(
        //   children: [
        //     InkWell(
        //       onTap: () {
        //         print("点击了群成员的某个头像，跳转到详情页");
        //       },
        //       child: Container(
        //           padding: EdgeInsets.only(right: 10),
        //           // 图片宽高
        //           width: 50,
        //           height: 50,
        //           // 描述图片的圆形，需要使用背景图来做
        //           child: Center(
        //             child: Text("-"),
        //           ),
        //           decoration: BoxDecoration(
        //             color: Colors.grey,
        //             borderRadius: BorderRadius.circular(50),
        //             // image: DecorationImage(
        //             //     fit: BoxFit.cover,
        //             //     image: NetworkImage(
        //             //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
        //           )),
        //     ),
        //   ],
        // );
        // users.add(user);
      } else if (i == icons.length) {
        //减号按钮 这个版本可能先没有  后面需要再打开 加号按钮和减号按钮可以合并到一起
        // Widget user = Column(
        //   children: [
        //     Container(
        //         padding: EdgeInsets.only(right: 10),
        //         // 图片宽高
        //         width: 50,
        //         height: 50,
        //         // 描述图片的圆形，需要使用背景图来做
        //         child: Center(
        //           child: Text("+"),
        //         ),
        //         decoration: BoxDecoration(
        //           color: Colors.grey,
        //           borderRadius: BorderRadius.circular(50),
        //           // image: DecorationImage(
        //           //     fit: BoxFit.cover,
        //           //     image: NetworkImage(
        //           //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
        //         )),
        //   ],
        // );
        // users.add(user);
      } else {
        NIMTeamMember member = icons[i];
        Widget user = Container(
          // color: Colors.orange,
          padding: EdgeInsets.all(10),
          width: 1.sw / 5,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  //点击了加号按钮 创建群聊 需要跳转到选择好友页面
                  print("点击了加号按钮 创建群聊 需要跳转到选择好友页面");
                },
                child: Container(
                    padding: EdgeInsets.only(right: 10),
                    // 图片宽高
                    width: 50,
                    height: 50,
                    // 描述图片的圆形，需要使用背景图来做
                    child: Center(
                      child: Text("头像"),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                      // image: DecorationImage(
                      //     fit: BoxFit.cover,
                      //     image: NetworkImage(
                      //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F24%2F20150824161927_X8U23.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1633052489&t=740f6f0c84e1b373d66a9e61ee5ec039'))),
                    )),
              ),
              Text(
                member.name,
                style: TextStyle(
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                    fontSize: 24.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        );
        users.add(user);
      }
    }
    return users;
  }
}
