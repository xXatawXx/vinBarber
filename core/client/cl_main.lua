ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(250)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(250)
    end

    PlayerData = ESX.GetPlayerData()
end)
---------------------------
    -- Variables --
---------------------------
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(newJob)
    PlayerData.job = newJob
    Citizen.Wait(5000)
end)

local barberData = {}
Data = {
    Player = {
        LocalPlayer = PlayerPedId(),
        Sitting = false,
        sittingPosition = {},
        sittingDict = "misshair_shop@barbers",
        sittingAnim = "customer_tutorial_base",
        outroDict = "misshair_shop@barbers",
        outroAnim = "customer_intro",
        barberDict = "misshair_shop@hair_dressers",
        barberAnim = "keeper_hair_cut_a",
        barberIdleDict = "misshair_shop@hair_dressers",
        barberIdleAnim = "keeper_idle_a",
        barberScissors = "prop_cs_scissors",
        cuttingHair = false,
        disableX = false,
    },
    Camera = {
        Begin = false,
        CamRot = false,
        SpawnCamera = false,
        cameraSide = 'front',
        cameraObject = nil,
        cameraThread = false,
    },
    Debug = {
        debug = Config.debug,
        drawTxt = function(x,y, text) -- Draw Text function
            SetTextFont(4)
            SetTextScale(0.4,0.4)
            SetTextColour(255, 0, 0, 255)
            SetTextDropShadow(0, 0, 0, 0,15)
            SetTextEdge(2, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(1)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandDisplayText(x, y)
        end,
    }
}

---------------------------
    -- Threads --
---------------------------
Citizen.CreateThread(function()
    Utils.AddBlip(Config.hairCutBlip, 71, 0, "Barbershop")
    while true do
        local sleep = Config.playerSeatTick
        Data.Player.LocalPlayer = PlayerPedId()
        if Data.Player.disableX then
            DisableControlAction(1, 73, true) -- Disables X
        end

        if Data.Player.Sitting and not IsEntityPlayingAnim(Data.Player.LocalPlayer, Data.Player.sittingDict, Data.Player.sittingAnim, 3) then
            TriggerEvent('vinBarber:client:GetUpFromChair')
        end
        
        for i = 1, #Config.barberChairs do
            local chairLocations = Config.barberChairs[i]
            if #(GetEntityCoords(Data.Player.LocalPlayer) - vector3(chairLocations.x, chairLocations.y, chairLocations.z)) <= 1.0  and not Data.Player.Sitting then
                sleep = 5
                Utils.DrawText3Ds(vector3(chairLocations.x, chairLocations.y, chairLocations.z), Strings.playerinfo['player_info'], Strings.playerinfo['scale'], Strings.playerinfo['color'], Strings.playerinfo['rectBox'])
                if IsControlJustReleased(0, 38) then
                    if Data.Player.Sitting then
                        TriggerEvent('vinBarber:client:GetUpFromChair')
                    else
                        if i then
                            TriggerEvent('vinBarber:client:sendToChair', chairLocations)
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = Config.workerSeatTick
        for j = 1, #barberData do
            local fromServerData = barberData[j]
            if j then
                if #(GetEntityCoords(Data.Player.LocalPlayer) - vector3(fromServerData.coords.x+1.18, fromServerData.coords.y-0.95, fromServerData.coords.z)) < 1.0 and not Data.Player.cuttingHair and PlayerData.job.name == "barber" then
                    local playerId = GetPlayerFromServerId(tonumber(fromServerData.playerId))
                    Utils.DrawText3Ds(vector3(fromServerData.coords.x+1.18, fromServerData.coords.y-0.95, fromServerData.coords.z), Strings.barberinfo['barber_info'], Strings.barberinfo['scale'], Strings.barberinfo['color'], Strings.barberinfo['rectBox'])
                    sleep = 5
                    if IsControlJustReleased(0, 38) and fromServerData.seated == true then
                        if GetPlayerServerId(playerId) then
                            hairMenu(fromServerData, GetPlayerServerId(playerId))
                            TriggerServerEvent('vinBarber:server:cutHairIdleAnim', fromServerData)
                        end
                    end
                end
                break
            end
        end
        Wait(sleep)
    end
end)

---------------------------
    -- Event Handlers --
---------------------------
RegisterNetEvent('vinBarber:client:receiveData')
AddEventHandler('vinBarber:client:receiveData', function(_receivedBarberData)
    barberData = _receivedBarberData
end)

RegisterNetEvent('vinBarber:client:sendToChair')
AddEventHandler('vinBarber:client:sendToChair', function(seatData)
    ESX.TriggerServerCallback('vinBarber:checkAvailable', function(seatTaken)
        if seatTaken then
            Config.Notify('error', 'Seat is taken')
        else
            Data.Player.disableX = true
            AddTextEntry("ARROW_UP", Strings['arrow_up'])
            AddTextEntry("ARROW_DOWN", Strings['arrow_down'])
            AddTextEntry("ARROW_LEFT", Strings['arrow_left'])
            AddTextEntry("ARROW_RIGHT", Strings['arrow_right'])
            DoScreenFadeOut(1000)
            Wait(1000)
            Data.Player.sittingPosition = seatData
            SetEntityCoords(Data.Player.LocalPlayer, seatData.x, seatData.y, seatData.z)
            SetEntityHeading(Data.Player.LocalPlayer, seatData.w)
            seatOffset = GetOffsetFromEntityInWorldCoords(Data.Player.LocalPlayer, 0.0, 0 - 0.5, -0.5)
            Utils.loadAnimDict(Data.Player.sittingDict)
            TaskPlayAnimAdvanced(Data.Player.LocalPlayer, Data.Player.sittingDict, Data.Player.sittingAnim, seatOffset.x, seatOffset.y, seatOffset.z, 0.0, 0.0, seatData.w, 8.0, -1.0, -1, 47, 0.0, 0, 0)
            FreezeEntityPosition(Data.Player.LocalPlayer, true)
            Wait(1000)
            DoScreenFadeIn(3000)
            TriggerServerEvent('vinBarber:server:sendToChair', seatData, true)
            Wait(500)
            Data.Player.Sitting = true
            Data.Camera.Begin = true
            Data.Camera.cameraThread = true
            HandleCamera()
        end
    end, seatData)
end)

RegisterNetEvent('vinBarber:client:GetUpFromChair')
AddEventHandler('vinBarber:client:GetUpFromChair', function()
    Data.Player.disableX = false
    Data.Camera.cameraObject = nil
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(Data.Camera.cameraObject, false)
    Utils.loadAnimDict(Data.Player.outroDict)
    TaskPlayAnimAdvanced(Data.Player.LocalPlayer, Data.Player.outroDict, Data.Player.outroAnim, Data.Player.sittingPosition.x+0.25, Data.Player.sittingPosition.y+0.1, Data.Player.sittingPosition.z-0.1, 0.0, 0.0, Data.Player.sittingPosition.w, 8.0, -1.0, -1, 47, 0.0, 0, 0)
    FreezeEntityPosition(Data.Player.LocalPlayer, false)
    Wait(3000)
    ClearPedTasks(Data.Player.LocalPlayer)
    TriggerServerEvent('vinBarber:server:GetUpFromChair', Data.Player.sittingPosition)
    Data.Player.sittingPosition = nil
    Data.Player.Sitting = false
    Data.Camera.Begin = false
    Data.Camera.cameraThread = false
    barberData = {}
    Wait(500)
end)

RegisterNetEvent('vinBarber:client:cutHairAnim')
AddEventHandler('vinBarber:client:cutHairAnim', function(_hairMenuData)
    FreezeEntityPosition(Data.Player.LocalPlayer, false)
    local obj = CreateObject(GetHashKey(Data.Player.barberScissors), GetEntityCoords(Data.Player.LocalPlayer), true, true, true)
    SetEntityCoords(Data.Player.LocalPlayer, _hairMenuData.coords.x+0.70, _hairMenuData.coords.y-0.50, _hairMenuData.coords.z-0.50)
    SetEntityHeading(Data.Player.LocalPlayer, _hairMenuData.coords.w)
    Utils.loadAnimDict(Data.Player.barberDict)
    AttachEntity(obj)
    while IsEntityAttachedToEntity(obj, Data.Player.LocalPlayer) do
        Citizen.Wait(5)

        if not IsEntityPlayingAnim(Data.Player.LocalPlayer, Data.Player.barberDict, Data.Player.barberAnim, 3) then
            Utils.PlayAnim(Data.Player.LocalPlayer, Data.Player.barberDict, Data.Player.barberAnim, 1.0, -1.0, -1, 47, 0.0, 0, 0, 0)
            Wait(10000)
            DeleteEntity(obj)
            DeleteObject(obj)
            DetachEntity(obj)
            ClearPedTasks(Data.Player.LocalPlayer)
            Data.Player.cuttingHair = false
        end
    end
end)

RegisterNetEvent('vinBarber:client:cutHairIdleAnim')
AddEventHandler('vinBarber:client:cutHairIdleAnim', function(_cutHairIdleAnim)
    Data.Player.cuttingHair = true
    FreezeEntityPosition(Data.Player.LocalPlayer, true)
    SetEntityCoords(Data.Player.LocalPlayer, _cutHairIdleAnim.coords.x+0.60, _cutHairIdleAnim.coords.y-0.70, _cutHairIdleAnim.coords.z-0.50)
    SetEntityHeading(Data.Player.LocalPlayer, _cutHairIdleAnim.coords.w)
    Utils.loadAnimDict(Data.Player.barberIdleDict)
    if not IsEntityPlayingAnim(Data.Player.LocalPlayer, Data.Player.barberIdleDict, Data.Player.barberIdleAnim, 3) then
        Utils.PlayAnim(Data.Player.LocalPlayer, Data.Player.barberIdleDict, Data.Player.barberIdleAnim, 1.0, -1.0, -1, 47, 0.0, 0, 0, 0)
    end
end)

RegisterNetEvent('vinBarber:client:changeHairData')
AddEventHandler('vinBarber:client:changeHairData', function(name, value)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        if name ~= nil and value ~= nil then
            TriggerEvent('skinchanger:change', name, value)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('esx_skin:save', skin)
            end)
        end
    end)
end)

---------------------------
    -- Functions --
---------------------------
hairMenu = function(hairMenuData, player)
    local closestPlayer, closestPlayerDistance = Utils.GetClosestPlayer()
    if closestPlayer ~= GetPlayerServerId(PlayerId()) then
        if closestPlayer == GetPlayerFromServerId(tonumber(player)) then
            local currentElements = {}
            TriggerEvent('skinchanger:getData', function(components, getMaxValues)
                for k,v in pairs(components) do
                    local componentsMatch = {"hair_1", "hair_2", "hair_color_1", "hair_color_2"}
                    for i,values in pairs(componentsMatch) do
                        if values == v.name then
                            local componentName = components[k].name
                            local value = components[k].value
                            local componentId = components[k].componentId

                            if componentId == 0 then
                                value = GetPedPropIndex(GetPlayerPed(player), components[k].componentId)
                            end
                            
                            if componentName == values then
                                local newData = {
                                    label = components[k].label,
                                    name = components[k].name,
                                    value = value,
                                    min = components[k].min,
                                    textureof = components[k].textureof,
                                    type = 'slider',
                                }
                                
                                for key2,values2 in pairs(getMaxValues) do
                                    if key2 == components[k].name then
                                        newData.max = values2
                                        break
                                    end
                                end
                                table.insert(currentElements, newData)
                            end
                        end
                    end
                end
            end)
            
            ESX.UI.Menu.CloseAll()
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'barber_menu', {
                title = 'Barber Menu',
                align = 'right',
                elements = currentElements
            }, function(newData, menu)
                menu.close()
                TriggerServerEvent('vinBarber:server:cutHairAnim', hairMenuData)
                ESX.UI.Menu.CloseAll()
            end, function(newData, menu)
                menu.close()
                Data.Player.cuttingHair = false
                FreezeEntityPosition(Data.Player.LocalPlayer, false)
                ClearPedTasks(Data.Player.LocalPlayer)
            end, function(newData, menu)
                
                local playerSkin, playerCurrentComp, playerGetMaxValues
                TriggerEvent('skinchanger:getSkin', function(getPlayerSkin)
                    playerSkin = getPlayerSkin
                end)
                
                if playerSkin[newData.current.name] ~= newData.current.value then
                    TriggerServerEvent('vinBarber:server:changeHairData', tonumber(player), newData.current.name, newData.current.value)
                    TriggerEvent('skinchanger:getData', function(components, maxValues)
                        playerCurrentComp, playerGetMaxValues = components, maxValues
                    end)
                    
                    local generateNewData = {}
                    
                    for k,v in pairs(currentElements) do
                        generateNewData = {}
                        generateNewData.max = playerGetMaxValues[v.name]
                        
                        if v.textureof ~= nil and newData.current.name == v.textureof then
                            generateNewData.value = 0
                        end 
                        menu.update( {name = v.name} , generateNewData)
                    end
                    menu.refresh()
                end
            end, function(newData, menu)
            end)
        end
    end
end

HandleCamera = function()
    CreateThread(function()
        while Data.Camera.cameraThread do
            Wait(0)
            if Data.Camera.Begin then
                if IsControlJustPressed(0, 74) then
                    createTheseButtons = Buttons:createButtonData({})
                    Data.Player.Sitting = false
                    Data.Camera.CamRot = true
                    Data.Camera.SpawnCam = true
                    Data.Camera.cameraSide = 'front'
                    createTheseButtons:CreateButton("ARROW_LEFT", 189, true)
                    createTheseButtons:CreateButton("ARROW_RIGHT", 190, true)
                    createTheseButtons:CreateButton("ARROW_DOWN", 187, true)
                    createTheseButtons:CreateButton("ARROW_UP", 188, true)
                elseif IsControlJustPressed(0, 177) then
                    Data.Player.Sitting = false
                    Data.Camera.CamRot = false
                    Data.Camera.SpawnCam = false
                    TriggerEvent('vinBarber:client:GetUpFromChair')
                    if createTheseButtons ~= nil then
                        createTheseButtons:CreateButton("ARROW_LEFT", 189, false)
                        createTheseButtons:CreateButton("ARROW_RIGHT", 190, false)
                        createTheseButtons:CreateButton("ARROW_DOWN", 187, false)
                        createTheseButtons:CreateButton("ARROW_UP", 188, false)
                    else
                        Config.Notify('inform', 'No camera buttons to be removed.')
                    end
                end
                if Data.Camera.SpawnCam then
                    RenderScriptCams(false, false, 0, 1, 0)
                    DestroyCam(Data.Camera.cameraObject, false)
                    if not DoesCamExist(Data.Camera.cameraObject) then
                        if Data.Camera.cameraSide == 'front' then
                            Data.Camera.cameraObject = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Data.Player.sittingPosition.x-0.45, Data.Player.sittingPosition.y+0.15, Data.Player.sittingPosition.z+1.0, 0.0, 0.0, 250.00, 65.0, false, 0)
                        elseif Data.Camera.cameraSide == 'down' then
                            Data.Camera.cameraObject = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Data.Player.sittingPosition.x+0.90, Data.Player.sittingPosition.y-0.30, Data.Player.sittingPosition.z+1.0, 0.0, 0.0, -290.00, 65.0, false, 0)
                        elseif Data.Camera.cameraSide == 'right' then
                            Data.Camera.cameraObject = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Data.Player.sittingPosition.x+0.20, Data.Player.sittingPosition.y-0.85, Data.Player.sittingPosition.z+1.0, 0.0, 0.0, -20.0, 65.0, false, 0)
                        elseif Data.Camera.cameraSide == 'left' then
                            Data.Camera.cameraObject = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Data.Player.sittingPosition.x+0.70, Data.Player.sittingPosition.y+0.60, Data.Player.sittingPosition.z+1.0, 0.0, 0.0, 160.0, 65.0, false, 0)
                        end
                        SetCamActive(Data.Camera.cameraObject, true)
                        RenderScriptCams(true, false, 0, 1, 0)
                    end
                end
                if Data.Camera.CamRot then
                    if IsControlJustPressed(0, 188) then
                        Data.Camera.cameraSide = 'front'
                    elseif IsControlJustPressed(0, 187) then
                        Data.Camera.cameraSide = 'down'
                    elseif IsControlJustPressed(0, 190) then
                        Data.Camera.cameraSide = 'right'
                    elseif IsControlPressed(0, 189) then
                        Data.Camera.cameraSide = 'left'
                    end
                end
            end
        end
    end)
end

AttachEntity = function(entity)
    AttachEntityToEntity(entity, Data.Player.LocalPlayer, GetPedBoneIndex(Data.Player.LocalPlayer, 28422), -0.025, -0.003, 0.005, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
end