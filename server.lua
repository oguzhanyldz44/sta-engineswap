local QBCore = exports['qb-core']:GetCoreObject()
local MySQL = exports.oxmysql
CreateThread(function()
    MySQL:query([[
        CREATE TABLE IF NOT EXISTS `sta_vehicle_engines` (
            `plate` VARCHAR(20) NOT NULL,
            `engine_sound` VARCHAR(50) NOT NULL,
            PRIMARY KEY (`plate`)
        )
    ]])
end)
QBCore.Functions.CreateCallback('sta-engineswap-server-getEngineSound', function(source, cb, plate)
    MySQL:query('SELECT engine_sound FROM sta_vehicle_engines WHERE plate = ?', {plate}, function(result)
        if result and result[1] then
            cb(result[1].engine_sound)
        else
            cb(false)
        end
    end)
end)
RegisterNetEvent('sta-engineswap-server-saveSound', function(plate, engineHash)
    local src = source
    MySQL:query('INSERT INTO sta_vehicle_engines (plate, engine_sound) VALUES (?, ?) ON DUPLICATE KEY UPDATE engine_sound = ?', 
    {plate, engineHash, engineHash}, function(affectedRows)
        if affectedRows then
            TriggerClientEvent('QBCore:Notify', src, "Motor sesi başarıyla kaydedildi!", "success")
        end
    end)
end)