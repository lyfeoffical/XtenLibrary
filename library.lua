--[[
    LIGHTWEIGHT BOUNCY UI LIBRARY (LIGHT MODE)
    Author: YourName
    Features: 
    - Custom Smooth Animations (OutBack)
    - Profile & Settings System
    - Light Theme (Clean Look)
    - Fully Responsive Elements
]]

local Library = {}
Library.__index = Library

-- [[ SERVICES ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [[ THEME CONFIGURATION ]]
local Theme = {
	WindowBackground = Color3.fromRGB(245, 245, 250),
	TitleBar = Color3.fromRGB(255, 255, 255),
	TitleLine = Color3.fromRGB(230, 230, 235),
	ContainerBackground = Color3.fromRGB(250, 250, 255),
	ItemBackground = Color3.fromRGB(255, 255, 255),
	ItemHover = Color3.fromRGB(240, 240, 245),
	ItemPressed = Color3.fromRGB(230, 230, 235),
	TextPrimary = Color3.fromRGB(30, 30, 35),
	TextSecondary = Color3.fromRGB(130, 130, 140),
	Stroke = Color3.fromRGB(220, 220, 225),
	Accent = Color3.fromRGB(80, 80, 255),
	ToggleOff = Color3.fromRGB(220, 220, 225),
	ToggleOn = Color3.fromRGB(80, 80, 255),
}

-- [[ PRIVATE HELPERS ]]
local function CreateTween(instance, duration, style, direction, goals)
	local tweenInfo = TweenInfo.new(duration, style, direction)
	local tween = TweenService:Create(instance, tweenInfo, goals)
	tween:Play()
	return tween
end

-- [[ MAIN LIBRARY METHODS ]]

function Library.new(titleText)
	local self = setmetatable({}, Library)

	-- Main Gui
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "CustomLibrary_v1"
	self.Gui.ResetOnSpawn = false
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Automatic Parent Detection
	pcall(function() self.Gui.Parent = CoreGui end)
	if not self.Gui.Parent then self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

	-- Window (CanvasGroup for fading)
	self.MainFrame = Instance.new("CanvasGroup") 
	self.MainFrame.BackgroundColor3 = Theme.WindowBackground
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200) 
	self.MainFrame.Size = UDim2.new(0, 560, 0, 400)
	self.MainFrame.GroupTransparency = 1 
	self.MainFrame.Parent = self.Gui
	
	Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 12)
	local windowStroke = Instance.new("UIStroke", self.MainFrame)
	windowStroke.Color = Theme.Stroke
	windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	self.UIScale = Instance.new("UIScale", self.MainFrame)
	self.UIScale.Scale = 0.5

	-- Title Bar
	self.TitleBar = Instance.new("Frame")
	self.TitleBar.BackgroundColor3 = Theme.TitleBar
	self.TitleBar.Size = UDim2.new(1, 0, 0, 50)
	self.TitleBar.Parent = self.MainFrame
	
	local line = Instance.new("Frame", self.TitleBar)
	line.Size = UDim2.new(1,0,0,1)
	line.Position = UDim2.new(0,0,1,0)
	line.BackgroundColor3 = Theme.TitleLine
	line.BorderSizePixel = 0

	-- Avatar & Title
	self.Avatar = Instance.new("ImageButton", self.TitleBar)
	self.Avatar.Position = UDim2.new(0, 10, 0, 5)
	self.Avatar.Size = UDim2.new(0, 40, 0, 40)
	self.Avatar.BackgroundTransparency = 1
	Instance.new("UICorner", self.Avatar).CornerRadius = UDim.new(1, 0)
	
	task.spawn(function()
		local content = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		self.Avatar.Image = content
	end)

	self.TitleLabel = Instance.new("TextLabel", self.TitleBar)
	self.TitleLabel.Position = UDim2.new(0, 60, 0, 0)
	self.TitleLabel.Size = UDim2.new(1, -110, 1, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Font = Enum.Font.GothamBold
	self.TitleLabel.Text = titleText or "UI LIBRARY"
	self.TitleLabel.TextColor3 = Theme.TextPrimary
	self.TitleLabel.TextSize = 18
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Close Button
	local close = Instance.new("TextButton", self.TitleBar)
	close.Position = UDim2.new(1, -40, 0, 10)
	close.Size = UDim2.new(0, 30, 0, 30)
	close.BackgroundTransparency = 1
	close.Text = "×"
	close.TextColor3 = Theme.TextSecondary
	close.TextSize = 24
	close.MouseButton1Click:Connect(function()
		CreateTween(self.UIScale, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, {Scale = 0.6})
		CreateTween(self.MainFrame, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {GroupTransparency = 1}).Completed:Wait()
		self.Gui:Destroy()
	end)

	-- Page Containers
	self.MainPage = Instance.new("ScrollingFrame", self.MainFrame)
	self.MainPage.Position = UDim2.new(0, 10, 0, 60)
	self.MainPage.Size = UDim2.new(1, -20, 1, -70)
	self.MainPage.BackgroundTransparency = 1
	self.MainPage.BorderSizePixel = 0
	self.MainPage.ScrollBarThickness = 2
	Instance.new("UIListLayout", self.MainPage).Padding = UDim.new(0, 10)

	self.SettingPage = Instance.new("ScrollingFrame", self.MainFrame)
	self.SettingPage.Position = UDim2.new(1, 10, 0, 60) -- Off-screen
	self.SettingPage.Size = UDim2.new(1, -20, 1, -70)
	self.SettingPage.BackgroundTransparency = 1
	self.SettingPage.Visible = false
	Instance.new("UIListLayout", self.SettingPage).Padding = UDim.new(0, 10)

	-- Dragging Logic
	local dragStart, startPos, dragging
	self.TitleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = self.MainFrame.Position end end)
	UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart; self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

	-- Open Animation
	CreateTween(self.UIScale, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1})
	CreateTween(self.MainFrame, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {GroupTransparency = 0})

	-- Profile Switch Logic
	local isSettings = false
	self.Avatar.MouseButton1Click:Connect(function()
		if isSettings then return end
		isSettings = true
		self.SettingPage.Visible = true
		CreateTween(self.MainPage, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(-1, 0, 0, 60)})
		CreateTween(self.SettingPage, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(0, 10, 0, 60)})
		
		local back = Instance.new("TextButton", self.TitleBar)
		back.Size = UDim2.new(0, 60, 0, 30); back.Position = UDim2.new(0, 60, 0, 10)
		back.Text = "< Back"; back.TextColor3 = Theme.Accent; back.BackgroundTransparency = 1; back.Font = Enum.Font.Gotham; back.TextSize = 14
		self.TitleLabel.Visible = false
		
		back.MouseButton1Click:Connect(function()
			isSettings = false
			CreateTween(self.MainPage, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(0, 10, 0, 60)})
			CreateTween(self.SettingPage, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(1, 0, 0, 60)})
			back:Destroy(); self.TitleLabel.Visible = true
		end)
	end)

	return self
end

function Library:CreateButton(text, page, callback)
	local target = page or self.MainPage
	local btn = Instance.new("TextButton", target)
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.BackgroundColor3 = Theme.ItemBackground
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Theme.TextPrimary
	btn.TextSize = 14
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local s = Instance.new("UIStroke", btn); s.Color = Theme.Stroke; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local scale = Instance.new("UIScale", btn)

	btn.MouseEnter:Connect(function() CreateTween(scale, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1.03}) end)
	btn.MouseLeave:Connect(function() CreateTween(scale, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Scale = 1}) end)
	btn.MouseButton1Down:Connect(function() CreateTween(scale, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Scale = 0.97}) end)
	btn.MouseButton1Up:Connect(function() CreateTween(scale, 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1.03}); if callback then callback() end end)
end

function Library:CreateToggle(text, page, default, callback)
	local target = page or self.MainPage
	local val = default or false
	local frame = Instance.new("Frame", target)
	frame.Size = UDim2.new(1, -10, 0, 45); frame.BackgroundColor3 = Theme.ItemBackground
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", frame).Color = Theme.Stroke

	local label = Instance.new("TextLabel", frame)
	label.Text = text; label.Position = UDim2.new(0, 15, 0, 0); label.Size = UDim2.new(1, -80, 1, 0)
	label.BackgroundTransparency = 1; label.TextColor3 = Theme.TextPrimary; label.Font = Enum.Font.GothamMedium; label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left

	local tgl = Instance.new("TextButton", frame)
	tgl.Size = UDim2.new(0, 44, 0, 22); tgl.Position = UDim2.new(1, -55, 0, 11); tgl.Text = ""; tgl.BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff
	Instance.new("UICorner", tgl).CornerRadius = UDim.new(1, 0)

	local circ = Instance.new("Frame", tgl)
	circ.Size = UDim2.new(0, 18, 0, 18); circ.Position = val and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2); circ.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)

	tgl.MouseButton1Click:Connect(function()
		val = not val
		CreateTween(circ, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = val and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)})
		CreateTween(tgl, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = val and Theme.ToggleOn or Theme.ToggleOff})
		if callback then callback(val) end
	end)
end

return Library
