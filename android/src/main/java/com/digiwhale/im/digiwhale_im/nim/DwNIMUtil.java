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
 * 云信工具类
 */
public class DwNIMUtil {

    private static final String TAG = "IM操作";

    /**
     * sdk设置
     *
     * @param context
     * @return
     */
    private static SDKOptions nimSDKOption(Context context) {
        SDKOptions sdkOptions = new SDKOptions();
//        sdkOptions.appKey = appKey;
        //使用应用扩展目录缓存，不需要申请读写文件权限
        sdkOptions.sdkStorageRootPath = context.getExternalFilesDir("mim").getAbsolutePath();
        //开启会话已读多端同步，支持多端同步会话未读数
        sdkOptions.sessionReadAck = true;
        //群通知消息计入未读数
        sdkOptions.teamNotificationMessageMarkUnread = true;
        //设置群消息已读回执
        sdkOptions.enableTeamMsgAck = true;
        //第三方推送(华米OV、魅族、fcm等)
        //todo 不确定是否需要
        //sdkOptions.mixPushConfig
        return sdkOptions;
    }

    /**
     * 初始化(做监听的注册，非SDK初始化)
     */
    public static void init() {
        Log.d(TAG, "init SDK: 注册监听");
        //注册监听
        NIMClient.getService(MsgServiceObserve.class).observeRecentContact(NIMObserver.sessionsObserver, true);
        NIMClient.getService(AuthServiceObserver.class).observeLoginSyncDataStatus(NIMObserver.loginSyncStatusObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeReceiveMessage(NIMObserver.incomingMessageObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeMessageReceipt(NIMObserver.messageReceiptsObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeTeamMessageReceipt(NIMObserver.teamMessageReceiptsObserver, true);
        NIMClient.getService(MsgServiceObserve.class).observeRevokeMessage(NIMObserver.revokeMessageObserver, true);
    }

    /**
     * 登录
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
                        //缓存账密，用于下次自动登录
                        NIMPreferences.saveUserAccount(account);
                        NIMPreferences.saveUserToken(token);
                        result.success(true);
                        //登陆成功后注册监听--监听会话列表变化
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
            Log.d(TAG, "在主线程，准备登录 ");
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
     * 登出
     */
    public static void loginOut() {
        NIMClient.getService(AuthService.class).logout();
        //清除账密缓存
        NIMPreferences.clear();
    }

    /**
     * 登录状态
     *
     * @param result
     */
    public static void loginStatus(MethodChannel.Result result) {
        StatusCode code = NIMClient.getStatus();
        Log.d(TAG, "login status: " + code.name());
        result.success(code.name());
    }

    /**
     * 未读消息数
     *
     * @param result
     */
    public static void unreadNum(MethodChannel.Result result) {
        int unreadNum = NIMClient.getService(MsgService.class).getTotalUnreadCount();
        Log.d(TAG, "unreadNum: " + unreadNum);
        result.success(unreadNum);
    }

    /**
     * 最近会话
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
                                //P2P聊天对象信息
                                NimUserInfo userInfo = null;
                                if (contact.getSessionType() == SessionTypeEnum.P2P) {
                                    userInfo = DwNIMUtil.getUserInfo(contact.getContactId());
                                }
                                NIMSession session = NIMSession.recentContact2NIMSession(contact, userInfo);
                                Log.d(TAG, "recent contact：会话: " + session.toString());
                                nimSessions.add(session);
                            }
                        }
                        result.success(JSON.toJSON(nimSessions));
                    }
                });
    }

    /**
     * 删除最近会话
     *
     * @param sessionId
     */
    public static void deleteSession(String sessionId, SessionTypeEnum sessionTypeEnum) {
        //查询会话
        RecentContact recentContact =
                NIMClient.getService(MsgService.class).queryRecentContact(sessionId, sessionTypeEnum);
        //删除会话
        if (recentContact != null) {
            NIMClient.getService(MsgService.class).deleteRecentContact(recentContact);
        }
    }

    /**
     * 发送消息
     *
     * @param sessionId   聊天对象ID(单聊为账号id，群聊为群组ID)
     * @param sessionType 会话类型
     * @param text        文本消息内容
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

        //设置该消息需要已读回执
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
     * 本地聊天记录
     *
     * @param sessionId   会话id
     * @param sessionType 会话类型
     * @param limit       最多拿多少条消息
     * @param messageId   锚点消息id,从这条往前查找（如果为空或无此消息，则从最新一条消息开始查找）（返回结果不包含此消息）
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
     * 云端聊天记录
     *
     * @param sessionId   会话id
     * @param sessionType 会话类型
     * @param limit       最多拿多少条消息(最多为100)
     * @param messageId   锚点消息id,从这条往前查找（如果为空或无此消息，则从最新一条消息开始查找）（返回结果不包含此消息）
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
     * 消息已读
     *
     * @param sessionId
     * @param messageId
     */
    public static void sendMessageReceipt(String sessionId, SessionTypeEnum typeEnum, String messageId) {
        if (typeEnum == SessionTypeEnum.P2P) {
            NIMClient.getService(MsgService.class).sendMessageReceipt(sessionId, getIMMessage(messageId));
        } else if (typeEnum == SessionTypeEnum.Team) {
            IMMessage message = getIMMessage(messageId);
            //判断是否已经发送了已读回执，已发送则不重复发送
            if (message != null && !message.hasSendAck()) {
                NIMClient.getService(TeamService.class).sendTeamMessageReceipt(message);
            }
        }
    }

    /**
     * 消息撤回
     *
     * @param messageId
     * @param result
     */
    public static void revokeMessage(String messageId, final MethodChannel.Result result) {
        final IMMessage message = getIMMessage(messageId);
        if (message == null) {
            Log.d(TAG, "revokeMessage: 没找到对应消息，messageId:" + messageId);
            result.success(false);
            return;
        }
        Log.d(TAG, "revokeMessage: 找到了对应消息，messageId:" + messageId);
        NIMClient.getService(MsgService.class).revokeMessage(message, null, null, true).setCallback(new RequestCallbackWrapper<Void>() {
            @Override
            public void onResult(int code, Void res, Throwable exception) {
                Log.d(TAG, "onResult: 撤回结果code：" + code);
                if (code == ResponseCode.RES_SUCCESS) {
                    result.success(true);
                    //往本地写一条撤回类消息
                    NIMLocalMessageHelper.saveMessageToLocalEx(message, NIMLocalMessageHelper.REVOKE_MESSAGE_ME_TYPE);
                } else {
                    result.success(false);
                }

            }
        });
    }

    /**
     * 获取人员信息
     *
     * @param accounts
     * @param result
     */
    public static void getUserInfoList(List<String> accounts, MethodChannel.Result result) {
        List<NimUserInfo> users = NIMClient.getService(UserService.class).getUserInfoList(accounts);
        List<NIMUser> nimUserList = new ArrayList<>();
        if (users != null && users.size() > 0) {
            Log.d(TAG, "本地getUserInfoList: " + users.size());
            for (NimUserInfo userInfo : users) {
                nimUserList.add(NIMUser.userInfo2NIMUser(userInfo));
            }
        }
        if (users.size() == accounts.size()) {
            result.success(JSON.toJSON(nimUserList));
        } else {
            //从云端获取资料
            NIMClient.getService(UserService.class).fetchUserInfo(accounts)
                    .setCallback(new RequestCallback<List<NimUserInfo>>() {

                        @Override
                        public void onSuccess(List<NimUserInfo> userInfoList) {
                            Log.d(TAG, "云端getUserInfoList: " + users.size());
                            nimUserList.clear();
                            for (NimUserInfo userInfo : userInfoList) {
                                nimUserList.add(NIMUser.userInfo2NIMUser(userInfo));
                            }
                            result.success(JSON.toJSON(nimUserList));
                        }

                        @Override
                        public void onFailed(int code) {
                            Log.d(TAG, "从云端获取人员资料失败，onFailed: " + code);
                            result.success(JSON.toJSON(nimUserList));
                        }

                        @Override
                        public void onException(Throwable exception) {
                            Log.d(TAG, "从云端获取人员资料异常，onException: " + exception.getMessage());
                            exception.getMessage();
                            result.success(JSON.toJSON(nimUserList));
                        }
                    });
        }
    }

    /**
     * 获取当前用户信息
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
     * 设置会话已读
     *
     * @param sessionId
     * @param sessionTypeEnum
     */
    public static void markAllMessagesReadInSession(String sessionId, SessionTypeEnum
            sessionTypeEnum) {
        NIMClient.getService(MsgService.class).clearUnreadCount(sessionId, sessionTypeEnum);
    }

    /**
     * 创建群组
     *
     * @param teamName 群名
     * @param accounts 群成员
     * @param result
     */
    public static void createTeam(String
                                          teamName, List<String> accounts, MethodChannel.Result result) {
        // 群组类型
        TeamTypeEnum type = TeamTypeEnum.Advanced;
        HashMap<TeamFieldEnum, Serializable> fields = new HashMap<TeamFieldEnum, Serializable>();
        fields.put(TeamFieldEnum.Name, teamName);
        //群被邀请模式：被邀请人的同意方式：不需要被邀请方同意
        fields.put(TeamFieldEnum.BeInviteMode, TeamBeInviteModeEnum.NoAuth);
        //做大成员数量：100
        fields.put(TeamFieldEnum.MaxMemberCount, 100);
        NIMClient.getService(TeamService.class).createTeam(fields, type, "", accounts)
                .setCallback(new RequestCallbackWrapper<CreateTeamResult>() {
                    @Override
                    public void onResult(int code, CreateTeamResult createTeamResult, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            //群创建成功
                            Log.d(TAG, "群创建成功：code: " + code);
                            result.success(JSON.toJSON(NIMTeam.team2NIMTeam(createTeamResult.getTeam())));
                        } else {
                            Log.d(TAG, "群创建失败：code: " + code);

//                            Log.d(TAG, "群创建失败：code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * 获取群信息
     *
     * @param teamId
     */
    public static void getTeam(String teamId, MethodChannel.Result result) {
        NIMClient.getService(TeamService.class).queryTeam(teamId).setCallback(
                new RequestCallbackWrapper<Team>() {
                    @Override
                    public void onResult(int code, Team team, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            //获取群信息成功
                            Log.d(TAG, "获取群信息成功：code: " + code);
                            result.success(JSON.toJSON(NIMTeam.team2NIMTeam(team)));
                        } else {
                            Log.d(TAG, "获取群信息失败：code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * 获取群成员列表
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
                            //获取群信息成功
                            Log.d(TAG, "获取群成员成功：code: " + code);
                            List<NIMTeamMember> memberList = new ArrayList<>();
                            for (TeamMember teamMember : teamMemberList) {
                                if (teamMember.isInTeam()) {
                                    memberList.add(NIMTeamMember.member2NIMTeamMember(teamMember));
                                }
                            }
                            result.success(JSON.toJSON(memberList));
                        } else {
                            Log.d(TAG, "获取群成员失败：code: " + code + ",exception:" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * 获取群消息已读未读详情
     *
     * @param messageId
     * @param result
     */
    public static void getTeamMessageReadInfo(String messageId, MethodChannel.Result result) {
        NIMClient.getService(TeamService.class).fetchTeamMessageReceiptDetail(getIMMessage(messageId))
                .setCallback(new RequestCallbackWrapper<TeamMsgAckInfo>() {
                    @Override
                    public void onResult(int code, TeamMsgAckInfo ackInfo, Throwable exception) {
                        Log.d(TAG, "获取群消息已读未读详情: code:" + code);
                        if (code == ResponseCode.RES_SUCCESS) {
                            result.success(JSON.toJSON(NIMTeamMessageReadInfo.teamMsgAckInfo2NIMTeamMessageReadInfo(ackInfo)));
                        } else {
                            Log.d(TAG, "获取群消息已读未读详情失败: code:" + code + ",exception" + exception.getMessage());
                        }
                    }
                });
    }

    /**
     * 根据uuid查找消息
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
     * 获取用户资料
     *
     * @param account
     * @return
     */
    public static NimUserInfo getUserInfo(String account) {
        return NIMClient.getService(UserService.class).getUserInfo(account);
    }
}
