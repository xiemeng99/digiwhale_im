package com.digiwhale.im.digiwhale_im.nim.util;

import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;

/**
 * 消息类型转换工具类（云信SDK未提供）
 */
public class MsgTypeUtil {

    public static MsgTypeEnum getMsgType(int msgType) {
        switch (msgType) {
            case 0:
                return MsgTypeEnum.text;
            case 1:
                return MsgTypeEnum.image;
            case 2:
                return MsgTypeEnum.audio;
            case 3:
                return MsgTypeEnum.video;
            case 4:
                return MsgTypeEnum.location;
            case 5:
                return MsgTypeEnum.notification;
            case 6:
                return MsgTypeEnum.file;
            case 10:
                return MsgTypeEnum.tip;
            case 11:
                return MsgTypeEnum.robot;
            case 100:
                return MsgTypeEnum.custom;
            default:
                return MsgTypeEnum.text;
        }
    }

}
