package com.digiwhale.im.digiwhale_im.nim.models;

import com.netease.nimlib.sdk.msg.model.TeamMessageReceipt;

import java.io.Serializable;

/**
 * 群消息已读回执
 */
public class NIMTeamMessageReceipt implements Serializable {
    private static final long serialVersionUID = -4564363163800947470L;

    /**
     * 所属会话id(群组id)
     */
    private String sessionId;

    /**
     * 消息id
     */
    private String messageId;

    /**
     * 已读人数
     */
    private int readCount;

    /**
     * 未读人数
     */
    private int unReadCount;

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public int getReadCount() {
        return readCount;
    }

    public void setReadCount(int readCount) {
        this.readCount = readCount;
    }

    public int getUnReadCount() {
        return unReadCount;
    }

    public void setUnReadCount(int unReadCount) {
        this.unReadCount = unReadCount;
    }

    public static NIMTeamMessageReceipt teamMessageReceipt2NIMTeamMessageReceipt(TeamMessageReceipt messageReceipt) {
        NIMTeamMessageReceipt nimTeamMessageReceipt = new NIMTeamMessageReceipt();
        nimTeamMessageReceipt.setSessionId(messageReceipt.getSessionId());
        nimTeamMessageReceipt.setMessageId(messageReceipt.getMsgId());
        nimTeamMessageReceipt.setReadCount(messageReceipt.getAckCount());
        nimTeamMessageReceipt.setUnReadCount(messageReceipt.getUnAckCount());
        return nimTeamMessageReceipt;
    }
}
