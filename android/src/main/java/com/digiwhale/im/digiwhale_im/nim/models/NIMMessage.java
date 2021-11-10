package com.digiwhale.im.digiwhale_im.nim.models;

import com.digiwhale.im.digiwhale_im.nim.helper.NIMPreferences;
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;

import java.io.Serializable;
import java.util.Map;

/**
 * 消息
 */
public class NIMMessage implements Serializable {
    private static final long serialVersionUID = 1604222847705520438L;

    /**
     * 消息ID,唯一标识
     */
    String messageId;

    /**
     * 所属会话id
     */
    String sessionId;

    /**
     * 消息发送人id
     */
    String fromId;

    /**
     * 发送人姓名
     */
    private String fromName;

    /**
     * 消息发送时间戳，单位 ms
     */
    long timestamp;

    /**
     * 对方是否已读
     */
    boolean remoteRead;

    /**
     * 消息类型
     */
    int messageType;

    /**
     * 是否是往外发的消息
     */
    boolean outgoingMsg;

    /**
     * 消息文本，仅文本类型消息有值
     */
    String text;

    /**
     * 消息状态
     */
    int messageState;

    /**
     * 群消息已读人数(仅群组有效)
     */
    private int readCount;

    /**
     * 群消息未读人数(仅群组有效)
     */
    private int unReadCount;

    /**
     * 扩展字段。参数名要改。。。。。。。
     * //todo
     */
    Map teamNotificationData;

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getFromId() {
        return fromId;
    }

    public void setFromId(String fromId) {
        this.fromId = fromId;
    }

    public String getFromName() {
        return fromName;
    }

    public void setFromName(String fromName) {
        this.fromName = fromName;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public boolean isRemoteRead() {
        return remoteRead;
    }

    public void setRemoteRead(boolean remoteRead) {
        this.remoteRead = remoteRead;
    }

    public int getMessageType() {
        return messageType;
    }

    public void setMessageType(int messageType) {
        this.messageType = messageType;
    }

    public boolean isOutgoingMsg() {
        return outgoingMsg;
    }

    public void setOutgoingMsg(boolean outgoingMsg) {
        this.outgoingMsg = outgoingMsg;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public int getMessageState() {
        return messageState;
    }

    public void setMessageState(int messageState) {
        this.messageState = messageState;
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

    public Map getTeamNotificationData() {
        return teamNotificationData;
    }

    public void setTeamNotificationData(Map teamNotificationData) {
        this.teamNotificationData = teamNotificationData;
    }

    public static NIMMessage imMessage2NIMMessage(IMMessage message) {
        NIMMessage nimMessage = new NIMMessage();
        nimMessage.setMessageId(message.getUuid());
        nimMessage.setSessionId(message.getSessionId());
        if (message.getMsgType().getValue() == MsgTypeEnum.tip.getValue()) {
            //提醒类类型时，取子类型
            nimMessage.setMessageType(message.getSubtype());
        } else {
            nimMessage.setMessageType(message.getMsgType().getValue());
        }
        nimMessage.setRemoteRead(message.isRemoteRead());
        nimMessage.setMessageState(message.getStatus().getValue());
        nimMessage.setText(message.getContent());
        nimMessage.setFromId(message.getFromAccount());
        if (NIMPreferences.getLoginInfo() != null && message.getFromAccount().equals(NIMPreferences.getLoginInfo().getAccount())) {
            nimMessage.setOutgoingMsg(true);
        } else {
            nimMessage.setOutgoingMsg(false);
        }
        nimMessage.setFromName(message.getFromNick());
        nimMessage.setTimestamp(message.getTime());
        nimMessage.setReadCount(message.getTeamMsgAckCount());
        nimMessage.setUnReadCount(message.getTeamMsgUnAckCount());
        nimMessage.setTeamNotificationData(message.getRemoteExtension());
        return nimMessage;
    }

    @Override
    public String toString() {
        return "NIMMessage{" +
                "messageId='" + messageId + '\'' +
                ", fromId='" + fromId + '\'' +
                ", fromName='" + fromName + '\'' +
                ", timestamp=" + timestamp +
                ", messageType=" + messageType +
                ", text='" + text + '\'' +
                ", readCount='" + readCount + '\'' +
                ", unReadCount='" + unReadCount + '\'' +
                ", messageState=" + messageState +
                '}';
    }
}
