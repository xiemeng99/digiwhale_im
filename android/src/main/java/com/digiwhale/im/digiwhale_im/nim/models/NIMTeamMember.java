package com.digiwhale.im.digiwhale_im.nim.models;

import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.netease.nimlib.sdk.team.model.TeamMember;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.io.Serializable;

/**
 * 群成员
 */
public class NIMTeamMember implements Serializable {
    private static final long serialVersionUID = 3650237853868801969L;
    /**
     * 所属群id
     */
    String teamId;

    /**
     * 群成员账号
     */
    String account;

    /**
     * 群成员类型
     */
    int teamMemberType;

    /**
     * 在当前群里的昵称
     */
    String name;

    /**
     * 入群时间
     */
    long joinTime;

    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public int getTeamMemberType() {
        return teamMemberType;
    }

    public void setTeamMemberType(int teamMemberType) {
        this.teamMemberType = teamMemberType;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public long getJoinTime() {
        return joinTime;
    }

    public void setJoinTime(long joinTime) {
        this.joinTime = joinTime;
    }

    public static NIMTeamMember member2NIMTeamMember(TeamMember member) {
        NIMTeamMember teamMember = new NIMTeamMember();
        teamMember.setAccount(member.getAccount());
        //获取到的群昵称默认为空，这里去查用户姓名作为群昵称
        //teamMember.setName(member.getTeamNick());
        //群昵称--取用户名
        NimUserInfo userInfo = DwNIMUtil.getUserInfo(member.getAccount());
        if (userInfo != null) {
            teamMember.setName(userInfo.getName());
        }
        member.getAccount();
        teamMember.setJoinTime(member.getJoinTime());
        teamMember.setTeamId(member.getTid());
        teamMember.setTeamMemberType(member.getType().getValue());
        return teamMember;
    }
}
