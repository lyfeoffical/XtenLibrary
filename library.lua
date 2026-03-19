--[[
    ZENITH UI LIBRARY v3.0 (ULTIMATE EDITION)
    - Theme: Modern Glass / Neon
    - System: Bouncy OOP Framework
]]

local ZenithLib = {}
ZenithLib.__index = ZenithLib

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Helper Functions
local function Ripple(obj)
    -- ฟังก์ชันทำ Effect คลื่นเวลาคลิก (Optional)
end

local function ApplyTween(inst, dur, style, dir, goals)
    local info = TweenInfo.new(dur, Enum.EasingStyle[style], Enum.EasingDirection[direction or "Out"])
    local tween = TweenService:Create(inst, info, goals)
    tween:Play()
    return tween
end

-- [[ MAIN LIBRARY CONSTRUCTOR ]]
function ZenithLib.new(hubName)
    local self = setmetatable({}, ZenithLib)
    
    -- Root Gui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "Zenith_" .. math.random(1000)
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() self.Gui.Parent = CoreGui end)
    if not self.Gui.Parent then self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Frame (The Glass)
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0, 500, 0, 380)
    self.Main.Position = UDim2.new(0.5, -250, 0.5, -190)
    self.Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self.Main.BackgroundTransparency = 0.15
    self.Main.GroupTransparency = 1 -- For Fade-in
    
    -- ขอบเรืองแสง (Neon Glow)
    local mainStroke = Instance.new("UIStroke", self.Main)
    mainStroke.Color = Color3.fromRGB(100, 150, 255)
    mainStroke.Thickness = 2
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local mainCorner = Instance.new("UICorner", self.Main)
    mainCorner.CornerRadius = UDim.new(0, 15)

    -- Scale for Bouncy Effect
    self.UIScale = Instance.new("UIScale", self.Main)
    self.UIScale.Scale = 0.7

    -- Sidebar (Navigation)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 150, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.Sidebar.BackgroundTransparency = 0.5
    self.Sidebar.BorderSizePixel = 0

    -- Title ใน Sidebar
    local title = Instance.new("TextLabel", self.Sidebar)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = hubName; title.Font = "GothamBold"; title.TextColor3 = Color3.new(1,1,1); title.TextSize = 16; title.BackgroundTransparency = 1

    -- Content Area
    self.PageContainer = Instance.new("Frame", self.Main)
    self.PageContainer.Position = UDim2.new(0, 160, 0, 10)
    self.PageContainer.Size = UDim2.new(1, -170, 1, -20)
    self.PageContainer.BackgroundTransparency = 1

    -- [[ ANIMATION: STARTUP ]]
    TweenService:Create(self.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = 1}):Play()
    TweenService:Create(self.Main, TweenInfo.new(0.4), {GroupTransparency = 0}):Play()

    -- Dragging Setup
    local dragging, dragInput, dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = self.Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    return self
end

-- [[ ELEMENT: TAB SYSTEM ]]
function ZenithLib:CreateTab(name)
    local tab = {}
    
    -- ปุ่มกดใน Sidebar
    local tabBtn = Instance.new("TextButton", self.Sidebar)
    tabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    tabBtn.Position = UDim2.new(0.05, 0, 0, 60 + (#self.Sidebar:GetChildren() * 40))
    tabBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    tabBtn.BackgroundTransparency = 0.8
    tabBtn.Text = name; tabBtn.Font = "GothamMedium"; tabBtn.TextColor3 = Color3.new(1,1,1); tabBtn.TextSize = 13
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

    -- หน้า Page จริงๆ
    local page = Instance.new("ScrollingFrame", self.PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.Visible = false
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.PageContainer:GetChildren()) do v.Visible = false end
        page.Visible = true
        -- Animation เลื่อนเข้า
        page.Position = UDim2.new(0, 20, 0, 0)
        TweenService:Create(page, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    
    -- แสดงหน้าแรกอัตโนมัติ
    if #self.PageContainer:GetChildren() == 1 then page.Visible = true end

    -- [[ ADD ELEMENTS TO TAB ]]
    function tab:Button(text, callback)
        local btn = Instance.new("TextButton", page)
        btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "Gotham"; btn.TextSize = 14; btn.AutoButtonColor = false
        Instance.new("UICorner", btn)
        local sc = Instance.new("UIScale", btn)
        
        btn.MouseEnter:Connect(function() TweenService:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Scale = 1.05}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(sc, TweenInfo.new(0.2), {Scale = 1}):Play() end)
        btn.MouseButton1Click:Connect(callback)
    end

    function tab:Toggle(text, callback)
        local state = false
        local tglFrame = Instance.new("Frame", page)
        tglFrame.Size = UDim2.new(1, 0, 0, 45); tglFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", tglFrame)
        
        local label = Instance.new("TextLabel", tglFrame); label.Text = text; label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 15, 0, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1); label.TextXAlignment = "Left"; label.Font = "Gotham"
        
        local btn = Instance.new("TextButton", tglFrame)
        btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10); btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65); btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        local dot = Instance.new("Frame", btn)
        dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(0, 2, 0.5, -8); dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 65)}):Play()
            callback(state)
        end)
    end

    return tab
end

return ZenithLib
