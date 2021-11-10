package com.digiwhale.im.digiwhale_im.nim.helper;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import com.netease.nimlib.sdk.auth.LoginInfo;

/**
 * NIM账号密码缓存、自动登录工具类
 */
public class NIMPreferences {
    private static final String KEY_USER_ACCOUNT = "flutter_nim_account";
    private static final String KEY_USER_TOKEN = "flutter_nim_token";

    private static Context context;

    private static Context getContext() {
        return context;
    }

    /**
     * 入口application中调用，初始化context
     *
     * @param context
     */
    public static void setContext(Context context) {
        NIMPreferences.context = context.getApplicationContext();
    }

    /**
     * 获取云信用户登录信息，用于自动登录
     */
    public static LoginInfo getLoginInfo() {
        String account = getUserAccount();
        String token = getUserToken();
        if (!TextUtils.isEmpty(account) && !TextUtils.isEmpty(token)) {
            return new LoginInfo(account, token);
        } else {
            return null;
        }
    }

    public static void saveUserAccount(String account) {
        saveString(KEY_USER_ACCOUNT, account);
    }

    private static String getUserAccount() {
        return getString(KEY_USER_ACCOUNT);
    }

    public static void saveUserToken(String token) {
        saveString(KEY_USER_TOKEN, token);
    }

    private static String getUserToken() {
        return getString(KEY_USER_TOKEN);
    }

    /**
     * 缓存--存
     *
     * @param key
     * @param value
     */
    private static void saveString(String key, String value) {
        SharedPreferences.Editor editor = getSharedPreferences().edit();
        editor.putString(key, value);
        editor.apply();
    }

    /**
     * 缓存--取
     *
     * @param key
     * @return
     */
    private static String getString(String key) {
        return getSharedPreferences().getString(key, null);
    }

    /**
     * 缓存--清除
     */
    public static void clear() {
        SharedPreferences.Editor editor = getSharedPreferences().edit();
        editor.clear();
        editor.apply();
    }

    private static SharedPreferences getSharedPreferences() {
        return getContext().getSharedPreferences("FlutterNIM", Context.MODE_PRIVATE);
    }
}
