-- NarcoExUI.lua
-- Modernized NarcoEx UI Library
-- Place this file in your GitHub and replace the placeholder URL in your loader with the real raw link.
-- Author: Generated for user

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local NarcoExUI = {}
NarcoExUI.__index = NarcoExUI

-- Styling values
local THEME = {
    Background = Color3.fromRGB(18,18,20),
    Panel = Color3.fromRGB(26,27,30),
    Accent = Color3.fromRGB(96,165,250), -- bluish
    Subtle = Color3.fromRGB(38,39,42),
    Text = Color3.fromRGB(230,230,230),
    MutedText = Color3.fromRGB(170,170,170),
    Corner = UDim.new(0,12)
}

-- Helper: tween properties
local function tween(obj, props, duration, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.22, style, direction)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- Helper: round number
local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- Create base ScreenGui
local function makeBaseGui(name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name or "NarcoExUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    -- Main container
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 900, 0, 540)
    main.BackgroundColor3 = THEME.Background
    main.BorderSizePixel = 0
    main.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = THEME.Corner
    mainCorner.Parent = main

    -- Topbar
    local top = Instance.new("Frame")
    top.Name = "Top"
    top.Size = UDim2.new(1, 0, 0, 64)
    top.BackgroundColor3 = THEME.Panel
    top.BorderSizePixel = 0
    top.Parent = main
    local topCorner = Instance.new("UICorner") topCorner.CornerRadius = UDim.new(0,10) topCorner.Parent = top

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = THEME.Text
    title.Text = "NarcoEx  — Modern"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    -- Sidebar (vertical tabs)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Position = UDim2.new(0.02, 0, 0.12, 0)
    sidebar.Size = UDim2.new(0, 180, 0, 440)
    sidebar.BackgroundColor3 = THEME.Subtle
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    local sbCorner = Instance.new("UICorner") sbCorner.CornerRadius = UDim.new(0,8) sbCorner.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0,8)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = sidebar

    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.new(0.22, 0, 0.12, 0)
    content.Size = UDim2.new(0.76, -24, 0, 440)
    content.BackgroundColor3 = THEME.Panel
    content.BorderSizePixel = 0
    content.Parent = main
    local contentCorner = Instance.new("UICorner") contentCorner.CornerRadius = UDim.new(0,10) contentCorner.Parent = content

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.Padding = UDim.new(0,12)
    contentLayout.Parent = content

    return {
        ScreenGui = screenGui,
        Main = main,
        Top = top,
        Sidebar = sidebar,
        Content = content,
        ContentLayout = contentLayout,
        TabLayout = tabLayout
    }
end

-- Create a tab button in sidebar
local function makeTabButton(sidebar, name)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, -12, 0, 36)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextColor3 = THEME.Text
    btn.Text = name
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar

    local hover = Instance.new("Frame")
    hover.Size = UDim2.new(1,0,1,0)
    hover.BackgroundTransparency = 1
    hover.BorderSizePixel = 0
    hover.Parent = btn

    return btn
end

-- Create a settings panel (frame slot)
local function makePanel(content)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0.5, -6, 1, 0)
    panel.BackgroundColor3 = THEME.Panel
    panel.BorderSizePixel = 0
    panel.Parent = content

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = panel

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0, 12, 0, 12)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = panel

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,12)
    list.Parent = scroll

    return panel
end

-- UI element factory: Toggle
local function createToggle(parent, labelText, default)
    default = default and true or false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.8, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Gotham
    text.TextSize = 16
    text.TextColor3 = THEME.Text
    text.Text = labelText
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 64, 0, 32)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -12, 0.5, 0)
    btn.BackgroundColor3 = THEME.Subtle
    btn.BorderSizePixel = 0
    btn.Parent = container
    local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0,16) btnCorner.Parent = btn

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 28, 0, 28)
    handle.Position = UDim2.new(default and 1 or 0, -30, 0.5, -14)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.Parent = btn
    local handleCorner = Instance.new("UICorner") handleCorner.CornerRadius = UDim.new(0,14) handleCorner.Parent = handle

    -- Initialize style
    btn.BackgroundColor3 = default and THEME.Accent or THEME.Subtle
    handle.Position = default and UDim2.new(1, -30, 0.5, -14) or UDim2.new(0, 2, 0.5, -14)

    local state = default
    local callback = nil

    btn.MouseButton1Click:Connect(function()
        state = not state
        tween(btn, {BackgroundColor3 = state and THEME.Accent or THEME.Subtle}, 0.18)
        tween(handle, {Position = state and UDim2.new(1, -30, 0.5, -14) or UDim2.new(0, 2, 0.5, -14)}, 0.18)
        if callback then
            pcall(callback, state)
        end
    end)

    local api = {}
    function api:Get() return state end
    function api:Set(v)
        state = v and true or false
        btn.BackgroundColor3 = state and THEME.Accent or THEME.Subtle
        handle.Position = state and UDim2.new(1, -30, 0.5, -14) or UDim2.new(0, 2, 0.5, -14)
        if callback then pcall(callback, state) end
    end
    function api:OnChange(fn) callback = fn end

    return container, api
end

-- UI element factory: Slider
local function createSlider(parent, labelText, default, min, max, step)
    default = tonumber(default) or 0
    min = tonumber(min) or 0
    max = tonumber(max) or 100
    step = tonumber(step) or 1
    default = clamp(default, min, max)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 64)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.TextColor3 = THEME.Text
    title.Text = string.format("%s — %s", labelText, tostring(default))
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local barBack = Instance.new("Frame")
    barBack.Size = UDim2.new(1, 0, 0, 16)
    barBack.Position = UDim2.new(0, 0, 0, 24)
    barBack.BackgroundColor3 = THEME.Subtle
    barBack.BorderSizePixel = 0
    barBack.Parent = container
    local barCorner = Instance.new("UICorner") barCorner.CornerRadius = UDim.new(0,8) barCorner.Parent = barBack

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    barFill.BackgroundColor3 = THEME.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBack
    local fillCorner = Instance.new("UICorner") fillCorner.CornerRadius = UDim.new(0,8) fillCorner.Parent = barFill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = barBack
    local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(0,9) knobCorner.Parent = knob

    local dragging = false
    local current = default
    local callback = nil

    local function updateFromX(x)
        local absX = clamp(x - barBack.AbsolutePosition.X, 0, barBack.AbsoluteSize.X)
        local t = absX / barBack.AbsoluteSize.X
        local raw = min + (max-min) * t
        local stepped = math.round(raw/step) * step
        current = clamp(stepped, min, max)
        local frac = (current - min) / (max - min)
        tween(barFill, {Size = UDim2.new(frac,0,1,0)}, 0.08)
        tween(knob, {Position = UDim2.new(frac,0,0.5,0)}, 0.08)
        title.Text = string.format("%s — %s", labelText, tostring(current))
        if callback then pcall(callback, current) end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    barBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateFromX(input.Position.X)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = game.Players.LocalPlayer:GetMouse()
            updateFromX(mouse.X)
        end
    end)

    local api = {}
    function api:Get() return current end
    function api:Set(v)
        current = clamp(math.round(v/step)*step, min, max)
        local frac = (current-min)/(max-min)
        barFill.Size = UDim2.new(frac,0,1,0)
        knob.Position = UDim2.new(frac,0,0.5,0)
        title.Text = string.format("%s — %s", labelText, tostring(current))
        if callback then pcall(callback, current) end
    end
    function api:OnChange(fn) callback = fn end

    return container, api
end

-- UI element factory: Button
local function createButton(parent, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = THEME.Accent
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = labelText
    btn.TextColor3 = THEME.Text
    btn.TextSize = 16
    btn.Parent = parent
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,8) corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
        tween(btn, {BackgroundColor3 = THEME.Accent}, 0.12)
    end)

    return btn
end

-- UI element factory: Dropdown
local function createDropdown(parent, labelText, options, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,44)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,16)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.Text = labelText
    title.TextColor3 = THEME.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,24)
    box.Position = UDim2.new(0,0,0,18)
    box.BackgroundColor3 = THEME.Subtle
    box.Parent = container
    box.BorderSizePixel = 0
    local boxCorner = Instance.new("UICorner") boxCorner.CornerRadius = UDim.new(0,8) boxCorner.Parent = box

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, -8, 1, 0)
    label.Position = UDim2.new(0,8,0,0)
    label.BackgroundTransparency = 1
    label.Text = tostring(default or options[1] or "")
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = THEME.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = box

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0.2, -8, 1, 0)
    arrow.Position = UDim2.new(0.8, 0, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 18
    arrow.Text = "▾"
    arrow.TextColor3 = THEME.MutedText
    arrow.Parent = box

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1,0,0,0)
    list.Position = UDim2.new(0,0,0,42)
    list.BackgroundColor3 = THEME.Panel
    list.Visible = false
    list.Parent = container
    local listCorner = Instance.new("UICorner") listCorner.CornerRadius = UDim.new(0,8) listCorner.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list
    listLayout.Padding = UDim.new(0,6)

    local items = {}
    local selected = label.Text
    for i, opt in ipairs(options or {}) do
        local it = Instance.new("TextButton")
        it.Size = UDim2.new(1, -12, 0, 28)
        it.Position = UDim2.new(0, 6, 0, 0)
        it.BackgroundColor3 = THEME.Subtle
        it.Text = tostring(opt)
        it.TextColor3 = THEME.Text
        it.Font = Enum.Font.Gotham
        it.TextSize = 14
        it.Parent = list
        local itCorner = Instance.new("UICorner") itCorner.CornerRadius = UDim.new(0,6) itCorner.Parent = it
        items[#items+1] = it

        it.MouseButton1Click:Connect(function()
            label.Text = tostring(opt)
            selected = opt
            list.Visible = false
        end)
    end

    box.MouseButton1Click = box.MouseButton1Click or Instance.new("BindableEvent")
    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            list.Visible = not list.Visible
            if list.Visible then
                local total = #options * 34 + 8
                tween(list, {Size = UDim2.new(1,0,0,total)}, 0.16)
            else
                tween(list, {Size = UDim2.new(1,0,0,0)}, 0.12):Play()
                task.delay(0.12, function() if list then list.Visible = false end end)
            end
        end
    end)

    local api = {}
    function api:Get() return selected end
    function api:Set(v)
        selected = v
        label.Text = tostring(v)
    end

    return container, api
end

-- Library constructor
function NarcoExUI:New(name)
    local self = setmetatable({}, NarcoExUI)
    self._name = name or "NarcoEx"
    self._gui = makeBaseGui(self._name)
    self._tabs = {}
    return self
end

-- Create Tab
function NarcoExUI:CreateTab(name)
    local tabBtn = makeTabButton(self._gui.Sidebar, name)
    local panelLeft = makePanel(self._gui.Content)
    local panelRight = makePanel(self._gui.Content)
    panelLeft.Name = name .. "_L"
    panelRight.Name = name .. "_R"

    -- If only right panel should be used, left will be hidden. We'll manage auto-resize later.
    local tab = {
        Name = name,
        Button = tabBtn,
        Panels = {panelLeft, panelRight},
        API = {}
    }

    -- Button behavior: switch visible panels
    tabBtn.MouseButton1Click:Connect(function()
        -- hide other tabs panels
        for _, t in pairs(self._tabs) do
            for _, p in ipairs(t.Panels) do
                tween(p, {BackgroundTransparency = 0}, 0.12)
                p.Visible = false
            end
        end
        -- show this tab panels
        for _, p in ipairs(tab.Panels) do
            p.Visible = true
            p.BackgroundTransparency = 0
        end

        -- if only one panel has children, expand it
        task.defer(function()
            local leftCount = #panelLeft.Scroll:GetChildren()
            local rightCount = #panelRight.Scroll:GetChildren()
            -- UIListLayout and scroll contains layout object, so count real elements
            local l = 0 local r = 0
            for _,c in ipairs(panelLeft.Scroll:GetChildren()) do if c:IsA('Frame') or c:IsA('TextButton') or c:IsA('TextLabel') then l = l + 1 end end
            for _,c in ipairs(panelRight.Scroll:GetChildren()) do if c:IsA('Frame') or c:IsA('TextButton') or c:IsA('TextLabel') then r = r + 1 end end
            if l > 0 and r == 0 then
                tween(panelLeft, {Size = UDim2.new(1, -12, 1, 0)}, 0.18)
                tween(panelRight, {Size = UDim2.new(0, 0, 1, 0)}, 0.18)
            elseif r > 0 and l == 0 then
                tween(panelRight, {Size = UDim2.new(1, -12, 1, 0)}, 0.18)
                tween(panelLeft, {Size = UDim2.new(0, 0, 1, 0)}, 0.18)
            else
                tween(panelLeft, {Size = UDim2.new(0.5, -6, 1, 0)}, 0.18)
                tween(panelRight, {Size = UDim2.new(0.5, -6, 1, 0)}, 0.18)
            end
        end)
    end)

    -- API functions to add controls
    function tab.API:AddToggle(label, default, callback, leftSide)
        local parentPanel = leftSide and panelLeft.Scroll or panelLeft.Scroll
        -- if leftSide is false use right
        parentPanel = leftSide == false and panelRight.Scroll or panelLeft.Scroll
        local container, api = createToggle(parentPanel, label, default)
        api:OnChange(callback)
        return api
    end
    function tab.API:AddSlider(label, default, min, max, step, callback, leftSide)
        local parentPanel = leftSide == false and panelRight.Scroll or panelLeft.Scroll
        local container, api = createSlider(parentPanel, label, default, min, max, step)
        api:OnChange(callback)
        return api
    end
    function tab.API:AddButton(label, callback, leftSide)
        local parentPanel = leftSide == false and panelRight.Scroll or panelLeft.Scroll
        return createButton(parentPanel, label, callback)
    end
    function tab.API:AddDropdown(label, options, default, leftSide)
        local parentPanel = leftSide == false and panelRight.Scroll or panelLeft.Scroll
        local container, api = createDropdown(parentPanel, label, options, default)
        return api
    end

    -- store
    self._tabs[name] = tab
    -- make first tab visible automatically
    if #self._tabs == 1 then
        tabBtn:MouseButton1Click()
    end
    return tab.API
end

-- Minimal example loader (this will be included in README on your GitHub)
-- Placeholder URL: https://raw.githubusercontent.com/youruser/yourrepo/main/NarcoExUI.lua
-- Example usage:
-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/youruser/yourrepo/main/NarcoExUI.lua"))()
-- local lib = UI:New("NarcoEx")
-- local main = lib:CreateTab("Main")
-- main:AddToggle("God Mode", false, function(state) print(state) end)
-- main:AddSlider("WalkSpeed", 16, 0, 200, 1, function(v) print(v) end)
-- main:AddButton("Reset", function() print('reset') end)
-- main:AddDropdown("Mode", {"Normal","Fast","Slow"}, "Normal")

return NarcoExUI
