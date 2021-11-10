package com.digiwhale.im.digiwhale_im.nim.util;

import com.google.gson.Gson;

/**
 * json工具类
 */
public class JsonUtil {

    /**
     * 对象转为json字符串
     *
     * @param obj
     * @return
     */
    public static String object2jsonString(Object obj) {
        Gson gson = new Gson();
        return gson.toJson(obj);
    }

}
