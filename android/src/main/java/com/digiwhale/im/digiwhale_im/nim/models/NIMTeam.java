package com.digiwhale.im.digiwhale_im.nim.models;

import com.netease.nimlib.sdk.team.model.Team;

import java.io.Serializable;

/**
 * 群组
 */
public class NIMTeam implements Serializable {
    private static final long serialVersionUID = 6283798926297450448L;
    /**
     * 群组id
     */
    String teamId;

    /**
     * 群组名称
     */
    String name;

    /**
     * 头像url
     */
    String avatarUrl;

    /**
     * 创建人账号
     */
    String creator;

    /**
     * 群创建时间
     */
    long createTime;

    /**
     * 群组内成员数
     */
    int userCount;

    /**
     * 群组成员人数上限
     */
    int userLimit;


    public String getTeamId() {
        return teamId;
    }

    public void setTeamId(String teamId) {
        this.teamId = teamId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public int getUserCount() {
        return userCount;
    }

    public void setUserCount(int userCount) {
        this.userCount = userCount;
    }

    public int getUserLimit() {
        return userLimit;
    }

    public void setUserLimit(int userLimit) {
        this.userLimit = userLimit;
    }

    public static NIMTeam team2NIMTeam(Team team) {
        NIMTeam nimTeam = new NIMTeam();
        nimTeam.setTeamId(team.getId());
        nimTeam.setName(team.getName());
        nimTeam.setAvatarUrl(team.getIcon());
        nimTeam.setCreator(team.getCreator());
        nimTeam.setCreateTime(team.getCreateTime());
        nimTeam.setUserCount(team.getMemberCount());
        nimTeam.setUserLimit(team.getMemberLimit());
        return nimTeam;
    }
}
