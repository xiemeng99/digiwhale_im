package com.digiwhale.im.digiwhale_im.nim.models;

import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 群消息已读、未读详情信息
 */
public class NIMTeamMessageReadInfo implements Serializable {
    private static final long serialVersionUID = -2489819849731884475L;

    /**
     * 群组id
     */
    private String teamId;
    /**
     * 消息id
     */
    private String messageId;
    /**
     * 已读用户的账号
     */
    private List<NIMUser> readUserList;
    /**
     * 未读用户的账号
     */
    private List<NIMUser> unReadUserList;

    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    public String getMessageId() {
        return messageId;
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public List<NIMUser> getReadUserList() {
        return readUserList;
    }

    public void setReadUserList(List<NIMUser> readUserList) {
        this.readUserList = readUserList;
    }

    public List<NIMUser> getUnReadUserList() {
        return unReadUserList;
    }

    public void setUnReadUserList(List<NIMUser> unReadUserList) {
        this.unReadUserList = unReadUserList;
    }

    public static NIMTeamMessageReadInfo teamMsgAckInfo2NIMTeamMessageReadInfo(TeamMsgAckInfo ackInfo) {
        NIMTeamMessageReadInfo readInfo = new NIMTeamMessageReadInfo();
        readInfo.setTeamId(ackInfo.getTeamId());
        readInfo.setMessageId(ackInfo.getMsgId());
        List<NIMUser> readUserList = new ArrayList<>();
        if (ackInfo.getAckAccountList() != null && ackInfo.getAckAccountList().size() > 0) {
            for (String account : ackInfo.getAckAccountList()) {
                readUserList.add(NIMUser.userInfo2NIMUser(DwNIMUtil.getUserInfo(account)));
            }
        }
        readInfo.setReadUserList(readUserList);
        List<NIMUser> unReadUserList = new ArrayList<>();
        if (ackInfo.getUnAckAccountList() != null && ackInfo.getUnAckAccountList().size() > 0) {
            for (String account : ackInfo.getUnAckAccountList()) {
                unReadUserList.add(NIMUser.userInfo2NIMUser(DwNIMUtil.getUserInfo(account)));
            }
        }
        readInfo.setUnReadUserList(unReadUserList);
        return readInfo;
    }
}
