package com.digiwhale.im.digiwhale_im.nim.helper;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.msg.MessageBuilder;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.model.IMMessage;

/**
 * 本地消息
 */
public class NIMLocalMessageHelper {
    //子类型-自己撤回
    public static final int REVOKE_MESSAGE_ME_TYPE = 1001;
    //子类型-对方撤回
    public static final int REVOKE_MESSAGE_OTHER_TYPE = 1002;

    /**
     * 保存一条撤回类消息到本地
     *
     * @param message 原消息
     * @param subType 子类型
     */
    public static void saveMessageToLocalEx(IMMessage message, int subType) {
        IMMessage newMessage = getIMMessage(message, subType);
//        message.setSubtype(subType);
        NIMClient.getService(MsgService.class).saveMessageToLocalEx(newMessage, true, message.getTime());
    }

    /**
     * 根据原消息生成新消息
     *
     * @param message
     * @param subType
     * @return
     */
    private static IMMessage getIMMessage(final IMMessage message, final int subType) {
        IMMessage newIMMessage = MessageBuilder.createTipMessage(message.getSessionId(), message.getSessionType());
        newIMMessage.setSubtype(subType);
        return newIMMessage;

//        return new IMMessage() {
//            private static final long serialVersionUID = 2075411865430895252L;
//
//            @Override
//            public String getUuid() {
//                return message.getUuid();
//            }
//
//            @Override
//            public boolean isTheSame(IMMessage message) {
//                if (message == null || message.getUuid() == null) {
//                    return false;
//                }
//                return message.getUuid().equals(getUuid());
//            }
//
//            @Override
//            public String getSessionId() {
//                return message.getSessionId();
//            }
//
//            @Override
//            public SessionTypeEnum getSessionType() {
//                return message.getSessionType();
//            }
//
//            @Override
//            public String getFromNick() {
//                return message.getFromNick();
//            }
//
//            @Override
//            public MsgTypeEnum getMsgType() {
//                return MsgTypeEnum.custom;
//            }
//
//            @Override
//            public int getSubtype() {
//                return subType;
//            }
//
//            @Override
//            public void setSubtype(int subtype) {
//            }
//
//            @Override
//            public MsgStatusEnum getStatus() {
//                return message.getStatus();
//            }
//
//            @Override
//            public void setStatus(MsgStatusEnum status) {
//
//            }
//
//            @Override
//            public void setDirect(MsgDirectionEnum direct) {
//
//            }
//
//            @Override
//            public MsgDirectionEnum getDirect() {
//                return null;
//            }
//
//            @Override
//            public void setContent(String content) {
//
//            }
//
//            @Override
//            public String getContent() {
//                return message.getContent();
//            }
//
//            @Override
//            public long getTime() {
//                return message.getTime();
//            }
//
//            @Override
//            public void setFromAccount(String account) {
//
//            }
//
//            @Override
//            public String getFromAccount() {
//                return message.getFromAccount();
//            }
//
//            @Override
//            public void setAttachment(MsgAttachment attachment) {
//
//            }
//
//            @Override
//            public MsgAttachment getAttachment() {
//                return null;
//            }
//
//            @Override
//            public String getAttachStr() {
//                return null;
//            }
//
//            @Override
//            public AttachStatusEnum getAttachStatus() {
//                return null;
//            }
//
//            @Override
//            public void setAttachStatus(AttachStatusEnum attachStatus) {
//
//            }
//
//            @Override
//            public CustomMessageConfig getConfig() {
//                return null;
//            }
//
//            @Override
//            public void setConfig(CustomMessageConfig config) {
//
//            }
//
//            @Override
//            public Map<String, Object> getRemoteExtension() {
//                return null;
//            }
//
//            @Override
//            public void setRemoteExtension(Map<String, Object> remoteExtension) {
//
//            }
//
//            @Override
//            public Map<String, Object> getLocalExtension() {
//                return null;
//            }
//
//            @Override
//            public void setLocalExtension(Map<String, Object> localExtension) {
//
//            }
//
//            @Override
//            public String getCallbackExtension() {
//                return null;
//            }
//
//            @Override
//            public String getPushContent() {
//                return null;
//            }
//
//            @Override
//            public void setPushContent(String pushContent) {
//
//            }
//
//            @Override
//            public Map<String, Object> getPushPayload() {
//                return null;
//            }
//
//            @Override
//            public void setPushPayload(Map<String, Object> pushPayload) {
//
//            }
//
//            @Override
//            public MemberPushOption getMemberPushOption() {
//                return null;
//            }
//
//            @Override
//            public void setMemberPushOption(MemberPushOption pushOption) {
//
//            }
//
//            @Override
//            public boolean isRemoteRead() {
//                return true;
//            }
//
//            @Override
//            public boolean needMsgAck() {
//                return false;
//            }
//
//            @Override
//            public void setMsgAck() {
//
//            }
//
//            @Override
//            public boolean hasSendAck() {
//                return false;
//            }
//
//            @Override
//            public int getTeamMsgAckCount() {
//                return 0;
//            }
//
//            @Override
//            public int getTeamMsgUnAckCount() {
//                return 0;
//            }
//
//            @Override
//            public int getFromClientType() {
//                return 0;
//            }
//
//            @Override
//            public NIMAntiSpamOption getNIMAntiSpamOption() {
//                return null;
//            }
//
//            @Override
//            public void setNIMAntiSpamOption(NIMAntiSpamOption nimAntiSpamOption) {
//
//            }
//
//            @Override
//            public void setClientAntiSpam(boolean hit) {
//
//            }
//
//            @Override
//            public void setForceUploadFile(boolean forceUpload) {
//
//            }
//
//            @Override
//            public boolean isInBlackList() {
//                return false;
//            }
//
//            @Override
//            public long getServerId() {
//                return 0;
//            }
//
//            @Override
//            public void setChecked(Boolean isChecked) {
//
//            }
//
//            @Override
//            public Boolean isChecked() {
//                return null;
//            }
//
//            @Override
//            public boolean isSessionUpdate() {
//                return false;
//            }
//
//            @Override
//            public void setSessionUpdate(boolean sessionUpdate) {
//
//            }
//
//            @Override
//            public MsgThreadOption getThreadOption() {
//                return null;
//            }
//
//            @Override
//            public void setThreadOption(IMMessage parent) {
//
//            }
//
//            @Override
//            public boolean isThread() {
//                return false;
//            }
//
//            @Override
//            public long getQuickCommentUpdateTime() {
//                return 0;
//            }
//
//            @Override
//            public boolean isDeleted() {
//                return false;
//            }
//
//            @Override
//            public String getYidunAntiCheating() {
//                return null;
//            }
//
//            @Override
//            public void setYidunAntiCheating(String yidunAntiCheating) {
//
//            }
//
//            @Override
//            public String getEnv() {
//                return null;
//            }
//
//            @Override
//            public void setEnv(String env) {
//
//            }
//
//            @Override
//            public String getYidunAntiSpamExt() {
//                return null;
//            }
//
//            @Override
//            public void setYidunAntiSpamExt(String yidunAntiSpamExt) {
//
//            }
//
//            @Override
//            public String getYidunAntiSpamRes() {
//                return null;
//            }
//        };
    }
}
