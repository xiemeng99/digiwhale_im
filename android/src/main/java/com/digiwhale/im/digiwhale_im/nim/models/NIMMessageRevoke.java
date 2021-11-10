package com.digiwhale.im.digiwhale_im.nim.models;

import com.netease.nimlib.sdk.msg.model.RevokeMsgNotification;

import java.io.Serializable;

/**
 * 消息撤回
 */
public class NIMMessageRevoke implements Serializable {
    private static final long serialVersionUID = 1491658138281147876L;

    /**
     * 被撤回的消息
     */
    private NIMMessage message;

    /**
     * 消息撤回者账号
     */
    private String revokeAcctId;

    public NIMMessage getMessage() {
        return message;
    }

    public void setMessage(NIMMessage message) {
        this.message = message;
    }

    public String getRevokeAcctId() {
        return revokeAcctId;
    }

    public void setRevokeAcctId(String revokeAcctId) {
        this.revokeAcctId = revokeAcctId;
    }

    public static NIMMessageRevoke revokeMsgNotification2NIMMessageRevoke(RevokeMsgNotification revokeMsgNotification) {
        NIMMessageRevoke messageRevoke = new NIMMessageRevoke();
        messageRevoke.setMessage(NIMMessage.imMessage2NIMMessage(revokeMsgNotification.getMessage()));
        messageRevoke.setRevokeAcctId(revokeMsgNotification.getRevokeAccount());
        return messageRevoke;
    }
}
