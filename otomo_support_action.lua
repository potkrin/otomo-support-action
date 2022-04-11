-- otomo_support_action.lua : written by hotkrin
-- fix the main monster's spawn area by reframework. (no need to restart game)

log.debug("[otomo_support_action.lua] started loading")

-- type is the "typeof" variant, not the type definition
local function dump_fields_by_type(type)
    log.info("Dumping fields...")

    local binding_flags = 32 | 16 | 4 | 8
    local fields = type:call("GetFields(System.Reflection.BindingFlags)", binding_flags)

    if fields then
        fields = fields:get_elements()

        for i, field in ipairs(fields) do
            log.info("Field: " .. field:call("ToString"))
        end
    end
end

local function dump_fields(object)
    log.debug("dump_fields start")
    local object_type = object:call("GetType")

    dump_fields_by_type(object_type)
    log.debug("dump_fields end")
end

local invisible_player = true
local invisible_otomo = true

re.on_frame(function()
    if true then return end

    local otomoManager = sdk.get_managed_singleton("snow.otomo.OtomoManager")
    if not otomoManager then return end

    local playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    if not playerManager then return end

    local master = playerManager:call("findMasterPlayer")
    if not master then return end
    
    local masterId = playerManager:call("getMasterPlayerID")
    if not masterId then return end

    local omUserData = otomoManager:call("get_RefUserData")
    log.debug("omUserData = "..tostring(omUserData))

    local airouSupportAllData = omUserData:call("get_AirouSupportData")
    log.debug("airouSupportAllData = "..tostring(airouSupportAllData))
 
    -- ToArray() もある
    local supportList = airouSupportAllData:get_field("data")
    log.debug("supportList = "..tostring(supportList))

 
    for i = 1, 24 do
        local supportData = supportList:call("get_Item", i)
        -- log.debug(tostring(i)..": supportData = "..tostring(supportData))

        local priority = supportData:get_field("Priority")
        -- log.debug(tostring(i)..": prio = "..tostring(priority))
   
        local checkEventList = supportData:get_field("CheckEvent")
        -- log.debug(tostring(i)..": checkEventList = "..tostring(checkEventList))

        local checkEvent = checkEventList:call("get_Item", 0)
        -- log.debug(tostring(i)..": checkEvent = "..tostring(checkEvent))
    
        local checkParamU32 = checkEvent:get_field("CheckParamU32")
        -- log.debug(tostring(i)..": checkParamU32 = "..tostring(checkParamU32))

        local baseRateList = checkEvent:get_field("BaseRateList")
        local TableRateList = baseRateList:get_elements()
        for k = 0, 4 do
            local element = baseRateList:get_element(k)
            log.debug(tostring(i)..": BaseRateList["..tostring(k).."] = "..tostring(element:get_field("mValue")))
        end
    end
end)


function on_pre_get_SupportID(args)
    log.debug("on_pre_get_SupportID")
    return sdk.PreHookResult.CALL_ORIGINAL
end

local SpawnAreaID = 0

function on_post_get_SupportID(retval)
    log.debug("on_post_get_SupportID")
end

sdk.hook(sdk.find_type_definition("snow.otomo.OtAirouSupportLotData"):get_method("get_SupportID"), 
	on_pre_get_SupportID,
	on_post_get_SupportID)


function on_pre_get_BaseLotRate(args)
    log.debug("on_pre_get_BaseLotRate")
    return sdk.PreHookResult.CALL_ORIGINAL
end

function on_post_get_BaseLotRate(retval)
    -- local rate = sdk.to_managed_object(retval)
    log.debug("on_post_get_BaseLotRate"..tostring(retval))
    return retval
end

sdk.hook(sdk.find_type_definition("snow.otomo.OtAirouSupportLotData"):get_method("get_BaseLotRate"), 
	on_pre_get_BaseLotRate,
	on_post_get_BaseLotRate)


function on_pre_set_BaseLotRate(args)
    log.debug("on_pre_set_BaseLotRate")
    return sdk.PreHookResult.CALL_ORIGINAL
end

function on_post_set_BaseLotRate(retval)
    log.debug("on_post_set_BaseLotRate")
    return retval
end

sdk.hook(sdk.find_type_definition("snow.otomo.OtAirouSupportLotData"):get_method("set_BaseLotRate"), 
	on_pre_set_BaseLotRate,
	on_post_set_BaseLotRate)



function on_pre_getSupportParam(args)
    log.debug("on_pre_getSupportParam")
    return sdk.PreHookResult.CALL_ORIGINAL
end

function on_post_getSupportParam(retval)
    log.debug("on_post_getSupportParam")
    local support_base_data = sdk.to_managed_object(retval)
    log.debug("sbd: "..tostring(support_base_data))
    -- dump_fields(support_base_data)
    local SupportID = support_base_data:get_field("SupportID")
    local Priority = support_base_data:get_field("Priority")
    local RelotTime = support_base_data:get_field("RelotTime")
    local CoolDownTime = support_base_data:get_field("CoolDownTime")
    local FailAddRate = support_base_data:get_field("FailAddRate")
    log.debug("SupportID: "..tostring(SupportID))
    log.debug("Priority: "..tostring(Priority))
    log.debug("RelotTime: "..tostring(RelotTime))
    log.debug("CoolDownTime: "..tostring(CoolDownTime))
    log.debug("FailAddRate: "..tostring(FailAddRate))

   
    local CheckEventList = support_base_data:get_field("CheckEvent")
    log.debug("CheckEventList"..tostring(CheckEventList))

    local CheckEvent = CheckEventList:call("get_Item", 0)
 
    local CheckParamU32 = CheckEvent:get_field("CheckParamU32")
    log.debug("CheckParamU32"..tostring(CheckParamU32))
 
    local BaseRateList = CheckEvent:get_field("BaseRateList")
    local TableRateList = BaseRateList:get_elements()
    for k = 0, 4 do
        local element = BaseRateList:get_element(k)
        log.debug("BaseRateList["..tostring(k).."] = "..tostring(element:get_field("mValue")))
    end

    local ptr = sdk.to_ptr(mretval)
    if ptr ~= nil then
        return ptr
    end
    -- return retval
end

-- this fuction is called on quest start, activation of support action
sdk.hook(sdk.find_type_definition("snow.otomo.OtomoManager"):get_method("getSupportParam"), 
	on_pre_getSupportParam,
	on_post_getSupportParam)


function on_pre_initAllSupportData(args)
    log.debug("on_pre_initAllSupportData")
    return sdk.PreHookResult.CALL_ORIGINAL
end

function on_post_initAllSupportData(retval)
    local support_list = sdk.to_managed_object(retval)
    log.debug("on_post_initAllSupportData"..tostring(support_list))
end

sdk.hook(sdk.find_type_definition("snow.otomo.OtAirouSupportAllData"):get_method("initAllSupportData"), 
	on_pre_initAllSupportData,
	on_post_initAllSupportData)



log.debug("[otomo_support_action.lua] finished loading")