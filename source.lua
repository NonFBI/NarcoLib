-- NarcoEx UI Library (v1.1) - Original style + bluish-purple theme + widgets + save/load + draggable top bar
-- Load with: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NonFBI/NarcoLib/refs/heads/main/source.lua"))()

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.__index = UI

-- Colors
local ThemeColor = Color3.fromRGB(120, 90, 200) -- bluish-purple accent
local BackgroundColor = Color3.fromRGB(20, 20, 20)
local TopBarColor = Color3.fromRGB(30, 30, 30)
local TextColor = Color3.fromRGB(255, 255, 255)
local DisabledColor = Color3.fromRGB(90, 90, 90)

-- Tween helper
local function TweenObject(obj, prop, val, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop] = val}):Play()
end

-- Draggable topbar
local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos

    dragArea.InputBegan:Connect(function(input)
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

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(
                math.clamp(startPos.X.Scale,0,1),
                math.clamp(startPos.X.Offset + delta.X, 0, math.huge),
                math.clamp(startPos.Y.Scale,0,1),
                math.clamp(startPos.Y.Offset + delta.Y, 0, math.huge)
            )
        end
    end)
end

-- Save/load settings helpers
local function SaveSettings(key, data)
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(data)
        -- Save under PlayerGui for simplicity (local)
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        local storage = pg:FindFirstChild("NarcoExSettings")
        if not storage then
            storage = Instance.new("StringValue")
            storage.Name = "NarcoExSettings"
            storage.Parent = pg
        end
        storage.Value = json
    end)
    return success, err
end

local function LoadSettings(key)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local storage = pg:FindFirstChild("NarcoExSettings")
    if storage and storage.Value ~= "" then
        local success, data = pcall(function()
            return HttpService:JSONDecode(storage.Value)
        end)
        if success then return data end
    end
    return nil
end

-- Main UI constructor
function UI:New(title)
    local self = setmetatable({}, UI)

    self.Settings = {}
    self.Objects = {}

    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NarcoExUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    self.ScreenGui = ScreenGui

    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    self.MainFrame = MainFrame

    -- Top bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = TopBarColor
    TopBar.Parent = MainFrame
    self.TopBar = TopBar

    MakeDraggable(MainFrame, TopBar)

    -- Icon
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 4, 0.5, -16)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://10734895530" -- original icon
    Icon.Parent = TopBar

    -- Title label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "NarcoEx UI"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextColor3 = TextColor
    TitleLabel.Parent = TopBar
    self.TitleLabel = TitleLabel

    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = TextColor
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 22
    CloseButton.Parent = TopBar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Content frame (for widgets)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    self.ContentFrame = ContentFrame

    -- Left and right columns
    local LeftColumn = Instance.new("Frame")
    LeftColumn.Size = UDim2.new(0.5, -10, 1, 0)
    LeftColumn.Position = UDim2.new(0, 10, 0, 0)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ContentFrame
    self.LeftColumn = LeftColumn

    local RightColumn = Instance.new("Frame")
    RightColumn.Size = UDim2.new(0.5, -10, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 10, 0, 0)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ContentFrame
    self.RightColumn = RightColumn

    -- Internal storage for widgets, so save/load works
    self.WidgetValues = {}

    -- Load settings if available
    local saved = LoadSettings()
    if saved then
        self.WidgetValues = saved
    end

    return self
end

-- Utility to create a section label
function UI:CreateSection(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ThemeColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- Toggle Widget
function UI:Toggle(options)
    local parent = options.Parent or self.LeftColumn
    local label = options.Text or "Toggle"
    local default = options.Default or false
    local key = options.Key or label

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = BackgroundColor
    btn.BorderSizePixel = 0
    btn.TextColor3 = TextColor
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.Text = label .. ": OFF"
    btn.Parent = parent

    local toggled = self.WidgetValues[key] ~= nil and self.WidgetValues[key] or default
    local function updateState()
        btn.Text = label .. ": " .. (toggled and "ON" or "OFF")
        TweenObject(btn, "BackgroundColor3", toggled and ThemeColor or BackgroundColor, 0.3)
    end
    updateState()

    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        self.WidgetValues[key] = toggled
        updateState()
        if options.Callback then options.Callback(toggled) end
    end)

    return btn
end

-- Slider Widget
function UI:Slider(options)
    local parent = options.Parent or self.RightColumn
    local label = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local key = options.Key or label

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = TextColor
    title.Font = Enum.Font.Gotham
    title.TextSize = 16
    title.Text = label .. ": " .. tostring(default)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local barBack = Instance.new("Frame")
    barBack.Size = UDim2.new(1, 0, 0, 14)
    barBack.Position = UDim2.new(0, 0, 0, 30)
    barBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    barBack.BorderSizePixel = 0
    barBack.Parent = frame

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    barFill.BackgroundColor3 = ThemeColor
    barFill.BorderSizePixel = 0
    barFill.Parent = barBack

    local dragging = false

    barBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local function update(input2)
                local x = math.clamp(input2.Position.X - barBack.AbsolutePosition.X, 0, barBack.AbsoluteSize.X)
                local value = min + (x / barBack.AbsoluteSize.X) * (max - min)
                value = math.floor(value)
                barFill.Size = UDim2.new(x / barBack.AbsoluteSize.X, 0, 1, 0)
                title.Text = label .. ": " .. tostring(value)
                self.WidgetValues[key] = value
                if options.Callback then options.Callback(value) end
            end
            update(input)
            local conn
            conn = game:GetService("UserInputService").InputChanged:Connect(function(input2)
                if dragging and input2.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input2)
                else
                    conn:Disconnect()
                end
            end)
        end
    end)

    barBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Set initial saved value
    if self.WidgetValues[key] then
        local val = self.WidgetValues[key]
        local frac = (val - min) / (max - min)
        barFill.Size = UDim2.new(frac, 0, 1, 0)
        title.Text = label .. ": " .. tostring(val)
    end

    return frame
end

-- Button Widget
function UI:Button(options)
    local parent = options.Parent or self.LeftColumn
    local label = options.Text or "Button"
    local callback = options.Callback

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = ThemeColor
    btn.BorderSizePixel = 0
    btn.TextColor3 = TextColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = label
    btn.Parent = parent
    btn.AutoButtonColor = true

    btn.MouseButton1Click:Connect(function()
        TweenObject(btn, "BackgroundColor3", ThemeColor:lerp(Color3.new(1,1,1), 0.5), 0.1)
        wait(0.1)
        TweenObject(btn, "BackgroundColor3", ThemeColor, 0.3)
        if callback then
            callback()
        end
    end)

    return btn
end

-- Dropdown Widget
function UI:Dropdown(options)
    local parent = options.Parent or self.RightColumn
    local label = options.Text or "Dropdown"
    local items = options.Items or {}
    local default = options.Default or items[1]
    local key = options.Key or label

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = BackgroundColor
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local open = false
    local selected = self.WidgetValues[key] or default or (items[1] or nil)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -25, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = TextColor
    title.Font = Enum.Font.Gotham
    title.TextSize = 16
    title.Text = label .. ": " .. tostring(selected)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 25, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = TextColor
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16
    arrow.Parent = frame

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = BackgroundColor
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.Parent = frame

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = listFrame
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 2)

    local function closeDropdown()
        open = false
        TweenObject(listFrame, "Size", UDim2.new(1, 0, 0, 0), 0.3)
        arrow.Text = "▼"
    end
    local function openDropdown()
        open = true
        local totalHeight = 0
        for _, itemBtn in ipairs(listFrame:GetChildren()) do
            if itemBtn:IsA("TextButton") then
                totalHeight = totalHeight + itemBtn.AbsoluteSize.Y + 2
            end
        end
        TweenObject(listFrame, "Size", UDim2.new(1, 0, 0, totalHeight), 0.3)
        arrow.Text = "▲"
    end

    arrow.MouseButton1Click:Connect(function()
        if open then
            closeDropdown()
        else
            openDropdown()
        end
    end)

    for _, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = BackgroundColor
        btn.BorderSizePixel = 0
        btn.TextColor3 = TextColor
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 16
        btn.Text = tostring(item)
        btn.Parent = listFrame
        btn.AutoButtonColor = true

        btn.MouseButton1Click:Connect(function()
            selected = item
            self.WidgetValues[key] = selected
            title.Text = label .. ": " .. tostring(selected)
            if options.Callback then options.Callback(selected) end
            closeDropdown()
        end)
    end

    -- Set initial selection from saved value
    if self.WidgetValues[key] then
        title.Text = label .. ": " .. tostring(self.WidgetValues[key])
    end

    return frame
end

-- Keybind Widget
function UI:Keybind(options)
    local parent = options.Parent or self.LeftColumn
    local label = options.Text or "Keybind"
    local default = options.Default or Enum.KeyCode.LeftShift
    local key = options.Key or label

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = BackgroundColor
    btn.BorderSizePixel = 0
    btn.TextColor3 = TextColor
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = label .. ": " .. tostring(default.Name)
    btn.Parent = parent
    btn.AutoButtonColor = false

    local binding = self.WidgetValues[key] or default
    local waitingForInput = false

    local function updateText()
        btn.Text = label .. ": " .. tostring(binding.Name)
    end

    updateText()

    btn.MouseButton1Click:Connect(function()
        if waitingForInput then return end
        waitingForInput = true
        btn.Text = label .. ": Press a key..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                binding = input.KeyCode
                self.WidgetValues[key] = binding
                updateText()
                waitingForInput = false
                conn:Disconnect()
                if options.Callback then options.Callback(binding) end
            end
        end)
    end)

    return btn
end

-- Color Picker Widget
function UI:ColorPicker(options)
    local parent = options.Parent or self.RightColumn
    local label = options.Text or "Color"
    local default = options.Default or ThemeColor
    local key = options.Key or label

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = TextColor
    title.Font = Enum.Font.Gotham
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.Parent = frame

    local colorBox = Instance.new("Frame")
    colorBox.Size = UDim2.new(0, 30, 0, 30)
    colorBox.Position = UDim2.new(0.65, 0, 0.5, -15)
    colorBox.BackgroundColor3 = self.WidgetValues[key] or default
    colorBox.BorderSizePixel = 0
    colorBox.Parent = frame
    colorBox.ClipsDescendants = true
    colorBox.Active = true

    -- Color picker GUI popup
    local pickerGui = Instance.new("Frame")
    pickerGui.Size = UDim2.new(0, 200, 0, 150)
    pickerGui.Position = UDim2.new(0, 0, 1, 5)
    pickerGui.BackgroundColor3 = BackgroundColor
    pickerGui.BorderSizePixel = 0
    pickerGui.Visible = false
    pickerGui.Parent = frame

    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(0, 20, 1, 0)
    hueSlider.Position = UDim2.new(0, 170, 0, 0)
    hueSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hueSlider.Parent = pickerGui

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, 0, 0, 10)
    hueBar.Position = UDim2.new(0, 0, 0, 140)
    hueBar.BackgroundColor3 = BackgroundColor
    hueBar.BorderSizePixel = 0
    hueBar.Parent = pickerGui

    local colorPicker = Instance.new("ImageLabel")
    colorPicker.Size = UDim2.new(1, -30, 1, 0)
    colorPicker.BackgroundColor3 = Color3.new(1, 1, 1)
    colorPicker.Position = UDim2.new(0, 0, 0, 0)
    colorPicker.Image = "rbxassetid://4155801254" -- saturation/value square
    colorPicker.Parent = pickerGui
    colorPicker.ScaleType = Enum.ScaleType.Stretch

    local selector = Instance.new("Frame")
    selector.Size = UDim2.new(0, 10, 0, 10)
    selector.BackgroundColor3 = Color3.new(0, 0, 0)
    selector.BorderColor3 = Color3.new(1, 1, 1)
    selector.BorderSizePixel = 2
    selector.AnchorPoint = Vector2.new(0.5, 0.5)
    selector.Position = UDim2.new(0, 0, 0, 0)
    selector.Parent = colorPicker

    local hueSelector = Instance.new("Frame")
    hueSelector.Size = UDim2.new(1, 0, 0, 4)
    hueSelector.BackgroundColor3 = Color3.new(0, 0, 0)
    hueSelector.BorderSizePixel = 0
    hueSelector.AnchorPoint = Vector2.new(0.5, 0)
    hueSelector.Position = UDim2.new(0.5, 0, 0, 0)
    hueSelector.Parent = hueSlider

    local currentColor = self.WidgetValues[key] or default
    local currentHue = 0

    local function HSVtoRGB(h, s, v)
        local c = v * s
        local x = c * (1 - math.abs((h * 6) % 2 - 1))
        local m = v - c
        local r, g, b = 0, 0, 0

        if h < 1/6 then r, g, b = c, x, 0
        elseif h < 2/6 then r, g, b = x, c, 0
        elseif h < 3/6 then r, g, b = 0, c, x
        elseif h < 4/6 then r, g, b = 0, x, c
        elseif h < 5/6 then r, g, b = x, 0, c
        else r, g, b = c, 0, x
        end

        return Color3.new(r+m, g+m, b+m)
    end

    local function RGBtoHSV(color)
        local r, g, b = color.R, color.G, color.B
        local maxc = math.max(r, g, b)
        local minc = math.min(r, g, b)
        local delta = maxc - minc

        local h = 0
        if delta == 0 then h = 0
        elseif maxc == r then h = ((g - b) / delta) % 6 / 6
        elseif maxc == g then h = ((b - r) / delta + 2) / 6
        else h = ((r - g) / delta + 4) / 6
        end

        local s = (maxc == 0) and 0 or delta / maxc
        local v = maxc

        return h, s, v
    end

    local hue, sat, val = RGBtoHSV(currentColor)
    currentHue = hue

    local function updateHueSlider()
        hueSlider.BackgroundColor3 = HSVtoRGB(currentHue, 1, 1)
        local huePos = currentHue * hueSlider.AbsoluteSize.Y
        hueSelector.Position = UDim2.new(0, 0, currentHue, 0)
    end

    local function updateColorPicker()
        colorPicker.ImageColor3 = HSVtoRGB(currentHue, 1, 1)
    end

    local function updateSelectedColor(sx, sy)
        sat = math.clamp(sx, 0, 1)
        val = 1 - math.clamp(sy, 0, 1)
        currentColor = HSVtoRGB(currentHue, sat, val)
        colorBox.BackgroundColor3 = currentColor
        self.WidgetValues[key] = currentColor
        if options.Callback then options.Callback(currentColor) end
    end

    -- Set initial color
    colorBox.BackgroundColor3 = currentColor
    updateHueSlider()
    updateColorPicker()

    -- Input handling for color picker area
    local draggingColorPicker = false
    colorPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColorPicker = true
            local function updatePos(pos)
                local relative = colorPicker.AbsolutePosition
                local x = pos.X - relative.X
                local y = pos.Y - relative.Y
                updateSelectedColor(x / colorPicker.AbsoluteSize.X, y / colorPicker.AbsoluteSize.Y)
            end
            updatePos(input.Position)
            local conn
            conn = UserInputService.InputChanged:Connect(function(input2)
                if draggingColorPicker and input2.UserInputType == Enum.UserInputType.MouseMovement then
                    updatePos(input2.Position)
                else
                    conn:Disconnect()
                end
            end)
        end
    end)
    colorPicker.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingColorPicker = false
        end
    end)

    -- Input handling for hue slider
    local draggingHue = false
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            local function updateHue(pos)
                local relative = hueSlider.AbsolutePosition
                local y = pos.Y - relative.Y
                currentHue = math.clamp(y / hueSlider.AbsoluteSize.Y, 0, 1)
                updateHueSlider()
                updateColorPicker()
                updateSelectedColor(sat, val)
            end
            updateHue(input.Position)
            local conn
            conn = UserInputService.InputChanged:Connect(function(input2)
                if draggingHue and input2.UserInputType == Enum.UserInputType.MouseMovement then
                    updateHue(input2.Position)
                else
                    conn:Disconnect()
                end
            end)
        end
    end)
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)

    -- Toggle picker visibility on colorBox click
    colorBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerGui.Visible = not pickerGui.Visible
        end
    end)

    return frame
end

-- Save all current widget values
function UI:Save()
    local success, err = SaveSettings("NarcoExUI", self.WidgetValues)
    if not success then
        warn("Failed to save settings:", err)
    end
end

-- Load settings into widgets (called automatically on init)
function UI:Load()
    local saved = LoadSettings("NarcoExUI")
    if saved then
        self.WidgetValues = saved
    end
end

-- Example usage function to demonstrate all widgets
function UI:Example()
    -- Section labels
    self:CreateSection(self.LeftColumn, "Player Settings")
    local godToggle = self:Toggle({
        Text = "God Mode",
        Default = false,
        Key = "GodMode",
        Callback = function(v) print("GodMode:", v) end
    })

    local sprintKeybind = self:Keybind({
        Text = "Sprint Key",
        Default = Enum.KeyCode.LeftShift,
        Key = "SprintKey",
        Callback = function(k) print("Sprint Keybind set to:", k.Name) end
    })

    self:CreateSection(self.RightColumn, "Movement Settings")
    local walkSpeedSlider = self:Slider({
        Text = "Walk Speed",
        Min = 16,
        Max = 100,
        Default = 16,
        Key = "WalkSpeed",
        Callback = function(v) print("WalkSpeed:", v) end
    })

    local walkStyleDropdown = self:Dropdown({
        Text = "Walk Style",
        Items = {"Normal", "Sneak", "Run"},
        Default = "Normal",
        Key = "WalkStyle",
        Callback = function(v) print("WalkStyle:", v) end
    })

    local themeColorPicker = self:ColorPicker({
        Text = "Theme Color",
        Default = ThemeColor,
        Key = "ThemeColor",
        Callback = function(c)
            ThemeColor = c
            -- Update colors on UI elements as needed here (not automated in this example)
        end
    })

    -- Reset button
    self:Button({
        Text = "Reset Settings",
        Parent = self.LeftColumn,
        Callback = function()
            self.WidgetValues = {}
            godToggle.Text = "God Mode: OFF"
            walkSpeedSlider:FindFirstChildOfClass("TextLabel").Text = "Walk Speed: 16"
            walkStyleDropdown:FindFirstChildOfClass("TextLabel").Text = "Walk Style: Normal"
            sprintKeybind.Text = "Sprint Key: LeftShift"
            themeColorPicker:FindFirstChildOfClass("TextLabel").Text = "Theme Color"
            self:Save()
            print("Settings reset!")
        end
    })

    -- Save button
    self:Button({
        Text = "Save Settings",
        Parent = self.RightColumn,
        Callback = function()
            self:Save()
            print("Settings saved!")
        end
    })
end

return UI
