-- Narco UI Library (Updated)
-- Requires Starlight Library by Nebula
-- Loads as: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NonFBI/NarcoLib/refs/heads/main/source.lua"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SettingsFile = "NarcoSettings.json"

local NarcoUI = {}
NarcoUI.__index = NarcoUI

-- Load Starlight
local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/nebula-softworks/starlight/main/library.lua"))()

-- Save settings
local function SaveSettings(data)
    if writefile then
        writefile(SettingsFile, HttpService:JSONEncode(data))
    else
        warn("writefile not supported")
    end
end

-- Load settings
local function LoadSettings()
    if isfile and isfile(SettingsFile) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SettingsFile))
        end)
        if success then
            return decoded
        end
    end
    return {}
end

-- Create window
function NarcoUI:CreateWindow(title)
    local window = Starlight:CreateWindow({
        Title = title or "Narco UI",
        Theme = "Dark"
    })
    return window
end

-- Create tab
function NarcoUI:AddTab(window, name)
    return window:AddTab(name)
end

-- Widgets
function NarcoUI:AddToggle(tab, text, default, callback)
    tab:AddToggle(text, default or false, callback)
end

function NarcoUI:AddSlider(tab, text, min, max, default, callback)
    tab:AddSlider(text, min, max, default or min, callback)
end

function NarcoUI:AddDropdown(tab, text, list, default, callback)
    tab:AddDropdown(text, list, default, callback)
end

function NarcoUI:AddButton(tab, text, callback)
    tab:AddButton(text, callback)
end

function NarcoUI:AddKeybind(tab, text, default, callback)
    tab:AddKeybind(text, default or Enum.KeyCode.Unknown, callback)
end

function NarcoUI:AddColorPicker(tab, text, default, callback)
    tab:AddColorPicker(text, default or Color3.fromRGB(255, 255, 255), callback)
end

-- Save/Load buttons
function NarcoUI:AddSaveLoad(tab, settingsTable)
    self:AddButton(tab, "💾 Save Settings", function()
        SaveSettings(settingsTable)
    end)
    self:AddButton(tab, "📂 Load Settings", function()
        local loaded = LoadSettings()
        for k, v in pairs(loaded) do
            settingsTable[k] = v
        end
    end)
end

return NarcoUI
