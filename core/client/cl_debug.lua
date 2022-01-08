if Config.debug then
---------------------------
    -- Debug Settings --
---------------------------
RegisterCommand('sittingpos',function()
    -- for k,v in pairs(barberData) do 
        print(json.encode(vector3(Data.Player.sittingPosition.x, Data.Player.sittingPosition.y, Data.Player.sittingPosition.z)))
    -- end
end)

RegisterCommand('clientdata',function()
    for i=1, #barberData do
        print(json.encode(barberData[i]))
        print(json.encode(barberData[i].seated))
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         local sleep = 1000
--         if Data.Debug.debug then
--             sleep = 0
--         Data.Debug.drawTxt(0.70, 0.30, "\n~w~Debug Menu")
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n~w~Sitting Check : ~s~".. tostring(Data.Player.Sitting))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n~w~Sitting Position : ~s~".. tostring(json.encode(Data.Player.sittingPosition)))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n~w~Camera Object : ~s~".. tostring(json.encode(Data.Camera.cameraObject)))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n~w~Camera Rotation : ~s~".. tostring(Data.Camera.CamRot))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n~w~Can rotate cam : ~s~".. tostring(Data.Camera.cameraSide))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n~w~Spawn cam : ~s~".. tostring(Data.Camera.SpawnCam))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n\n~w~Begin cam : ~s~".. tostring(Data.Camera.Begin))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n\n\n~w~Cam Coords : ~s~".. tostring(GetCamCoord(Data.Camera.cameraObject)))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n\n\n\n~w~Cam Rotation : ~s~".. tostring(GetCamRot(Data.Camera.cameraObject, 2)))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n\n\n\n\n\n~w~Cutting Hair : ~s~".. tostring(Data.Player.cuttingHair))
--         Data.Debug.drawTxt(0.70, 0.30, "\n\n\n\n\n\n\n\n\n\n\n\n\n~w~Player Loaded : ~s~".. tostring(Data.Player.Loaded))
--         end
--         Citizen.Wait(sleep)
--     end
-- end)

RegisterCommand('tpbackhair', function()
    SetEntityCoords(Data.Player.LocalPlayer,-32.81, -152.14, 57.08)
end)

RegisterCommand('loadme', function(source, args, user)
    Data.Player.Loaded = not Data.Player.Loaded
end)

RegisterCommand('testclient', function(source)
    TriggerServerEvent('vinBarber:server:sendToChair', vector4(-34.67, -150.21, 56.56, 70.81), true)
end)
end