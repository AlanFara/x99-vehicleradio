local radioDisplay = false
local isInVeh = false
local playerRadioId = nil
local vehiclesInPlayerScope = {}
local cachedGlobalState = {}
local muteRadio = false
local clientTime = 0
DEBUG = false

local radiosSyncQueue = {
    ["addSong"] = {},
    ["registerRadio"] = {},
    ["syncVolume"] = {},
    ["syncBassBoost"] = {},
    ["syncTrebleBoost"] = {},
    ["syncSeekTo"] = {},
    ["syncPause"] = {},
    ["playSong"] = {},
}

doorBones = {
    [-1] = "door_dside_f",
    [0] = "door_pside_f",
    [1] = "door_dside_r",
    [2] = "door_pside_r",
    [4] = "boot",
}

doorIdsToWindows = {
    [-1] = 1,
    [0] = 3,
    [1] = 2,
    [2] = 0,
    [4] = 7,
}

local _print = print

function GetAverageDoorAngles(vehicle)
    local bones = {}
    local brokenDoors = 0
    local doorCount = 0
    local totalDoorAngle = 0
    for i, name in pairs(doorBones) do
        local bone = GetEntityBoneIndexByName(vehicle, name)
        local coords = GetWorldPositionOfEntityBone(vehicle, bone)
        if #coords > 1 then
            if IsVehicleDoorDamaged(vehicle, i) ~= 1 then
                local door = GetVehicleDoorAngleRatio(vehicle, i + 1)
                local winId = doorIdsToWindows[i]
                local window = IsVehicleWindowIntact(vehicle, winId)

                totalDoorAngle += door > 0 and door or window and 0 or 0.9
            else
                totalDoorAngle += 1
                brokenDoors += 1
            end
            doorCount += 1
        end
    end
    return totalDoorAngle, doorCount, brokenDoors
end

CreateThread(function()
    activeTexts = {}
    local function DrawScreenText(x, y, text, justify)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.23)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextJustification(justify or 1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
    end

    while true do
        local msec = 1000
        if DEBUG then
            msec = 1
            for i = 1, #activeTexts do
                local text = activeTexts[i]
                if text then
                    local yOffset = #activeTexts - i
                    local t_len = string.len(text)
                    DrawScreenText(0.005, 0.68 - yOffset * 0.025, text, 2)
                end
            end
        end
        Wait(msec)
    end
end)

tprint = function(...)
    local args = {...}
    for i = 1, #args do
        if type(args[i]) == "table" then
            args[i] = "\n" .. json.encode(args[i], {indent = true}) 
        end
    end
    _print(table.unpack(args))
end

RegisterNetEvent("x99-vehicleradio:client:openRadio", function()
    if not isInVeh then return end
    registerRadio()
    displayRadio()
end)

function registerRadio()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:registerRadio", netId)
    playerRadioId = netId
    SendNUIMessage({
        type = "register",
        radio = playerRadioId,
    })
    Wait(200)
end

function displayRadio(bool)
    if bool == nil then
        bool = not radioDisplay
    end
    radioDisplay = bool
    SetNuiFocus(radioDisplay, radioDisplay)
    SendNUIMessage({
        type = "display",
        display = radioDisplay
    })
end

-- function getJSObject(gstate)
--     local radios = gstate or GlobalState.RegisteredRadios
--     local _table = {}
--     for netId, radio in pairs(radios) do
--         _table[tostring(netId)] = radio
--     end
--     return _table
-- end

RegisterNUICallback("addSong", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    -- if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:addSong", data, netId)
    cb(1)
end)

RegisterNUICallback("syncVolume", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:syncVolume", data.volume, netId)
    cb(1)
end)

RegisterNUICallback("syncBassBoost", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:syncBassBoost", data.bassBoost, netId)
    cb(1)
end)

RegisterNUICallback("syncTrebleBoost", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:syncTrebleBoost", data.trebleBoost, netId)
    cb(1)
end)

RegisterNUICallback("syncSeekTo", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:syncSeekTo", data.time, netId)
    cb(1)
end)

RegisterNUICallback("togglePause", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    local netId = data.radioId or NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:syncPause", data.isPlaying, netId, clientTime)
    cb(1)
end)

RegisterNUICallback("playSong", function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerServerEvent("x99-vehicleradio:playSong", data.songId, netId)
    cb(1)
end)

RegisterNUICallback("display", function(data, cb)
    displayRadio(data.display)
    cb(1)
end)

AddStateBagChangeHandler("RegisteredRadios", "global", function(bagName, _, data)
    for key, queue in pairs(radiosSyncQueue) do
        for k, v in pairs(queue) do
            local id = v.netId
            local radio = data[id]
            if radio then
                SendNUIMessage({
                    type = "syncGlobal",
                    key = key,
                    radio = radio,
                    args = v
                })
                table.remove(queue, k)
            end
        end
    end
end)

RegisterNetEvent("x99-vehicleradio:sync:registerRadio", function(netId)
    table.insert(radiosSyncQueue["registerRadio"], {
        netId = netId,
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:unregisterRadio", function(netId)
    SendNUIMessage({
        type = "unregister",
        radio = netId,
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:addSong", function(netId, songId, title, url)
    table.insert(radiosSyncQueue["addSong"], {
        netId = netId,
        songId = songId,
        title = title,
        url = url
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:syncVolume", function(netId, vol)
    table.insert(radiosSyncQueue["syncVolume"], {
        netId = netId,
        volume = vol
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:syncBassBoost", function(netId, bassBoost)
    table.insert(radiosSyncQueue["syncBassBoost"], {
        netId = netId,
        bassBoost = bassBoost
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:syncTrebleBoost", function(netId, trebleBoost)
    table.insert(radiosSyncQueue["syncTrebleBoost"], {
        netId = netId,
        trebleBoost = trebleBoost
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:syncSeekTo", function(netId, time)
    table.insert(radiosSyncQueue["syncSeekTo"], {
        netId = netId,
        time = time
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:playSong", function(netId, songId)
    table.insert(radiosSyncQueue["playSong"], {
        netId = netId,
        songId = songId
    })
end)

RegisterNetEvent("x99-vehicleradio:sync:syncPause", function(netId, isPlaying, time)
    -- table.insert(radiosSyncQueue["syncPause"], {
    --     netId = netId,
    --     isPlaying = isPlaying
    -- })

    SendNUIMessage({
        type = "syncGlobal",
        key = "syncPause",
        args = {
            netId = netId,
            isPlaying = isPlaying,
            time = time
        }
    })
end)

CreateThread(function()
    while true do
        local inVeh = IsPedInAnyVehicle(PlayerPedId(), false)

        if inVeh and not isInVeh then
            isInVeh = true
            -- playerRadioId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(PlayerPedId(), false))
        elseif not inVeh and isInVeh then
            isInVeh = false
            playerRadioId = nil
            displayRadio(false)
        end

        Wait(250)
    end
end)

local deg = math.deg
local acos = math.acos
local pi = math.pi
local atan2 = math.atan2


CreateThread(function()
    local vehiclesDoesNotExist = {}
    while true do
        if cachedGlobalState then
            local playerPed = PlayerPedId()
            local pos = GetPedBoneCoords(playerPed, 0x796e)
            local heading = GetGameplayCamRot(0)
            local direction = RotationToDirection(heading)

            for netId, radio in pairs(cachedGlobalState) do
                local vehicle = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId) or 0
                if not muteRadio and DoesEntityExist(vehicle) then
                    local isInRadioVeh = GetVehiclePedIsIn(playerPed, false) == vehicle
                    local vehPos = GetEntityCoords(vehicle)
                    local doorAngle, totalDoors = GetAverageDoorAngles(vehicle)
                    local totalAngleRatio = doorAngle / totalDoors

                    local dist = #(pos - vehPos) 
                    local volumeDist = (radio.volume * 0.8)-- * (totalAngleRatio * 4)

                    if not isInRadioVeh and dist < volumeDist then -- and radio.isPlaying
                        local volume = math.max(0.0, 1.0 - (dist / volumeDist))

                        local playerToVehicleDirection = (vehPos - pos)
                        local crossProductZ = -playerToVehicleDirection.x * direction.y + playerToVehicleDirection.y * direction.x
                        local stereoBalance = crossProductZ
                        local stereoSpread = 0.5

                        local leftBalance = (1.0 - stereoSpread) * (0.5 + 0.5 * stereoBalance)
                        local rightBalance = (1.0 - stereoSpread) * (0.5 - 0.5 * stereoBalance)

                        leftBalance = math.max(0.0, math.min(5.0, leftBalance)) -- (volume / 2) 
                        rightBalance = math.max(0.0, math.min(5.0, rightBalance)) -- (volume / 2)
                        
                        if not Config.useStereo then
                            leftBalance = 5.0
                            rightBalance = 5.0
                        end

                        if volume > 0 then
                            SendNUIMessage({
                                type = "updatePosition",
                                netId = netId,
                                leftBalance = leftBalance,
                                rightBalance = rightBalance,
                                volume = volume,
                                LPFValue = Config.useLPF and (2.5 * (1 - totalAngleRatio)) * dist,
                            }) 
                        end
                    elseif not isInRadioVeh then
                        SendNUIMessage({
                            type = "updatePosition",
                            netId = netId,
                            leftBalance = 0.0,
                            rightBalance = 0.0,
                            volume = 0.0
                        })
                    elseif isInRadioVeh then
                        SendNUIMessage({
                            type = "updatePosition",
                            netId = netId,
                            leftBalance = 5.0,
                            rightBalance = 5.0,
                            volume = 1.0
                        })
                    end
                    if vehiclesDoesNotExist[netId] then
                        vehiclesDoesNotExist[netId] = nil
                    end
                elseif not vehiclesDoesNotExist[netId] then
                    vehiclesDoesNotExist[netId] = true
                    SendNUIMessage({
                        type = "updatePosition",
                        netId = netId,
                        leftBalance = 0.0,
                        rightBalance = 0.0,
                        volume = 0.0
                    })
                end
            end
        end
        Wait(80)
    end
end)

CreateThread(function()
    local _before = {}
    while true do
        if cachedGlobalState and _before then
            for netId, radio in pairs(_before) do
                local vehicle = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId) or 0
                local vehicleExist = DoesEntityExist(vehicle)
                local dist = #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId()))
                -- print(dist)
                if vehicleExist and not vehiclesInPlayerScope[netId] and dist < 200 then
                    -- print("vehicleEnteredScope", netId)
                    vehiclesInPlayerScope[netId] = true
                    SendNUIMessage({
                        type = "vehicleEnteredScope",
                        netId = netId,
                        data = cachedGlobalState[netId]
                    })
                elseif not vehicleExist and vehiclesInPlayerScope[netId] or (dist > 200 and vehiclesInPlayerScope[netId]) then
                    -- print("vehicleLeftScope", netId)
                    vehiclesInPlayerScope[netId] = nil
                    SendNUIMessage({
                        type = "vehicleLeftScope",
                        netId = netId,
                    })
                elseif _before[netId] and not cachedGlobalState[netId] then
                    vehiclesInPlayerScope[netId] = nil
                    SendNUIMessage({
                        type = "vehicleLeftScope",
                        netId = netId
                    })
                end
            end
        end
        _before = cachedGlobalState
        Wait(1000)
    end
end)

AddStateBagChangeHandler("RegisteredRadios", "global", function(bagName, value, data)
    cachedGlobalState = data
    activeTexts = {}
    for k, v in pairs(cachedGlobalState) do
        for k1, v1 in pairs(v) do
            activeTexts[#activeTexts + 1] = "\"".. k1 .. "\": "..json.encode(v1)
        end
    end
end)

function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return vector3(direction.x, direction.y, direction.z)
end

RegisterNUICallback("requestRadioSync", function(data, cb)
    SendNUIMessage({
        type = "config",
        maxVolume = Config.maxVolume,
        bassRange = Config.bassRange,
        trebleRange = Config.trebleRange,
    })
    SendNUIMessage({
        type = "debug",
        debug = DEBUG
    })
    Wait(1000) -- 10000
    cachedGlobalState = GlobalState.RegisteredRadios
    local radiosObject = {}

    for netId, radio in pairs(cachedGlobalState) do
        radiosObject[tostring(netId)] = radio
    end

    -- SendNUIMessage({
    --     type = "syncRadios",
    --     radios = radiosObject
    -- })
    cb(1)
end)

RegisterNUICallback("timeupdate", function(data, cb)
    cb(1)
    local time = data.time
    local netId = data.radioId or playerRadioId
    if not vehiclesInPlayerScope[netId] then return end
    local radio = cachedGlobalState[netId]
    local playerId = GetPlayerServerId(PlayerId())
    if not radio or radio.source ~= playerId then 
        -- print("Radio not found", netId, time, playerId, radio and radio.source)
        return 
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(vehicle) then 
        -- print("Vehicle not found", netId, time, playerId, radio and radio.source)
        return 
    end

    Entity(vehicle).state:set("radioTime", time, true)
end)

if Config.muteRadioCommand then
    RegisterCommand(Config.muteRadioCommand, function()
        local text = "Radio is now "
        muteRadio = not muteRadio
        if muteRadio then
            text = text .. "muted"
        else
            text = text .. "unmuted"
        end

        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            multiline = true,
            args = {"Radio", text}
        })
    end)
end