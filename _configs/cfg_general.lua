---------------------------
    -- Configs --
---------------------------
--[[
Strings Tips:
rectBox: 'true' enables the text shadow box 
rectbox: 'false' disables the text shadow box
scale: Changing the number will determine how big/small the text will be and or scaled out as.
color: nil = no color, and you can use the gta 5 color codes instead, but if you enable it then keep in mind "~r~" color codes like this will be overlapped.
color = {r,g,b,a} 'a' = the alpha, or in other words, opacity.
--]]
Strings = {
    ['arrow_up'] = "Camera Front",
    ['arrow_down'] = "Camera Back",
    ['arrow_left'] = "Camera Left",
    ['arrow_right'] = "Camera Right",
    playerinfo = {
        ['player_info'] = 'Press [~r~E~w~] to sit.',
        scale = 0.3, 
        color = nil, 
        rectBox = false,
    },
    barberinfo = {
        ['barber_info'] = 'Press [~g~E~w~] to begin cutting their hair.', 
        scale = 0.3, 
        color = nil, 
        rectBox = false,
    },
}

--[[
You can replcae the function 'Config.Notify' with your notification function. 
--]]

Config = {
    debug = false,
    hairCutBlip = vector3(-32.81, -152.14, 57.08),
    barberChairs = {
        vector4(-34.67, -150.21, 56.56, 70.81),
        vector4(-35.17, -151.635, 56.56, 70.0)
    },
    drawCamButtonsTick = 2500,
    playerSeatTick = 1000,
    workerSeatTick = 5000,
    Notify = function(type, text)
        exports['mythic_notify']:SendAlert(type, text)
    end,
}
