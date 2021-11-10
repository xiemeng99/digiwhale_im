package com.digiwhale.im.digiwhale_im.nim.models;

import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.io.Serializable;
import java.util.Map;

/**
 * 用户信息
 */
public class NIMUser implements Serializable {
    private static final long serialVersionUID = 7564278611999955598L;

    /**
     * 在云信系统中的id
     */
    String acctId;

    /**
     * 姓名
     */
    String name;

    /**
     * 头像url
     */
    String avatarUrl;

    /**
     * eocID
     */
    String eocId;

    public NIMUser() {
    }

    public String getAcctId() {
        return acctId;
    }

    public void setAcctId(String acctId) {
        this.acctId = acctId;
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

    public String getEocId() {
        return eocId;
    }

    public void setEocId(String eocId) {
        this.eocId = eocId;
    }

    public static NIMUser userInfo2NIMUser(NimUserInfo userInfo) {
        if (userInfo == null) {
            return null;
        }
        NIMUser user = new NIMUser();
        user.setAcctId(userInfo.getAccount());
        user.setName(userInfo.getName());
        user.setAvatarUrl(userInfo.getAvatar());
        Map<String, Object> exMap = userInfo.getExtensionMap();
        if (exMap != null && exMap.get("eoxId") != null) {
            user.setEocId((String) exMap.get("eocId"));
        }
        return user;
    }
}
