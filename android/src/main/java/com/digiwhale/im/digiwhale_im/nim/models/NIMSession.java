package com.digiwhale.im.digiwhale_im.nim.models;

import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.io.Serializable;

/**
 * 会话
 */
public class NIMSession implements Serializable {
    private static final long serialVersionUID = 1373911846024727881L;

    /**
     * 会话Id，群聊为群组id,单聊为用户id
     */
    private String sessionId;

    /**
     * 会话类型
     */
    private int sessionType;

    /**
     * 最新一条消息
     */
    private NIMMessage message;

    /**
     * 未读消息数
     */
    private int unreadCount;

    /**
     * 聊天对象信息(单聊为对方用户信息，群聊待定)
     */
    private NIMUser user;

    public NIMSession() {
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public int getSessionType() {
        return sessionType;
    }

    public void setSessionType(int sessionType) {
        this.sessionType = sessionType;
    }

    public NIMMessage getMessage() {
        return message;
    }

    public void setMessage(NIMMessage message) {
        this.message = message;
    }

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public NIMUser getUser() {
        return user;
    }

    public void setUser(NIMUser user) {
        this.user = user;
    }

    public static NIMSession recentContact2NIMSession(RecentContact recentContact, NimUserInfo userInfo) {
        NIMSession session = new NIMSession();
        session.setSessionId(recentContact.getContactId());
        session.setSessionType(recentContact.getSessionType().getValue());
        session.setUnreadCount(recentContact.getUnreadCount());
        session.setUser(NIMUser.userInfo2NIMUser(userInfo));
        //最新一条消息
        NIMMessage message = new NIMMessage();
        message.setSessionId(recentContact.getContactId());
        message.setMessageId(recentContact.getRecentMessageId());
        MsgTypeEnum msgTypeEnum = recentContact.getMsgType();
        if (msgTypeEnum.getValue() == MsgTypeEnum.tip.getValue()) {
            //提醒类型时，取子类型
            message.setMessageType(DwNIMUtil.getIMMessage(message.getMessageId()).getSubtype());
        } else {
            message.setMessageType(recentContact.getMsgType().getValue());
        }

        message.setFromId(recentContact.getFromAccount());
        message.setFromName(recentContact.getFromNick());
        message.setText(recentContact.getContent());
        message.setTimestamp(recentContact.getTime());
        message.setMessageState(recentContact.getMsgStatus().getValue());
        session.setMessage(message);
        return session;
    }

    @Override
    public String toString() {
        return "NIMSession{" +
                "sessionId='" + sessionId + '\'' +
                ", sessionType=" + sessionType +
                ", message=" + (message == null ? null : message.toString()) +
                ", unreadCount=" + unreadCount +
                ", user=" + user +
                '}';
    }
}
