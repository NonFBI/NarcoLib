-- NarcoEx UI Library with Original Style + Toggles, Sliders, Dropdowns, Keybinds, ColorPickers & Save/Load
-- Keeps original icon, close button, draggable top bar, two-column layout under Content
-- Smooth tween animations & bluish-purple color theme for controls

local HttpService = game:GetService("HttpService")

local UI = {}
UI.__index = UI

local function TweenObject(obj, properties, duration, style, direction)
	return game:GetService("TweenService"):Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
end

function UI:New(title)
	-- Root ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NarcoExUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = game:GetService("CoreGui")

	-- Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 600, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui

	-- Top Bar (Draggable)
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	TopBar.Parent = MainFrame
	TopBar.Active = true
	TopBar.Draggable = true

	-- Icon
	local Icon = Instance.new("ImageLabel")
	Icon.Name = "Icon"
	Icon.Size = UDim2.new(0, 32, 0, 32)
	Icon.Position = UDim2.new(0, 4, 0.5, -16)
	Icon.BackgroundTransparency = 1
	Icon.Image = "rbxassetid://10734895530" -- Your original icon ID
	Icon.Parent = TopBar

	-- Title Label
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 40, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title or "NarcoEx"
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.Parent = TopBar

	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 40, 1, 0)
	CloseButton.Position = UDim2.new(1, -40, 0, 0)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "✕"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.TextSize = 18
	CloseButton.Parent = TopBar
	CloseButton.MouseEnter:Connect(function()
		TweenObject(CloseButton, {TextColor3 = Color3.fromRGB(200, 50, 50)}, 0.15):Play()
	end)
	CloseButton.MouseLeave:Connect(function()
		TweenObject(CloseButton, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15):Play()
	end)
	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- Content Frame (Below TopBar)
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.Size = UDim2.new(1, 0, 1, -40)
	ContentFrame.Position = UDim2.new(0, 0, 0, 40)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Parent = MainFrame

	-- Left and Right Columns
	local LeftColumn = Instance.new("Frame")
	LeftColumn.Name = "LeftColumn"
	LeftColumn.Size = UDim2.new(0.5, 0, 1, 0)
	LeftColumn.BackgroundTransparency = 1
	LeftColumn.Parent = ContentFrame

	local RightColumn = Instance.new("Frame")
	RightColumn.Name = "RightColumn"
	RightColumn.Size = UDim2.new(0.5, 0, 1, 0)
	RightColumn.Position = UDim2.new(0.5, 0, 0, 0)
	RightColumn.BackgroundTransparency = 1
	RightColumn.Parent = ContentFrame

	-- Tabs container
	local Tabs = {}
	local CurrentTab = nil

	local function CreateTab(name)
		local tab = {}
		tab.Name = name
		tab.LeftParent = Instance.new("Frame")
		tab.LeftParent.BackgroundTransparency = 1
		tab.LeftParent.Size = UDim2.new(1,0,1,0)
		tab.LeftParent.Parent = LeftColumn

		tab.RightParent = Instance.new("Frame")
		tab.RightParent.BackgroundTransparency = 1
		tab.RightParent.Size = UDim2.new(1,0,1,0)
		tab.RightParent.Parent = RightColumn

		-- Clear contents (for tab switching)
		local function ClearChildren()
			for _,v in pairs(tab.LeftParent:GetChildren()) do
				if not v:IsA("UIListLayout") then v:Destroy() end
			end
			for _,v in pairs(tab.RightParent:GetChildren()) do
				if not v:IsA("UIListLayout") then v:Destroy() end
			end
		end

		-- Layouts for spacing
		local leftLayout = Instance.new("UIListLayout")
		leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		leftLayout.Padding = UDim.new(0, 10)
		leftLayout.Parent = tab.LeftParent

		local rightLayout = Instance.new("UIListLayout")
		rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightLayout.Padding = UDim.new(0, 10)
		rightLayout.Parent = tab.RightParent

		-- Utils for adding controls with consistent style
		local themeColor = Color3.fromRGB(102, 51, 153) -- bluish purple

		-- Toggle
		function tab:AddToggle(name, default, callback)
			local toggled = default or false

			local button = Instance.new("TextButton")
			button.Text = name .. ": " .. (toggled and "ON" or "OFF")
			button.Size = UDim2.new(1, 0, 0, 40)
			button.BackgroundColor3 = themeColor
			button.TextColor3 = Color3.fromRGB(255,255,255)
			button.Font = Enum.Font.GothamBold
			button.TextSize = 16
			button.AutoButtonColor = false
			button.Parent = self.LeftParent

			local tweenOn = TweenObject(button, {BackgroundColor3 = themeColor:Lerp(Color3.new(1,1,1), 0.3)}, 0.2)
			local tweenOff = TweenObject(button, {BackgroundColor3 = themeColor}, 0.2)

			button.MouseEnter:Connect(function()
				tweenOn:Play()
			end)
			button.MouseLeave:Connect(function()
				tweenOff:Play()
			end)
			button.MouseButton1Click:Connect(function()
				toggled = not toggled
				button.Text = name .. ": " .. (toggled and "ON" or "OFF")
				callback(toggled)
			end)

			return button
		end

		-- Slider
		function tab:AddSlider(name, default, min, max, step, callback)
			step = step or 1
			local value = default or min

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, 50)
			container.BackgroundTransparency = 1
			container.Parent = self.RightParent

			local label = Instance.new("TextLabel")
			label.Text = string.format("%s: %d", name, value)
			label.Size = UDim2.new(1, 0, 0, 20)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255,255,255)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 16
			label.Parent = container

			local barBackground = Instance.new("Frame")
			barBackground.Size = UDim2.new(1, -20, 0, 20)
			barBackground.Position = UDim2.new(0, 10, 0, 25)
			barBackground.BackgroundColor3 = themeColor:Lerp(Color3.new(0,0,0), 0.8)
			barBackground.Parent = container

			local barFill = Instance.new("Frame")
			barFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			barFill.BackgroundColor3 = themeColor
			barFill.Parent = barBackground

			local dragging = false

			local function UpdateValue(x)
				local relative = math.clamp((x - barBackground.AbsolutePosition.X) / barBackground.AbsoluteSize.X, 0, 1)
				value = math.floor((min + relative * (max - min)) / step + 0.5) * step
				barFill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
				label.Text = string.format("%s: %d", name, value)
				callback(value)
			end

			barBackground.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					UpdateValue(input.Position.X)
				end
			end)

			barBackground.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateValue(input.Position.X)
				end
			end)

			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			return container
		end

		-- Button
		function tab:AddButton(name, callback)
			local button = Instance.new("TextButton")
			button.Text = name
			button.Size = UDim2.new(1, 0, 0, 40)
			button.BackgroundColor3 = themeColor
			button.TextColor3 = Color3.fromRGB(255,255,255)
			button.Font = Enum.Font.GothamBold
			button.TextSize = 16
			button.AutoButtonColor = false
			button.Parent = self.LeftParent

			local tweenOn = TweenObject(button, {BackgroundColor3 = themeColor:Lerp(Color3.new(1,1,1), 0.3)}, 0.2)
			local tweenOff = TweenObject(button, {BackgroundColor3 = themeColor}, 0.2)

			button.MouseEnter:Connect(function()
				tweenOn:Play()
			end)
			button.MouseLeave:Connect(function()
				tweenOff:Play()
			end)
			button.MouseButton1Click:Connect(function()
				callback()
			end)

			return button
		end

		-- Dropdown
		function tab:AddDropdown(name, options, default)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, 40)
			container.BackgroundColor3 = themeColor
			container.Parent = self.RightParent

			local label = Instance.new("TextLabel")
			label.Text = name .. ": " .. (default or options[1])
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255,255,255)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 16
			label.Parent = container

			local expanded = false

			local optionsFrame = Instance.new("Frame")
			optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
			optionsFrame.Position = UDim2.new(0, 0, 1, 2)
			optionsFrame.BackgroundColor3 = themeColor:Lerp(Color3.new(0,0,0), 0.9)
			optionsFrame.Visible = false
			optionsFrame.ClipsDescendants = true
			optionsFrame.Parent = container

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = optionsFrame

			local currentSelection = default or options[1]

			local function SetSelection(option)
				currentSelection = option
				label.Text = name .. ": " .. option
				optionsFrame.Visible = false
			end

			container.MouseButton1Click:Connect(function()
				expanded = not expanded
				optionsFrame.Visible = expanded
			end)

			for _, option in ipairs(options) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 30)
				optBtn.BackgroundColor3 = themeColor
				optBtn.TextColor3 = Color3.fromRGB(255,255,255)
				optBtn.Font = Enum.Font.GothamBold
				optBtn.TextSize = 14
				optBtn.Text = option
				optBtn.Parent = optionsFrame
				optBtn.MouseButton1Click:Connect(function()
					SetSelection(option)
					optionsFrame.Visible = false
					expanded = false
				end)
			end

			return container
		end

		-- Keybind
		function tab:AddKeybind(name, defaultKey, callback)
			local container = Instance.new("TextButton")
			container.Size = UDim2.new(1, 0, 0, 40)
			container.BackgroundColor3 = themeColor
			container.Font = Enum.Font.GothamBold
			container.TextSize = 16
			container.TextColor3 = Color3.fromRGB(255,255,255)
			container.Text = name .. ": " .. (defaultKey and defaultKey.Name or "None")
			container.Parent = self.LeftParent

			local waitingForKey = false

			local UIS = game:GetService("UserInputService")

			container.MouseButton1Click:Connect(function()
				if waitingForKey then return end
				waitingForKey = true
				container.Text = name .. ": Press a key..."
				local conn
				conn = UIS.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						waitingForKey = false
						container.Text = name .. ": " .. input.KeyCode.Name
						callback(input.KeyCode)
						conn:Disconnect()
					end
				end)
			end)

			return container
		end

		-- ColorPicker
		function tab:AddColorPicker(name, defaultColor, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, 60)
			container.BackgroundTransparency = 1
			container.Parent = self.RightParent

			local label = Instance.new("TextLabel")
			label.Text = name
			label.Size = UDim2.new(1, -70, 0, 20)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(255,255,255)
			label.Font = Enum.Font.GothamBold
			label.TextSize = 16
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local colorDisplay = Instance.new("Frame")
			colorDisplay.Size = UDim2.new(0, 50, 0, 30)
			colorDisplay.Position = UDim2.new(1, -55, 0, 15)
			colorDisplay.BackgroundColor3 = defaultColor or Color3.fromRGB(102, 51, 153)
			colorDisplay.BorderSizePixel = 0
			colorDisplay.Parent = container

			-- Simple color picker pop-up
			local pickerOpen = false
			local pickerFrame = Instance.new("Frame")
			pickerFrame.Size = UDim2.new(0, 150, 0, 150)
			pickerFrame.Position = UDim2.new(0, 0, 1, 5)
			pickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			pickerFrame.BorderSizePixel = 0
			pickerFrame.Visible = false
			pickerFrame.Parent = container

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
				else r, g, b = c, 0, x end
				return Color3.new(r+m, g+m, b+m)
			end

			local hue = 0
			local saturation = 1
			local value = 1

			local pickerCanvas = Instance.new("ImageLabel")
			pickerCanvas.Size = UDim2.new(1, 0, 1, 0)
			pickerCanvas.BackgroundTransparency = 1
			pickerCanvas.Image = "rbxassetid://4155801252" -- gradient
			pickerCanvas.Parent = pickerFrame

			local pickerIndicator = Instance.new("Frame")
			pickerIndicator.Size = UDim2.new(0, 10, 0, 10)
			pickerIndicator.BorderColor3 = Color3.fromRGB(255, 255, 255)
			pickerIndicator.BorderSizePixel = 2
			pickerIndicator.BackgroundTransparency = 1
			pickerIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
			pickerIndicator.Position = UDim2.new(hue, 0, 1 - saturation, 0)
			pickerIndicator.Parent = pickerCanvas

			local dragging = false
			pickerCanvas.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local pos = pickerCanvas.AbsolutePosition
					local size = pickerCanvas.AbsoluteSize
					local mouse = game:GetService("UserInputService"):GetMouseLocation()
					local x = math.clamp((mouse.X - pos.X) / size.X, 0, 1)
					local y = math.clamp((mouse.Y - pos.Y) / size.Y, 0, 1)
					hue = x
					saturation = 1 - y
					pickerIndicator.Position = UDim2.new(hue, 0, 1 - saturation, 0)
					local newColor = HSVtoRGB(hue, saturation, value)
					colorDisplay.BackgroundColor3 = newColor
					callback(newColor)
				end
			end)
			pickerCanvas.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			pickerCanvas.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = pickerCanvas.AbsolutePosition
					local size = pickerCanvas.AbsoluteSize
					local mouse = game:GetService("UserInputService"):GetMouseLocation()
					local x = math.clamp((mouse.X - pos.X) / size.X, 0, 1)
					local y = math.clamp((mouse.Y - pos.Y) / size.Y, 0, 1)
					hue = x
					saturation = 1 - y
					pickerIndicator.Position = UDim2.new(hue, 0, 1 - saturation, 0)
					local newColor = HSVtoRGB(hue, saturation, value)
					colorDisplay.BackgroundColor3 = newColor
					callback(newColor)
				end
			end)

			colorDisplay.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					pickerOpen = not pickerOpen
					pickerFrame.Visible = pickerOpen
				end
			end)

			return container
		end

		return tab
	end

	-- Save settings (table) to Player attribute as JSON string
	local function SaveSettings(settings)
		local player = game:GetService("Players").LocalPlayer
		if player then
			pcall(function()
				player:SetAttribute("NarcoExUI_Settings", HttpService:JSONEncode(settings))
			end)
		end
	end

	-- Load settings (returns table or empty table)
	local function LoadSettings()
		local player = game:GetService("Players").LocalPlayer
		if player then
			local json = player:GetAttribute("NarcoExUI_Settings")
			if json then
				local success, data = pcall(function()
					return HttpService:JSONDecode(json)
				end)
				if success and type(data) == "table" then
					return data
				end
			end
		end
		return {}
	end

	-- Library object
	local self = setmetatable({
		ScreenGui = ScreenGui,
		MainFrame = MainFrame,
		TopBar = TopBar,
		LeftColumn = LeftColumn,
		RightColumn = RightColumn,
		Tabs = Tabs,
		CurrentTab = nil,
		Settings = LoadSettings(),
		SaveSettings = SaveSettings,
		LoadSettings = LoadSettings,
		CreateTab = function(self, name)
			local tab = CreateTab(name)
			table.insert(self.Tabs, tab)
			if not self.CurrentTab then
				self.CurrentTab = tab
			else
				-- Hide tabs by default
				tab.LeftParent.Visible = false
				tab.RightParent.Visible = false
			end
			-- Show current tab parents only
			for _, t in pairs(self.Tabs) do
				t.LeftParent.Visible = (t == self.CurrentTab)
				t.RightParent.Visible = (t == self.CurrentTab)
			end
			return tab
		end,
	}, UI)

	return self
end

return UI
