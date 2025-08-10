-- NarcoEx UI Library
local NarcoEx = {}
NarcoEx.__index = NarcoEx

-- Colors
NarcoEx.Colors = {
    Background = Color3.fromRGB(12, 12, 12),
    Primary = Color3.fromRGB(79, 0, 255),
    Secondary = Color3.fromRGB(131, 255, 220),
    Text = Color3.fromRGB(255, 255, 255),
    Divider = Color3.fromRGB(208, 208, 208)
}

-- Utility functions
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Main Window
function NarcoEx.new(title)
    local self = setmetatable({}, NarcoEx)
    
    -- Create main GUI
    self.ScreenGui = createInstance("ScreenGui", {
        Name = "NarcoEx",
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false
    })
    
    -- Main container
    self.Main = createInstance("Frame", {
        Name = "Main",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.293, 0, 0.28, 0),
        Size = UDim2.new(0, 767, 0, 480),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Main
    })
    
    -- Top bar
    self.Topbar = createInstance("Frame", {
        Name = "Topbar",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.293, 0, 0.279, 0),
        Size = UDim2.new(0, 766, 0, 55),
        BackgroundColor3 = Color3.fromRGB(9, 9, 9),
        BorderSizePixel = 0
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Topbar
    })
    
    -- Title
    self.Title = createInstance("TextLabel", {
        Name = "Title",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.366, 0, 0.284, 0),
        Size = UDim2.new(0, 66, 0, 50),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = title or "NarcoEx",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    
    -- Icon
    self.Icon = createInstance("ImageLabel", {
        Name = "Icon",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.304, 0, 0.308, 0),
        Size = UDim2.new(0, 33, 0, 33),
        BackgroundTransparency = 1,
        Image = "rbxassetid://119400389511179"
    })
    
    -- Close button
    self.CloseButton = createInstance("ImageButton", {
        Name = "CloseButton",
        Parent = self.Topbar,
        Position = UDim2.new(0.95, 0, 0.29, 0),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734895530"
    })
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)
    
    -- Content area
    self.Content = createInstance("Frame", {
        Name = "Content",
        Parent = self.Main,
        Position = UDim2.new(0.222, 0, 0.133, 0),
        Size = UDim2.new(0, 595, 0, 415),
        BackgroundTransparency = 1
    })
    
    -- Tab system
    self.TabPlaceholder = createInstance("Frame", {
        Name = "TabPlaceholder",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.293, 0, 0.427, 0),
        Size = UDim2.new(0, 161, 0, 428),
        BackgroundColor3 = Color3.fromRGB(6, 6, 6),
        BorderSizePixel = 0
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.TabPlaceholder
    })
    
    createInstance("UIPadding", {
        Name = "UIPadding",
        Parent = self.TabPlaceholder,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5)
    })
    
    self.TabListLayout = createInstance("UIListLayout", {
        Name = "UIListLayout",
        Parent = self.TabPlaceholder,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Divider for tabs
    self.TabDivider = createInstance("TextLabel", {
        Name = "Divider",
        Parent = self.TabPlaceholder,
        Size = UDim2.new(0, 152, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = "Main Tabs",
        TextColor3 = NarcoEx.Colors.Divider,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    return self
end

-- Tab functions
function NarcoEx:AddTab(name)
    local tab = {
        Name = name,
        Content = createInstance("Frame", {
            Name = name .. "Content",
            Parent = self.Content,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        }),
        Button = createInstance("TextButton", {
            Name = name .. "Button",
            Parent = self.TabPlaceholder,
            Size = UDim2.new(0, 152, 0, 34),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = name,
            TextColor3 = NarcoEx.Colors.Text,
            TextSize = 22
        })
    }
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tab.Button
    })
    
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

function NarcoEx:SwitchTab(tab)
    if self.CurrentTab then
        self.CurrentTab.Content.Visible = false
        self.CurrentTab.Button.BackgroundTransparency = 1
        self.CurrentTab.Button.TextColor3 = NarcoEx.Colors.Text
    end
    
    self.CurrentTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundTransparency = 0.75
    tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local gradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 0, 255)),
            ColorSequenceKeypoint.new(0.54, NarcoEx.Colors.Primary),
            ColorSequenceKeypoint.new(1, NarcoEx.Colors.Secondary)
        }),
        Parent = tab.Button
    })
end

-- Groupbox functions
function NarcoEx.Tab:AddGroupbox(name, column)
    column = column or 1
    local groupbox = {
        Name = name,
        Frame = createInstance("Frame", {
            Name = name .. "Groupbox",
            Parent = self.Content,
            Size = UDim2.new(0.45, 0, 0, 0),
            BackgroundColor3 = NarcoEx.Colors.Background,
            BorderSizePixel = 0
        })
    }
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = groupbox.Frame
    })
    
    -- Position based on column
    if column == 1 then
        groupbox.Frame.Position = UDim2.new(0, 0, 0, 0)
    else
        groupbox.Frame.Position = UDim2.new(0.5, 10, 0, 0)
    end
    
    -- Title
    groupbox.Title = createInstance("TextLabel", {
        Name = "Title",
        Parent = groupbox.Frame,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = name,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Content container
    groupbox.Content = createInstance("Frame", {
        Name = "Content",
        Parent = groupbox.Frame,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 1, -45),
        BackgroundTransparency = 1
    })
    
    groupbox.ListLayout = createInstance("UIListLayout", {
        Parent = groupbox.Content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    groupbox.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        groupbox.Frame.Size = UDim2.new(groupbox.Frame.Size.X.Scale, groupbox.Frame.Size.X.Offset, 0, groupbox.ListLayout.AbsoluteContentSize.Y + 45)
    end)
    
    return groupbox
end

-- UI Components
function NarcoEx.Groupbox:AddLabel(text)
    local label = createInstance("TextLabel", {
        Name = "Label",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return label
end

function NarcoEx.Groupbox:AddDivider(text)
    local divider = createInstance("Frame", {
        Name = "Divider",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = NarcoEx.Colors.Divider,
        BorderSizePixel = 0
    })
    
    if text then
        divider.Size = UDim2.new(1, 0, 0, 20)
        divider.BackgroundTransparency = 1
        
        createInstance("TextLabel", {
            Parent = divider,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSans,
            Text = text,
            TextColor3 = NarcoEx.Colors.Divider,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end
    
    return divider
end

function NarcoEx.Groupbox:AddButton(text, callback)
    local button = createInstance("TextButton", {
        Name = "Button",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = NarcoEx.Colors.Primary,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 18
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = button
    })
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return button
end

function NarcoEx.Groupbox:AddToggle(text, default, callback)
    local toggle = {
        Value = default or false,
        Callback = callback
    }
    
    local frame = createInstance("Frame", {
        Name = "Toggle",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local label = createInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleButton = createInstance("TextButton", {
        Name = "ToggleButton",
        Parent = frame,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundColor3 = toggle.Value and NarcoEx.Colors.Primary or Color3.fromRGB(50, 50, 50),
        Font = Enum.Font.SourceSans,
        Text = toggle.Value and "ON" or "OFF",
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = toggleButton
    })
    
    toggleButton.MouseButton1Click:Connect(function()
        toggle.Value = not toggle.Value
        toggleButton.BackgroundColor3 = toggle.Value and NarcoEx.Colors.Primary or Color3.fromRGB(50, 50, 50)
        toggleButton.Text = toggle.Value and "ON" or "OFF"
        if toggle.Callback then
            toggle.Callback(toggle.Value)
        end
    end)
    
    toggle.Set = function(self, value)
        toggle.Value = value
        toggleButton.BackgroundColor3 = toggle.Value and NarcoEx.Colors.Primary or Color3.fromRGB(50, 50, 50)
        toggleButton.Text = toggle.Value and "ON" or "OFF"
        if toggle.Callback then
            toggle.Callback(toggle.Value)
        end
    end
    
    toggle.Get = function(self)
        return toggle.Value
    end
    
    return toggle
end

function NarcoEx.Groupbox:AddSlider(text, min, max, default, callback)
    local slider = {
        Value = default or min,
        Min = min,
        Max = max,
        Callback = callback
    }
    
    local frame = createInstance("Frame", {
        Name = "Slider",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    local label = createInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local valueLabel = createInstance("TextLabel", {
        Name = "ValueLabel",
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = tostring(slider.Value),
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local track = createInstance("Frame", {
        Name = "Track",
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    local fill = createInstance("Frame", {
        Name = "Fill",
        Parent = track,
        Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
        BackgroundColor3 = NarcoEx.Colors.Primary,
        BorderSizePixel = 0
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = fill
    })
    
    local thumb = createInstance("TextButton", {
        Name = "Thumb",
        Parent = track,
        Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -5, 0, -5),
        Size = UDim2.new(0, 15, 0, 15),
        BackgroundColor3 = NarcoEx.Colors.Text,
        Text = "",
        AutoButtonColor = false
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = thumb
    })
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        slider.Value = math.floor(slider.Min + relativeX * (slider.Max - slider.Min))
        valueLabel.Text = tostring(slider.Value)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        thumb.Position = UDim2.new(relativeX, -7, 0, -5)
        
        if slider.Callback then
            slider.Callback(slider.Value)
        end
    end
    
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    
    slider.Set = function(self, value)
        value = math.clamp(value, slider.Min, slider.Max)
        slider.Value = value
        valueLabel.Text = tostring(slider.Value)
        local relativeX = (value - slider.Min) / (slider.Max - slider.Min)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        thumb.Position = UDim2.new(relativeX, -7, 0, -5)
        if slider.Callback then
            slider.Callback(slider.Value)
        end
    end
    
    slider.Get = function(self)
        return slider.Value
    end
    
    return slider
end

function NarcoEx.Groupbox:AddDropdown(text, options, default, callback)
    local dropdown = {
        Value = default or options[1],
        Options = options,
        Callback = callback,
        Open = false
    }
    
    local frame = createInstance("Frame", {
        Name = "Dropdown",
        Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1
    })
    
    local label = createInstance("TextLabel", {
        Name = "Label",
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSans,
        Text = text,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local mainButton = createInstance("TextButton", {
        Name = "MainButton",
        Parent = frame,
        Position = UDim2.new(0.7, 0, 0, 0),
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundColor3 = NarcoEx.Colors.Primary,
        Font = Enum.Font.SourceSans,
        Text = dropdown.Value,
        TextColor3 = NarcoEx.Colors.Text,
        TextSize = 16
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = mainButton
    })
    
    local optionsFrame = createInstance("Frame", {
        Name = "OptionsFrame",
        Parent = frame,
        Position = UDim2.new(0.7, 0, 1, 5),
        Size = UDim2.new(0.3, 0, 0, 0),
        BackgroundColor3 = NarcoEx.Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false
    })
    
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = optionsFrame
    })
    
    local optionsList = createInstance("UIListLayout", {
        Parent = optionsFrame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local function updateOptions()
        for _, option in ipairs(dropdown.Options) do
            local optionButton = createInstance("TextButton", {
                Name = option .. "Option",
                Parent = optionsFrame,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = NarcoEx.Colors.Background,
                BorderSizePixel = 0,
                Font = Enum.Font.SourceSans,
                Text = option,
                TextColor3 = NarcoEx.Colors.Text,
                TextSize = 16
            })
            
            optionButton.MouseButton1Click:Connect(function()
                dropdown.Value = option
                mainButton.Text = option
                optionsFrame.Visible = false
                dropdown.Open = false
                if dropdown.Callback then
                    dropdown.Callback(option)
                end
            end)
        end
    end
    
    updateOptions()
    
    mainButton.MouseButton1Click:Connect(function()
        dropdown.Open = not dropdown.Open
        optionsFrame.Visible = dropdown.Open
        optionsFrame.Size = UDim2.new(0.3, 0, 0, math.min(#dropdown.Options * 30, 150))
    end)
    
    dropdown.Set = function(self, value)
        if table.find(dropdown.Options, value) then
            dropdown.Value = value
            mainButton.Text = value
            if dropdown.Callback then
                dropdown.Callback(value)
            end
        end
    end
    
    dropdown.Get = function(self)
        return dropdown.Value
    end
    
    dropdown.UpdateOptions = function(self, newOptions)
        dropdown.Options = newOptions
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        updateOptions()
    end
    
    return dropdown
end

return NarcoEx