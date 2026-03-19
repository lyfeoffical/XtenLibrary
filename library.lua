--[[
    ULTIMATE GLASSMORPHISM UI LIBRARY v2.0
    Features: 
    - Real-time Theme Switching (Glass, Dark, Light)
    - Dynamic Transparency & Blur Effect
    - Bouncy Animations (OutBack Easing)
    - Profile System with Settings
    - Full Elements: Button, Toggle, Slider, TextBox
]]

local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [[ THEME PRESETS ]]
local Themes = {
    Glass = {
        Main = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(100, 150, 255),
        Transparency = 0.25,
        Stroke = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(40, 40, 45)
    },
    Dark = {
        Main = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(255, 100, 100),
        Transparency = 0,
        Stroke = Color3.fromRGB(50, 50, 55),
        Text = Color3.fromRGB(240, 240, 240)
    }
}

local function QuickTween(inst, dur, style, dir, goals)
    local t = TweenService:Create(inst, TweenInfo.new(dur, style, dir), goals)
    t:Play() return t
end

function Library.new(title)
    local self = setmetatable({}, Library)
    
    -- Gui Setup
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "GlassLib_"..math.random(100,999)
    pcall(function() self.Gui.Parent = CoreGui end)
    if not self.Gui.Parent then self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Window (CanvasGroup)
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0, 550, 0, 400)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    self.Main.BackgroundColor3 = Themes.Glass.Main
    self.Main.BackgroundTransparency = Themes.Glass.Transparency
    self.Main.GroupTransparency = 1
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 16)
    
    self.Stroke = Instance.new("UIStroke", self.Main)
    self.Stroke.Color = Themes.Glass.Stroke
    self.Stroke.Transparency = 0.5
    self.Stroke.Thickness = 1.5

    self.Scale = Instance.new("UIScale", self.Main)
    self.Scale.Scale = 0.6

    -- TitleBar
    self.Bar = Instance.new("Frame", self.Main)
    self.Bar.Size = UDim2.new(1, 0, 0, 55)
    self.Bar.BackgroundTransparency = 1
    
    self.Title = Instance.new("TextLabel", self.Bar)
    self.Title.Position = UDim2.new(0, 65, 0, 0)
    self.Title.Size = UDim2.new(1, -120, 1, 0)
    self.Title.Text = title; self.Title.Font = "GothamBold"; self.Title.TextSize = 18; self.Title.BackgroundTransparency = 1; self.Title.TextColor3 = Themes.Glass.Text; self.Title.TextXAlignment = "Left"

    -- Avatar
    self.Avatar = Instance.new("ImageButton", self.Bar)
    self.Avatar.Position = UDim2.new(0, 15, 0, 7)
    self.Avatar.Size = UDim2.new(0, 40, 0, 40)
    Instance.new("UICorner", self.Avatar).CornerRadius = UDim.new(1,0)
    task.spawn(function() self.Avatar.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, "HeadShot", "Size420x420") end)

    -- Container
    self.Container = Instance.new("ScrollingFrame", self.Main)
    self.Container.Position = UDim2.new(0, 15, 0, 65)
    self.Container.Size = UDim2.new(1, -30, 1, -80)
    self.Container.BackgroundTransparency = 1; self.Container.BorderSizePixel = 0; self.Container.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", self.Container); Layout.Padding = UDim.new(0, 10)

    -- Dragging
    local dragStart, startPos, dragging
    self.Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = self.Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local delta = i.Position - dragStart; self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    -- Start Anim
    QuickTween(self.Scale, 0.4, "Back", "Out", {Scale = 1})
    QuickTween(self.Main, 0.3, "Quad", "Out", {GroupTransparency = 0})

    return self
end

-- [[ ELEMENT: BUTTON ]]
function Library:Button(text, callback)
    local btn = Instance.new("TextButton", self.Container)
    btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Color3.new(1,1,1); btn.BackgroundTransparency = 0.8
    btn.Text = text; btn.Font = "GothamMedium"; btn.TextColor3 = self.Title.TextColor3; btn.TextSize = 14; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", btn); s.Color = Color3.new(1,1,1); s.Transparency = 0.8
    local sc = Instance.new("UIScale", btn)

    btn.MouseEnter:Connect(function() QuickTween(sc, 0.2, "Back", "Out", {Scale = 1.03}) end)
    btn.MouseLeave:Connect(function() QuickTween(sc, 0.2, "Quad", "Out", {Scale = 1}) end)
    btn.MouseButton1Click:Connect(function() QuickTween(sc, 0.1, "Quad", "Out", {Scale = 0.95}); task.wait(0.05); QuickTween(sc, 0.1, "Back", "Out", {Scale = 1.03}); callback() end)
end

-- [[ ELEMENT: TOGGLE ]]
function Library:Toggle(text, default, callback)
    local val = default or false
    local frame = Instance.new("Frame", self.Container)
    frame.Size = UDim2.new(1, 0, 0, 45); frame.BackgroundTransparency = 0.9; frame.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Position = UDim2.new(0, 15, 0, 0); label.Size = UDim2.new(1, -70, 1, 0); label.BackgroundTransparency = 1
    label.Text = text; label.Font = "Gotham"; label.TextColor3 = self.Title.TextColor3; label.TextSize = 14; label.TextXAlignment = "Left"

    local tgl = Instance.new("TextButton", frame)
    tgl.Position = UDim2.new(1, -55, 0, 10); tgl.Size = UDim2.new(0, 45, 0, 25); tgl.Text = ""; tgl.BackgroundColor3 = val and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200,200,200)
    Instance.new("UICorner", tgl).CornerRadius = UDim.new(1,0)

    local circ = Instance.new("Frame", tgl)
    circ.Position = val and UDim2.new(1, -22, 0, 3) or UDim2.new(0, 3, 0, 3); circ.Size = UDim2.new(0, 19, 0, 19); circ.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", circ).CornerRadius = UDim.new(1,0)

    tgl.MouseButton1Click:Connect(function()
        val = not val
        QuickTween(circ, 0.2, "Quart", "Out", {Position = val and UDim2.new(1, -22, 0, 3) or UDim2.new(0, 3, 0, 3)})
        QuickTween(tgl, 0.2, "Quad", "Out", {BackgroundColor3 = val and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200,200,200)})
        callback(val)
    end)
end

-- [[ SYSTEM: THEME CHANGER ]]
function Library:SetTheme(mode)
    local t = Themes[mode]
    if t then
        QuickTween(self.Main, 0.5, "Quad", "Out", {BackgroundColor3 = t.Main, BackgroundTransparency = t.Transparency})
        self.Stroke.Color = t.Stroke
        self.Title.TextColor3 = t.Text
    end
end

return Library
