local skynet = require "skynet"
local filelog = require "filelog"
local sharedata = require "sharedata"
require "enum"

local filename = "configdao.lua"
local ConfigDAO = {}
local cfgcentermng = nil
local platforms = nil
local cfgsvrs = nil
local cfgdbhash = nil
local cfgclusters = nil

local function get_business_conf(platform, channel, business)
	if platform == nil or channel == nil or business == nil then
		filelog.sys_error(filename," [BASIC_CONFIGDAO] get_business_conf invalid param")		
		return nil
	end
	
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("get_business_conf cfgmng failed", cfgcentermng)
		 	cfgcentermng = nil
		 	return nil
		 end	 
		 platforms = cfgcentermng.platforms
	end	
	
    local platformtable = cfgcentermng[platform]
	if platformtable  == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid platfrom:"..platform, cfgcentermng)		
		return nil
	end
    local channeltable = platformtable[channel]
	if channeltable == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid channel:"..channel, cfgcentermng)		
		return nil		
	end
    local businesstable = channeltable[business]
	if businesstable == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid business:"..business)		
		return nil		
	end
	return businesstable.conf
end

function ConfigDAO.get_business_conf(platform, channel, business)
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("ConfigDAO.get_business_conf cfgmng", cfgcentermng)
		 	cfgcentermng = nil
		 	return nil
		 end
		 platforms = cfgcentermng.platforms
	end

	if cfgcentermng == nil then
		return nil
	end
	local conf
	platform = platforms[platform]
	if platform ~= nil then
		conf = get_business_conf(platform, channel, business)
		if conf == nil and platform ~= nil then
			conf = get_business_conf(platform, EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			if conf == nil then
				conf = get_business_conf("common", EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			end
		end 
	end

	if conf == nil then
		filelog.sys_error("ConfigDAO.get_business_conf can not find:", platform, channel, business)
	end

	return conf
end


local function get_business_source(platform, channel, business)
	if platform == nil or channel == nil or business == nil then
		filelog.sys_error(filename," [BASIC_CONFIGDAO] get_business_conf invalid param")		
		return nil
	end
	
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("get_business_conf cfgmng failed", cfgcentermng)
		 	cfgcentermng = nil
		 	return nil
		 end	 
		 platforms = cfgcentermng.platforms
	end	
	
    local platformtable = cfgcentermng[platform]
	if platformtable  == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid platfrom:"..platform, cfgcentermng)		
		return nil
	end
    local channeltable = platformtable[channel]
	if channeltable == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid channel:"..channel, cfgcentermng)		
		return nil		
	end
    local businesstable = channeltable[business]
	if businesstable == nil then
		--filelog.sys_error(filename.." [BASIC_CONFIGMNG] get_business_conf invalid business:"..business)		
		return nil		
	end
	return businesstable.source
end

function ConfigDAO.get_business_source(platform, channel, business)
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("ConfigDAO.get_business_conf cfgmng", cfgcentermng)
		 	cfgcentermng = nil
		 	return nil
		 end
		 platforms = cfgcentermng.platforms
	end

	if cfgcentermng == nil then
		return nil
	end
	local source
	platform = platforms[platform]
	if platform ~= nil then
		source = get_business_source(platform, channel, business)
		if source == nil and platform ~= nil then
			source = get_business_source(platform, EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			if source == nil then
				source = get_business_source("common", EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			end
		end 
	end

	if source == nil then
		filelog.sys_error("ConfigDAO.get_business_conf can not find:", platform, channel, business)
	end

	return source
end

function ConfigDAO.get_businessconfitem_by_index(platform, channel, business, index)
	local conf = ConfigDAO.get_business_conf(platform, channel, business)
	if conf == nil then
		return nil
	end 
	return conf[index]
end

function ConfigDAO.get_common_conf(conf_itemname)
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("ConfigDAO.get_common_conf failed", conf_itemname)
		 	cfgcentermng = nil
		 	return nil
		 end
		 platforms = cfgcentermng.platforms
	end

	if cfgcentermng == nil then
		return
	end
	
	local conf = cfgcentermng[conf_itemname]
	if conf == nil then
		return nil
	end
	return conf
end

function ConfigDAO.get_svrs(name)
	local status = false
	if cfgsvrs == nil then
		status, cfgsvrs = pcall(sharedata.query, "cfgsvrs")
		if not status then
		 	filelog.sys_error("ConfigDAO.get_svrs failed", name)
		 	cfgsvrs = nil
		 	return nil
		 end
	end
	if cfgsvrs == nil then
		return
	end

	return cfgsvrs[name]
end



function ConfigDAO.get_cfgsvrs()
	local status = false
	if cfgsvrs == nil then
		status, cfgsvrs = pcall(sharedata.query, "cfgsvrs")
		if not status then
		 	filelog.sys_error("ConfigDAO.get_cfgsvrs failed")
		 	cfgsvrs = nil
		 	return nil
		end
	end

	if cfgsvrs == nil then
		return nil
	end

	return cfgsvrs	
end

function ConfigDAO.get_cfgdbhash()
	local status = false
	if cfgdbhash == nil then
		status, cfgdbhash = pcall(sharedata.query, "cfgdbhash")
		if not status then
		 	filelog.sys_error("ConfigDAO.get_cfgdbhash failed")
		 	cfgdbhash = nil
		 	return nil
		end
	end
	return cfgdbhash	
end

function ConfigDAO.get_cfgclusters()
	local status = false
	if cfgclusters == nil then
		status, cfgclusters = pcall(sharedata.query, "cfgclusters")
		if not status then
		 	filelog.sys_error("ConfigDAO.get_cfgclusters failed")
		 	cfgclusters = nil
		 	return nil
		end		
	end
	return cfgclusters		
end

function ConfigDAO.reload()
	return skynet.call(".confcenter", "lua", "reload")
end

function ConfigDAO.deepcopy_business_conf(platform, channel, business)
	local status = false
	if cfgcentermng == nil then
		 status, cfgcentermng = pcall(sharedata.query, "cfgmng")
		 if not status then
		 	filelog.sys_error("ConfigDAO.get_business_conf cfgmng", cfgcentermng)
		 	cfgcentermng = nil
		 	return nil
		 end
		 platforms = cfgcentermng.platforms
	end

	if cfgcentermng == nil or platforms[platform] == nil then
		return nil
	end
	platform = platforms[platform]
	local restatus, retable = pcall(sharedata.deepcopy,"cfgmng", platform, channel, business)
	if not restatus or not retable then
		if platform ~= nil then
			restatus, retable = pcall(sharedata.deepcopy,"cfgmng", platform, EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			if not restatus or not retable then
				restatus, retable = pcall(sharedata.deepcopy,"cfgmng","common", EPublishChannel.PUBLISH_CHANNEL_COMMON, business)
			end
		end
	end
	return restatus,retable
end

return ConfigDAO
