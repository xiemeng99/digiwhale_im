package com.digiwhale.im.digiwhale_im.nim.models;

import com.netease.nimlib.sdk.msg.model.MessageReceipt;

import java.io.Serializable;

/**
 * 消息已读回执
 */
public class NIMMessageReceipt implements Serializable {
    private static final long serialVersionUID = -2452454624774666905L;
    /**
     * P2P聊天对象的账号
     */
    String sessionId;
    /**
     * 该会话最后一条已读消息的时间，比该时间早的消息都视为已读
     */
    long timestamp;

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public static NIMMessageReceipt messageReceipt2NIMMessageReceipt(MessageReceipt messageReceipt) {
        NIMMessageReceipt nimMessageReceipt = new NIMMessageReceipt();
        nimMessageReceipt.setSessionId(messageReceipt.getSessionId());
        nimMessageReceipt.setTimestamp(messageReceipt.getTime());
        return nimMessageReceipt;
    }
}
