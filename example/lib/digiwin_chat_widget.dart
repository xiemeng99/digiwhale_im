/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 18:25:38
 * @LastEditTime: 2021-09-29 16:57:10
 * @LastEditor: weiguoqing
 */

import 'package:digiwhale_im/models/nim_message_model.dart';
import 'package:digiwhale_im/models/nim_user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 监听已读消息回执回调
typedef RecvCallback = void Function(NIMMessage revokeMessage);

class DigiwinChatWidget extends StatefulWidget {
  NIMMessage previousMessage;
  NIMMessage currentMessage;
  String myEocId;
  NIMUser user;
  RecvCallback callBack;
  int timestamp;
  DigiwinChatWidget(
      {this.previousMessage,
      this.currentMessage,
      this.timestamp,
      this.callBack,
      this.user,
      this.myEocId});

  @override
  _DigiwinChatWidgetState createState() => _DigiwinChatWidgetState();
}

class _DigiwinChatWidgetState extends State<DigiwinChatWidget> {
  NIMUser chatUser;
  String _personName = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
    getChatUserName();
  }

  void getUserName() async {}

  void getChatUserName() async {
    _personName = "没有？";
    // _personName = await CacheUtils.getPersonName();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("object1");
      },
      child: getContentList(),
    );
  }

  Widget getContentList() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      // color: Color.fromRGBO(Random().nextInt(256), Random().nextInt(256),
      //     Random().nextInt(256), 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: widget.currentMessage.outgoingMsg
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: getNoReadWidget(),
      ),
    );
  }

  ///时间转换
  String transTime(timestamps) {
    String time =
        DateTime.fromMillisecondsSinceEpoch(timestamps).toLocal().toString();
    return time.substring(0, time.indexOf('.'));
  }

// 日期组件
  Widget showTimeWidget() {
    if (widget.previousMessage != null) {
      if ((widget.previousMessage.timestamp - widget.currentMessage.timestamp)
              .abs() >
          1 * 60 * 1000) {
        // var showTime; //最终显示的时间
        // //获取当前的时间,yyyy-MM-dd HH:mm
        // String nowTime = DateUtil.getDateStrByMs(
        //     new DateTime.now().millisecondsSinceEpoch,
        //     format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE);
        // //当前消息的时间,yyyy-MM-dd HH:mm
        // String indexTime = DateUtil.getDateStrByMs(
        //     double.parse(widget.currentMessage.timestamp.toString()).toInt(),
        //     format: DateFormat.YEAR_MONTH_DAY_HOUR_MINUTE);

        // if (DateUtil.formatDateTime1(indexTime, DateFormat.YEAR) !=
        //     DateUtil.formatDateTime1(nowTime, DateFormat.YEAR)) {
        //   //对比年份,不同年份，直接显示yyyy-MM-dd HH:mm
        //   showTime = indexTime;
        // } else if (DateUtil.formatDateTime1(indexTime, DateFormat.YEAR_MONTH) !=
        //     DateUtil.formatDateTime1(nowTime, DateFormat.YEAR_MONTH)) {
        //   //年份相同，对比年月,不同月或不同日，直接显示MM-dd HH:mm
        //   showTime = DateUtil.formatDateTime1(
        //       indexTime, DateFormat.MONTH_DAY_HOUR_MINUTE);
        // } else if (DateUtil.formatDateTime1(
        //         indexTime, DateFormat.YEAR_MONTH_DAY) !=
        //     DateUtil.formatDateTime1(nowTime, DateFormat.YEAR_MONTH_DAY)) {
        //   //年份相同，对比年月,不同月或不同日，直接显示MM-dd HH:mm
        //   showTime = DateUtil.formatDateTime1(
        //       indexTime, DateFormat.MONTH_DAY_HOUR_MINUTE);
        // } else {
        //   //否则HH:mm
        //   showTime =
        //       DateUtil.formatDateTime1(indexTime, DateFormat.HOUR_MINUTE);
        // }
        String showTime = "sadasd";
        return Center(
            child: Text(
          "${showTime}",
          style: TextStyle(color: Color(0xFF999999)),
        ));
      } else {
        // _isShowTime = false;
        return Container(
          child: null,
        );
      }
    } else {
      if (widget.previousMessage == null && widget.currentMessage != null) {
        return Center(
            child: Text(
          "dddd",
          // TimeUtils.timestamp2ShowTime(context, widget.currentMessage.timestamp,
          //     todayHidden: true),
          style: TextStyle(color: Color(0xFF999999)),
        ));
      }
    }
  }

  ///包含是否已读 未读等组件
  List<Widget> getNoReadWidget() {
    List<Widget> contentWidget = [];
    contentWidget.add(showTimeWidget());
    if (widget.currentMessage.text == null) {
      contentWidget.add(Container());
    } else {
      if (widget.currentMessage.text.contains("撤回了一条消息")) {
        contentWidget.add(Center(
          child: Container(
            padding: EdgeInsets.all(0),
            child: Text(
                ((widget.currentMessage.text == "撤回了一条消息" ? "你" : "") +
                    " " +
                    widget.currentMessage.text),
                style: TextStyle(color: Color(0xFF999999))),
          ),
        ));
      } else {
        Widget content = Container(
          // color: Colors.white,
          padding: EdgeInsets.only(left: 0, right: 0, top: 0),
          child: getContentlWidget(),
        );
        Widget readWidget = Container(
          // color: Colors.orange,
          padding: EdgeInsets.only(top: 0, bottom: 10),
          child: Text(
            widget.currentMessage.remoteRead ||
                    (widget.timestamp >= widget.currentMessage.timestamp)
                // (widget.currentMessage.timestamp > widget.timestamp)
                ? "已读"
                : "未读",
            // : "未读",
            style: TextStyle(color: Color(0xFFBCBDBF), fontSize: 24.sp),
          ),
        );
        Widget paddinngWidget = Container(
          width: 44 + 12.w + 24.w,
        );
        if (widget.currentMessage.outgoingMsg) {
          contentWidget.add(content);
          contentWidget.add(Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [readWidget, paddinngWidget],
          ));
        } else {
          contentWidget.add(content);
        }
      }
    }

    return contentWidget;
  }

  Widget getContentlWidget() {
    return Row(
        mainAxisAlignment: widget.currentMessage.outgoingMsg
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: getDetailWidget());
  }

  Widget getIconWidget(bool isOutgoingMsg) {
    Widget icon = GestureDetector(
        onTap: () {
          print("object");
          if ((isOutgoingMsg && widget.myEocId != null) ||
              (!isOutgoingMsg && widget.user.eocId != null)) {
            // Navigator.push(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => Container(
            //         color: Color.fromRGBO(246, 247, 251, 1),
            //         child: ContactDetailsPage(
            //           employeeId:
            //               isOutgoingMsg ? widget.myEocId : widget.user.eocId,
            //           fromChat: true,
            //         )),
            //   ),
            // );
          }
        },
        onLongPress: () {},
        child: Container(
            padding: EdgeInsets.only(
                left: !isOutgoingMsg ? 24.w : 0.w,
                right: !isOutgoingMsg ? 0 : 24.w,
                top: 10),
            child: Container(
              width: 50,
              height: 50,
              child: Text("ddd"),
            )
            // ImageBadgeWidget(
            //   badgeNum: 0,
            //   type: 1,
            //   name: widget.currentMessage.isOutgoingMsg
            //       ? _personName
            //       : widget.currentMessage.senderName,
            //   imgUrl: null,
            // ),
            ));
    return icon;
  }

  List<Widget> getDetailWidget() {
    List<Widget> detailWidget = [];
    // if (widget.currentMessage.se == null) {
    //   print("object");
    // }
    Widget textWidget = Flexible(
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 12.w, right: 12.w),
        decoration: BoxDecoration(
            color: widget.currentMessage.outgoingMsg
                ? Color(0xFFCDE1FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.only(left: 12.w, bottom: 10, right: 12.w, top: 10),
        // color: Colors.grey,
        child: Text(widget.currentMessage.text ?? "null"),
      ),
    );
    if (widget.currentMessage.outgoingMsg) {
      detailWidget.add(Container(
        width: 24.w,
      ));
      detailWidget.add(emptyContainer);
      // detailWidget.add(textWidget);
      detailWidget.add(Container(
        child: textWidget,
      ));
      detailWidget.add(getIconWidget(widget.currentMessage.outgoingMsg));
    } else {
      detailWidget.add(getIconWidget(widget.currentMessage.outgoingMsg));
      detailWidget.add(textWidget);
      detailWidget.add(Container(
        width: 24.w,
      ));
      detailWidget.add(emptyContainer);
    }
    return detailWidget;
  }

  Widget emptyContainer = GestureDetector(
      onTap: () {},
      onLongPress: () {},
      child: Container(
        // color: Colors.white,
        padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 10),
        child: Container(
          width: 44,
          height: 44,
        ),
      ));
}
