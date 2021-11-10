/*
 * @Author: weiguoqing
 * @Date: 2021-09-28 13:37:11
 * @LastEditTime: 2021-10-22 14:32:07
 * @LastEditor: ----Athena----
 */
import 'dart:async';
import 'dart:io';

import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im/enums/nim_message_type.dart';
import 'package:digiwhale_im/enums/nim_message_type_extension.dart';
import 'package:digiwhale_im/enums/nim_session_type_extension.dart';
import 'package:digiwhale_im/models/nim_message_model.dart';
import 'package:digiwhale_im/models/nim_message_receipt_model.dart';
import 'package:digiwhale_im/models/nim_user_model.dart';
import 'package:digiwhale_im_example/digiwin_chat_setting_page.dart';
import 'package:digiwhale_im_example/digiwin_chat_widget.dart';
import 'package:digiwhale_im_example/digiwin_team_setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'digiwin_chat_provider.dart';

class DigiwinChatPage extends StatefulWidget {
  String sessionID;
  int sessionType; //sessionID和sessionType分开传是因为这个页面不仅仅是从会话列表页过来的，还有可能是从推送过来的，如果传过来的是个对象，可能会麻烦点，如果需要的参数再增加，可以考虑传过来个对象
  Map teamMemberList; // 群成员列表

  DigiwinChatProvider chatShareData;
  NIMUser user;
  DigiwinChatPage(
      {this.sessionID, this.chatShareData, this.user, this.sessionType});

  @override
  _DigiwinChatPageState createState() => _DigiwinChatPageState();
}

class _DigiwinChatPageState extends State<DigiwinChatPage> {
  //手指移动的位置
  double _lastMoveY = 0.0;
  //手指按下的位置
  double _downY = 0.0;

  List<NIMMessage> dataSource = [];
  ScrollController scrollController = ScrollController();
  String myEocId = "";
  NIMUser chatUser;

  // final ItemScrollController itemScrollController = ItemScrollController();
  FocusNode _focusNode = FocusNode();
  TextEditingController controller;
  DigiwhaleIm digiwin;
  bool isScroll = true;
  BuildContext baseContext;
  final TextEditingController _textEditingController = TextEditingController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    digiwin = DigiwhaleIm();
    widget.chatShareData.recentMessage = []; //进来的时候 先把之前的监听到的消息置为空  否则可能会有重复消息
    // 当前页面收到消息 设置当前会话 所有消息 已读
    DigiwhaleIm().markAllMessagesReadInSession(
        sessionId: widget.sessionID,
        sessionType: NIMSessionTypeExtension.getTypeValue(widget.sessionType));
    loadHistory();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // print("ddddd");
      // if (MediaQuery.of(context).viewInsets.bottom > 0) {
      //   print("键盘弹出");
      // }
      Timer(Duration(milliseconds: 110), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 50, //滚动到底部
          duration: const Duration(milliseconds: 100),
          curve: Curves.elasticIn,
        );
      });
    });
  }

  @override
  void deactivate() {
    // Navigator.pop(context);
    // Navigator.pop(context);
    super.deactivate();
    print("ddd");
  }

  /// 获取当前聊天用户资料（他人）
  void getCurrentChatUserInfo() async {
    // List<String> accIDS = [];
    // accIDS.add(widget.user.acctId);

    // Map accIds = await DigiwhaleIm().getUserInfo(accounts: accIDS);
    // chatUser = accIds[widget.user.acctId];
  }

  /// 获取当前聊天用户资料（自己）
  void getCurrentUserInfo() {
    // DigiwhaleIm().getCurrentUserInfo().then((List value) {
    //   print(value);
    //   if (value.length > 0) {
    //     NIMUser user = value[0];
    //     myEocId = user.eocId;
    //   }
    // });
  }

  ///下拉加载更多
  void _onRefresh() async {
    await DigiwhaleIm()
        .fetchLocalMessageHistory(
            sessionId: widget.sessionID,
            limit: 30,
            sessionType:
                NIMSessionTypeExtension.getTypeValue(widget.sessionType),
            messageId: dataSource.first.messageId)
        .then((value) {
      List<NIMMessage> messages = [];
      for (var item in value) {
        messages.add(item);
      }
      dataSource.insertAll(0, messages);
      //在聊天页面  收到这条后 需要把这条消息 标记为已读
      if (mounted) {
        setState(() {});
      }
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {}

  ///历史聊天记录
  void loadHistory() async {
    // 默认 30条
    await DigiwhaleIm()
        .fetchLocalMessageHistory(
            sessionId: widget.sessionID,
            limit: 30,
            sessionType:
                NIMSessionTypeExtension.getTypeValue(widget.sessionType),
            messageId: null)
        .then((value) {
      List<NIMMessage> messages = [];
      for (var item in value) {
        dataSource.add(item);
      }
      //在聊天页面  收到这条后 需要把这条消息 标记为已读
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    DigiwhaleIm().markAllMessagesReadInSession(
        sessionId: widget.sessionID,
        sessionType: NIMSessionTypeExtension.getTypeValue(widget.sessionType));
    controller.dispose();
    super.dispose();
  }

  ///关闭键盘
  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    Timer(Duration(milliseconds: 100), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    /// 键盘是否是弹起状态
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      // FocusManager.instance.primaryFocus.unfocus();
      print("!= null");
    } else {
      print("== null");
    }
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUserInfo();
    getCurrentChatUserInfo();
    closeKeyboard(context);
    //todo
    List<NIMMessage> message =
        context.watch<DigiwinChatProvider>().recentMessage;

    List<NIMMessageReceipt> receiptsMessage =
        context.watch<DigiwinChatProvider>().receiptsMessage;
    int timestamp = 0;
    for (var item in receiptsMessage) {
      if (item.sessionId == widget.sessionID) {
        timestamp = item.timestamp;
      }
    }
    for (var i = 0; i < message.length; i++) {
      NIMMessage item = message[i];

      ///如果不是当前用户 收到消息后也不处理
      if (item.sessionId != widget.sessionID) {
        break;
      }
      if (item.messageType == "100") {
        for (var j = 0; j < dataSource.length; j++) {
          NIMMessage currentItem = dataSource[j];
          if (currentItem.messageId == item.messageId) {
            dataSource.replaceRange(j, j + 1, [item]);
            break;
          }
        }
      } else {
        dataSource.add(item);
      }
    }
    widget.chatShareData.updateSelfMessage();
    NIMMessage lastEntity;
    if (dataSource.length == 0) {
      lastEntity = null;
    } else {
      lastEntity = dataSource.last;
    }
    if (lastEntity != null) {
      DigiwhaleIm().sendMessageReceipt(
          sessionId: lastEntity.sessionId,
          messageId: lastEntity.messageId,
          sessionType:
              NIMSessionTypeExtension.getTypeValue(widget.sessionType));
    }
    baseContext = context;
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
                // Navigator.pop(con3
              },
            ),
            actions: <Widget>[
              Container(
                width: 60,
                // color: Colors.red,
                child: InkWell(
                  onTap: () {
                    Widget page;
                    if (widget.sessionType == 1) {
                      page = DigiwinTeamSetting(
                        teamId: widget.sessionID,
                      );
                    } else {
                      page = DigiwinChatSetting();
                    }
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => page,
                        ));
                  },
                  child: Center(
                    child: Text(
                      "...",
                      style: TextStyle(color: Colors.black, fontSize: 22),
                    ),
                  ),
                ),
              )
            ],
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
                "没有",
                //widget.user.name,
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
          body: Listener(
            onPointerDown: (PointerDownEvent event) {
              //手指按下的距离
              _downY = event.position.distance;
            },
            onPointerMove: (PointerMoveEvent event) {
              //手指移动的距离
              var position = event.position.distance;
              //判断距离差
              var detal = position - _lastMoveY;
              if (detal > 0) {
                //手指移动的距离
                double pos = (position - _downY);
                print("================向下移动================");
                // Timer(Duration(milliseconds: 20), () {
                hideKeyboard(context);
                // });
              } else {
                // 所摸点长度 +滑动距离  = IistView的长度  说明到达底部
                print("================向上移动================");
              }
              _lastMoveY = position;
            },
            child: GestureDetector(
              onTap: () => hideKeyboard(context), //点击页面的空白处关闭键盘
              child: Container(
                color: Color(0xFFF6F7FB),
                // color: Color.fromRGBO(151, 151, 151, 0.1),
                child: _buildBodyWidget(timestamp),
              ),
            ),
          )),
    );
  }

  /// 聊天视图
  Widget _buildBodyWidget(int timestamp) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: SmartRefresher(
                  enablePullDown: true,
                  // enablePullUp: true,
                  header: WaterDropHeader(
                    complete: Text("加载成功"),
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  // onLoading: null,
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: dataSource.length,
                      itemBuilder: (BuildContext context, int index) {
                        //list最后一条消息（时间上是最老的），是没有下一条了
                        NIMMessage _previousEntity =
                            (index == 0) ? null : dataSource[index - 1];
                        if (dataSource[index].runtimeType.toString() ==
                            "NIMMessage") {
                          if (_previousEntity.runtimeType.toString() !=
                              "NIMMessage") {
                            _previousEntity = null;
                          }
                          return DigiwinChatWidget(
                            previousMessage: _previousEntity,
                            currentMessage: dataSource[index],
                            timestamp: timestamp,
                            // user: chatUser,
                            // myEocId: myEocId,
                            callBack: (revokeMessgae) {
                              // loadHistory();
                              // dataSource.remove(revokeMessgae);
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                ),
              ),
              _buildInputBar(),
            ],
          ),
        ],
      ),
    );
  }

  ///输入框的文字
  String _inputText = "";

  /// 底部ToolBar
  Widget _buildInputBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        // color: const Color(0xFFF6F6F6),
        color: Color.fromRGBO(246, 247, 251, 1),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE1E4E6),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Container(
                padding: EdgeInsets.only(left: 20.w, right: 25.w),
                child: Text("无图？")
                // Icon(
                //   DigiIconData(0xe6C3),
                //   size: 46.w,
                //   color: Color(0xFF999999),
                // )
                ),
            onTap: () {
              digiwin.sendMessage(
                  sessionId: widget.sessionID,
                  sessionType:
                      NIMSessionTypeExtension.getTypeValue(widget.sessionType),
                  text: _inputText);
            },
          ),
          Expanded(
              child: Container(
            color: Colors.white,
            constraints: BoxConstraints(maxHeight: 100.0),
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              maxLines: Platform.isIOS ? null : 1,
              style: TextStyle(
                color: const Color(0xff203152),
                fontSize: 15.0,
              ),
              decoration: InputDecoration(
                hintText: "",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                counter: null,
                contentPadding: const EdgeInsets.all(10.0),
              ),
              onChanged: (text) {
                _inputText = text;
                if (text.isNotEmpty) {
                  // _chatProvider.isShowSendButton = true;
                } else {
                  // _chatProvider.isShowSendButton = false;
                }
              },
              onSubmitted: (text) {
                FocusScope.of(context).requestFocus(_focusNode);
                if (_textEditingController.text == "") {
                  return;
                }
                digiwin.sendMessage(
                    sessionId: widget.sessionID,
                    sessionType: NIMSessionTypeExtension.getTypeValue(
                        widget.sessionType),
                    messageType: NIMMessageType.Custom,
                    text: text);
                // digiwin.sendTextMessage(text, widget.sessionID);
                _textEditingController.text = "";
                Timer(Duration(milliseconds: 2000), () {
                  isScroll = false;
                });
                // FocusScope.of(context).requestFocus(_focusNode);
                // _onSendTextMessage(text);
              },
            ),
          )),
          Container(
            padding: EdgeInsets.only(left: 0),
            child: // 暂时隐藏表情按钮
                Offstage(
                    offstage: false,
                    child: Container(
                        padding: EdgeInsets.only(left: 24.w, right: 24.w),
                        child: Text("1")
                        // Icon(
                        //   DigiIconData(0xe6C4),
                        //   size: 46.w,
                        //   color: Color(0xFF999999),
                        // ),
                        )),
          ),
          Container(padding: EdgeInsets.only(right: 24.w), child: Text("2")
              // Icon(
              //   DigiIconData(0xe6C2),
              //   size: 46.w,
              //   color: Color(0xFF999999),
              // ),
              )
        ],
      ),
    );
  }

  ///点击了加号按钮 暂时没用
  void _showActionPanel() {
    print("点击了加号按钮");
  }

  /// 隐藏键盘
  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus.unfocus();
    }
  }
}

/// 底部输入框图片组件
class InputBarButton extends StatelessWidget {
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Widget icon;
  final Color color;
  final VoidCallback onPressed;

  const InputBarButton({
    Key key,
    this.iconSize = 24.0,
    this.padding =
        const EdgeInsets.only(left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
    @required this.icon,
    this.color,
    @required this.onPressed,
  })  : assert(iconSize != null),
        assert(padding != null),
        assert(icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: padding,
        child: IconTheme.merge(
          data: IconThemeData(
            size: iconSize,
            color: color,
          ),
          child: icon,
        ),
      ),
    );
  }
}
