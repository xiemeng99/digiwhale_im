package com.digiwhale.im.digiwhale_im_example;

import android.content.Context;
import android.util.Log;

import com.digiwhale.im.digiwhale_im.nim.DwNIMUtil;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.lifecycle.SdkLifecycleObserver;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.util.NIMUtil;

public class MNimUtil {

    private static final String TAG = "IM操作";

    /**
     * 初始化
     *
     * @param context
     */
    public static void init(Context context, final LoginInfo info) {
        NIMClient.init(context,info,nimSDKOption(context));
    }

    private static SDKOptions nimSDKOption(Context context) {
        SDKOptions sdkOptions = new SDKOptions();
        //使用应用扩展目录缓存，不需要申请读写文件权限
        sdkOptions.sdkStorageRootPath = context.getExternalFilesDir("nim").getAbsolutePath();
        //开启会话已读多端同步，支持多端同步会话未读数
        sdkOptions.sessionReadAck = true;
        //群通知消息计入未读数
        sdkOptions.teamNotificationMessageMarkUnread = true;
        //第三方推送(华米OV、魅族、fcm等)
        //todo 不确定是否需要
        //sdkOptions.mixPushConfig
        return sdkOptions;
    }
}
