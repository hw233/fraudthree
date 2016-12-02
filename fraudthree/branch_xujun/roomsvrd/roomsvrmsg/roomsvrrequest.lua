local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "roomsvrhelper"
local msgproxy = require "msgproxy"
local base = require "base"
local configdao = require "configdao"
local timetool = require "timetool"
require "enum"

local filename = "RoomsvrRequest.lua"
local RoomsvrRequest = {}

function RoomsvrRequest.process(session, source, event, ...)
	local f = RoomsvrRequest[event] 
	if f == nil then
		filelog.sys_error(filename.." RoomsvrRequest.process invalid event:"..event)
		base.skynet_retpack(nil)
		return
	end
	f(session, source, ...)
end

--[[
//请求创建朋友桌
message CreateFriendTableReq {
	optional Version version = 1;
	optional int32 room_type = 2;
	optional int32 game_type = 3;
	optional string name = 4;
	optional int32 base_coin = 5;            //底分
	optional int32 retain_time = 6;          //朋友桌保留时间单位s
	optional int32 action_timeout = 7;       //玩家操作限时
	optional int32 action_timeout_count = 8; //玩家可操作超时次数
	optional int32 force_overturns = 9;          //牌级
	optional int32 min_carry_coin = 10;      //最小携带金币	
}

//响应创建朋友桌
message CreateFriendTableRes {
	optional int32 errcode = 1; //错误原因 0表示成功
	optional string errcodedes = 2; //错误描述
	optional string create_table_id = 3; //朋友桌索引号
}
]]

function RoomsvrRequest.createfriendtable(session, source, request)
	local responsemsg = {
		errcode = EErrCode.ERR_SUCCESS,
	}

	if request.room_type == nil 
		or request.retain_time == nil
		or request.action_timeout == nil
		or request.action_timeout_count == nil
		--各个游戏相关
		or request.base_coin == nil
		or request.force_overturns == nil
		or request.min_carry_coin == nil then
		responsemsg.errcodedes = "无效请求！"
		base.skynet_retpack(responsemsg)
		filelog.sys_error("RoomsvrRequest.createfriendtable two invalid request param")		
		return
	end 

	local conf = {
		conf_version = 1,
		room_type = request.room_type,
		--桌子解散时间，60秒后释放
		retain_time = 180,--request.retain_time,
		name = request.name or "",
		game_type = request.game_type or EGameType.GAME_TYPE_COMMON,
	    max_player_num = request.maxperson,
	    min_player_num = 2,
	    create_user_rid = request.rid,
	    create_user_rolename = request.playerinfo.rolename,
	    create_user_logo = request.playerinfo.logo,
	    create_time = timetool.get_time(),
	   	action_timeout = request.action_timeout,       --玩家操作限时
		action_timeout_count = request.action_timeout_count, --玩家可操作超时次数
		--各个游戏相关
		base_coin = request.base_coin,
		force_overturns = request.force_overturns,
		min_carry_coin = request.min_carry_coin,
		accesscontrol = request.accesscontrol,
		ready_timeout = 5*60,   
        tuoguan_timeout_count = 2,  --托管超时次数  

	}

    local result, create_table_id = msghelper:create_friend_table(conf)
    if not result then
		responsemsg.errcode = EErrCode.ERR_CREATE_TABLE_FAILED
    	responsemsg.errcodedes = "系统错误，创建朋友桌失败！"
		filelog.sys_error("RoomsvrRequest.createfriendtable create_friend_table failed")
    else
    	responsemsg.create_table_id = create_table_id
    end
    --print("createfriendtable id"..create_table_id)
    base.skynet_retpack(responsemsg)
end

return RoomsvrRequest