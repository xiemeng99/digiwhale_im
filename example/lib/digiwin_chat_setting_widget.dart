/*
 * @Author: weiguoqing
 * @Date: 2021-09-29 14:23:45
 * @LastEditTime: 2021-10-12 09:54:14
 * @LastEditor: ----Athena----
 */

import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DigiwinChatSettingWidget extends StatefulWidget {
  bool switchStatus = false; //开关状态
  String labelName; //label名字
  bool isSwitch; //右边是否是开关
  double topMargin; //

  DigiwinChatSettingWidget(
      {this.switchStatus, this.labelName, this.isSwitch, this.topMargin});
  @override
  _DigiwinChatSettingWidgetState createState() =>
      _DigiwinChatSettingWidgetState();
}

class _DigiwinChatSettingWidgetState extends State<DigiwinChatSettingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: widget.topMargin, bottom: 0),
      padding: EdgeInsets.only(left: 10, right: 10),
      child: addUserWidget(),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.switchStatus == null) {
      widget.switchStatus = false;
    }
  }

  ///添加用户组件
  Widget addUserWidget() {
    Widget settingDefault = Row(
      children: [
        Text(
          widget.labelName,
          style: TextStyle(
              fontSize: 28.sp,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400),
        ),
        Spacer(),
        rightWidget(),
        // Switch(
        //     value: widget.switchStatus,
        //     onChanged: (value) {
        //       widget.switchStatus = value;
        //       print(value);
        //       setState(() {});
        //     })
      ],
    );
    return settingDefault;
  }

  /// 右边组件 可能是开关 也可能是箭头
  Widget rightWidget() {
    if (widget.isSwitch) {
      return Container(
        height: 50,
        child: Transform.scale(
          scale: 1,
          child: CupertinoSwitch(
            value: false,
            onChanged: (bool value) {
              setState(() {
                widget.switchStatus = value;
                print(value);
                setState(() {});
              });
            },
          ),
        ),
      );
    } else {
      return Container(
        height: 50,
        child: Center(
          child: Text(">"),
        ),
      );
    }
  }
}
