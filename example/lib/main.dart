import 'dart:async';
import 'dart:io';

import 'package:digiwhale_im/digiwhale_im.dart';
import 'package:digiwhale_im/enums/nim_session_type.dart';
import 'package:digiwhale_im/models/nim_session_model.dart';
import 'package:digiwhale_im_example/digiwin_chat_compent.dart';
import 'package:digiwhale_im_example/digiwin_chat_page.dart';
import 'package:digiwhale_im_example/digiwin_chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

///Android沉浸式状态栏设置
class Global {
  static Future init(VoidCallback callback) async {
    WidgetsFlutterBinding.ensureInitialized();
    callback();
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }
}

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => DigiwinChatProvider()),
    ],
    child: MyApp(),
  ));
  // });
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List dataSource = [];
  ScrollController scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  TextEditingController controller;
  DigiwhaleIm digiwin = DigiwhaleIm();
  List<NIMSession> sessions = [];
  DigiwinChatProvider chatShareData = DigiwinChatProvider();
  Map teamMap = {};
  @override
  void initState() {
    super.initState();

    digiwin.nimClientInit();

    /// 云信登录
    digiwin.login("710", "07c714a6246259c510592a4acf0692b0").then((value) {
      // digiwin.login("712", "cb04d00c0964dd7d9c24f594cc877051").then((value) {
      configSessionsList();
    });
  }

  ///获取群成员列表
  void getTeamAccountList(List<NIMSession> sessions) {
    for (NIMSession item in sessions) {
      if (item.sessionType == NIMSessionType.Team) {
        DigiwhaleIm().getTeamMemberList(teamId: item.sessionId).then((value) {
          print(value);
          teamMap[item.sessionId] = value;
          setState(() {});
        });
      }
    }
  }

  /// 获取会话列表
  void configSessionsList() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      digiwin.getAllSessions().then((value) {
        print(value);
        for (int i = 0; i < value.length; i++) {
          sessions.add(value[i]);
        }
        getTeamAccountList(sessions);
      });
    });
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(750, 1624),
        builder: () => MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => chatShareData),
              ],
              child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    appBar: AppBar(
                      title: const Text('Plugin example app'),
                    ),
                    body:
                        // DigiwinChatPage(
                        //   sessionID: "712",
                        //   chatShareData: chatShareData,
                        // )
                        DigiwinChatCompent(
                            sessions: sessions,
                            chatShareData: chatShareData,
                            teamMemberMap: teamMap),
                  )),
            ));
  }
}
