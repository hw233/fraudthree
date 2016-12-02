local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "agenthelper"
local msgproxy = require "msgproxy"
local playerdatadao = require "playerdatadao"
local processstate = require "processstate"
local table = table
require "enum"

local processing = processstate:new({timeout=4})
local  LeaveTable = {}

--[[
//请求进入桌子
message LeaveTableReq {
	optional Version version = 1;
	optional int32 id = 2;
	optional string roomsvr_id = 3; //房间服务器id
	optional int32  roomsvr_table_address = 4; //桌子的服务器地址 
}

//响应进入桌子
message LeaveTableRes {
	optional int32 errcode = 1; //错误原因 0表示成功
	optional string errcodedes = 2; //错误描述	
	optional GameInfo gameinfo = 3;
}
]]

function  LeaveTable.process(session, source, fd, request)
	local responsemsg = {
		errcode = EErrCode.ERR_SUCCESS,
	}
	local server = msghelper:get_server()

	--检查当前登陆状态
	if not msghelper:is_login_success() then
		filelog.sys_warning("LeaveTable.process invalid server state", server.state)
		responsemsg.errcode = EErrCode.ERR_INVALID_REQUEST
		responsemsg.errcodedes = "无效的请求！"
		msghelper:send_resmsgto_client(fd, "LeaveTableRes", responsemsg)		
		return
	end

	if processing:is_processing() then
		responsemsg.errcode = EErrCode.ERR_DEADING_LASTREQ
		responsemsg.errcodedes = "正在处理上一次请求！"
		msghelper:send_resmsgto_client(fd, "LeaveTableRes", responsemsg)		
		return
	end

	if server.roomsvr_id == "" 
		or server.roomsvr_table_id <= 0 then
		responsemsg.errcode = EErrCode.ERR_NOT_INTABLE
		responsemsg.errcodedes = "你已经不在桌内！"
		msghelper:send_resmsgto_client(fd, "LeaveTableRes", responsemsg)		
		return		
	end

	if server.roomsvr_id ~= request.roomsvr_id 
		or server.roomsvr_table_id ~= request.id
		or server.roomsvr_table_address ~= request.roomsvr_table_address then
		responsemsg.errcode = EErrCode.ERR_INVALID_PARAMS
		responsemsg.errcodedes = "无效的参数！"
		msghelper:send_resmsgto_client(fd, "LeaveTableRes", responsemsg)		
		return				
	end

	request.rid = server.rid
	processing:set_process_state(true)
	responsemsg = msgproxy.sendrpc_reqmsgto_roomsvrd(nil, request.roomsvr_id, "gameroom"..request.id, "leavetable", request)
	--responsemsg = msgproxy.sendrpc_reqmsgto_roomsvrd(nil, request.roomsvr_id, request.roomsvr_table_address, "leavetable", request)
	processing:set_process_state(false)

	if not msghelper:is_login_success() then
		return
	end

	if responsemsg == nil then
		responsemsg = {
			errcode = EErrCode.ERR_INVALID_REQUEST,
			errcodedes = "无效的请求!",
		}
	end

	if responsemsg.errcode == EErrCode.ERR_SUCCESS then
		server.roomsvr_id = ""
		server.roomsvr_table_id = 0
		server.roomsvr_table_address = -1
		server.roomsvr_seat_index = 0
		server.online.roomsvr_id = ""
		server.online.roomsvr_table_id = 0
	    server.online.roomsvr_table_address = -1
		playerdatadao.save_player_online("update", server.rid, server.online)
	end 

	msghelper:send_resmsgto_client(fd, "LeaveTableRes", responsemsg)
end

return LeaveTable

