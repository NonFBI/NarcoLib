```lua
-- Load Narco UI Library
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NonFBI/NarcoLib/refs/heads/main/source.lua"))()

-- Create main window
local Window = UI:CreateWindow({
    Title = "Narco Ex",
    Theme = "Dark",
    Size = UDim2.new(0, 500, 0, 350)
})

-- Example Tab
local ExampleTab = Window:CreateTab("Example")

-- Toggle
local godModeToggle = ExampleTab:CreateToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(value)
        print("God Mode:", value)
    end
})

-- Slider
local walkSpeedSlider = ExampleTab:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Dropdown
local walkStyleDropdown = ExampleTab:CreateDropdown({
    Name = "Walk Style",
    Options = {"Normal", "Ninja", "Robot"},
    Default = "Normal",
    Callback = function(value)
        print("Selected Walk Style:", value)
    end
})

-- Button
ExampleTab:CreateButton({
    Name = "Quick Reset",
    Callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end
})

-- Keybind
local sprintKeybind = ExampleTab:CreateKeybind({
    Name = "Sprint Key",
    Default = Enum.KeyCode.LeftShift,
    Callback = function()
        print("Sprint key pressed!")
    end
})

-- Color Picker
local themeColorPicker = ExampleTab:CreateColorPicker({
    Name = "Theme Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        print("Selected Color:", color)
    end
})

-- Save/Load Settings
ExampleTab:CreateButton({
    Name = "Save Settings",
    Callback = function()
        UI:SaveSettings("NarcoSettings.json")
    end
})

ExampleTab:CreateButton({
    Name = "Load Settings",
    Callback = function()
        UI:LoadSettings("NarcoSettings.json")
    end
})
```
