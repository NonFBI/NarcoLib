local NarcoEx = {}
NarcoEx.__index = NarcoEx
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
-- Helper function for creating gradients
local function createGradient(parent)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(238, 0, 255)),
ColorSequenceKeypoint.new(0.54, Color3.fromRGB(79, 0, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(131, 255, 220))
})
gradient.Parent = parent
return gradient
end
-- Helper for smooth tween
local function tween(object, properties, duration, easingStyle)
local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(object, tweenInfo, properties):Play()
end
function NarcoEx:CreateWindow(title)
local self = setmetatable({}, NarcoEx)
self.ScreenGui = Instance.new("ScreenGui")
self.ScreenGui.Parent = CoreGui
self.MainFrame = Instance.new("Frame")
self.MainFrame.Size = UDim2.new(0, 767, 0, 480)
self.MainFrame.Position = UDim2.new(0.5, -383.5, 0.5, -240)
self.MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
self.MainFrame.Parent = self.ScreenGui
Instance.new("UICorner", self.MainFrame)
self.Topbar = Instance.new("Frame")
self.Topbar.Size = UDim2.new(1, 0, 0, 55)
self.Topbar.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
self.Topbar.Parent = self.MainFrame
Instance.new("UICorner", self.Topbar)
self.TitleLabel = Instance.new("TextLabel")
self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
self.TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
self.TitleLabel.BackgroundTransparency = 1
self.TitleLabel.Text = title or "NarcoEx"
self.TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
self.TitleLabel.TextSize = 20
self.TitleLabel.Font = Enum.Font.SourceSans
self.TitleLabel.Parent = self.Topbar
self.CloseButton = Instance.new("ImageButton")
self.CloseButton.Size = UDim2.new(0, 22, 0, 22)
self.CloseButton.Position = UDim2.new(0.97, -11, 0.5, -11)
self.CloseButton.BackgroundTransparency = 1
self.CloseButton.Image = "rbxassetid://10734895530"
self.CloseButton.Parent = self.Topbar
self.TabContainer = Instance.new("Frame")
self.TabContainer.Size = UDim2.new(0, 161, 1, -55)
self.TabContainer.Position = UDim2.new(0, 0, 0, 55)
self.TabContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
self.TabContainer.Parent = self.MainFrame
Instance.new("UICorner", self.TabContainer)
local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.Parent = self.TabContainer
self.TabListLayout = Instance.new("UIListLayout")
self.TabListLayout.Padding = UDim.new(0, 8)
self.TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
self.TabListLayout.Parent = self.TabContainer
self.ContentFrame = Instance.new("Frame")
self.ContentFrame.Size = UDim2.new(1, -161, 1, -55)
self.ContentFrame.Position = UDim2.new(0, 161, 0, 55)
self.ContentFrame.BackgroundTransparency = 1
self.ContentFrame.Parent = self.MainFrame
-- Columns for groupboxes
self.LeftColumn = Instance.new("Frame")
self.LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
self.LeftColumn.BackgroundTransparency = 1
self.LeftColumn.Parent = self.ContentFrame
self.LeftColumnLayout = Instance.new("UIListLayout")
self.LeftColumnLayout.SortOrder = Enum.SortOrder.LayoutOrder
self.LeftColumnLayout.Padding = UDim.new(0, 10)
self.LeftColumnLayout.Parent = self.LeftColumn
self.RightColumn = Instance.new("Frame")
self.RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
self.RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
self.RightColumn.BackgroundTransparency = 1
self.RightColumn.Parent = self.ContentFrame
self.RightColumnLayout = Instance.new("UIListLayout")
self.RightColumnLayout.SortOrder = Enum.SortOrder.LayoutOrder
self.RightColumnLayout.Padding = UDim.new(0, 10)
self.RightColumnLayout.Parent = self.RightColumn
self.Tabs = {}
self.Sections = {}
self.CurrentTab = nil
self.Minimized = false
-- Close/Minimize functionality
self.CloseButton.MouseButton1Click:Connect(function()
self:Minimize()
end)
-- Toggle with LeftCtrl
UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == Enum.KeyCode.LeftControl then
if self.Minimized then
self:Maximize()
else
self:Minimize()
end
end
end)
return self
end
function NarcoEx:Minimize()
if self.Minimized then return end
self.Minimized = true
tween(self.MainFrame, {Size = UDim2.new(0, 767, 0, 0)}, 0.5, Enum.EasingStyle.Quint)
end
function NarcoEx:Maximize()
if not self.Minimized then return end
self.Minimized = false
tween(self.MainFrame, {Size = UDim2.new(0, 767, 0, 480)}, 0.5, Enum.EasingStyle.Quint)
end
function NarcoEx:AddSection(name)
local section = Instance.new("TextLabel")
section.Size = UDim2.new(1, -10, 0, 22)
section.BackgroundTransparency = 1
section.Text = name
section.TextColor3 = Color3.fromRGB(208, 208, 208)
section.TextSize = 18
section.Font = Enum.Font.SourceSans
section.TextXAlignment = Enum.TextXAlignment.Left
section.Parent = self.TabContainer
table.insert(self.Sections, section)
return section
end
function NarcoEx:AddTab(name, section)
local tab = {}
tab.Name = name
tab.Button = Instance.new("TextButton")
tab.Button.Size = UDim2.new(1, -10, 0, 34)
tab.Button.BackgroundTransparency = 1
tab.Button.Text = name
tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
tab.Button.TextSize = 22
tab.Button.Font = Enum.Font.SourceSans
Instance.new("UICorner", tab.Button)
tab.Container = Instance.new("Frame")
tab.Container.Size = UDim2.new(1, 0, 1, 0)
tab.Container.BackgroundTransparency = 1
tab.Container.Visible = false
tab.Container.Parent = self.ContentFrame
-- Re-parent columns to tab container
self.LeftColumn.Parent = tab.Container
self.RightColumn.Parent = tab.Container
if section then
tab.Button.Parent = section
else
tab.Button.Parent = self.TabContainer
end
tab.Button.MouseButton1Click:Connect(function()
self:SelectTab(tab)
end)
table.insert(self.Tabs, tab)
if not self.CurrentTab then
self:SelectTab(tab)
end
function tab:AddGroupbox(name, column)
local groupbox = Instance.new("Frame")
groupbox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", groupbox)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = name
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.SourceSans
title.Parent = groupbox
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Parent = groupbox
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = content
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 5)
padding.Parent = content
-- Auto-size height
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
groupbox.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 40)
end)
if column == "right" then
groupbox.Parent = self.RightColumn
groupbox.Size = UDim2.new(1, 0, 0, 100) -- Initial
else
groupbox.Parent = self.LeftColumn
groupbox.Size = UDim2.new(1, 0, 0, 100) -- Initial
end
-- Add elements functions
function groupbox:AddToggle(options)
local toggle = Instance.new("Frame")
toggle.Size = UDim2.new(1, -10, 0, 30)
toggle.BackgroundTransparency = 1
toggle.Parent = content
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.8, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = options.text or "Toggle"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 16
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = toggle
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 20, 0, 20)
button.Position = UDim2.new(1, -20, 0.5, -10)
button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
button.Text = ""
Instance.new("UICorner", button)
button.Parent = toggle
local value = options.default or false
local function update()
button.BackgroundColor3 = value and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end
update()
button.MouseButton1Click:Connect(function()
value = not value
update()
if options.callback then options.callback(value) end
end)
return {GetValue = function() return value end, SetValue = function(v) value = v; update() end}
end
function groupbox:AddSlider(options)
local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, -10, 0, 40)
slider.BackgroundTransparency = 1
slider.Parent = content
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.5, 0)
label.BackgroundTransparency = 1
label.Text = options.text or "Slider"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 16
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = slider
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, 0, 0.2, 0)
sliderBar.Position = UDim2.new(0, 0, 0.6, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", sliderBar)
createGradient(sliderBar) -- Gradient for filler
sliderBar.Parent = slider
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.5, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
Instance.new("UICorner", fill)
fill.Parent = sliderBar
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(0, 50, 1, 0)
valueLabel.Position = UDim2.new(1, 0, 0, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valueLabel.TextSize = 14
valueLabel.Parent = sliderBar
local min = options.min or 0
local max = options.max or 100
local value = options.default or min
local function update()
local percent = (value - min) / (max - min)
tween(fill, {Size = UDim2.new(percent, 0, 1, 0)})
valueLabel.Text = tostring(value)
end
update()
sliderBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
local function drag(input)
local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
value = min + (max - min) * percent
if options.step then value = math.round(value / options.step) * options.step end
update()
if options.callback then options.callback(value) end
end
drag(input)
local conn = UserInputService.InputChanged:Connect(function(inp)
if inp.UserInputType == Enum.UserInputType.MouseMovement then drag(inp) end
end)
input.InputEnded:Connect(function(inp)
if inp.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
end)
end
end)
return {GetValue = function() return value end, SetValue = function(v) value = math.clamp(v, min, max); update() end}
end
function groupbox:AddDropdown(options)
local dropdown = Instance.new("Frame")
dropdown.Size = UDim2.new(1, -10, 0, 30)
dropdown.BackgroundTransparency = 1
dropdown.Parent = content
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.Text = options.text or "Select"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
Instance.new("UICorner", button)
button.Parent = dropdown
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0, 100)
listFrame.Position = UDim2.new(0, 0, 1, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.Visible = false
listFrame.ScrollBarThickness = 4
Instance.new("UICorner", listFrame)
listFrame.Parent = dropdown
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listFrame
local value = options.default
local items = options.items or {}
local function updateList()
listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end
local function toggleList()
listFrame.Visible = not listFrame.Visible
end
button.MouseButton1Click:Connect(toggleList)
for _, item in ipairs(items) do
local opt = Instance.new("TextButton")
opt.Size = UDim2.new(1, 0, 0, 25)
opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
opt.Text = item
opt.TextColor3 = Color3.fromRGB(255, 255, 255)
opt.TextSize = 14
Instance.new("UICorner", opt)
opt.Parent = listFrame
opt.MouseButton1Click:Connect(function()
value = item
button.Text = item
toggleList()
if options.callback then options.callback(value) end
end)
end
updateList()
return {GetValue = function() return value end, SetValue = function(v) value = v; button.Text = v end, AddItem = function(item)
table.insert(items, item)
local opt = Instance.new("TextButton")
opt.Size = UDim2.new(1, 0, 0, 25)
opt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
opt.Text = item
opt.TextColor3 = Color3.fromRGB(255, 255, 255)
opt.TextSize = 14
Instance.new("UICorner", opt)
opt.Parent = listFrame
opt.MouseButton1Click:Connect(function()
value = item
button.Text = item
toggleList()
if options.callback then options.callback(value) end
end)
updateList()
end}
end
-- Add more elements as needed (e.g., buttons, labels, etc.)
return groupbox
end
return tab
end
function NarcoEx:SelectTab(tab)
if self.CurrentTab == tab then return end
if self.CurrentTab then
self.CurrentTab.Container.Visible = false
self.CurrentTab.Button.BackgroundTransparency = 1
if self.CurrentTab.Button:FindFirstChild("UIGradient") then
self.CurrentTab.Button.UIGradient:Destroy()
end
end
self.CurrentTab = tab
tab.Container.Visible = true
tab.Button.BackgroundTransparency = 0.75
createGradient(tab.Button)
-- Reset columns to new tab
self.LeftColumn.Parent = tab.Container
self.RightColumn.Parent = tab.Container
end