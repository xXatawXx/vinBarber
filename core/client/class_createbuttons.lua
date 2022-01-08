Buttons = {}
function Buttons:createButtonData(scaleformdata)
    local btn = {}
    btn.enabled = nil
    btn.found = false
    btn.settings = scaleformdata
    self.__index = self
    return setmetatable(btn, self)
end

function Buttons:loadScaleForm(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    return scaleform
end

function Buttons:DrawScaleForm(scaleform, entry)
    local scaleform = self:loadScaleForm(scaleform)
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for i = 1, #entry do
        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(i-1)
        ScaleformMovieMethodAddParamPlayerNameString((GetControlInstructionalButton(2, entry[i].control, true)))
        BeginTextCommandScaleformString(entry[i].name)
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end
    
    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()
    return scaleform
end

local drawform = nil
local createButtons = Buttons:createButtonData({})
function Buttons:CreateButton(controlKeyName, controlKey, enabled)
    createButtons.enabled = enabled
    for i = 1, #createButtons do
        if createButtons[i].name == controlKeyName and createButtons[i].control == controlKey then
            createButtons.found = true
            if not createButtons.enabled then
                table.remove(createButtons, i)
                drawform = createButtons:DrawScaleForm("instructional_buttons", createButtons)
            end
            break
        end
    end
    if not createButtons.found then
        if createButtons.enabled then
            table.insert(createButtons, {name = controlKeyName, control = controlKey})
            drawform = createButtons:DrawScaleForm("instructional_buttons", createButtons)
        end
    end
end

local function formDraw()
    sleep = Config.drawCamButtonsTick
    if #createButtons > 0 then
        sleep = 0
        DrawScaleformMovieFullscreen(drawform, 255, 255, 255, 255, 0)
    else
        drawform = nil
    end
    SetTimeout(sleep, formDraw)
end
formDraw()