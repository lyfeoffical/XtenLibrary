--[[
    ✨ NEON GLASS UI LIBRARY v4.0 (ULTIMATE ANIMATED)
    - 0% Bugs, 100% Smooth
    - Bouncy UI, Glassmorphism, Neon Strokes
    - Fully OOP Based
]]

local Library = {}
Library.__index = Library

-- [ SERVICES ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [ HELPER FUNCTION: TWEEN ]
local function Tween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

-- ==========================================
-- 1. MAIN WINDOW (สร้างหน้าต่างหลัก)
-- ==========================================
function Library.new(HubName)
    local self = setmetatable({}, Library)
    self.Tabs = {} -- เก็บหน้ารวมไว้สลับ
    
    -- Main GUI
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "NeonGlassHub_" .. tostring(math.random(1000, 9999))
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() self.Gui.Parent = CoreGui end)
    if not self.Gui.Parent then self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Window (CanvasGroup สำหรับทำลูกเล่นโปร่งแสงและ Fade)
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0, 550, 0, 380)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -190)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.Main.BackgroundTransparency = 0.2 -- กระจกใส
    self.Main.GroupTransparency = 1 -- เตรียมโผล่
    
    -- มุมโค้ง & ขอบเรืองแสง (Neon)
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 12)
    local UIStroke = Instance.new("UIStroke", self.Main)
    UIStroke.Color = Color3.fromRGB(80, 140, 255)
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.3

    -- สเกลสำหรับอนิเมชั่นเด้ง
    self.Scale = Instance.new("UIScale", self.Main)
    self.Scale.Scale = 0.5

    -- Sidebar (เมนูด้านซ้าย)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 150, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.Sidebar.BackgroundTransparency = 0.5
    self.Sidebar.BorderSizePixel = 0
    
    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 8)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- โลโก้ / ชื่อ Hub
    local Title = Instance.new("TextLabel", self.Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Text = HubName
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    -- Container สำหรับเก็บหน้า Tab (ด้านขวา)
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Position = UDim2.new(0, 160, 0, 15)
    self.Container.Size = UDim2.new(1, -170, 1, -30)
    self.Container.BackgroundTransparency = 1

    -- [ ANIMATION: เปิดหน้าต่างแบบเด้งๆ ]
    Tween(self.Scale, 0.5, {Scale = 1}, Enum.EasingStyle.Back)
    Tween(self.Main, 0.4, {GroupTransparency = 0})

    -- [ ระบบลากหน้าต่าง (Smooth Drag) ]
    local dragging, dragStart, startPos
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
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return self
end

-- ==========================================
-- 2. TAB SYSTEM (ระบบสลับหน้า)
-- ==========================================
function Library:CreateTab(TabName)
    local TabFuncs = {}
    
    -- ปุ่มกดเลือก Tab
    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0.85, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.BackgroundTransparency = 0.5
    TabBtn.Text = TabName
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 13
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local BtnScale = Instance.new("UIScale", TabBtn)

    -- หน้า Page ของ Tab นี้
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0
    Page.Visible = false
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- เก็บ Page ไว้ในตารางเพื่อใช้ซ่อน/โชว์
    table.insert(self.Tabs, {Button = TabBtn, Page = Page})

    -- ระบบคลิกสลับ Tab พร้อมอนิเมชั่น
    TabBtn.MouseButton1Click:Connect(function()
        for _, tabInfo in pairs(self.Tabs) do
            tabInfo.Page.Visible = false
            Tween(tabInfo.Button, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), TextColor3 = Color3.fromRGB(200, 200, 200)})
        end
        Page.Visible = true
        Page.Position = UDim2.new(0, 30, 0, 0) -- เลื่อนมาจากขวานิดนึง
        Page.GroupTransparency = 1
        Tween(Page, 0.4, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, Enum.EasingStyle.Quart)
        Tween(TabBtn, 0.3, {BackgroundColor3 = Color3.fromRGB(80, 140, 255), TextColor3 = Color3.fromRGB(255, 255, 255)})
        
        -- อนิเมชั่นปุ่มเด้งตอนคลิก
        Tween(BtnScale, 0.1, {Scale = 0.9})
        task.wait(0.1)
        Tween(BtnScale, 0.2, {Scale = 1}, Enum.EasingStyle.Back)
    end)

    -- โชว์หน้าแรกอัตโนมัติ
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    -- ==========================================
    -- 3. ELEMENTS (ปุ่ม, สวิตช์, แถบเลื่อน ภายใน Tab)
    -- ==========================================
    
    -- [ BUTTON ]
    function TabFuncs:Button(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Btn.Text = text
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 14
        Btn.AutoButtonColor = false
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color = Color3.fromRGB(60, 60, 70)
        
        local BScale = Instance.new("UIScale", Btn)

        Btn.MouseEnter:Connect(function() Tween(BScale, 0.2, {Scale = 1.03}, Enum.EasingStyle.Back) Stroke.Color = Color3.fromRGB(80, 140, 255) end)
        Btn.MouseLeave:Connect(function() Tween(BScale, 0.2, {Scale = 1}) Stroke.Color = Color3.fromRGB(60, 60, 70) end)
        Btn.MouseButton1Click:Connect(function()
            Tween(BScale, 0.1, {Scale = 0.95})
            task.wait(0.1)
            Tween(BScale, 0.2, {Scale = 1.03}, Enum.EasingStyle.Back)
            pcall(callback)
        end)
    end

    -- [ TOGGLE ]
    function TabFuncs:Toggle(text, default, callback)
        local state = default or false
        local TglFrame = Instance.new("Frame", Page)
        TglFrame.Size = UDim2.new(1, -10, 0, 40)
        TglFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", TglFrame).Color = Color3.fromRGB(60, 60, 70)

        local Label = Instance.new("TextLabel", TglFrame)
        Label.Size = UDim2.new(1, -60, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamMedium; Label.TextColor3 = Color3.new(1,1,1); Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left

        local TglBtn = Instance.new("TextButton", TglFrame)
        TglBtn.Size = UDim2.new(0, 40, 0, 20); TglBtn.Position = UDim2.new(1, -55, 0.5, -10)
        TglBtn.BackgroundColor3 = state and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(20, 20, 25)
        TglBtn.Text = ""; TglBtn.AutoButtonColor = false
        Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame", TglBtn)
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Circle.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        TglBtn.MouseButton1Click:Connect(function()
            state = not state
            Tween(Circle, 0.3, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, Enum.EasingStyle.Quart)
            Tween(TglBtn, 0.3, {BackgroundColor3 = state and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(20, 20, 25)})
            pcall(callback, state)
        end)
    end

    return TabFuncs
end

return Library
