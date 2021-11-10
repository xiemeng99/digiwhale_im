package com.digiwhale.im.digiwhale_im;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.digiwhale.im.digiwhale_im.nim.util.MsgTypeUtil;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * DigiwhaleImPlugin
 */
public class DigiwhaleImPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    private Activity mActivity;

    private static EventChannel.EventSink eventSink;

    public static EventChannel.EventSink getEventSink() {
        return eventSink;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "digiwhale_im_flutter");
        methodChannel.setMethodCallHandler(this);
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "digiwhale_im_native");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "nimClientInit":
                DwNIMUtil.init();
                break;
            case "nimLogin":
                String loginAccount = call.argument("account");
                String loginToken = call.argument("token");
                DwNIMUtil.login(mActivity, loginAccount, loginToken, result);
                break;
            case "loginOut":
                DwNIMUtil.loginOut();
                break;
            case "getAllSessions":
                DwNIMUtil.recentContacts(result);
                break;
            case "deleteSession":
                String deleteSessionId = call.argument("sessionId");
                Integer deleteSessionType = call.argument("sessionType");
                DwNIMUtil.deleteSession(deleteSessionId, SessionTypeEnum.typeOfValue(deleteSessionType));
                break;
            case "loginStatus":
                DwNIMUtil.loginStatus(result);
                break;
            case "sendMessage":
                String sessionId = call.argument("sessionId");
                Integer sessionType = call.argument("sessionType");
                Integer messageType = call.argument("messageType");
                String text = call.argument("text");
                Map extMap = call.argument("teamNotificationData");
                DwNIMUtil.sendMessage(sessionId, SessionTypeEnum.typeOfValue(sessionType), MsgTypeUtil.getMsgType(messageType), text, extMap, result);
                break;
            case "fetchLocalMessageHistory":
                Integer localMsgSessionType = call.argument("sessionType");
                String localMsgSessionId = call.argument("sessionId");
                Integer localMsgLimit = call.argument("limit");
                String localMsgId = call.argument("messageId");
                DwNIMUtil.fetchLocalMessageHistory(localMsgSessionId,
                        SessionTypeEnum.typeOfValue(localMsgSessionType),
                        localMsgLimit,
                        localMsgId,
                        result);
                break;
            case "fetchMessageHistory":
                Integer msgSessionType = call.argument("sessionType");
                String msgSessionId = call.argument("sessionId");
                Integer msgLimit = call.argument("limit");
                String msgId = call.argument("messageId");
                Long toTime = call.argument("toTime");
                DwNIMUtil.fetchMessageHistory(msgSessionId,
                        SessionTypeEnum.typeOfValue(msgSessionType),
                        toTime.longValue(),
                        msgLimit,
                        msgId,
                        result);
                break;
            case "sendMessageReceipt":
                String receiptSessionId = call.argument("sessionId");
                String receiptMessageId = call.argument("messageId");
                Integer receiptSessionType = call.argument("sessionType");
                DwNIMUtil.sendMessageReceipt(receiptSessionId, SessionTypeEnum.typeOfValue(receiptSessionType), receiptMessageId);
                break;
            case "revokeMessage":
                String revokeMessageId = call.argument("messageId");
                DwNIMUtil.revokeMessage(revokeMessageId, result);
                break;
            case "getUserInfoList":
                List<String> accounts = call.argument("accounts");
                DwNIMUtil.getUserInfoList(accounts, result);
                break;
            case "markAllMessagesReadInSession":
                String allMessageSessionId = call.argument("sessionId");
                Integer allMessageSessionType = call.argument("sessionType");
                DwNIMUtil.markAllMessagesReadInSession(allMessageSessionId, SessionTypeEnum.typeOfValue(allMessageSessionType));
                break;
            case "createTeam":
                String teamName = call.argument("name");
                List<String> teamAccounts = call.argument("accounts");
                DwNIMUtil.createTeam(teamName, teamAccounts, result);
                break;
            case "getTeam":
                String teamId = call.argument("teamId");
                DwNIMUtil.getTeam(teamId, result);
                break;
            case "getTeamMemberList":
                String queryTeamId = call.argument("teamId");
                DwNIMUtil.getTeamMemberList(queryTeamId, result);
                break;
            case "getTeamMessageReadInfo":
                String teamMessageId = call.argument("messageId");
                DwNIMUtil.getTeamMessageReadInfo(teamMessageId, result);
                break;
            case "getCurrentUserInfo":
                DwNIMUtil.getCurrentUserInfo(result);
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        mActivity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
    }
}
