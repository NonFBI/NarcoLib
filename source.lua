-- NarcoEx UI Library
-- Based on the provided UI structure, enhanced with functionality

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local NarcoEx = {}

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function NarcoEx:CreateWindow(title)
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    window.TabGroups = {}
    window.IsMinimized = false

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = CoreGui
    screenGui.Name = "NarcoExGui"

    -- NarcoEx (transparent container)
    local narcoEx = Instance.new("Frame")
    narcoEx.Parent = screenGui
    narcoEx.Name = "NarcoEx"
    narcoEx.Size = UDim2.new(0, 539, 0, 349)
    narcoEx.BackgroundTransparency = 1
    narcoEx.Position = UDim2.new(0.5, 0, 0.5, 0)
    narcoEx.AnchorPoint = Vector2.new(0.5, 0.5)

    -- UIScale for smooth open/close
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = narcoEx
    uiScale.Scale = 1

    -- Main frame
    local main = Instance.new("Frame")
    main.Parent = narcoEx
    main.Name = "Main"
    main.Position = UDim2.new(0, 0, 0, 55)  -- Below topbar
    main.Size = UDim2.new(1, 0, 1, -55)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    local mainCorner = Instance.new("UICorner")
    mainCorner.Parent = main

    -- Content frame for tabs
    local content = Instance.new("Frame")
    content.Parent = main
    content.Name = "Content"
    content.Position = UDim2.new(0.22, 0, 0, 0)
    content.Size = UDim2.new(0.78, 0, 1, 0)
    content.BackgroundTransparency = 1

    -- Tab sidebar
    local tabPlaceholder = Instance.new("Frame")
    tabPlaceholder.Parent = narcoEx
    tabPlaceholder.Name = "TabPlaceholder"
    tabPlaceholder.Position = UDim2.new(0, 0, 0, 55)
    tabPlaceholder.Size = UDim2.new(0.22, 0, 1, -55)
    tabPlaceholder.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = tabPlaceholder
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = tabPlaceholder
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabPlaceholder
    tabList.Padding = UDim.new(0, 8)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Parent = narcoEx
    topbar.Name = "Topbar"
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.Size = UDim2.new(1, 0, 0, 55)
    topbar.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
    local topbarCorner = Instance.new("UICorner")
    topbarCorner.Parent = topbar

    -- Close button
    local closeButton = Instance.new("ImageButton")
    closeButton.Parent = topbar
    closeButton.Position = UDim2.new(0.95, 0, 0.29, 0)
    closeButton.Size = UDim2.new(0, 22, 0, 22)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://10734895530"
    closeButton.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = topbar
    titleLabel.Position = UDim2.new(0.3, 0, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.Text = title or "NarcoEx"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Parent = topbar
    icon.Position = UDim2.new(0.05, 0, 0.1, 0)
    icon.Size = UDim2.new(0, 33, 0, 33)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://11940038951"  -- Truncated in original, assuming correction

    -- Function to create divider (section label in sidebar)
    function window:CreateDivider(name)
        local divider = Instance.new("TextLabel")
        divider.Parent = tabPlaceholder
        divider.Size = UDim2.new(1, 0, 0, 22)
        divider.BackgroundTransparency = 1
        divider.Font = Enum.Font.SourceSans
        divider.TextColor3 = Color3.fromRGB(208, 208, 208)
        divider.TextSize = 18
        divider.Text = name
        divider.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Create tab
    function window:CreateTab(name, group)
        if group and not window.TabGroups[group] then
            window:CreateDivider(group)
            window.TabGroups[group] = true
        end

        local tab = {}
        tab.Name = name
        tab.Elements = {}

        -- Tab button in sidebar
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabPlaceholder
        tabButton.Size = UDim2.new(1, -10, 0, 34)
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 1  -- Unselected by default
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 22
        tabButton.Text = name
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.Parent = tabButton
        local buttonGradient = Instance.new("UIGradient")
        buttonGradient.Parent = tabButton
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 0, 255)),
            ColorSequenceKeypoint.new(0.54, Color3.fromRGB(79, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 255, 220))
        })

        -- Tab content frame
        local tabContent = Instance.new("Frame")
        tabContent.Parent = content
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false

        -- Two columns for groupboxes
        local leftColumn = Instance.new("Frame")
        leftColumn.Parent = tabContent
        leftColumn.Size = UDim2.new(0.5, -5, 1, 0)
        leftColumn.BackgroundTransparency = 1
        local leftList = Instance.new("UIListLayout")
        leftList.Parent = leftColumn
        leftList.SortOrder = Enum.SortOrder.LayoutOrder
        leftList.Padding = UDim.new(0, 10)

        local rightColumn = Instance.new("Frame")
        rightColumn.Parent = tabContent
        rightColumn.Position = UDim2.new(0.5, 5, 0, 0)
        rightColumn.Size = UDim2.new(0.5, -5, 1, 0)
        rightColumn.BackgroundTransparency = 1
        local rightList = Instance.new("UIListLayout")
        rightList.Parent = rightColumn
        rightList.SortOrder = Enum.SortOrder.LayoutOrder
        rightList.Padding = UDim.new(0, 10)

        tab.LeftColumn = leftColumn
        tab.RightColumn = rightColumn
        tab.CurrentColumn = 1  -- Alternate columns

        -- Select tab function
        function tab:Select()
            if window.CurrentTab then
                window.CurrentTab.Content.Visible = false
                window.CurrentTab.Button.BackgroundTransparency = 1
            end
            tabContent.Visible = true
            tabButton.BackgroundTransparency = 0.75
            window.CurrentTab = tab
        end

        tab.Button = tabButton
        tab.Content = tabContent

        -- Click to select
        tabButton.MouseButton1Click:Connect(function()
            tab:Select()
        end)

        table.insert(window.Tabs, tab)

        -- Select first tab by default
        if #window.Tabs == 1 then
            tab:Select()
        end

        -- Create groupbox/section
        function tab:CreateSection(name)
            local section = Instance.new("Frame")
            section.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.Parent = section
            section.Size = UDim2.new(1, 0, 0, 0)  -- Auto height

            -- Title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Parent = section
            sectionTitle.Size = UDim2.new(1, 0, 0, 25)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Font = Enum.Font.SourceSans
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 18
            sectionTitle.Text = name
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            local titlePadding = Instance.new("UIPadding")
            titlePadding.Parent = sectionTitle
            titlePadding.PaddingLeft = UDim.new(0, 10)

            -- Content list
            local sectionContent = Instance.new("Frame")
            sectionContent.Parent = section
            sectionContent.Position = UDim2.new(0, 0, 0, 25)
            sectionContent.Size = UDim2.new(1, 0, 1, -25)
            sectionContent.BackgroundTransparency = 1
            local sectionList = Instance.new("UIListLayout")
            sectionList.Parent = sectionContent
            sectionList.SortOrder = Enum.SortOrder.LayoutOrder
            sectionList.Padding = UDim.new(0, 5)
            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.Parent = sectionContent
            sectionPadding.PaddingLeft = UDim.new(0, 10)
            sectionPadding.PaddingRight = UDim.new(0, 10)
            sectionPadding.PaddingTop = UDim.new(0, 5)
            sectionPadding.PaddingBottom = UDim.new(0, 5)

            -- Auto size height
            sectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Size = UDim2.new(1, 0, 0, sectionList.AbsoluteContentSize.Y + 30)
            end)

            -- Add to column
            if tab.CurrentColumn == 1 then
                section.Parent = leftColumn
                tab.CurrentColumn = 2
            else
                section.Parent = rightColumn
                tab.CurrentColumn = 1
            end

            -- Elements
            function section:CreateToggle(name, callback)
                local toggle = Instance.new("Frame")
                toggle.Parent = sectionContent
                toggle.Size = UDim2.new(1, 0, 0, 25)
                toggle.BackgroundTransparency = 1

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Parent = toggle
                toggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Font = Enum.Font.SourceSans
                toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.TextSize = 16
                toggleLabel.Text = name
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                local toggleButton = Instance.new("TextButton")
                toggleButton.Parent = toggle
                toggleButton.Position = UDim2.new(0.8, 0, 0, 0)
                toggleButton.Size = UDim2.new(0.2, 0, 1, 0)
                toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                toggleButton.Text = "Off"
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.Parent = toggleButton

                local state = false
                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.Text = state and "On" or "Off"
                    toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    if callback then callback(state) end
                end)
            end

            function section:CreateSlider(name, min, max, callback)
                local slider = Instance.new("Frame")
                slider.Parent = sectionContent
                slider.Size = UDim2.new(1, 0, 0, 30)
                slider.BackgroundTransparency = 1

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Parent = slider
                sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Font = Enum.Font.SourceSans
                sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderLabel.TextSize = 16
                sliderLabel.Text = name
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

                local sliderBar = Instance.new("Frame")
                sliderBar.Parent = slider
                sliderBar.Position = UDim2.new(0, 0, 0.5, 0)
                sliderBar.Size = UDim2.new(1, 0, 0.5, 0)
                sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                local barCorner = Instance.new("UICorner")
                barCorner.Parent = sliderBar

                local fill = Instance.new("Frame")
                fill.Parent = sliderBar
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                local fillCorner = Instance.new("UICorner")
                fillCorner.Parent = fill
                local fillGradient = Instance.new("UIGradient")
                fillGradient.Parent = fill
                fillGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 0, 255))
                })

                local value = min
                local dragging = false

                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                sliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        value = min + (max - min) * relativeX
                        fill.Size = UDim2.new(relativeX, 0, 1, 0)
                        if callback then callback(math.floor(value)) end
                    end
                end)
            end

            function section:CreateDropdown(name, options, callback)
                local dropdown = Instance.new("Frame")
                dropdown.Parent = sectionContent
                dropdown.Size = UDim2.new(1, 0, 0, 25)
                dropdown.BackgroundTransparency = 1

                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Parent = dropdown
                dropdownButton.Size = UDim2.new(1, 0, 1, 0)
                dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownButton.Text = name .. ": Select"
                local ddCorner = Instance.new("UICorner")
                ddCorner.Parent = dropdownButton

                local dropdownList = Instance.new("Frame")
                dropdownList.Parent = dropdown
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                dropdownList.Visible = false
                local ddListLayout = Instance.new("UIListLayout")
                ddListLayout.Parent = dropdownList
                ddListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                ddListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    dropdownList.Size = UDim2.new(1, 0, 0, ddListLayout.AbsoluteContentSize.Y)
                end)

                for _, opt in ipairs(options) do
                    local optButton = Instance.new("TextButton")
                    optButton.Parent = dropdownList
                    optButton.Size = UDim2.new(1, 0, 0, 25)
                    optButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    optButton.Text = opt
                    optButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optButton.MouseButton1Click:Connect(function()
                        dropdownButton.Text = name .. ": " .. opt
                        dropdownList.Visible = false
                        if callback then callback(opt) end
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                end)
            end

            return section
        end

        return tab
    end

    -- Toggle minimize
    function window:ToggleMinimize()
        window.IsMinimized = not window.IsMinimized
        local targetScale = window.IsMinimized and 0 or 1
        TweenService:Create(uiScale, tweenInfo, {Scale = targetScale}):Play()
    end

    -- Keybind for toggle
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
            window:ToggleMinimize()
        end
    end)

    return window
end

return NarcoEx