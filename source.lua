-- NarcoEx UI Library with Original Style + Sliders/Toggles, Bluish Purple Theme
-- Keeps original icon & close button, draggable top bar, two-column content layout

local UI = {}
UI.__index = UI

function UI:New(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TopBar.Parent = MainFrame
    TopBar.Active = true
    TopBar.Draggable = true

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 40, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Parent = TopBar

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 4, 0.5, -16)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://<original_icon_id_here>"
    Icon.Parent = TopBar

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

    -- Two-column content frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local LeftColumn = Instance.new("Frame")
    LeftColumn.Size = UDim2.new(0.5, 0, 1, 0)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = ContentFrame

    local RightColumn = Instance.new("Frame")
    RightColumn.Size = UDim2.new(0.5, 0, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 0, 0, 0)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = ContentFrame

    -- Example toggle (God Mode)
    local GodToggle = Instance.new("TextButton")
    GodToggle.Size = UDim2.new(0, 200, 0, 40)
    GodToggle.Position = UDim2.new(0, 20, 0, 20)
    GodToggle.BackgroundColor3 = Color3.fromRGB(90, 60, 150)
    GodToggle.Text = "God Mode: OFF"
    GodToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    GodToggle.Parent = LeftColumn

    local godEnabled = false
    GodToggle.MouseButton1Click:Connect(function()
        godEnabled = not godEnabled
        GodToggle.Text = "God Mode: " .. (godEnabled and "ON" or "OFF")
    end)

    -- Example slider (Walk Speed)
    local WalkSpeedSlider = Instance.new("TextButton")
    WalkSpeedSlider.Size = UDim2.new(0, 200, 0, 40)
    WalkSpeedSlider.Position = UDim2.new(0, 20, 0, 20)
    WalkSpeedSlider.BackgroundColor3 = Color3.fromRGB(90, 60, 150)
    WalkSpeedSlider.Text = "Walk Speed: 16"
    WalkSpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkSpeedSlider.Parent = RightColumn

    local speed = 16
    WalkSpeedSlider.MouseButton1Click:Connect(function()
        speed = speed + 1
        if speed > 100 then speed = 0 end
        WalkSpeedSlider.Text = "Walk Speed: " .. speed
    end)

    return UI
end

return UI
