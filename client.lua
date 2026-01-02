local QBCore = exports['qb-core']:GetCoreObject()
local isTesting, menuOpen = false, false
local originalSound, lastPos = nil, nil
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local pData = QBCore.Functions.GetPlayerData()
        local job = pData.job and pData.job.name or "unemployed"
        local availableLocations = {}
        if Config.Locations[job] then 
            for _, v in pairs(Config.Locations[job]) do table.insert(availableLocations, v) end 
        end
        if Config.Locations["all"] then 
            for _, v in pairs(Config.Locations["all"]) do table.insert(availableLocations, v) end 
        end
        for _, loc in pairs(availableLocations) do
            local dist = #(pos - loc)
            if dist < 10.0 then
                sleep = 0
                DrawMarker(Config.MarkerSettings.type, loc.x, loc.y, loc.z + 0.3, 0,0,0,0,0,0, Config.MarkerSettings.size.x, Config.MarkerSettings.size.y, Config.MarkerSettings.size.z, Config.MarkerSettings.color.r, Config.MarkerSettings.color.g, Config.MarkerSettings.color.b, Config.MarkerSettings.color.a, false, false, 2, nil, nil, false)
                
                if dist < 2.0 and not menuOpen then
                    QBCore.Functions.DrawText3D(loc.x, loc.y, loc.z + 0.8, "~g~E~w~ - Motor Sesleri")
                    if IsControlJustPressed(0, 38) then OpenEngineMenu() end
                end
            end
        end
        if menuOpen and lastPos then
            sleep = 0
            if #(pos - lastPos) > 5.0 then
                CloseMenu()
                QBCore.Functions.Notify("Uzaklaştığınız için menü kapatıldı.", "error")
            end
        end
        Wait(sleep)
    end
end)
RegisterNetEvent('QBCore:Client:OnPlayerVehicleEnter', function(vehicle)
    local plate = QBCore.Functions.GetPlate(vehicle)
    QBCore.Functions.TriggerCallback('sta-engineswap-server-getEngineSound', function(soundHash)
        if soundHash and soundHash ~= "" then
            ForceVehicleEngineAudio(vehicle, soundHash)
        end
    end, plate)
end)
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle ~= 0 then
            local plate = QBCore.Functions.GetPlate(vehicle)
            QBCore.Functions.TriggerCallback('sta-engineswap-server-getEngineSound', function(soundHash)
                if soundHash and soundHash ~= "" then
                    ForceVehicleEngineAudio(vehicle, soundHash)
                end
            end, plate)
            Wait(60000) 
        else
            Wait(2000)
        end
    end
end)
function OpenEngineMenu()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local plate = QBCore.Functions.GetPlate(vehicle)
        QBCore.Functions.TriggerCallback('sta-engineswap-server-getEngineSound', function(sound)
            originalSound = sound
            lastPos = GetEntityCoords(vehicle)
            menuOpen = true
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(true) 
            SendNUIMessage({ action = "open", engines = Config.Engines, plate = plate })
        end, plate)
    else
        QBCore.Functions.Notify("Araçta olmalısın!", "error")
    end
end
function CloseMenu()
    isTesting = false
    menuOpen = false
    lastPos = nil
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "closeUI" })
    SetNuiFocus(false, false) 
end

RegisterNUICallback('testEngine', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        isTesting = true
        ForceVehicleEngineAudio(vehicle, data.hash)
    end
    cb('ok')
end)
RegisterNUICallback('resetToDefault', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        ForceVehicleEngineAudio(vehicle, "") 
        TriggerServerEvent('sta-engineswap-server-saveSound', data.plate, "") 
    end
    CloseMenu() 
    cb('ok')
end)
RegisterNUICallback('confirm', function(data, cb)
    TriggerServerEvent('sta-engineswap-server-saveSound', data.plate, data.hash)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then ForceVehicleEngineAudio(vehicle, originalSound or "") end
    CloseMenu()
    cb('ok')
end)