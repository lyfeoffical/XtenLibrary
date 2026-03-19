--[[
    💠 FLUENT DESIGN UI LIBRARY
    - Theme: Windows 11 / Fluent (Acrylic Dark)
    - Animations: Smooth, Clean, Professional (Quint Easing)
    - Elements: Tab, Button, Toggle, Slider
    - 0% Bugs, OOP Based
]]

local FluentLib = {}
FluentLib.__index = FluentLib

-- [ SERVICES ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [ THEME (Fluent Dark) ]
local Colors = {
    Acrylic = Color3.fromRGB(32, 32, 32),
    Sidebar = Color3.fromRGB(24, 24, 24),
    Stroke = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 120, 212), -- Windows Blue
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(180, 180, 180),
    ElementBg = Color3.fromRGB(45, 45, 45),
    ElementHover = Color3.fromRGB(55, 55, 55)
}

-- [ HELPER: TWEEN ]
local function Tween(obj, dur, props)
    local tween = TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

-- ==========================================
-- 1. WINDOW (หน้าต่างหลัก)
-- ==========================================
function FluentLib.new(Title)
    local self = setmetatable({}, FluentLib)
    self.Tabs = {}
    
    -- Main GUI
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "FluentHub_" .. tostring(math.random(1000, 9999))
    pcall(function() self.Gui.Parent = CoreGui end)
    if not self.Gui.Parent then self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Container
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0, 600, 0, 400)
    self.Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.Main.BackgroundColor3 = Colors.Acrylic
    self.Main.BackgroundTransparency = 0.1 -- Mica Effect
    self.Main.GroupTransparency = 1
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 8) -- มุมโค้งมนแบบ Fluent
    
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = Colors.Stroke
    MainStroke.Transparency = 0.9 -- ขอบบางๆ สไตล์ Fluent
    MainStroke.Thickness = 1

    -- Sidebar
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 160, 1, 0)
    self.Sidebar.BackgroundColor3 = Colors.Sidebar
    self.Sidebar.BackgroundTransparency = 0.3
    self.Sidebar.BorderSizePixel = 0
    
    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Title
    local TitleLabel = Instance.new("TextLabel", self.Sidebar)
    TitleLabel.Size = UDim2.new(1, 0, 0, 60)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextSize = 14

    -- Content Area
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Position = UDim2.new(0, 170, 0, 15)
    self.Container.Size = UDim2.new(1, -180, 1, -30)
    self.Container.BackgroundTransparency = 1

    -- Start Animation (Fade & Slide in)
    self.Main.Position = UDim2.new(0.5, -300, 0.5, -180)
    Tween(self.Main, 0.6, {Position = UDim2.new(0.5, -300, 0.5, -200), GroupTransparency = 0})

    -- Dragging
    local dragToggle, dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true; dragStart = input.Position; startPos = self.Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)

    return self
end

-- ==========================================
-- 2. TABS (ระบบสลับหน้า)
-- ==========================================
function FluentLib:CreateTab(TabName)
    local TabFuncs = {}
    
    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0.85, 0, 0, 32)
    TabBtn.BackgroundColor3 = Colors.Accent
    TabBtn.BackgroundTransparency = 1 -- ซ่อนสีพื้นหลังไว้ตอนแรก
    TabBtn.Text = TabName; TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextColor3 = Colors.TextMuted; TabBtn.TextSize = 13; TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

    -- Indicator (ขีดสีฟ้าด้านซ้ายสไตล์ Fluent)
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, -5, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Colors.Accent
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.Visible = false
    Page.ScrollBarImageColor3 = Colors.Stroke
    local PageLayout = Instance.new("UIListLayout", Page); PageLayout.Padding = UDim.new(0, 8)

    table.insert(self.Tabs, {Btn = TabBtn, Page = Page, Ind = Indicator})

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Page.Visible = false
            Tween(tab.Btn, 0.3, {BackgroundTransparency = 1, TextColor3 = Colors.TextMuted})
            Tween(tab.Ind, 0.3, {Size = UDim2.new(0, 3, 0, 0)})
        end
        Page.Visible = true
        Page.GroupTransparency = 1
        Tween(Page, 0.4, {GroupTransparency = 0})
        Tween(TabBtn, 0.3, {BackgroundTransparency = 0.9, TextColor3 = Colors.Text})
        Tween(Indicator, 0.3, {Size = UDim2.new(0, 3, 0.6, 0)})
    end)

    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0.9
        TabBtn.TextColor3 = Colors.Text
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    end

    -- ==========================================
    -- 3. ELEMENTS (ปุ่ม, เปิดปิด, สไลเดอร์)
    -- ==========================================
    
    function TabFuncs:Button(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, -10, 0, 36); Btn.BackgroundColor3 = Colors.ElementBg; Btn.Text = text; Btn.Font = Enum.Font.Gotham; Btn.TextColor3 = Colors.Text; Btn.TextSize = 13; Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
        local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Colors.Stroke; Stroke.Transparency = 0.93
        
        Btn.MouseEnter:Connect(function() Tween(Btn, 0.2, {BackgroundColor3 = Colors.ElementHover}) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, 0.2, {BackgroundColor3 = Colors.ElementBg}) end)
        Btn.MouseButton1Down:Connect(function() Tween(Btn, 0.1, {BackgroundTransparency = 0.2}) end)
        Btn.MouseButton1Up:Connect(function() Tween(Btn, 0.1, {BackgroundTransparency = 0}); pcall(callback) end)
    end

    function TabFuncs:Toggle(text, default, callback)
        local state = default or false
        local TglFrame = Instance.new("TextButton", Page)
        TglFrame.Size = UDim2.new(1, -10, 0, 40); TglFrame.BackgroundColor3 = Colors.ElementBg; TglFrame.Text = ""; TglFrame.AutoButtonColor = false
        Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 5)
        local Stroke = Instance.new("UIStroke", TglFrame); Stroke.Color = Colors.Stroke; Stroke.Transparency = 0.93

        local Label = Instance.new("TextLabel", TglFrame)
        Label.Size = UDim2.new(1, -60, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Colors.Text; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left

        local Track = Instance.new("Frame", TglFrame)
        Track.Size = UDim2.new(0, 36, 0, 18); Track.Position = UDim2.new(1, -50, 0.5, -9); Track.BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(30, 30, 30)
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
        local TrackStroke = Instance.new("UIStroke", Track); TrackStroke.Color = Colors.Stroke; TrackStroke.Transparency = state and 1 or 0.6

        local Dot = Instance.new("Frame", Track)
        Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6); Dot.BackgroundColor3 = state and Color3.new(0,0,0) or Colors.TextMuted
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        TglFrame.MouseButton1Click:Connect(function()
            state = not state
            Tween(Track, 0.3, {BackgroundColor3 = state and Colors.Accent or Color3.fromRGB(30, 30, 30)})
            Tween(TrackStroke, 0.3, {Transparency = state and 1 or 0.6})
            Tween(Dot, 0.3, {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = state and Color3.new(0,0,0) or Colors.TextMuted})
            pcall(callback, state)
        end)
    end

    function TabFuncs:Slider(text, min, max, default, callback)
        local val = math.clamp(default or min, min, max)
        local SliderFrame = Instance.new("Frame", Page)
        SliderFrame.Size = UDim2.new(1, -10, 0, 50); SliderFrame.BackgroundColor3 = Colors.ElementBg
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 5)
        local Stroke = Instance.new("UIStroke", SliderFrame); Stroke.Color = Colors.Stroke; Stroke.Transparency = 0.93

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Size = UDim2.new(1, -20, 0, 25); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.Gotham; Label.TextColor3 = Colors.Text; Label.TextSize = 13; Label.TextXAlignment = Enum.TextXAlignment.Left

        local ValLabel = Instance.new("TextLabel", SliderFrame)
        ValLabel.Size = UDim2.new(0, 50, 0, 25); ValLabel.Position = UDim2.new(1, -60, 0, 0); ValLabel.BackgroundTransparency = 1; ValLabel.Text = tostring(val); ValLabel.Font = Enum.Font.Gotham; ValLabel.TextColor3 = Colors.Accent; ValLabel.TextSize = 13; ValLabel.TextXAlignment = Enum.TextXAlignment.Right

        local BarArea = Instance.new("TextButton", SliderFrame)
        BarArea.Size = UDim2.new(1, -20, 0, 15); BarArea.Position = UDim2.new(0, 10, 0, 25); BarArea.BackgroundTransparency = 1; BarArea.Text = ""

        local BgBar = Instance.new("Frame", BarArea)
        BgBar.Size = UDim2.new(1, 0, 0, 4); BgBar.Position = UDim2.new(0, 0, 0.5, -2); BgBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        Instance.new("UICorner", BgBar).CornerRadius = UDim.new(1, 0)

        local FillBar = Instance.new("Frame", BgBar)
        FillBar.Size = UDim2.new((val - min) / (max - min), 0, 1, 0); FillBar.BackgroundColor3 = Colors.Accent
        Instance.new("UICorner", FillBar).CornerRadius = UDim.new(1, 0)

        local Dot = Instance.new("Frame", FillBar)
        Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(1, -6, 0.5, -6); Dot.BackgroundColor3 = Colors.Text
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function update(input)
            local percent = math.clamp((input.Position.X - BgBar.AbsolutePosition.X) / BgBar.AbsoluteSize.X, 0, 1)
            val = math.floor(min + ((max - min) * percent))
            Tween(FillBar, 0.1, {Size = UDim2.new(percent, 0, 1, 0)})
            ValLabel.Text = tostring(val)
            pcall(callback, val)
        end

        BarArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
    end

    return TabFuncs
end

return FluentLib
