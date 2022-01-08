---------------------------
    -- ESX --
---------------------------
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
---------------------------
    -- Event Handlers --
---------------------------
TriggerEvent('esx_society:registerSociety', 'barber', 'Barber', 'society_barber', 'society_barber', 'society_barber', {type = 'public'})

local barberSeats = {}
local sendBackData = {}

RegisterServerEvent('vinBarber:server:sendToChair')
AddEventHandler('vinBarber:server:sendToChair', function(seatCoords, sitting)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local x,y,z,w = table.unpack(seatCoords)
    if #(GetEntityCoords(GetPlayerPed(src)) - vector3(x,y,z)) < 1.5 then
        if sitting then
            table.insert(sendBackData, {playerId = src, seated = sitting, coords = vector4(x,y,z,w)})
            barberSeats[seatCoords] = true
            TriggerClientEvent('vinBarber:client:receiveData', -1, sendBackData)
        else
            print(('[^6vinBarber^7] %s\'s (%s) attempted to parse something than a boolean value!'):format(xPlayer.getName(), xPlayer.identifier))
            return
        end
    else
        print(('[^6vinBarber^7] [^1WARNING^7] %s\'s (%s) Tried executing server event: "vinBarber:server:sendToChair" from run distance!'):format(xPlayer.getName(), xPlayer.identifier))
        return
    end
end)

ESX.RegisterServerCallback('vinBarber:checkAvailable', function(source, cb, seatCoords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer ~= nil then
        cb(barberSeats[seatCoords])
    else
        print('[^6vinBarber^7] [^1WARNING^7] xPlayer is nil!')
    end
end)

RegisterServerEvent('vinBarber:server:GetUpFromChair')
AddEventHandler('vinBarber:server:GetUpFromChair', function(seatCoords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer ~= nil then
        for k,v in pairs(barberSeats) do
            if barberSeats[seatCoords] ~= nil then
                barberSeats[src] = nil
                barberSeats[seatCoords] = nil
                sendBackData = {}
                TriggerClientEvent('vinBarber:client:receiveData', -1, sendBackData)
                print(('[^6vinBarber^7] [^2INFO^7] Clearing seat data for: %s\'s (%s).'):format(xPlayer.getName(), xPlayer.identifier))
            end
        end
    else
        print('[^6vinBarber^7] [^1WARNING^7] xPlayer is nil!')
    end
end)

RegisterServerEvent('vinBarber:server:changeHairData')
AddEventHandler('vinBarber:server:changeHairData', function(target, name, value)
    TriggerClientEvent('vinBarber:client:changeHairData', tonumber(target), name, value)
end)

RegisterServerEvent('vinBarber:server:cutHairAnim')
AddEventHandler('vinBarber:server:cutHairAnim', function(server_hairMenuData)
    TriggerClientEvent('vinBarber:client:cutHairAnim', source, server_hairMenuData)
end)

RegisterServerEvent('vinBarber:server:cutHairIdleAnim')
AddEventHandler('vinBarber:server:cutHairIdleAnim', function(server_cutHairIdleAnim)
    TriggerClientEvent('vinBarber:client:cutHairIdleAnim', source, server_cutHairIdleAnim)
end)

AddEventHandler('esx:playerDropped', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        if barberSeats[src] then
            barberSeats[src] = nil
            barberSeats[seatCoords] = nil
            sendBackData = {}
            print(('[^6vinBarber^7] [^2INFO^7] Dropping %s\'s with identifier (%s).'):format(xPlayer.getName(), xPlayer.identifier))
        end
    end
end)