package com.digiwhale.im.digiwhale_im.nim.listener;

import java.io.Serializable;

/**
 * 监听封装
 *
 * @param <T>
 */
public class EventListener<T> implements Serializable {
    private static final long serialVersionUID = -3103458438309265753L;
    private String eventName;
    private T data;

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
