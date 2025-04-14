RegisteredRadios = {}

CreateThread(function()
    GlobalState.RegisteredRadios = {}

    while true do
        for netId, radio in pairs(RegisteredRadios) do
            local vehicle = NetworkGetEntityFromNetworkId(netId)
            if not DoesEntityExist(vehicle) or GetVehicleNumberPlateText(vehicle) ~= radio.plate then
                RegisteredRadios[netId] = nil
                GlobalState.RegisteredRadios = RegisteredRadios
                TriggerClientEvent("x99-vehicleradio:sync:unregisterRadio", -1, netId)
            end
        end
        Wait(1000 * 2)
    end
end)

RegisterNetEvent("x99-vehicleradio:registerRadio", function(netId)
    local source = source
    if not RegisteredRadios[netId] then
        RegisteredRadios[netId] = VehicleRadio:create(netId, source)
        TriggerClientEvent("x99-vehicleradio:sync:registerRadio", -1, netId)
    end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local radio = RegisteredRadios[netId]
    radio.plate = GetVehicleNumberPlateText(vehicle)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:addSong", function(data, netId)
    local source = source
    local id = data.id
    local radio = RegisteredRadios[netId]
    if not radio then
        return false
    end

    local ytData = exports[GetCurrentResourceName()]:loadYT(id)
    if not ytData then
        return false
    end
    
    radio:addSong(ytData, id)
    radio.source = source
    TriggerClientEvent("x99-vehicleradio:sync:addSong", -1, netId, id, ytData.title, ytData.url)
    GlobalState.RegisteredRadios = RegisteredRadios
    return true
end)

RegisterNetEvent("x99-vehicleradio:syncVolume", function(vol, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    
    radio.source = source
    radio:syncVolume(vol)
    TriggerClientEvent("x99-vehicleradio:sync:syncVolume", -1, netId, vol)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:syncBassBoost", function(boost, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:syncBassBoost(boost)
    TriggerClientEvent("x99-vehicleradio:sync:syncBassBoost", -1, netId, boost)
    -- print("syncBassBoost", netId, boost)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:syncTrebleBoost", function(boost, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:syncTrebleBoost(boost)
    TriggerClientEvent("x99-vehicleradio:sync:syncTrebleBoost", -1, netId, boost)
    -- print("syncTrebleBoost", netId, boost)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:syncSeekTo", function(seek, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:syncSeekTo(seek)
    TriggerClientEvent("x99-vehicleradio:sync:syncSeekTo", -1, netId, seek)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:syncPause", function(pause, netId, currentTime)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:syncPause(pause)
    radio:syncSeekTo(currentTime)
    TriggerClientEvent("x99-vehicleradio:sync:syncPause", -1, netId, pause, currentTime)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:playSong", function(id, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:playSong(id)

    TriggerClientEvent("x99-vehicleradio:sync:playSong", -1, netId, id)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

RegisterNetEvent("x99-vehicleradio:syncCurrentTime", function(time, netId)
    local source = source
    local radio = RegisteredRadios[netId]
    if not radio then
        return
    end
    radio.source = source
    radio:syncCurrentTime(time)
    GlobalState.RegisteredRadios = RegisteredRadios
    return radio.id
end)

AddStateBagChangeHandler("radioTime", nil, function(bagName, value, data)
    local netId = bagName:gsub("entity:", "")
    if not netId then return end
    netId = tonumber(netId)
    local radio = RegisteredRadios[netId]
    if not radio then return end
    
    radio:syncCurrentTime(data)
    GlobalState.RegisteredRadios = RegisteredRadios
end)