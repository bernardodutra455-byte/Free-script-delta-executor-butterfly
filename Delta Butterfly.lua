--[[
    ╔══════════════════════════════════════════════════════╗
    ║   🦋 DELTA BUTTERFLY v5.0 MOBILE EDITION 🦋          ║
    ║          Versão Corrigida • Touch Friendly           ║
    ║  Fly Fix • Sliders Touch • Drag Manual • Botão Flut. ║
    ╚══════════════════════════════════════════════════════╝
--]]

-- ==================== SERVIÇOS ====================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==================== CONFIG GLOBAL ====================
_G.DBF = {
    WalkSpeed     = 16,
    JumpPower     = 50,
    FlySpeed      = 80,
    KillAura      = false,
    KillAuraRange = 20,
    AutoFarm      = false,
    Noclip        = false,
    InfJump       = false,
    FullBright    = false,
    Gravity       = 196,
    FlyActive     = false,
    FlyUp         = false,
    FlyDown       = false,
}

-- ==================== DETECÇÃO MOBILE ====================
-- Em alguns executores mobile, KeyboardEnabled retorna true por causa do teclado virtual.
-- Usamos apenas TouchEnabled para evitar UI gigante fora da tela.
local isMobile = UserInputService.TouchEnabled

-- ==================== UTILS ====================
local function GetHRP()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = LP.Character
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local PlayerGui = LP:WaitForChild("PlayerGui")

local function Notify(title, text, duration, color)
    duration = duration or 2.5
    color = color or Color3.fromRGB(138, 43, 226)
    local sg = PlayerGui:FindFirstChild("DBF_Notify")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "DBF_Notify"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 1000
        sg.IgnoreGuiInset = true
        sg.Parent = PlayerGui
    end
    if #sg:GetChildren() > 4 then
        sg:GetChildren()[1]:Destroy()
    end

    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 280, 0, 60)
    n.Position = UDim2.new(1, 320, 0, 20)
    n.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
    n.BorderSizePixel = 0
    n.Parent = sg

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = n
    local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = 2; s.Parent = n

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = n
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = bar

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 26)
    t.Position = UDim2.new(0, 15, 0, 6)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = color
    t.TextSize = 13
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = n

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -20, 0, 18)
    d.Position = UDim2.new(0, 15, 0, 30)
    d.BackgroundTransparency = 1
    d.Text = text
    d.TextColor3 = Color3.fromRGB(200, 200, 220)
    d.TextSize = 10
    d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = n

    TweenService:Create(n, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -290, 0, 20 + (#sg:GetChildren() - 1) * 65)
    }):Play()

    task.delay(duration, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 320, 0, 20)
            }):Play()
            task.wait(0.4)
            if n then n:Destroy() end
        end
    end)
end

-- ==================== SCREEN GUI PRINCIPAL ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaButterfly_v5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- ==================== JANELA PRINCIPAL ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
if isMobile then
    MainFrame.Size = UDim2.new(0, 320, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
else
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
end
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false -- começa escondido (abre pelo botão flutuante)
MainFrame.Parent = ScreenGui

local MCorner = Instance.new("UICorner"); MCorner.CornerRadius = UDim.new(0, 12); MCorner.Parent = MainFrame
local MStroke = Instance.new("UIStroke"); MStroke.Color = Color3.fromRGB(138, 43, 226); MStroke.Thickness = 2; MStroke.Parent = MainFrame

-- ==================== HEADER ====================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(30, 15, 55)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HCorner = Instance.new("UICorner"); HCorner.CornerRadius = UDim.new(0, 12); HCorner.Parent = Header

local HGrad = Instance.new("UIGradient")
HGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(75, 0, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
}
HGrad.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -130, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🦋 DELTA BUTTERFLY v5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = isMobile and 13 or 16
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local function MkHeaderBtn(txt, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, isMobile and 32 or 30, 0, isMobile and 32 or 30)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = isMobile and 14 or 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = Header
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    return b
end

local MinBtn   = MkHeaderBtn("—", UDim2.new(1, -75, 0, 8), Color3.fromRGB(255, 200, 0))
local CloseBtn = MkHeaderBtn("✕", UDim2.new(1, -38, 0, 8), Color3.fromRGB(220, 50, 50))

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, isMobile and 95 or 140, 1, -55)
Sidebar.Position = UDim2.new(0, 4, 0, 52)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.Parent = MainFrame

local SCorner = Instance.new("UICorner"); SCorner.CornerRadius = UDim.new(0, 8); SCorner.Parent = Sidebar

local SList = Instance.new("UIListLayout")
SList.Padding = UDim.new(0, 3)
SList.SortOrder = Enum.SortOrder.LayoutOrder
SList.Parent = Sidebar

local SPad = Instance.new("UIPadding")
SPad.PaddingTop = UDim.new(0, 6)
SPad.PaddingLeft = UDim.new(0, 5)
SPad.PaddingRight = UDim.new(0, 5)
SPad.Parent = Sidebar

SList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, SList.AbsoluteContentSize.Y + 12)
end)

-- ==================== CONTENT ====================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, isMobile and -105 or -152, 1, -55)
Content.Position = UDim2.new(0, isMobile and 100 or 146, 0, 52)
Content.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
Content.BorderSizePixel = 0
Content.Parent = MainFrame

local CCorner = Instance.new("UICorner"); CCorner.CornerRadius = UDim.new(0, 8); CCorner.Parent = Content

local CPad = Instance.new("UIPadding")
CPad.PaddingTop = UDim.new(0, 8)
CPad.PaddingLeft = UDim.new(0, 8)
CPad.PaddingRight = UDim.new(0, 8)
CPad.PaddingBottom = UDim.new(0, 8)
CPad.Parent = Content

-- ==================== SISTEMA DE ABAS ====================
local Tabs = {}

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, isMobile and 40 or 34)
    btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
    btn.Text = icon .. (isMobile and "\n" or "  ") .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.TextSize = isMobile and 10 or 12
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = false
    frame.Parent = Content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = frame

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    Tabs[name] = {Button = btn, Frame = frame}

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Frame.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 20, 50)}):Play()
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
        frame.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return frame
end

-- ==================== COMPONENTES ====================
local function CreateButton(parent, text, cb, color)
    color = color or Color3.fromRGB(40, 25, 70)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, isMobile and 42 or 34)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = isMobile and 12 or 13
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(138, 43, 226); s.Transparency = 0.5; s.Parent = b

    b.MouseButton1Down:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(cb)
        if not ok then Notify("⚠️ Erro", tostring(err):sub(1, 50), 2, Color3.fromRGB(255, 80, 80)) end
    end)
    return b
end

local function CreateToggle(parent, text, default, cb)
    local state = default or false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, isMobile and 42 or 34)
    f.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    f.BorderSizePixel = 0
    f.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = f

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -70, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = isMobile and 12 or 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, isMobile and 52 or 44, 0, isMobile and 28 or 22)
    b.Position = UDim2.new(1, isMobile and -62 or -54, 0.5, isMobile and -14 or -11)
    b.BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 80)
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = f
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = b

    local dotSize = isMobile and 22 or 18
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, dotSize, 0, dotSize)
    dot.Position = state and UDim2.new(1, -(dotSize + 2), 0.5, -dotSize/2) or UDim2.new(0, 3, 0.5, -dotSize/2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = b
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

    local function updateVisual()
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 80)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -(dotSize + 2), 0.5, -dotSize/2) or UDim2.new(0, 3, 0.5, -dotSize/2)
        }):Play()
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        local ok, err = pcall(cb, state)
        if not ok then Notify("⚠️ Erro", tostring(err):sub(1, 50), 2, Color3.fromRGB(255, 80, 80)) end
    end)
    return f
end

-- SLIDER TOUCH-FRIENDLY CORRIGIDO
local function CreateSlider(parent, text, min, max, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, isMobile and 60 or 48)
    f.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    f.BorderSizePixel = 0
    f.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = f

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 22)
    l.Position = UDim2.new(0, 12, 0, 4)
    l.BackgroundTransparency = 1
    l.Text = text .. ": " .. default
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, isMobile and 12 or 8)
    bar.Position = UDim2.new(0, 12, 0, isMobile and 38 or 30)
    bar.BackgroundColor3 = Color3.fromRGB(60, 40, 90)
    bar.BorderSizePixel = 0
    bar.Parent = f
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local knobSize = isMobile and 26 or 18
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, knobSize, 0, knobSize)
    knob.Position = UDim2.new((default - min) / (max - min), -knobSize/2, 0.5, -knobSize/2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = bar
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob
    local kStroke = Instance.new("UIStroke"); kStroke.Color = Color3.fromRGB(138, 43, 226); kStroke.Thickness = 2; kStroke.Parent = knob

    -- Zona invisível maior pra facilitar o toque no mobile
    local touchZone = Instance.new("TextButton")
    touchZone.Size = UDim2.new(1, 0, 0, isMobile and 40 or 24)
    touchZone.Position = UDim2.new(0, 0, 0.5, isMobile and -20 or -12)
    touchZone.BackgroundTransparency = 1
    touchZone.Text = ""
    touchZone.ZIndex = 4
    touchZone.Parent = f

    local dragging = false

    local function updFromX(x)
        local pos = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * pos + 0.5)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -knobSize/2, 0.5, -knobSize/2)
        l.Text = text .. ": " .. v
        local ok, err = pcall(cb, v)
        if not ok then Notify("⚠️ Erro Slider", tostring(err):sub(1,50), 2, Color3.fromRGB(255,80,80)) end
    end

    touchZone.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updFromX(i.Position.X)
        end
    end)
    touchZone.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updFromX(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return f
end

local function CreateTextBox(parent, ph, cb)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(1, 0, 0, isMobile and 42 or 34)
    b.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    b.PlaceholderText = ph
    b.Text = ""
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    b.TextSize = isMobile and 12 or 13
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.ClearTextOnFocus = false
    b.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    b.FocusLost:Connect(function()
        local ok, err = pcall(cb, b.Text)
        if not ok then Notify("⚠️ Erro", tostring(err):sub(1, 50), 2, Color3.fromRGB(255, 80, 80)) end
    end)
    return b
end

local function CreateLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180, 180, 200)
    l.TextSize = 11
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function CreateDivider(parent)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    d.BorderSizePixel = 0
    d.Parent = parent
    return d
end

-- ==================== FLY ====================
local flyBV, flyConn

local function StartFly()
    if flyBV then return end
    local hrp = GetHRP()
    if not hrp then
        Notify("⚠️ Fly", "Personagem não encontrado", 2, Color3.fromRGB(255, 80, 80))
        return
    end

    _G.DBF.FlyActive = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "DBF_FlyBV"
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        if not char or not flyBV or not flyBV.Parent then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local cam = Workspace.CurrentCamera
        local move = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

        -- Botões virtuais mobile
        if _G.DBF.FlyUp then move = move + Vector3.new(0, 1, 0) end
        if _G.DBF.FlyDown then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            flyBV.Velocity = move.Unit * _G.DBF.FlySpeed
        else
            flyBV.Velocity = Vector3.zero
        end
    end)

    Notify("✈️ Fly ON", "Use o direcional ou os botões", 3)
end

local function StopFly()
    _G.DBF.FlyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    _G.DBF.FlyUp = false
    _G.DBF.FlyDown = false
    Notify("✈️ Fly OFF", "Desativado", 2)
end

-- ==================== CONTROLES DE FLY (MOBILE) ====================
local FlyControls = Instance.new("Frame")
FlyControls.Size = UDim2.new(0, 140, 0, 60)
FlyControls.Position = UDim2.new(0, 20, 1, -80)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = ScreenGui

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 60, 0, 60)
UpBtn.Position = UDim2.new(0, 0, 0, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
UpBtn.Text = "⬆️"
UpBtn.TextSize = 26
UpBtn.Font = Enum.Font.GothamBold
UpBtn.BorderSizePixel = 0
UpBtn.Parent = FlyControls
local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1, 0); uc.Parent = UpBtn

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 60, 0, 60)
DownBtn.Position = UDim2.new(0, 75, 0, 0)
DownBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
DownBtn.Text = "⬇️"
DownBtn.TextSize = 26
DownBtn.Font = Enum.Font.GothamBold
DownBtn.BorderSizePixel = 0
DownBtn.Parent = FlyControls
local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = DownBtn

UpBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _G.DBF.FlyUp = true
    end
end)
UpBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _G.DBF.FlyUp = false
    end
end)

DownBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _G.DBF.FlyDown = true
    end
end)
DownBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _G.DBF.FlyDown = false
    end
end)

-- ==================== LOOPS DE CORREÇÃO ====================

-- WalkSpeed / JumpPower forçados continuamente
task.spawn(function()
    while task.wait(0.1) do
        local hum = GetHum()
        if hum then
            if hum.WalkSpeed ~= _G.DBF.WalkSpeed then
                hum.WalkSpeed = _G.DBF.WalkSpeed
            end
            if hum.UseJumpPower and hum.JumpPower ~= _G.DBF.JumpPower then
                hum.JumpPower = _G.DBF.JumpPower
            end
        end
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if _G.DBF.Noclip and LP.Character then
        for _, p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if _G.DBF.InfJump then
        local h = GetHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- KILL AURA
task.spawn(function()
    while task.wait(0.15) do
        if _G.DBF.KillAura and LP.Character then
            local myHRP = GetHRP()
            if myHRP then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local h = p.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and h and (hrp.Position - myHRP.Position).Magnitude <= _G.DBF.KillAuraRange then
                            h.Health = 0
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO FARM
task.spawn(function()
    while task.wait(0.3) do
        if _G.DBF.AutoFarm and LP.Character then
            local myHRP = GetHRP()
            if myHRP then
                local closest, cd = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        local h = p.Character:FindFirstChildOfClass("Humanoid")
                        if hrp and h and h.Health > 0 then
                            local d = (hrp.Position - myHRP.Position).Magnitude
                            if d < cd then cd = d; closest = hrp end
                        end
                    end
                end
                if closest and cd <= 60 then
                    myHRP.CFrame = CFrame.new(closest.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

-- ==================== ABAS + FEATURES ====================
local TabMain    = CreateTab("Principal", "🏠")
local TabCombat  = CreateTab("Combate",   "⚔️")
local TabMove    = CreateTab("Movimento", "🏃")
local TabVisual  = CreateTab("Visual",    "👁️")
local TabMisc    = CreateTab("Extra",     "⚙️")

-- Aba principal ativa por padrão
Tabs["Principal"].Button.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
Tabs["Principal"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
TabMain.Visible = true

-- PRINCIPAL
CreateLabel(TabMain, "— VELOCIDADE —")
CreateSlider(TabMain, "WalkSpeed", 16, 300, 16, function(v) _G.DBF.WalkSpeed = v end)
CreateSlider(TabMain, "JumpPower", 50, 500, 50, function(v) _G.DBF.JumpPower = v end)
CreateDivider(TabMain)
CreateButton(TabMain, "🔄 Resetar Velocidade", function()
    _G.DBF.WalkSpeed = 16; _G.DBF.JumpPower = 50
    Notify("🔄 Reset", "Velocidade padrão", 2)
end)

-- COMBATE
CreateLabel(TabCombat, "— KILL AURA —")
CreateToggle(TabCombat, "Kill Aura", false, function(s)
    _G.DBF.KillAura = s
    Notify("⚔️ Kill Aura", s and "ON" or "OFF", 2)
end)
CreateSlider(TabCombat, "Alcance", 5, 100, 20, function(v) _G.DBF.KillAuraRange = v end)
CreateDivider(TabCombat)
CreateToggle(TabCombat, "Auto Farm (TP)", false, function(s)
    _G.DBF.AutoFarm = s
    Notify("🌾 AutoFarm", s and "ON" or "OFF", 2)
end)

-- MOVIMENTO
CreateLabel(TabMove, "— FLY —")
CreateToggle(TabMove, "Fly", false, function(s)
    if s then StartFly(); FlyControls.Visible = true
    else StopFly(); FlyControls.Visible = false end
end)
CreateSlider(TabMove, "Fly Speed", 20, 500, 80, function(v) _G.DBF.FlySpeed = v end)
CreateDivider(TabMove)
CreateToggle(TabMove, "Noclip", false, function(s)
    _G.DBF.Noclip = s
    Notify("👻 Noclip", s and "ON" or "OFF", 2)
end)
CreateToggle(TabMove, "Infinite Jump", false, function(s)
    _G.DBF.InfJump = s
    Notify("🦘 Inf Jump", s and "ON" or "OFF", 2)
end)

-- VISUAL
CreateLabel(TabVisual, "— ILUMINAÇÃO —")
CreateToggle(TabVisual, "Full Bright", false, function(s)
    _G.DBF.FullBright = s
    if s then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 1
    end
end)

-- EXTRA
CreateLabel(TabMisc, "— TELEPORTE —")
CreateTextBox(TabMisc, "Nome do jogador...", function(txt)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(txt:lower()) and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local my = GetHRP()
            if hrp and my then
                my.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                Notify("📡 TP", "Teleportado até "..p.Name, 2)
            end
            return
        end
    end
    Notify("❌", "Jogador não encontrado", 2, Color3.fromRGB(255,80,80))
end)
CreateDivider(TabMisc)
CreateLabel(TabMisc, "— GRAVIDADE —")
CreateSlider(TabMisc, "Gravity", 0, 300, 196, function(v)
    Workspace.Gravity = v
    _G.DBF.Gravity = v
end)

-- ==================== BOTÃO FLUTUANTE ====================
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -27)
FloatBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
FloatBtn.Text = "🦋"
FloatBtn.TextSize = 26
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Parent = ScreenGui
local fbC = Instance.new("UICorner"); fbC.CornerRadius = UDim.new(1, 0); fbC.Parent = FloatBtn
local fbS = Instance.new("UIStroke"); fbS.Color = Color3.fromRGB(255, 255, 255); fbS.Thickness = 1.5; fbS.Parent = FloatBtn

-- DRAG do botão flutuante
do
    local dragging, dragStart, startPos
    FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            -- se moveu mais de 5px cancela o "click"
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
                FloatBtn:SetAttribute("Dragged", true)
            end
            FloatBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            task.delay(0.1, function() FloatBtn:SetAttribute("Dragged", false) end)
        end
    end)
end

-- Mostrar/esconder painel
FloatBtn.MouseButton1Click:Connect(function()
    if FloatBtn:GetAttribute("Dragged") then return end
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==================== DRAG DA JANELA (MOBILE + PC) ====================
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ==================== BOTÕES HEADER ====================
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    Notify("🦋 Painel", "Minimizado. Toque no 🦋 pra abrir", 2)
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFly()
    ScreenGui:Destroy()
    local notifyGui = PlayerGui:FindFirstChild("DBF_Notify")
    if notifyGui then notifyGui:Destroy() end
end)

-- ==================== RESET AO RESPAWN ====================
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.DBF.FlyActive then
        StopFly()
        FlyControls.Visible = false
    end
end)

-- ==================== INICIALIZAÇÃO ====================
Notify("🦋 Delta Butterfly v5.0", "Toque no 🦋 pra abrir o painel", 4)
MainFrame.Visible = true -- abre automaticamente na primeira execução
