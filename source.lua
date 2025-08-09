-- NarcoEx UI Library (Original Style + Sliders/Toggles, Bluish‑Purple Theme)
-- Keeps original icon & close button, draggable top bar, two-column content layout
-- Provides Toggle, Slider, Button, and Dropdown (working) with smooth tweens

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UI = {}
UI.__index = UI

local THEME = {
    Background = Color3.fromRGB(20,20,20),
    Topbar = Color3.fromRGB(30,30,30),
    Panel = Color3.fromRGB(12,12,12),
    Accent = Color3.fromRGB(150, 120, 255), -- bluish purple
    AccentDark = Color3.fromRGB(110, 80, 230),
    Text = Color3.fromRGB(255,255,255)
}

local function tween(obj, props, dur)
    local info = TweenInfo.new(dur or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function UI:New(title, iconAssetId)
    local self = setmetatable({}, UI)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.Name = title or "NarcoEx"

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = THEME.Topbar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    TopBar.Active = true
    TopBar.Draggable = true

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "NarcoEx"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = THEME.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 4, 0.5, -16)
    Icon.BackgroundTransparency = 1
    Icon.Image = iconAssetId or "rbxassetid://119400389511179" -- keep original icon by default
    Icon.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = THEME.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TopBar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Content (two columns)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local LeftColumn = Instance.new("Frame")
    LeftColumn.Name = "Left"
    LeftColumn.Size = UDim2.new(0.5, 0, 1, 0)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ContentFrame

    local RightColumn = Instance.new("Frame")
    RightColumn.Name = "Right"
    RightColumn.Size = UDim2.new(0.5, 0, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 0, 0, 0)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ContentFrame

    -- helper factories for controls
    local function makeToggle(parent, text, default)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 220, 0, 40)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.TextColor3 = THEME.Text
        label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 64, 0, 32)
        btn.Position = UDim2.new(1, -72, 0.5, -16)
        btn.BackgroundColor3 = THEME.Panel
        btn.BorderSizePixel = 0
        btn.Parent = container
        local uic = Instance.new("UICorner") uic.CornerRadius = UDim.new(0,8) uic.Parent = btn

        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 26, 0, 26)
        handle.Position = UDim2.new(0, 4, 0.5, -13)
        handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
        handle.Parent = btn
        local handleC = Instance.new("UICorner") handleC.CornerRadius = UDim.new(0,13) handleC.Parent = handle

        local enabled = default and true or false
        -- initialize appearance
        if enabled then
            btn.BackgroundColor3 = THEME.Accent
            handle.Position = UDim2.new(1, -30, 0.5, -13)
        else
            btn.BackgroundColor3 = THEME.Panel
            handle.Position = UDim2.new(0, 4, 0.5, -13)
        end

        local event = Instance.new("BindableEvent")

        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            tween(btn, {BackgroundColor3 = enabled and THEME.Accent or THEME.Panel}, 0.15)
            tween(handle, {Position = enabled and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)}, 0.15)
            event:Fire(enabled)
        end)

        return container, {
            Get = function() return enabled end,
            Set = function(v)
                enabled = v and true or false
                btn.BackgroundColor3 = enabled and THEME.Accent or THEME.Panel
                handle.Position = enabled and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
                event:Fire(enabled)
            end,
            OnChange = function(fn) event.Event:Connect(fn) end
        }
    end

    local function makeSlider(parent, text, default, min, max, step)
        default = tonumber(default) or 0
        min = tonumber(min) or 0
        max = tonumber(max) or 100
        step = tonumber(step) or 1
        default = math.clamp(default, min, max)

        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 260, 0, 56)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextColor3 = THEME.Text
        label.Text = text .. " — " .. tostring(default)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local barBack = Instance.new("Frame")
        barBack.Size = UDim2.new(1, 0, 0, 16)
        barBack.Position = UDim2.new(0, 0, 0, 24)
        barBack.BackgroundColor3 = THEME.Panel
        barBack.BorderSizePixel = 0
        barBack.Parent = container
        local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0,8) bc.Parent = barBack

        local barFill = Instance.new("Frame")
        local frac = (default - min) / (max - min)
        barFill.Size = UDim2.new(frac, 0, 1, 0)
        barFill.BackgroundColor3 = THEME.Accent
        barFill.BorderSizePixel = 0
        barFill.Parent = barBack
        local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0,8) fc.Parent = barFill

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(frac, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.Parent = barBack
        local kc = Instance.new("UICorner") kc.CornerRadius = UDim.new(0,9) kc.Parent = knob

        local dragging = false
        local current = default
        local event = Instance.new("BindableEvent")

        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        knob.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        barBack.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                local posX = inp.Position.X - barBack.AbsolutePosition.X
                local t = math.clamp(posX / barBack.AbsoluteSize.X, 0, 1)
                local raw = min + (max - min) * t
                local stepped = math.round(raw / step) * step
                current = math.clamp(stepped, min, max)
                local frac = (current - min) / (max - min)
                tween(barFill, {Size = UDim2.new(frac, 0, 1, 0)}, 0.12)
                tween(knob, {Position = UDim2.new(frac, 0, 0.5, 0)}, 0.12)
                label.Text = text .. " — " .. tostring(current)
                event:Fire(current)
            end
        end)

        RunService.RenderStepped:Connect(function()
            if dragging then
                local m = game.Players.LocalPlayer:GetMouse()
                local posX = m.X - barBack.AbsolutePosition.X
                local t = math.clamp(posX / barBack.AbsoluteSize.X, 0, 1)
                local raw = min + (max - min) * t
                local stepped = math.round(raw / step) * step
                current = math.clamp(stepped, min, max)
                local frac = (current - min) / (max - min)
                barFill.Size = UDim2.new(frac, 0, 1, 0)
                knob.Position = UDim2.new(frac, 0, 0.5, 0)
                label.Text = text .. " — " .. tostring(current)
                event:Fire(current)
            end
        end)

        return container, {
            Get = function() return current end,
            Set = function(v)
                current = math.clamp(math.round(v/step)*step, min, max)
                local frac = (current - min) / (max - min)
                barFill.Size = UDim2.new(frac, 0, 1, 0)
                knob.Position = UDim2.new(frac, 0, 0.5, 0)
                label.Text = text .. " — " .. tostring(current)
                event:Fire(current)
            end,
            OnChange = function(fn) event.Event:Connect(fn) end
        }
    end

    local function makeButton(parent, text)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 220, 0, 36)
        btn.BackgroundColor3 = THEME.Accent
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.Text = text
        btn.TextColor3 = THEME.Text
        btn.TextSize = 16
        btn.Parent = parent
        local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,6) c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            tween(btn, {BackgroundTransparency = 0.6}, 0.08)
            task.delay(0.08, function()
                tween(btn, {BackgroundTransparency = 0}, 0.12)
            end)
        end)
        return btn
    end

    local function makeDropdown(parent, text, options, default)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 260, 0, 44)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextColor3 = THEME.Text
        label.Text = text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local box = Instance.new("TextButton")
        box.Size = UDim2.new(1, 0, 0, 24)
        box.Position = UDim2.new(0, 0, 0, 18)
        box.BackgroundColor3 = THEME.Panel
        box.BorderSizePixel = 0
        box.Parent = container
        local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0,6) bc.Parent = box

        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.Size = UDim2.new(0.8, -8, 1, 0)
        selectedLabel.Position = UDim2.new(0, 8, 0, 0)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.TextColor3 = THEME.Text
        selectedLabel.Font = Enum.Font.Gotham
        selectedLabel.TextSize = 14
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
        selectedLabel.Text = tostring(default or options[1] or "")
        selectedLabel.Parent = box

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0.2, -8, 1, 0)
        arrow.Position = UDim2.new(0.8, 0, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Font = Enum.Font.Gotham
        arrow.TextSize = 18
        arrow.Text = "▾"
        arrow.TextColor3 = THEME.Text
        arrow.Parent = box

        local list = Instance.new("Frame")
        list.Size = UDim2.new(1, 0, 0, 0)
        list.Position = UDim2.new(0, 0, 0, 42)
        list.BackgroundColor3 = THEME.Panel
        list.BorderSizePixel = 0
        list.Parent = container
        local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0,6) lc.Parent = list

        local layout = Instance.new("UIListLayout") layout.Padding = UDim.new(0,6) layout.Parent = list

        list.Visible = false

        local function showList()
            list.Visible = true
            local total = math.clamp(#options * 30 + 8, 0, 180)
            tween(list, {Size = UDim2.new(1, 0, 0, total)}, 0.16)
        end
        local function hideList()
            tween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
            task.delay(0.12, function() if list then list.Visible = false end end)
        end

        for i, opt in ipairs(options or {}) do
            local it = Instance.new("TextButton")
            it.Size = UDim2.new(1, -12, 0, 28)
            it.Position = UDim2.new(0, 6, 0, 0)
            it.BackgroundColor3 = THEME.Panel
            it.BorderSizePixel = 0
            it.Text = tostring(opt)
            it.Font = Enum.Font.Gotham
            it.TextColor3 = THEME.Text
            it.TextSize = 14
            it.Parent = list
            local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(0,6) ic.Parent = it

            it.MouseButton1Click:Connect(function()
                selectedLabel.Text = tostring(opt)
                hideList()
            end)
        end

        box.MouseButton1Click:Connect(function()
            if list.Visible then
                hideList()
            else
                showList()
            end
        end)

        return container, {
            Get = function() return selectedLabel.Text end,
            Set = function(v) selectedLabel.Text = tostring(v) end,
            OnChange = function(fn) -- not implemented: selection event - user can modify
                -- simple implementation: connect each item to call fn
                for _,child in ipairs(list:GetChildren()) do
                    if child:IsA('TextButton') then
                        child.MouseButton1Click:Connect(function()
                            fn(child.Text)
                        end)
                    end
                end
            end
        }
    end

    -- expose factories on instance
    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.LeftColumn = LeftColumn
    self.RightColumn = RightColumn
    self.MakeToggle = function(_, ...) return makeToggle(LeftColumn, ...) end -- by default add to left
    self.MakeToggleOnRight = function(_, ...) return makeToggle(RightColumn, ...) end
    self.MakeSlider = function(_, ...) return makeSlider(LeftColumn, ...) end
    self.MakeSliderOnRight = function(_, ...) return makeSlider(RightColumn, ...) end
    self.MakeButton = function(_, ...) return makeButton(LeftColumn, ...) end
    self.MakeButtonOnRight = function(_, ...) return makeButton(RightColumn, ...) end
    self.MakeDropdown = function(_, ...) return makeDropdown(LeftColumn, ...) end
    self.MakeDropdownOnRight = function(_, ...) return makeDropdown(RightColumn, ...) end

    return self
end

-- Example usage (two tabs simulated by two different windows for simplicity)
-- Replace the loader with your raw GitHub link when you publish
local example = {}
example.run = function()
    -- Tab 1 window (Main)
    local win1 = UI:New("NarcoEx", "rbxassetid://119400389511179")

    local godContainer, godApi = win1:MakeToggle(win1, "God Mode", false)
    godApi:OnChange(function(state)
        print("God Mode ->", state)
        -- smooth text update animation
        local label = godContainer:FindFirstChildOfClass('TextLabel')
        if label then
            tween(label, {TextTransparency = state and 0.2 or 0}, 0.12)
        end
    end)

    local _, walkApi = win1:MakeSliderOnRight(win1, "Walk Speed", 16, 0, 200, 1)
    walkApi:OnChange(function(v)
        print("WalkSpeed ->", v)
        -- update humanoid if available
        local plr = game.Players.LocalPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            pcall(function() plr.Character.Humanoid.WalkSpeed = v end)
        end
    end)

    -- simple button
    local btn = win1:MakeButton(win1, "Reset Settings")
    btn.MouseButton1Click:Connect(function()
        godApi:Set(false)
        walkApi:Set(16)
    end)

    -- Tab 2 window (Extras) — create a second smaller window to simulate tabs
    local win2 = UI:New("NarcoEx — Extras", "rbxassetid://119400389511179")
    win2.MainFrame.Position = UDim2.new(0.5, 220, 0.5, -200) -- offset so it doesn't overlap

    local ddContainer, ddApi = win2:MakeDropdown(win2, "Mode", {"Normal", "Fast", "Slow"}, "Normal")
    ddApi.OnChange(function(v) print("Selected ->", v) end)

    --- place an extra slider
    local _, volApi = win2:MakeSlider(win2, "Volume", 50, 0, 100, 5)
    volApi:OnChange(function(v) print("Volume ->", v) end)
end

-- Run example automatically when this module is loaded (comment out if you only want the library)
example.run()

return UI
