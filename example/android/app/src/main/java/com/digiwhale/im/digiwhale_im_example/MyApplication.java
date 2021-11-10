package com.digiwhale.im.digiwhale_im_example;

import com.digiwhale.im.digiwhale_im.nim.helper.NIMPreferences;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        NIMPreferences.setContext(this);
        MNimUtil.init(this,NIMPreferences.getLoginInfo());
    }
}
