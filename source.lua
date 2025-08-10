-- UILibrary.lua
-- Refactored version of your NarcoEx UI with functional tabs, sliders, toggles, dropdowns
-- by ChatGPT, based on original UI from hold4564

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

-- Utility Functions
local function Tween(obj, time, props)
	return TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(frame, dragHandle)
	local dragging, dragInput, startPos, startInputPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInputPos = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - startInputPos
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Create Main UI
function Library.new(title)
	local self = setmetatable({}, Library)
	
	self.ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	self.ScreenGui.Name = "NarcoExUI"
	
	self.Main = Instance.new("Frame", self.ScreenGui)
	self.Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	self.Main.Size = UDim2.new(0, 766, 0, 480)
	self.Main.Position = UDim2.new(0.3, 0, 0.28, 0)
	Instance.new("UICorner", self.Main)
	
	-- Topbar
	self.Topbar = Instance.new("Frame", self.ScreenGui)
	self.Topbar.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
	self.Topbar.Size = UDim2.new(0, 766, 0, 55)
	self.Topbar.Position = UDim2.new(0.3, 0, 0.279, 0)
	Instance.new("UICorner", self.Topbar)
	MakeDraggable(self.Main, self.Topbar)

	local titleLabel = Instance.new("TextLabel", self.Topbar)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0, 200, 1, 0)
	titleLabel.Font = Enum.Font.SourceSans
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 20
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.Position = UDim2.new(0.05, 0, 0, 0)

	-- Tab list
	self.TabHolder = Instance.new("Frame", self.ScreenGui)
	self.TabHolder.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	self.TabHolder.Size = UDim2.new(0, 161, 0, 428)
	self.TabHolder.Position = UDim2.new(0.2938, 0, 0.4275, 0)
	Instance.new("UICorner", self.TabHolder)

	local tabLayout = Instance.new("UIListLayout", self.TabHolder)
	tabLayout.Padding = UDim.new(0, 8)

	self.ContentHolder = Instance.new("Frame", self.Main)
	self.ContentHolder.BackgroundTransparency = 1
	self.ContentHolder.Size = UDim2.new(0.78, 0, 0.87, 0)
	self.ContentHolder.Position = UDim2.new(0.22, 0, 0.13, 0)

	self.Tabs = {}
	
	return self
end

-- Add Tab
function Library:AddTab(tabName)
	local tabButton = Instance.new("TextButton", self.TabHolder)
	tabButton.Size = UDim2.new(0, 152, 0, 34)
	tabButton.BackgroundTransparency = 0.98
	tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabButton.Font = Enum.Font.RobotoMono
	tabButton.TextSize = 20
	tabButton.Text = tabName
	Instance.new("UICorner", tabButton)
	
	local tabFrame = Instance.new("Frame", self.ContentHolder)
	tabFrame.Size = UDim2.new(1, 0, 1, 0)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = false
	
	local layout = Instance.new("UIListLayout", tabFrame)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0.01, 0)
	
	self.Tabs[tabName] = {Frame = tabFrame, Groups = {}}
	
	tabButton.MouseButton1Click:Connect(function()
		for name, tab in pairs(self.Tabs) do
			tab.Frame.Visible = (name == tabName)
		end
	end)
	
	if #self.Tabs == 1 then
		tabFrame.Visible = true
	end
	
	return self.Tabs[tabName]
end

-- Add Group Box
function Library:AddGroupBox(tab, name)
	local groupFrame = Instance.new("Frame", tab.Frame)
	groupFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	groupFrame.Size = UDim2.new(0.5, -5, 1, 0)
	Instance.new("UICorner", groupFrame)
	
	local title = Instance.new("TextLabel", groupFrame)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Font = Enum.Font.RobotoMono
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Text = name
	
	local contentLayout = Instance.new("UIListLayout", groupFrame)
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	
	table.insert(tab.Groups, groupFrame)
	return groupFrame
end

-- Add Slider
function Library:AddSlider(group, name, min, max, default, callback)
	local sliderFrame = Instance.new("Frame", group)
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Size = UDim2.new(1, 0, 0, 40)
	
	local label = Instance.new("TextLabel", sliderFrame)
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.RobotoMono
	label.TextSize = 16
	
	local bar = Instance.new("Frame", sliderFrame)
	bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	bar.Size = UDim2.new(1, 0, 0, 8)
	bar.Position = UDim2.new(0, 0, 0.6, 0)
	Instance.new("UICorner", bar)
	
	local fill = Instance.new("Frame", bar)
	fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	Instance.new("UICorner", fill)
	
	local dragging = false
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relPos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			Tween(fill, 0.1, {Size = UDim2.new(relPos, 0, 1, 0)})
			local value = math.floor(min + (max - min) * relPos)
			callback(value)
		end
	end)
end

-- Add Toggle
function Library:AddToggle(group, name, default, callback)
	local toggleFrame = Instance.new("Frame", group)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Size = UDim2.new(1, 0, 0, 30)
	
	local button = Instance.new("TextButton", toggleFrame)
	button.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
	button.Size = UDim2.new(0, 40, 0, 20)
	Instance.new("UICorner", button)
	
	local state = default
	button.MouseButton1Click:Connect(function()
		state = not state
		Tween(button, 0.2, {BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)})
		callback(state)
	end)
	
	local label = Instance.new("TextLabel", toggleFrame)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 50, 0, 0)
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Font = Enum.Font.RobotoMono
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = name
end

-- Add Dropdown
function Library:AddDropdown(group, name, options, default, callback)
	local dropdownFrame = Instance.new("Frame", group)
	dropdownFrame.BackgroundTransparency = 1
	dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
	
	local button = Instance.new("TextButton", dropdownFrame)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.Size = UDim2.new(1, 0, 1, 0)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.RobotoMono
	button.TextSize = 16
	button.Text = name .. ": " .. default
	Instance.new("UICorner", button)
	
	local open = false
	local optionContainer
	
	button.MouseButton1Click:Connect(function()
		if not open then
			open = true
			optionContainer = Instance.new("Frame", group)
			optionContainer.BackgroundTransparency = 1
			optionContainer.Size = UDim2.new(1, 0, 0, #options * 25)
			
			for _, option in ipairs(options) do
				local optBtn = Instance.new("TextButton", optionContainer)
				optBtn.Size = UDim2.new(1, 0, 0, 25)
				optBtn.BackgroundTransparency = 1
				optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				optBtn.Font = Enum.Font.RobotoMono
				optBtn.TextSize = 14
				optBtn.Text = option
				optBtn.MouseButton1Click:Connect(function()
					button.Text = name .. ": " .. option
					callback(option)
					optionContainer:Destroy()
					open = false
				end)
			end
		else
			if optionContainer then optionContainer:Destroy() end
			open = false
		end
	end)
end

return Library
