-- NarcoLib UI Library v1.2
-- Original style, draggable top bar, bluish-purple theme
-- Supports toggles, sliders, buttons, dropdowns, keybinds, color pickers
-- Saves & loads settings automatically

local UI = {}
UI.__index = UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local SETTINGS_STORE_NAME = "NarcoLibSettings"

local function tweenGui(gui, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, direction)
    local tween = TweenService:Create(gui, tweenInfo, props)
    tween:Play()
    return tween
end

local function createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

local function createLabel(text, size, parent)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = size or UDim2.new(1, 0, 0, 20)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Text = text or ""
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeDraggable(frame, dragTarget)
    dragTarget = dragTarget or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        frame.Position = newPos
    end

    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragTarget.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function createToggle(text, parent, accentColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
    btn.AutoButtonColor = false
    createUICorner(btn)
    btn.Text = ""
    btn.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 235, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 24, 0, 24)
    circle.Position = UDim2.new(1, -34, 0.5, -12)
    circle.BackgroundColor3 = Color3.fromRGB(100, 80, 180)
    circle.BorderSizePixel = 0
    createUICorner(circle, UDim.new(1,0))
    circle.Parent = btn

    local toggled = false
    local tweenOn = tweenGui(circle, {BackgroundColor3 = accentColor or Color3.fromRGB(140, 100, 255)}, 0.25)
    local tweenOff = tweenGui(circle, {BackgroundColor3 = Color3.fromRGB(100, 80, 180)}, 0.25)
    tweenOff:Pause()
    tweenOn:Pause()

    local function setState(state)
        toggled = state
        if toggled then
            tweenOn:Play()
            tweenOff:Pause()
        else
            tweenOff:Play()
            tweenOn:Pause()
        end
    end

    btn.MouseButton1Click:Connect(function()
        setState(not toggled)
        if btn._callback then
            btn._callback(toggled)
        end
    end)

    function btn:Set(value)
        setState(value == true)
    end

    function btn:Get()
        return toggled
    end

    function btn:OnChanged(callback)
        btn._callback = callback
    end

    return btn
end

local function createSlider(text, parent, min, max, default, accentColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = createLabel(text .. ": " .. tostring(default), UDim2.new(1, 0, 0, 20), frame)
    label.Position = UDim2.new(0, 0, 0, 0)

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Position = UDim2.new(0, 0, 0, 24)
    sliderFrame.Size = UDim2.new(1, 0, 0, 18)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 55, 140)
    createUICorner(sliderFrame)
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = accentColor or Color3.fromRGB(140, 100, 255)
    createUICorner(fill)
    fill.Parent = sliderFrame

    local dragging = false
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local function updateSlider(input2)
                local relativeX = math.clamp(input2.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                local value = min + (max - min) * (relativeX / sliderFrame.AbsoluteSize.X)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. math.floor(value * 100) / 100
                if frame._callback then
                    frame._callback(value)
                end
            end
            updateSlider(input)
            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(input3)
                if dragging and input3 == input then
                    updateSlider(input3)
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(input4)
                if input4 == input then
                    dragging = false
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)

    function frame:Set(value)
        value = math.clamp(value, min, max)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. math.floor(value * 100) / 100
    end

    function frame:Get()
        local frac = fill.Size.X.Scale
        return min + frac * (max - min)
    end

    function frame:OnChanged(callback)
        frame._callback = callback
    end

    return frame
end

local function createButton(text, parent, accentColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = accentColor or Color3.fromRGB(120, 90, 230)
    btn.TextColor3 = Color3.fromRGB(245, 245, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    createUICorner(btn)
    btn.Parent = parent

    function btn:OnClick(callback)
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

local function createDropdown(text, parent, options, accentColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
    createUICorner(frame)
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local arrow = Instance.new("TextLabel")
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(200, 180, 255)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 18
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0.15, 0, 1, 0)
    arrow.Position = UDim2.new(0.85, 0, 0, 0)
    arrow.Parent = frame

    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(60, 50, 130)
    optionsFrame.ClipsDescendants = true
    createUICorner(optionsFrame)
    optionsFrame.Position = UDim2.new(0, 0, 1, 2)
    optionsFrame.Parent = frame

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = optionsFrame

    local opened = false

    local function closeDropdown()
        tweenGui(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
        tweenGui(arrow, {Rotation = 0}, 0.25)
        opened = false
    end

    local function openDropdown()
        local targetSize = math.min(#options * 28, 140)
        tweenGui(optionsFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.25)
        tweenGui(arrow, {Rotation = 180}, 0.25)
        opened = true
    end

    local selectedValue = nil

    local function selectOption(value)
        selectedValue = value
        label.Text = text .. ": " .. value
        closeDropdown()
        if frame._callback then
            frame._callback(value)
        end
    end

    for i, v in ipairs(options) do
        local opt = Instance.new("TextButton")
        opt.Text = v
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.BackgroundColor3 = Color3.fromRGB(100, 90, 170)
        opt.BorderSizePixel = 0
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 14
        opt.TextColor3 = Color3.fromRGB(230, 230, 255)
        opt.Parent = optionsFrame

        opt.MouseEnter:Connect(function()
            tweenGui(opt, {BackgroundColor3 = Color3.fromRGB(130, 120, 210)}, 0.15)
        end)

        opt.MouseLeave:Connect(function()
            tweenGui(opt, {BackgroundColor3 = Color3.fromRGB(100, 90, 170)}, 0.15)
        end)

        opt.MouseButton1Click:Connect(function()
            selectOption(v)
        end)
    end

    frame.MouseButton1Click:Connect(function()
        if opened then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    function frame:Set(value)
        for _, v in ipairs(options) do
            if v == value then
                selectedValue = v
                label.Text = text .. ": " .. v
                return
            end
        end
    end

    function frame:Get()
        return selectedValue
    end

    function frame:OnChanged(callback)
        frame._callback = callback
    end

    return frame
end

local function createKeybind(text, parent, accentColor)
    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(90, 70, 180)
    createUICorner(frame)
    frame.TextColor3 = Color3.fromRGB(240, 240, 255)
    frame.Font = Enum.Font.GothamBold
    frame.TextSize = 16
    frame.Text = text .. ": NONE"
    frame.Parent = parent

    local waitingForKey = false
    local keyBound = nil

    local function updateText()
        frame.Text = text .. ": " .. (keyBound and tostring(keyBound) or "NONE")
    end

    frame.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        frame.Text = text .. ": PRESS KEY..."

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyBound = input.KeyCode.Name
                updateText()
                waitingForKey = false
                conn:Disconnect()
                if frame._callback then
                    frame._callback(keyBound)
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                keyBound = input.UserInputType.Name
                updateText()
                waitingForKey = false
                conn:Disconnect()
                if frame._callback then
                    frame._callback(keyBound)
                end
            end
        end)
    end)

    function frame:Set(value)
        keyBound = value
        updateText()
    end

    function frame:Get()
        return keyBound
    end

    function frame:OnChanged(callback)
        frame._callback = callback
    end

    return frame
end

local function createColorPicker(text, parent, defaultColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = createLabel(text, UDim2.new(1, 0, 0, 20), frame)
    label.Position = UDim2.new(0, 0, 0, 0)

    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, 0, 0, 36)
    pickerFrame.Position = UDim2.new(0, 0, 0, 24)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(70, 55, 140)
    createUICorner(pickerFrame)
    pickerFrame.Parent = frame

    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 36, 0, 36)
    colorPreview.Position = UDim2.new(0, 4, 0, 0)
    colorPreview.BackgroundColor3 = defaultColor or Color3.fromRGB(140, 100, 255)
    colorPreview.BorderSizePixel = 0
    createUICorner(colorPreview)
    colorPreview.Parent = pickerFrame

    local hue = 0.7
    local sat = 0.8
    local val = 0.8

    local function HSVtoRGB(h, s, v)
        local c = v * s
        local x = c * (1 - math.abs(((h * 6) % 2) - 1))
        local m = v - c
        local r, g, b
        if h < 1/6 then
            r, g, b = c, x, 0
        elseif h < 2/6 then
            r, g, b = x, c, 0
        elseif h < 3/6 then
            r, g, b = 0, c, x
        elseif h < 4/6 then
            r, g, b = 0, x, c
        elseif h < 5/6 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end
        return Color3.new(r+m, g+m, b+m)
    end

    local function updatePreview()
        colorPreview.BackgroundColor3 = HSVtoRGB(hue, sat, val)
        if frame._callback then
            frame._callback(colorPreview.BackgroundColor3)
        end
    end

    local function onClick()
        -- Open simple hue slider popup (basic)
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 250, 0, 150)
        popup.Position = UDim2.new(0.5, -125, 0.5, -75)
        popup.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
        popup.BorderSizePixel = 0
        popup.ZIndex = 10
        createUICorner(popup, UDim.new(0, 10))
        popup.Parent = frame.Parent.Parent -- Main UI frame

        -- Close on outside click
        local bg = Instance.new("TextButton")
        bg.BackgroundTransparency = 1
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.ZIndex = 9
        bg.Parent = popup.Parent
        bg.MouseButton1Click:Connect(function()
            popup:Destroy()
            bg:Destroy()
        end)

        -- Hue slider bar
        local hueSlider = Instance.new("Frame")
        hueSlider.Size = UDim2.new(1, -40, 0, 20)
        hueSlider.Position = UDim2.new(0, 20, 0, 30)
        hueSlider.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        hueSlider.BorderSizePixel = 0
        createUICorner(hueSlider)
        hueSlider.Parent = popup

        -- Hue gradient
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }
        grad.Parent = hueSlider

        -- Hue picker circle
        local huePicker = Instance.new("Frame")
        huePicker.Size = UDim2.new(0, 16, 0, 24)
        huePicker.Position = UDim2.new(hue, -8, 0, -2)
        huePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        huePicker.BorderColor3 = Color3.fromRGB(100, 100, 100)
        huePicker.BorderSizePixel = 2
        createUICorner(huePicker, UDim.new(1, 0))
        huePicker.Parent = hueSlider

        -- Sat/Val box
        local svBox = Instance.new("Frame")
        svBox.Size = UDim2.new(1, -40, 0, 100)
        svBox.Position = UDim2.new(0, 20, 0, 60)
        svBox.BackgroundColor3 = HSVtoRGB(hue, 1, 1)
        createUICorner(svBox)
        svBox.Parent = popup

        local svGradientSat = Instance.new("UIGradient")
        svGradientSat.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
        svGradientSat.Rotation = 0
        svGradientSat.Parent = svBox

        local svGradientVal = Instance.new("UIGradient")
        svGradientVal.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
        svGradientVal.Rotation = 270
        svGradientVal.Parent = svBox

        local pickerCircle = Instance.new("Frame")
        pickerCircle.Size = UDim2.new(0, 16, 0, 16)
        pickerCircle.Position = UDim2.new(sat, -8, 1 - val, -8)
        pickerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        pickerCircle.BorderColor3 = Color3.fromRGB(100, 100, 100)
        pickerCircle.BorderSizePixel = 2
        createUICorner(pickerCircle, UDim.new(1, 0))
        pickerCircle.Parent = svBox

        -- Update saturation and value on drag
        local draggingSV = false
        svBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = true
                UserInputService.MouseMoved:Connect(function()
                    if draggingSV then
                        local pos = UserInputService:GetMouseLocation()
                        local absPos = svBox.AbsolutePosition
                        local absSize = svBox.AbsoluteSize
                        local x = math.clamp(pos.X - absPos.X, 0, absSize.X) / absSize.X
                        local y = math.clamp(pos.Y - absPos.Y, 0, absSize.Y) / absSize.Y
                        sat = x
                        val = 1 - y
                        svBox.BackgroundColor3 = HSVtoRGB(hue, 1, 1)
                        pickerCircle.Position = UDim2.new(sat, -8, val, -8)
                        updatePreview()
                    end
                end)
            end
        end)
        svBox.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSV = false
            end
        end)

        -- Update hue on drag
        local draggingHue = false
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = true
                UserInputService.MouseMoved:Connect(function()
                    if draggingHue then
                        local pos = UserInputService:GetMouseLocation()
                        local absPos = hueSlider.AbsolutePosition
                        local absSize = hueSlider.AbsoluteSize
                        hue = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
                        huePicker.Position = UDim2.new(hue, -8, 0, -2)
                        svBox.BackgroundColor3 = HSVtoRGB(hue, 1, 1)
                        updatePreview()
                    end
                end)
            end
        end)
        hueSlider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = false
            end
        end)

        -- Close popup function on outside click already handled above

    end

    colorPreview.MouseButton1Click:Connect(onClick)
    colorPreview.Active = true

    function frame:Set(color)
        colorPreview.BackgroundColor3 = color or Color3.fromRGB(140, 100, 255)
        if frame._callback then
            frame._callback(colorPreview.BackgroundColor3)
        end
    end

    function frame:Get()
        return colorPreview.BackgroundColor3
    end

    function frame:OnChanged(callback)
        frame._callback = callback
    end

    return frame
end

-- SETTINGS SAVE/LOAD --

local function getSettingsFolder()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local folder = playerGui:FindFirstChild(SETTINGS_STORE_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = SETTINGS_STORE_NAME
        folder.Parent = playerGui
    end
    return folder
end

function UI:SaveSettings(settingsTable)
    local folder = getSettingsFolder()
    local json = HttpService:JSONEncode(settingsTable)
    local stored = folder:FindFirstChild("SettingsJSON")
    if not stored then
        stored = Instance.new("StringValue")
        stored.Name = "SettingsJSON"
        stored.Parent = folder
    end
    stored.Value = json
end

function UI:LoadSettings()
    local folder = getSettingsFolder()
    local stored = folder:FindFirstChild("SettingsJSON")
    if stored and stored.Value ~= "" then
        local success, data = pcall(function()
            return HttpService:JSONDecode(stored.Value)
        end)
        if success and type(data) == "table" then
            return data
        end
    end
    return {}
end

-- MAIN UI CREATION --

function UI:New(title)
    local self = setmetatable({}, UI)

    -- ScreenGui parent
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NarcoExUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui = ScreenGui

    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    self.MainFrame = MainFrame

    -- Topbar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame

    makeDraggable(MainFrame, TopBar)

    -- Title label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "NarcoEx"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Parent = TopBar

    -- Icon
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 4, 0.5, -16)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://10734895530" -- original icon
    Icon.Parent = TopBar

    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TopBar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Content frame (two columns)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    self.ContentFrame = ContentFrame

    local LeftColumn = Instance.new("Frame")
    LeftColumn.Size = UDim2.new(0.5, -10, 1, 0)
    LeftColumn.Position = UDim2.new(0, 10, 0, 0)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ContentFrame
    self.LeftColumn = LeftColumn

    local RightColumn = Instance.new("Frame")
    RightColumn.Size = UDim2.new(0.5, -10, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 0, 0, 0)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ContentFrame
    self.RightColumn = RightColumn

    -- Tabs container (dictionary of tabs)
    self.Tabs = {}

    -- Settings storage for Save/Load
    self._settings = self:LoadSettings() or {}

    return self
end

-- Adds a new tab frame; returns tab table with AddToggle, AddSlider etc methods
function UI:AddTab(name)
    local tab = {}
    tab.Name = name

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.Parent = self.ContentFrame
    tab.Frame = tabFrame

    -- Left and right columns inside tab
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0.5, -10, 1, 0)
    left.Position = UDim2.new(0, 10, 0, 0)
    left.BackgroundTransparency = 1
    left.Parent = tabFrame
    tab.LeftColumn = left

    local right = Instance.new("Frame")
    right.Size = UDim2.new(0.5, -10, 1, 0)
    right.Position = UDim2.new(0.5, 0, 0, 0)
    right.BackgroundTransparency = 1
    right.Parent = tabFrame
    tab.RightColumn = right

    -- Show the first tab by default
    if not next(self.Tabs) then
        tabFrame.Visible = true
    end

    self.Tabs[name] = tab

    -- Helper to save/load key for this tab
    local function saveKey(key, value)
        self._settings[key] = value
        self:SaveSettings(self._settings)
    end

    local function loadKey(key)
        return self._settings[key]
    end

    -- Create widgets for this tab --

    function tab:AddToggle(text, key)
        local toggle = createToggle(text, tab.LeftColumn, Color3.fromRGB(140, 100, 255))
        local saved = loadKey(key)
        if saved ~= nil then toggle:Set(saved) end
        toggle:OnChanged(function(val)
            saveKey(key, val)
        end)
        return toggle
    end

    function tab:AddSlider(text, min, max, default, key)
        local slider = createSlider(text, tab.RightColumn, min, max, default, Color3.fromRGB(140, 100, 255))
        local saved = loadKey(key)
        if saved ~= nil then slider:Set(saved) else slider:Set(default) end
        slider:OnChanged(function(val)
            saveKey(key, val)
        end)
        return slider
    end

    function tab:AddButton(text)
        local button = createButton(text, tab.LeftColumn, Color3.fromRGB(140, 100, 255))
        return button
    end

    function tab:AddDropdown(text, options, key)
        local dropdown = createDropdown(text, tab.RightColumn, options, Color3.fromRGB(140, 100, 255))
        local saved = loadKey(key)
        if saved then dropdown:Set(saved) end
        dropdown:OnChanged(function(val)
            saveKey(key, val)
        end)
        return dropdown
    end

    function tab:AddKeybind(text, key)
        local keybind = createKeybind(text, tab.LeftColumn, Color3.fromRGB(140, 100, 255))
        local saved = loadKey(key)
        if saved then keybind:Set(saved) end
        keybind:OnChanged(function(val)
            saveKey(key, val)
        end)
        return keybind
    end

    function tab:AddColorPicker(text, defaultColor, key)
        local colorpicker = createColorPicker(text, tab.RightColumn, defaultColor or Color3.fromRGB(140, 100, 255))
        local saved = loadKey(key)
        if saved then
            local c = saved
            if typeof(c) == "table" and c.R and c.G and c.B then
                colorpicker:Set(Color3.new(c.R, c.G, c.B))
            elseif typeof(c) == "Color3" then
                colorpicker:Set(c)
            end
        end
        colorpicker:OnChanged(function(val)
            saveKey(key, {R=val.R,G=val.G,B=val.B})
        end)
        return colorpicker
    end

    function tab:Show()
        for _, t in pairs(self.Parent.Tabs) do
            t.Frame.Visible = false
        end
        tabFrame.Visible = true
    end

    tab.Parent = self

    return tab
end

return UI
