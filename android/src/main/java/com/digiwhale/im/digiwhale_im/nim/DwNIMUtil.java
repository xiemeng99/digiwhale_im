package com.digiwhale.im.digiwhale_im.nim;

import android.content.Context;
import android.util.Log;

import com.alibaba.fastjson.JSON;
import com.digiwhale.im.digiwhale_im.DigiwhaleImPlugin;
import com.digiwhale.im.digiwhale_im.nim.helper.NIMLocalMessageHelper;
import com.digiwhale.im.digiwhale_im.nim.helper.NIMPreferences;
import com.digiwhale.im.digiwhale_im.nim.listener.EventListener;
import com.digiwhale.im.digiwhale_im.nim.models.NIMMessage;
import com.digiwhale.im.digiwhale_im.nim.models.NIMSession;
import com.digiwhale.im.digiwhale_im.nim.models.NIMTeam;
import com.digiwhale.im.digiwhale_im.nim.models.NIMTeamMember;
import com.digiwhale.im.digiwhale_im.nim.models.NIMTeamMessageReadInfo;
import com.digiwhale.im.digiwhale_im.nim.models.NIMUser;
import com.digiwhale.im.digiwhale_im.nim.observer.NIMObserver;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.auth.constant.LoginSyncStatus;
import com.netease.nimlib.sdk.msg.MessageBuilder;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.IMMessage;
import com.netease.nimlib.sdk.msg.model.QueryDirectionEnum;
import com.netease.nimlib.sdk.msg.model.RecentContact;
import com.netease.nimlib.sdk.msg.model.TeamMsgAckInfo;
import com.netease.nimlib.sdk.team.TeamService;
import com.netease.nimlib.sdk.team.constant.TeamBeInviteModeEnum;
import com.netease.nimlib.sdk.team.constant.TeamFieldEnum;
import com.netease.nimlib.sdk.team.constant.TeamTypeEnum;
import com.netease.nimlib.sdk.team.model.CreateTeamResult;
import com.netease.nimlib.sdk.team.model.Team;
import com.netease.nimlib.sdk.team.model.TeamMember;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * ???????????????
 */
public class DwNIMUtil {

    private static final String TAG = "IM??????";

    /**
     * sdk??????
     *
     * @param context
     * @return
     */
    private static SDKOptions nimSDKOption(Context context) {
        SDKOptions sdkOptions = new SDKOptions();
//        sdkOptions.appKey = appKey;
        //??????????????????????????????????????????????????????????????????
        sdkOptions.sdkStorageRootPath = context.getExternalFilesDir("mim").getAbsolutePath();
        //??????????????????????????????????????????????????????????????????
        sdkOptions.sessionReadAck = true;
        //??????????????????????????????
        sdkOptions.teamNotificationMessageMarkUnread = true;
        //???????????????????????????
        sdkOptions.enableTeamMsgAck = true;
        //???????????????(??????OV????????????fcm???)
        //todo ?????????????????????
        //sdkOptions.mixPushConfig
        return sdkOptions;
    }

    /**
     * ?????????(????????????????????????SDK?????????)
     */
    public static void init() {
        Log.d(TAG, "init SDK: ????????????");
        //????????????
        NIMClient.getService(MsgServiceObserve.class).observeRecentContact(NIMObserver.sessionsObserver, true);
        NIMClient.getService(AuthServiceObserver.class).observeLoginSyncDataStatus(NIMObserver.loginSyncStatusObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeReceiveMessage(NIMObserver.incomingMessageObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeMessageReceipt(NIMObserver.messageReceiptsObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeTeamMessageReceipt(NIMObserver.teamMessageReceiptsObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeRevokeMessage(NIMObserver.revokeMessageObserver, true);
    }

    /**
     * ??????
     *
     * @param account
     * @param token
     */
    public static void login(Context context, final String account, final String token, final MethodChannel.Result result) {
        RequestCallback<LoginInfo> callback =
                new RequestCallback<LoginInfo>() {
                    @Override
                    public void onSuccess(LoginInfo param) {
                        Log.d(TAG, "login onSuccess: " + param);
                        //???????????????????????????????????????
                        NIMPreferences.saveUserAccount(account);
                        NIMPreferences.saveUserToken(token);
                        result.success(true);
                        //???????????????????????????--????????????????????????
//                        NIMClient.getService(MsgServiceObserve.class).
//                                observeRecentContact(NIMObserver.messageObserver, true);
                    }

                    @Override
                    public void onFailed(int code) {
                        Log.d(TAG, "login onFailed: code=" + code);
                        result.success(false);
                    }

                    @Override
                    public void onException(Throwable exception) {
                        Log.d(TAG, "login onException!");
                        exception.printStackTrace();
                        result.success(false);
                    }
                };
        if (com.netease.nimlib.sdk.util.NIMUtil.isMainProcess(context)) {
            Log.d(TAG, "??????????????????????????? ");
            NIMClient.getService(AuthService.class).login(new LoginInfo(account, token)).setCallback(callback);
        }
        NIMClient.getService(AuthServiceObserver.class).observeLoginSyncDataStatus(new Observer<LoginSyncStatus>() {
            @Override
            public void onEvent(LoginSyncStatus status) {
                if (status == LoginSyncStatus.BEGIN_SYNC) {
                    Log.d(TAG, "login sync data begin!!");
                } else if (status == LoginSyncStatus.SYNC_COMPLETED) {
                    Log.d(TAG, "login sync data completed!!");
                }
            }
        }, true);


    }

    /**
     * ??????
     */
    public static void loginOut() {
        NIMClient.getService(AuthService.class).logout();
        //??????????????????
        NIMPreferences.clear();
    }

    /**
     * ????????????
     *
     * @param result
     */
    public static void loginStatus(MethodChannel.Result result) {
        StatusCode code = NIMClient.getStatus();
        Log.d(TAG, "login status: " + code.name());
        result.success(code.name());
    }

    /**
     * ???????????????
     *
     * @param result
     */
    public static void unreadNum(MethodChannel.Result result) {
        int unreadNum = NIMClient.getService(MsgService.class).getTotalUnreadCount();
        Log.d(TAG, "unreadNum: " + unreadNum);
        result.success(unreadNum);
    }

    /**
     * ????????????
     *
     * @param result
     */
    public static void recentContacts(final MethodChannel.Result result) {
        NIMClient.getService(MsgService.class).queryRecentContacts()
                .setCallback(new RequestCallbackWrapper<List<RecentContact>>() {
                    @Override
                    public void onResult(int code, List<RecentContact> contacts, Throwable e) {
                        Log.d(TAG, "recent contact: code:" + code);
                        Log.d(TAG, "recent contact: size:" + contacts.size());
                        List<NIMSession> nimSessions = new ArrayList<>();
                        if (contacts.size() > 0) {
                            for (RecentContact contact : contacts) {
                                //P2P??????????????????
                                NimUserInfo userInfo = null;
                                if (contact.getSessionType() == SessionTypeEnum.P2P) {
                                    userInfo = DwNIMUtil.getUserInfo(contact.getContactId());
                                }
                                NIMSession session = NIMSession.recentContact2NIMSession(contact, userInfo);
                                Log.d(TAG, "recent contact?????????: " + session.toString());
                                nimSessions.add(session);
                            }
                        }
                        result.success(JSON.toJSON(nimSessions));
                    }
                });
    }

    /**
     * ??????????????????
     *
     * @param sessionId
     */
    public static void deleteSession(String sessionId, SessionTypeEnum sessionTypeEnum) {
        //????????????
        RecentContact recentContact =
                NIMClient.getService(MsgService.class).queryRecentContact(sessionId, sessionTypeEnum);
        //????????????
        if (recentContact != null) {
            NIMClient.getService(MsgService.class).deleteRecentContact(recentContact);
        }
    }

    /**
     * ????????????
     *
     * @param sessionId   ????????????ID(???????????????id??????????????????ID)
     * @param sessionType ????????????
     * @param text        ??????????????????
     * @param result
     */
    public static void sendMessage(String sessionId,
                                   SessionTypeEnum sessionType,
                                   MsgTypeEnum msgType,
                                   String text,
                                   Map extMap,
                                   final MethodChannel.Result result) {
        IMMessage imMessage;
        if (msgType == MsgTypeEnum.custom) {
            imMessage = MessageBuilder.createCustomMessage(sessionId, sessionType, "", null);
            imMessage.setRemoteExtension(extMap);
        } else {
            imMessage = MessageBuilder.createTextMessage(sessionId, sessionType, text);
        }

        //?????????????????????????????????
        imMessage.setMsgAck();
        IMMessage finalImMessage = imMessage;
        NIMClient.getService(MsgService.class).sendMessage(imMessage, false).setCallback(new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                Log.d(TAG, "send message onSuccess: " + param);
                EventListener<List<NIMMessage>> eventListener = new EventListener<>();
                eventListener.setEventName(NIMObserver.MESSAGE_UPDATE_EVENT_NAME);
                eventListener.setData(Collections.singletonList(NIMMessage.imMessage2NIMMessage(finalImMessage)));
                DigiwhaleImPlugin.getEventSink().success(JSON.toJSON(eventListener));
                result.success(true);
            }

            @Override
            public void onFailed(int code) {
                Log.d(TAG, "send message onFailed: code=" + code);
                result.success(false);
            }

            @Override
            public void onException(Throwable exception) {
                Log.d(TAG, "send message onException!");
                exception.printStackTrace();
                result.success(false);
            }
        });
    }

    /**
     * ??????????????????
     *
     * @param sessionId   ??????id
     * @param sessionType ????????????
     * @param limit       ????????????????????????
     * @param messageId   ????????????id,?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
     * @param result
     */
    public static void fetchLocalMessageHistory(String sessionId,
                                                SessionTypeEnum sessionType,
                                                Integer limit,
                                                String messageId,
                                                final MethodChannel.Result result) {
        IMMessage anchor = null;
        if (null != messageId) {
            List<IMMessage> messageList = NIMClient.getService(MsgService.class).queryMessageListByUuidBlock(Collections.singletonList(messageId));
            if (messageList.size() > 0) {
                anchor = messageList.get(0);
            }
        }
        if (anchor == null) {
            anchor = MessageBuilder.createEmptyMessage(sessionId, sessionType, System.currentTimeMillis());
        }
        NIMClient.getService(MsgService.class).queryMessageListEx(anchor, QueryDirectionEnum.QUERY_OLD,
                limit, true).setCallback(new RequestCallbackWrapper<List<IMMessage>>() {
            @Override
            public void onResult(int code, List<IMMessage> messageList, Throwable exception) {
                Log.d(TAG, "get local message history, code=: " + code);
                List<NIMMessage> nimMessageList = new ArrayList<>();
                if (messageList != null && messageList.size() > 0) {
                    for (IMMessage message : messageList) {
                        nimMessageList.add(NIMMessage.imMessage2NIMMessage(message));
                    }
                }
                result.success(JSON.toJSON(nimMessageList));
            }
        });

    }

    /**
     * ??????????????????
     *
     * @param sessionId   ??????id
     * @param sessionType ????????????
     * @param limit       ????????????????????????(?????????100)
     * @param messageId   ????????????id,?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
     * @param result
     */
    public static void fetchMessageHistory(String sessionId,
                                           SessionTypeEnum sessionType,
                                           long toTime,
                                           Integer limit,
                                           String messageId,
                                           final MethodChannel.Result result) {
        IMMessage anchor = null;
        if (null != messageId) {
            anchor = getIMMessage(messageId);
        }
        if (anchor == null) {
            anchor = MessageBuilder.createEmptyMessage(sessionId, sessionType, System.currentTimeMillis());
        }
        NIMClient.getService(MsgService.class).pullMessageHistoryExType(
                anchor,
                toTime,
                limit > 100 ? 100 : limit,
                QueryDirectionEnum.QUERY_OLD,
                new MsgTypeEnum[]{MsgTypeEnum.text,
                        MsgTypeEnum.image,
                        MsgTypeEnum.audio,
                        MsgTypeEnum.video,
                        MsgTypeEnum.location,
                        MsgTypeEnum.notification,
                        MsgTypeEnum.file,
                        MsgTypeEnum.tip},

                true).setCallback(new RequestCallbackWrapper<List<IMMessage>>() {
            @Override
            public void onResult(int code, List<IMMessage> messageList, Throwable exception) {
                Log.d(TAG, "get cloud message history, code = " + code);
                List<NIMMessage> nimMessageList = new ArrayList<>();
                if (messageList != null && messageList.size() > 0) {
                    for (IMMessage message : messageList) {
                        nimMessageList.add(NIMMessage.imMessage2NIMMessage(message));
                    }
                }
                result.success(JSON.toJSON(nimMessageList));
            }
        });
    }

    /**
     * ????????????
     *
     * @param sessionId
     * @param messageId
     */
    public static void sendMessageReceipt(String sessionId, SessionTypeEnum typeEnum, String messageId) {
        if (typeEnum == SessionTypeEnum.P2P) {
            NIMClient.getService(MsgService.class).sendMessageReceipt(sessionId, getIMMessage(messageId));
        } else if (typeEnum == SessionTypeEnum.Team) {
            IMMessage message = getIMMessage(messageId);
            //?????????????????????????????????????????????????????????????????????
            if (message != null && !message.hasSendAck()) {
                NIMClient.getService(TeamService.class).sendTeamMessageReceipt(message);
            }
        }
    }

    /**
     * ????????????
     *
     * @param messageId
     * @param result
     */
    public static void revokeMessage(String messageId, final MethodChannel.Result result) {
        final IMMessage message = getIMMessage(messageId);
        if (message == null) {
            Log.d(TAG, "revokeMessage: ????????????????????????messageId:" + messageId);
            result.success(false);
            return;
        }
        Log.d(TAG, "revokeMessage: ????????????????????????messageId:" + messageId);
        NIMClient.getService(MsgService.class).revokeMessage(message, null, null, true).setCallback(new RequestCallbackWrapper<Void>() {
            @Override
            public void onResult(int code, Void res, Throwable exception) {
                Log.d(TAG, "onResult: ????????????code???" + code);
                if (code == ResponseCode.RES_SUCCESS) {
                    result.success(true);
                    //?????????????????????????????????
                    NIMLocalMessageHelper.saveMessageToLocalEx(message, NIMLocalMessageHelper.REVOKE_MESSAGE_ME_TYPE);
                } else {
                    result.success(false);
                }

            }
        });
    }

    /**
     * ??????????????????
     *
     * @param accounts
     * @param result
     */
    public static void getUserInfoList(List<String> accounts, MethodChannel.Result result) {
        List<NimUserInfo> users = NIMClient.getService(UserService.class).getUserInfoList(accounts);
        List<NIMUser> nimUserList = new ArrayList<>();
        if (users != null && users.size() > 0) {
            Log.d(TAG, "??????getUserInfoList: " + users.size());
            for (NimUserInfo userInfo : users) {
                nimUserList.add(NIMUser.userInfo2NIMUser(userInfo));
            }
        }
        if (users.size() == accounts.size()) {
            result.success(JSON.toJSON(nimUserList));
        } else {
            //?????????????????????
            NIMClient.getService(UserService.class).fetchUserInfo(accounts)
                    .setCallback(new RequestCallback<List<NimUserInfo>>() {

                        @Override
                        public void onSuccess(List<NimUserInfo> userInfoList) {
                            Log.d(TAG, "??????getUserInfoList: " + users.size());
                            nimUserList.clear();
                            for (NimUserInfo userInfo : userInfoList) {
                                nimUserList.add(NIMUser.userInfo2NIMUser(userInfo));
                            }
                            result.success(JSON.toJSON(nimUserList));
                        }

                        @Override
                        public void onFailed(int code) {
                            Log.d(TAG, "????????????????????????????????????onFailed: " + code);
                            result.success(JSON.toJSON(nimUserList));
                        }

                        @Override
                        public void onException(Throwable exception) {
                            Log.d(TAG, "????????????????????????????????????onException: " + exception.getMessage());
                            exception.getMessage();
                            result.success(JSON.toJSON(nimUserList));
                        }
                    });
        }
    }

    /**
     * ????????????????????????
     *
     * @param result
     */
    public static void getCurrentUserInfo(MethodChannel.Result result) {
        String account = "";
        if (NIMPreferences.getLoginInfo() != null) {
            account = NIMPreferences.getLoginInfo().getAccount();
        }
        NIMUser user = NIMUser.userInfo2NIMUser(getUserInfo(account));
        result.success(JSON.toJSON(user));
    }

    /**
     * ??????????????????
     *
     * @param sessionId
     * @param sessionTypeEnum
     */
    public static void markAllMessagesReadInSession(String sessionId, SessionTypeEnum
            sessionTypeEnum) {
        NIMClient.getService(MsgService.class).clearUnreadCount(sessionId, sessionTypeEnum);
    }

    /**
     * ????????????
     *
     * @param teamName ??????
     * @param accounts ?????????
     * @param result
     */
    public static void createTeam(String
                                          teamName, List<String> accounts, MethodChannel.Result result) {
        // ????????????
        TeamTypeEnum type = TeamTypeEnum.Advanced;
        HashMap<TeamFieldEnum, Serializable> fields = new HashMap<TeamFieldEnum, Serializable>();
        fields.put(TeamFieldEnum.Name, teamName);
        //??????????????????????????????????????????????????????????????????????????????
        fields.put(TeamFieldEnum.BeInviteMode, TeamBeInviteModeEnum.NoAuth);
        //?????????????????????100
        fields.put(TeamFieldEnum.MaxMemberCount, 100);
        NIMClient.getService(TeamService.class).createTeam(fields, type, "", accounts)
                .setCallback(new RequestCallbackWrapper<CreateTeamResult>() {
                    @Override
                    public void onResult(int code, CreateTeamResult createTeamResult, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            //???????????????
                            Log.d(TAG, "??????????????????code: " + code);
                            result.success(JSON.toJSON(NIMTeam.team2NIMTeam(createTeamResult.getTeam())));
                        } else {
                            Log.d(TAG, "??????????????????code: " + code);

//                            Log.d(TAG, "??????????????????code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * ???????????????
     *
     * @param teamId
     */
    public static void getTeam(String teamId, MethodChannel.Result result) {
        NIMClient.getService(TeamService.class).queryTeam(teamId).setCallback(
                new RequestCallbackWrapper<Team>() {
                    @Override
                    public void onResult(int code, Team team, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            //?????????????????????
                            Log.d(TAG, "????????????????????????code: " + code);
                            result.success(JSON.toJSON(NIMTeam.team2NIMTeam(team)));
                        } else {
                            Log.d(TAG, "????????????????????????code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * ?????????????????????
     *
     * @param teamId
     * @param result
     */
    public static void getTeamMemberList(String teamId, MethodChannel.Result result) {
        NIMClient.getService(TeamService.class).queryMemberList(teamId)
                .setCallback(new RequestCallbackWrapper<List<TeamMember>>() {
                    @Override
                    public void onResult(int code, List<TeamMember> teamMemberList, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            //?????????????????????
                            Log.d(TAG, "????????????????????????code: " + code);
                            List<NIMTeamMember> memberList = new ArrayList<>();
                            for (TeamMember teamMember : teamMemberList) {
                                if (teamMember.isInTeam()) {
                                    memberList.add(NIMTeamMember.member2NIMTeamMember(teamMember));
                                }
                            }
                            result.success(JSON.toJSON(memberList));
                        } else {
                            Log.d(TAG, "????????????????????????code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * ?????????????????????????????????
     *
     * @param messageId
     * @param result
     */
    public static void getTeamMessageReadInfo(String messageId, MethodChannel.Result result) {
        NIMClient.getService(TeamService.class).fetchTeamMessageReceiptDetail(getIMMessage(messageId))
                .setCallback(new RequestCallbackWrapper<TeamMsgAckInfo>() {
                    @Override
                    public void onResult(int code, TeamMsgAckInfo ackInfo, Throwable exception) {
                        Log.d(TAG, "?????????????????????????????????: code:" + code);
                        if (code == ResponseCode.RES_SUCCESS) {
                            result.success(JSON.toJSON(NIMTeamMessageReadInfo.teamMsgAckInfo2NIMTeamMessageReadInfo(ackInfo)));
                        } else {
                            Log.d(TAG, "???????????????????????????????????????: code:" + code + ",exception" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * ??????uuid????????????
     *
     * @param uuid
     * @return
     */
    public static IMMessage getIMMessage(String uuid) {
        List<IMMessage> messageList = NIMClient.getService(MsgService.class).queryMessageListByUuidBlock(Collections.singletonList(uuid));
        if (messageList != null && messageList.size() > 0) {
            return messageList.get(0);
        }
        return null;
    }

    /**
     * ??????????????????
     *
     * @param account
     * @return
     */
    public static NimUserInfo getUserInfo(String account) {
        return NIMClient.getService(UserService.class).getUserInfo(account);
    }
}
