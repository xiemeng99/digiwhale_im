package com.digiwhale.im.digiwhale_im.nim.observer;

import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.digiwhale.im.digiwhale_im.DigiwhaleImPlugin;
import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.digiwhale.im.digiwhale_im.nim.helper.NIMLocalMessageHelper;
import com.digiwhale.im.digiwhale_im.nim.listener.EventListener;
import com.digiwhale.im.digiwhale_im.nim.models.NIMMessage;
import com.digiwhale.im.digiwhale_im.nim.models.NIMMessageReceipt;
import com.digiwhale.im.digiwhale_im.nim.models.NIMMessageRevoke;
import com.digiwhale.im.digiwhale_im.nim.models.NIMSession;
import com.digiwhale.im.digiwhale_im.nim.models.NIMTeamMessageReceipt;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.auth.constant.LoginSyncStatus;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.msg.model.MessageReceipt;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.msg.model.RevokeMsgNotification;
import com.netease.nimlib.sdk.msg.model.TeamMessageReceipt;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * 监听
 */
public class NIMObserver {

    public static final String TAG = "IM操作";
    public static final String SESSIONS_UPDATE_EVENT_NAME = "onSessionsUpdate";
    public static final String MESSAGE_UPDATE_EVENT_NAME = "onMessagesUpdate";
    public static final String MESSAGE_RECEIPT_EVENT_NAME = "onMessagesReceipt";
    public static final String Team_MESSAGE_RECEIPT_EVENT_NAME = "onTeamMessagesReceipt";
    public static final String MESSAGE_REVOKE_EVENT_NAME = "onMessageRevoke";

    /**
     * 监听会话列表变化
     */
    public static Observer<List<RecentContact>> sessionsObserver = new Observer<List<RecentContact>>() {
        private static final long serialVersionUID = -437260721517827098L;

        @Override
        public void onEvent(List<RecentContact> messages) {
            Log.d(TAG, "recent contacts update: " + messages);
            EventListener<List<NIMSession>> eventListener = new EventListener<>();
            eventListener.setEventName(SESSIONS_UPDATE_EVENT_NAME);
            List<NIMSession> sessionList = new ArrayList<>();
            if (messages != null && messages.size() > 0) {
                for (RecentContact contact : messages) {
                    //P2P聊天对象信息
                    NimUserInfo userInfo = null;
                    if (contact.getSessionType() == SessionTypeEnum.P2P) {
                        userInfo = DwNIMUtil.getUserInfo(contact.getContactId());
                    }
                    sessionList.add(NIMSession.recentContact2NIMSession(contact, userInfo));
                }
            }
            eventListener.setData(sessionList);
            DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
        }
    };

    /**
     * 监听消息接收
     */
    public static Observer<List<IMMessage>> incomingMessageObserver = new Observer<List<IMMessage>>() {
        private static final long serialVersionUID = 344748193863204795L;

        @Override
        public void onEvent(List<IMMessage> messages) {
            //处理新收到的消息，为了上传处理方便，SDK 保证参数 messages 全部来自同一个聊天对象。
            Log.d(TAG, "receive new message: " + messages);
            EventListener<List<NIMMessage>> eventListener = new EventListener<>();
            eventListener.setEventName(MESSAGE_UPDATE_EVENT_NAME);
            List<NIMMessage> messageList = new ArrayList<>();
            if (messages != null && messages.size() > 0) {
                for (IMMessage message : messages) {
                    messageList.add(NIMMessage.imMessage2NIMMessage(message));
                }
            }
            eventListener.setData(messageList);
            DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
        }
    };

    /**
     * 监听P2P消息已读回执
     */
    public static Observer<List<MessageReceipt>> messageReceiptsObserver = new Observer<List<MessageReceipt>>() {
        private static final long serialVersionUID = -487610312249741297L;

        @Override
        public void onEvent(List<MessageReceipt> messageReceipts) {
            Log.d(TAG, "receive P2P message receipt: " + messageReceipts);
            EventListener<List<NIMMessageReceipt>> eventListener = new EventListener<>();
            List<NIMMessageReceipt> nimMessageReceiptList = new ArrayList<>();
            if (messageReceipts != null && messageReceipts.size() > 0) {
                for (MessageReceipt messageReceipt : messageReceipts) {
                    nimMessageReceiptList.add(NIMMessageReceipt.messageReceipt2NIMMessageReceipt(messageReceipt));
                }
            }
            eventListener.setEventName(MESSAGE_RECEIPT_EVENT_NAME);
            eventListener.setData(nimMessageReceiptList);
            DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
        }
    };

    /**
     * 监听群组消息已读回执
     */
    public static Observer<List<TeamMessageReceipt>> teamMessageReceiptsObserver = new Observer<List<TeamMessageReceipt>>() {
        private static final long serialVersionUID = 4858189887719689260L;

        @Override
        public void onEvent(List<TeamMessageReceipt> teamMessageReceipts) {
            Log.d(TAG, "receive team message receipt: " + teamMessageReceipts);
            EventListener<List<NIMTeamMessageReceipt>> eventListener = new EventListener<>();
            List<NIMTeamMessageReceipt> nimTeamMessageReceiptList = new ArrayList<>();
            if (teamMessageReceipts != null && teamMessageReceipts.size() > 0) {
                for (TeamMessageReceipt messageReceipt : teamMessageReceipts) {
                    nimTeamMessageReceiptList.add(NIMTeamMessageReceipt.teamMessageReceipt2NIMTeamMessageReceipt(messageReceipt));
                }
            }
            eventListener.setEventName(Team_MESSAGE_RECEIPT_EVENT_NAME);
            eventListener.setData(nimTeamMessageReceiptList);
            DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
        }
    };

    /**
     * 监听消息撤回
     */
    public static Observer<RevokeMsgNotification> revokeMessageObserver = new Observer<RevokeMsgNotification>() {
        private static final long serialVersionUID = 6341505801649039126L;

        @Override
        public void onEvent(RevokeMsgNotification notification) {
            Log.d(TAG, "receive message revoke: " + notification);
            EventListener<NIMMessageRevoke> eventListener = new EventListener<>();
            eventListener.setEventName(MESSAGE_REVOKE_EVENT_NAME);
            eventListener.setData(NIMMessageRevoke.revokeMsgNotification2NIMMessageRevoke(notification));
            DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
            //往本地写一条撤回类消息
            IMMessage message = notification.getMessage();
            NIMLocalMessageHelper.saveMessageToLocalEx(message, NIMLocalMessageHelper.REVOKE_MESSAGE_OTHER_TYPE);
        }
    };

    /**
     * 监听登录后数据同步
     */
    public static Observer<LoginSyncStatus> loginSyncStatusObserver = new Observer<LoginSyncStatus>() {
        private static final long serialVersionUID = -7960169415457120288L;

        @Override
        public void onEvent(LoginSyncStatus status) {
            if (status == LoginSyncStatus.BEGIN_SYNC) {
                Log.d(TAG, "login sync data begin!!");
            } else if (status == LoginSyncStatus.SYNC_COMPLETED) {
                Log.d(TAG, "login sync data completed!!");
            }
        }
    };
}
