--=============================================================
--  土豆脚本 v10.0 · 最终版
--  隐身v9.3整合 / 娱乐分区 / 无限跳 / 僵尸透视优化
--  攻击速度 / 甩飞 / 黄牙修复 / 窗口层级修复
--=============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local Config = {
    ESP = false, Team = true,
    Box = false, Dist = false,
    Fly = false, FlySpeed = 50,
    Speed = false, SpeedVal = 30,
    JumpEnabled = false, JumpValue = 50,
    InfJump = false,
    RotateEnabled = false, RotateSpeed = 200,
    TeleportEnabled = false,
    InvisUI = false,
    ZombieESP = false, ZombieBody = true,
    ZombieScanRate = 1,
    BrightScreen = false,
    AimEnabled = false, AimShowCircle = false,
    AimRange = 5, AimPart = "Head",
    LagSim = false, LagCycle = 0.4, LagRatio = 0.5,
    YellowTeeth = false,
    AttackSpeed = false, AttackSpeedVal = 50,
    Fling = false, FlingPower = 800,
}

local THEME = {
    BG = Color3.fromRGB(20, 30, 70),
    SIDEBAR = Color3.fromRGB(14, 22, 55),
    TOPBAR = Color3.fromRGB(16, 25, 62),
    ACCENT = Color3.fromRGB(74, 158, 255),
    ACCENT2 = Color3.fromRGB(140, 80, 220),
    GREEN = Color3.fromRGB(58, 208, 125),
    OFF = Color3.fromRGB(58, 58, 64),
    TRACK = Color3.fromRGB(40, 50, 90),
    TEXT = Color3.fromRGB(230, 230, 235),
    SUBTEXT = Color3.fromRGB(150, 160, 200),
    BORDER = Color3.fromRGB(60, 100, 220),
    YELLOW = Color3.fromRGB(255, 200, 50),
    BLUE = Color3.fromRGB(100, 180, 255),
    WHITE = Color3.fromRGB(255, 255, 255),
    RED = Color3.fromRGB(255, 60, 60),
    PLAYER_GREEN = Color3.fromRGB(90, 220, 120),
}

local ZOMBIE_NAMES = {
    cuirassier = "Cuirassier", shambler = "Shambler",
    barrel = "Barrel", zapper = "Zapper",
    run = "Runner", runner = "Runner",
    sapper = "Sapper", bomber = "Bomber", igniter = "Igniter",
}

local ZOMBIE_COLORS = {
    Cuirassier = Color3.fromRGB(200, 100, 50),
    Shambler = Color3.fromRGB(150, 200, 100),
    Barrel = Color3.fromRGB(180, 140, 60),
    Zapper = Color3.fromRGB(100, 180, 255),
    Runner = Color3.fromRGB(255, 100, 200),
    Sapper = Color3.fromRGB(200, 200, 100),
    Bomber = Color3.fromRGB(255, 80, 80),
    Igniter = Color3.fromRGB(255, 160, 60),
    default = Color3.fromRGB(200, 200, 200),
}

-- 波光动画统一节奏
local waveT = 0
local function getWaveBgSeq()
    local d = math.sin(waveT * 0.8) * 0.05
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0.62 + d, 0.7, 0.28)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.72 + d, 0.65, 0.38)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(0.60 + d, 0.7, 0.32)),
    })
end
local function getWaveBorderSeq()
    local d = math.sin(waveT * 0.8 + 1.5) * 0.05
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0.60 + d, 0.75, 0.95)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.75 + d, 0.7, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(0.62 + d, 0.75, 0.9)),
    })
end
local waveFrameRegistry = {}

local function registerWaveFrame(outerGrad, bgGrad)
    table.insert(waveFrameRegistry, { o = outerGrad, b = bgGrad })
end

local guiParent = LP:WaitForChild("PlayerGui")

pcall(function()
    for _, n in ipairs({"PotatoScript", "InvisibleTest", "AuraTest", "FlyTest", "UIDemo", "InvisV92", "InvisV93"}) do
        local o = guiParent:FindFirstChild(n)
        if o then o:Destroy() end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "PotatoScript"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = guiParent

-- 欢迎弹窗（带 X 关闭按钮）
do
    local w = Instance.new("Frame")
    w.Size = UDim2.new(0, 300, 0, 44)
    w.Position = UDim2.new(1, -312, 0, 12)
    w.BackgroundColor3 = THEME.BG
    w.BorderSizePixel = 0
    w.Active = false
    w.ZIndex = 100
    w.Parent = gui
    local wc = Instance.new("UICorner") wc.CornerRadius = UDim.new(0, 8) wc.Parent = w
    local ws = Instance.new("UIStroke") ws.Color = THEME.ACCENT ws.Thickness = 1.5 ws.Parent = w

    local wt = Instance.new("TextLabel")
    wt.Size = UDim2.new(1, -50, 1, 0)
    wt.Position = UDim2.new(0, 10, 0, 0)
    wt.BackgroundTransparency = 1
    wt.Text = "欢迎使用最后一代土豆脚本，以后再也不会对其进行任何更新"
    wt.TextColor3 = THEME.TEXT
    wt.TextSize = 12
    wt.Font = Enum.Font.GothamBold
    wt.TextWrapped = true
    wt.TextXAlignment = Enum.TextXAlignment.Left
    wt.ZIndex = 101
    wt.Parent = w

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 102
    closeBtn.Parent = w
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    local closed = false
    local function closeIt()
        if closed then return end
        closed = true
        pcall(function() w:Destroy() end)
    end

    closeBtn.MouseButton1Click:Connect(closeIt)

    spawn(function()
        wait(3)
        closeIt()
    end)
end

-- 全局状态
local homeConn = nil
local homeStartTime = tick()
local playerSelected = ""
local teleportConn = nil

-- 隐身状态 (v9.3)
local invisState = {
    active = false,
    savedCF = nil,
    conn = nil,
    hum = nil,
    savedHealth = 0,
    savedMax = 0,
    camFocus = nil,
    savedCamSubject = nil,
    savedCamType = nil,
    savedMinZoom = nil,
    savedMaxZoom = nil,
    height = 300,
}

local invisMainOuter = nil
local invisMainWin = nil
local invisStatusOuter = nil
local invisStatusWin = nil
local invisMiniOuter = nil
local invisMiniWin = nil
local invisStatusTip = nil

-- 娱乐：我卡了
local lagConn = nil
local lagTracks = {}
local lagAnimatorConns = {}
local lagCycleT = 0

-- 娱乐：英国黄牙
local FACE_ID = "rbxassetid://92350941655794"
local faceOrigTextures = {}

-- 高亮画面
local savedLighting = nil

-- 僵尸透视缓存
local zombieESP = {}
local lastZombieScan = 0

-- 方框 / 距离 同步
local boxButtons = {}
local distButtons = {}

--========== 玩家透视 ==========
local function isSameTeam(plr)
    if not plr.Team then return false end
    if not LP.Team then return false end
    return plr.Team == LP.Team
end

local espCache = {}

local function createESP(plr)
    if espCache[plr] then return end

    local hl = Instance.new("Highlight")
    hl.Name = "PotatoESP"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = THEME.PLAYER_GREEN
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.OutlineTransparency = 0
    hl.Enabled = false
    hl.Parent = gui

    local bb = Instance.new("BillboardGui")
    bb.Name = "PotatoName"
    bb.Size = UDim2.new(0, 60, 0, 14)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = THEME.PLAYER_GREEN
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = plr.Name
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = bb

    local box = Instance.new("BillboardGui")
    box.Name = "PotatoBox"
    box.Size = UDim2.new(0, 24, 0, 36)
    box.AlwaysOnTop = true
    box.Enabled = false
    box.Parent = gui

    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = THEME.PLAYER_GREEN
    boxStroke.Thickness = 1
    boxStroke.Parent = boxFrame

    local distBB = Instance.new("BillboardGui")
    distBB.Name = "PotatoDist"
    distBB.Size = UDim2.new(0, 36, 0, 10)
    distBB.StudsOffset = Vector3.new(0, -2.5, 0)
    distBB.AlwaysOnTop = true
    distBB.Enabled = false
    distBB.Parent = gui

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 1, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = THEME.PLAYER_GREEN
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Text = "0"
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = distBB

    espCache[plr] = {
        h = hl, bb = bb, label = label,
        box = box, boxStroke = boxStroke,
        distBB = distBB, distLabel = distLabel,
    }
end

local function removeESP(plr)
    local e = espCache[plr]
    if e then
        if e.h then e.h:Destroy() end
        if e.bb then e.bb:Destroy() end
        if e.box then e.box:Destroy() end
        if e.distBB then e.distBB:Destroy() end
        espCache[plr] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for plr, e in pairs(espCache) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        local valid = char
            and char.Parent == workspace
            and hum and hum.Health > 0
            and root

        if not Config.ESP or not valid then
            e.h.Enabled = false
            e.bb.Enabled = false
            e.box.Enabled = false
            e.distBB.Enabled = false
            continue
        end

        local color = THEME.PLAYER_GREEN
        local same = Config.Team and isSameTeam(plr)
        local d = myRoot and (root.Position - myRoot.Position).Magnitude or 0

        if d > 300 then
            e.h.Enabled = false
            e.bb.Enabled = false
            e.box.Enabled = false
            e.distBB.Enabled = false
            continue
        end

        local scale = math.clamp(15 / (d + 10), 0.05, 1.0)

        e.h.Adornee = char
        e.h.Enabled = true
        e.h.FillColor = color
        e.h.FillTransparency = same and 0.85 or 0.5

        if same then
            e.bb.Enabled = false
        else
            e.bb.Adornee = root
            e.bb.Enabled = true
            e.bb.Size = UDim2.new(0, 60 * scale, 0, 14 * scale)
            e.label.TextColor3 = color
        end

        if Config.Box and not same then
            e.box.Adornee = root
            e.box.Enabled = true
            e.boxStroke.Color = color
            e.box.Size = UDim2.new(0, 24 * scale, 0, 36 * scale)
        else
            e.box.Enabled = false
        end

        if Config.Dist and not same then
            e.distBB.Adornee = root
            e.distBB.Enabled = true
            e.distBB.Size = UDim2.new(0, 36 * scale, 0, 10 * scale)
            e.distLabel.Text = tostring(math.floor(d))
            e.distLabel.TextColor3 = color
        else
            e.distBB.Enabled = false
        end
    end
end)

--========== 僵尸透视 ==========
local function isZombieModel(m)
    if not m:IsA("Model") then return false end
    if m == LP.Character then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == m then return false end
    end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    return true
end

local function getZombieInfo(model)
    local typeAttr = model:GetAttribute("Type")
    local t = typeAttr and tostring(typeAttr) or model.Name
    local lower = string.lower(t)
    local matched = nil
    for key, display in pairs(ZOMBIE_NAMES) do
        if string.find(lower, key, 1, true) then
            matched = display
            break
        end
    end
    local display = matched or t
    local short
    if #display > 10 then
        short = string.sub(display, 1, 1)
    else
        short = display
    end
    local color = ZOMBIE_COLORS[display] or ZOMBIE_COLORS.default
    return short, color, display
end

local function createZombieESP(model)
    local short, color = getZombieInfo(model)

    local hl = Instance.new("Highlight")
    hl.Name = "PotatoZombieHL"
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.3
    hl.Enabled = false
    hl.Parent = gui

    local bb = Instance.new("BillboardGui")
    bb.Name = "PotatoZombieName"
    bb.Size = UDim2.new(0, 50, 0, 12)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = short
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = bb

    local box = Instance.new("BillboardGui")
    box.Name = "PotatoZombieBox"
    box.Size = UDim2.new(0, 24, 0, 36)
    box.AlwaysOnTop = true
    box.Enabled = false
    box.Parent = gui

    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = color
    boxStroke.Thickness = 1
    boxStroke.Parent = boxFrame

    local distBB = Instance.new("BillboardGui")
    distBB.Name = "PotatoZombieDist"
    distBB.Size = UDim2.new(0, 36, 0, 10)
    distBB.StudsOffset = Vector3.new(0, -2.5, 0)
    distBB.AlwaysOnTop = true
    distBB.Enabled = false
    distBB.Parent = gui

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 1, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = color
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Text = "0"
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = distBB

    zombieESP[model] = {
        h = hl, bb = bb, label = label,
        box = box, boxStroke = boxStroke,
        distBB = distBB, distLabel = distLabel,
    }
end

local function destroyZombieESP(model)
    local e = zombieESP[model]
    if e then
        if e.h then e.h:Destroy() end
        if e.bb then e.bb:Destroy() end
        if e.box then e.box:Destroy() end
        if e.distBB then e.distBB:Destroy() end
        zombieESP[model] = nil
    end
end

local function clearAllZombieESP()
    for m, _ in pairs(zombieESP) do
        destroyZombieESP(m)
    end
end

local function scanZombies()
    local found = {}
    local folder = workspace:FindFirstChild("Zombies")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if isZombieModel(obj) then
                found[obj] = true
                if not zombieESP[obj] then createZombieESP(obj) end
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("Type") and not found[obj] then
            if isZombieModel(obj) then
                found[obj] = true
                if not zombieESP[obj] then createZombieESP(obj) end
            end
        end
    end
    for m, _ in pairs(zombieESP) do
        if not found[m] or not m.Parent then
            destroyZombieESP(m)
        end
    end
end
RunService.Heartbeat:Connect(function()
    if not Config.ZombieESP then
        if next(zombieESP) then clearAllZombieESP() end
        return
    end

    local now = tick()
    if now - lastZombieScan >= Config.ZombieScanRate then
        lastZombieScan = now
        pcall(scanZombies)
    end

    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for m, e in pairs(zombieESP) do
        if not m.Parent then
            destroyZombieESP(m)
            continue
        end
        local root = m:FindFirstChild("HumanoidRootPart")
                    or m:FindFirstChild("UpperTorso")
                    or m:FindFirstChild("Torso")
                    or m:FindFirstChild("Head")
        if not root then
            destroyZombieESP(m)
            continue
        end

        local short, color = getZombieInfo(m)
        local d = myRoot and (root.Position - myRoot.Position).Magnitude or 0

        if d > 300 then
            e.h.Enabled = false
            e.bb.Enabled = false
            e.box.Enabled = false
            e.distBB.Enabled = false
            continue
        end

        local scale = math.clamp(15 / (d + 10), 0.05, 1.0)

        if Config.ZombieBody then
            e.h.Adornee = m
            e.h.Enabled = true
            e.h.FillColor = color
            e.h.OutlineColor = color
        else
            e.h.Enabled = false
        end

        e.bb.Adornee = root
        e.bb.Enabled = true
        e.bb.Size = UDim2.new(0, 50 * scale, 0, 12 * scale)
        e.label.Text = short
        e.label.TextColor3 = color

        if Config.Box then
            e.box.Adornee = root
            e.box.Enabled = true
            e.boxStroke.Color = color
            e.box.Size = UDim2.new(0, 24 * scale, 0, 36 * scale)
        else
            e.box.Enabled = false
        end

        if Config.Dist then
            e.distBB.Adornee = root
            e.distBB.Enabled = true
            e.distBB.Size = UDim2.new(0, 36 * scale, 0, 10 * scale)
            e.distLabel.Text = tostring(math.floor(d))
            e.distLabel.TextColor3 = color
        else
            e.distBB.Enabled = false
        end
    end
end)

--========== 高亮画面 ==========
local function applyBright()
    if savedLighting then return end
    savedLighting = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
    }
    pcall(function()
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 0
    end)
end

local function restoreBright()
    if not savedLighting then return end
    pcall(function()
        Lighting.Brightness = savedLighting.Brightness
        Lighting.Ambient = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.GlobalShadows = savedLighting.GlobalShadows
        Lighting.FogEnd = savedLighting.FogEnd
        Lighting.FogStart = savedLighting.FogStart
    end)
    savedLighting = nil
end

local function updateBright()
    if Config.BrightScreen then applyBright() else restoreBright() end
end

--========== 移速 ==========
local function applySpeed()
    if Config.Fly then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if Config.Speed then
            hum.WalkSpeed = Config.SpeedVal
        else
            hum.WalkSpeed = 16
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not Config.Speed or Config.Fly then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= Config.SpeedVal then
        pcall(function() hum.WalkSpeed = Config.SpeedVal end)
    end
end)

--========== 跳跃 ==========
local function applyJump()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = Config.JumpEnabled and Config.JumpValue or 50
    pcall(function() hum.UseJumpPower = true end)
    pcall(function() hum.JumpPower = target end)
    pcall(function() hum.JumpHeight = target * 0.4 end)
end

RunService.Heartbeat:Connect(function()
    if not Config.JumpEnabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if hum.UseJumpPower ~= true then hum.UseJumpPower = true end
        if hum.JumpPower ~= Config.JumpValue then hum.JumpPower = Config.JumpValue end
        local jh = Config.JumpValue * 0.4
        if hum.JumpHeight ~= jh then hum.JumpHeight = jh end
    end)
end)

--========== 无限跳 ==========
local infJumpConn = nil

local function startInfJump()
    if infJumpConn then infJumpConn:Disconnect() end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if not Config.InfJump then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
end

startInfJump()

--========== 旋转 ==========
local rotateConn = nil

local function stopRotate()
    if rotateConn then rotateConn:Disconnect() rotateConn = nil end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.AutoRotate = true end) end
end

local function startRotate()
    stopRotate()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.AutoRotate = false end) end
    rotateConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.RotateEnabled then return end
        if Config.Fly then return end
        local c = LP.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end
        pcall(function()
            if h.AutoRotate ~= false then h.AutoRotate = false end
        end)
        local step = math.rad(Config.RotateSpeed) * (dt or 0.016) * 2.5
        pcall(function()
            root.CFrame = root.CFrame * CFrame.Angles(0, step, 0)
        end)
    end)
end

local function updateRotate()
    if Config.RotateEnabled then startRotate() else stopRotate() end
end
--========== 传送系统 ==========
local function stopTeleport()
    if teleportConn then
        teleportConn:Disconnect()
        teleportConn = nil
    end
end

local function startTeleport()
    stopTeleport()
    teleportConn = RunService.Heartbeat:Connect(function()
        if not Config.TeleportEnabled then return end
        if playerSelected == "" then return end
        local target = Players:FindFirstChild(playerSelected)
        if not target then return end
        local tChar = target.Character
        if not tChar then return end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        local myChar = LP.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        if Config.Fly then return end
        if invisState.active then return end
        pcall(function()
            myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 0, 3))
        end)
    end)
end

local function updateTeleport()
    if Config.TeleportEnabled then startTeleport() else stopTeleport() end
end

--========== 甩飞：传送 + 碰撞弹飞 ==========
RunService.Heartbeat:Connect(function()
    if not Config.Fling then return end
    if playerSelected == "" then return end
    local target = Players:FindFirstChild(playerSelected)
    if not target then return end
    local tChar = target.Character
    if not tChar then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function() hrp.CFrame = tRoot.CFrame end)
    pcall(function() hrp:SetNetworkOwner(LP) end)

    local bv = hrp:FindFirstChild("FlingSelf")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FlingSelf"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
    end
    bv.Velocity = Vector3.new(
        math.random(-Config.FlingPower, Config.FlingPower),
        Config.FlingPower,
        math.random(-Config.FlingPower, Config.FlingPower)
    )
end)

--========== 飞行系统 ==========
local flyConn = nil
local flyPos = nil
local flyLook = nil
local flyUp = false
local flyDown = false
local flyUI = nil
local flySwitchBtn = nil
local flySpeedLabel = nil
local flyFill = nil
local mainFlyToggle = nil
local flyMiniOuter = nil

local function stopFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
    flyUp = false
    flyDown = false
    flyPos = nil
    flyLook = nil
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.AutoRotate = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        end)
        pcall(function()
            if Config.Speed then
                hum.WalkSpeed = Config.SpeedVal
            else
                hum.WalkSpeed = 16
            end
        end)
    end
end

local function startFly()
    stopFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    pcall(function() hrp:SetNetworkOwner(LP) end)
    flyPos = hrp.Position
    do
        local camLook = workspace.CurrentCamera.CFrame.LookVector
        local flat = Vector3.new(camLook.X, 0, camLook.Z)
        if flat.Magnitude > 0.01 then
            flyLook = flat.Unit
        else
            flyLook = Vector3.new(0, 0, -1)
        end
    end
    pcall(function()
        hum.AutoRotate = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    end)
    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not Config.Fly then return end
        local c = LP.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end
        pcall(function()
            if h.AutoRotate ~= false then h.AutoRotate = false end
        end)
        if not flyPos then flyPos = root.Position end
        local fwd = 0
        local side = 0
        local md = h.MoveDirection
        if md and md.Magnitude > 0.01 then
            local cam = workspace.CurrentCamera
            local camLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            local camRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
            if camLook.Magnitude > 0.01 then camLook = camLook.Unit else camLook = Vector3.new(0, 0, -1) end
            if camRight.Magnitude > 0.01 then camRight = camRight.Unit else camRight = Vector3.new(1, 0, 0) end
            local flat = Vector3.new(md.X, 0, md.Z)
            if flat.Magnitude > 0.01 then
                flat = flat.Unit
                fwd = flat:Dot(camLook)
                side = flat:Dot(camRight)
            end
        end
        if math.abs(fwd) < 0.01 and math.abs(side) < 0.01 then
            local mv = Vector3.new(0, 0, 0)
            pcall(function() mv = UIS:GetMoveVector() end)
            if mv.Magnitude > 0.01 then
                fwd = mv.Z
                side = mv.X
            end
        end
        if UIS:IsKeyDown(Enum.KeyCode.W) then fwd = fwd + 1 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then fwd = fwd - 1 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then side = side + 1 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then side = side - 1 end
        if fwd > 1 then fwd = 1 elseif fwd < -1 then fwd = -1 end
        if side > 1 then side = 1 elseif side < -1 then side = -1 end
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local move = look * fwd + right * side
        if flyUp then move = move + Vector3.new(0, 1, 0) end
        if flyDown then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then
            flyPos = flyPos + move.Unit * Config.FlySpeed * dt
        end
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude > 0.01 then
            flyLook = flatLook.Unit
        end
        pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
        pcall(function() root.Velocity = Vector3.new(0, 0, 0) end)
        pcall(function() root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end)
        pcall(function() root.RotVelocity = Vector3.new(0, 0, 0) end)
        root.CFrame = CFrame.new(flyPos, flyPos + flyLook)
    end)
end

local function setFlyEnabled(v)
    Config.Fly = v
    if v then startFly() else stopFly() end
    if flySwitchBtn then
        flySwitchBtn.Text = v and "ON" or "OFF"
        flySwitchBtn.BackgroundColor3 = v and THEME.GREEN or THEME.OFF
    end
    if mainFlyToggle then
        mainFlyToggle.Text = v and "ON" or "OFF"
        mainFlyToggle.BackgroundColor3 = v and THEME.GREEN or THEME.OFF
    end
    if v and flyUI then flyUI.Visible = true end
end
--========== 自瞄 ==========
local aimCircle = nil
local aimConn = nil

local function getClosestPlayer()
    local cam = workspace.CurrentCamera
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local radius = cam.ViewportSize.Y * (Config.AimRange / 10) * 0.5
    local closest = nil
    local minDist = math.huge
    local targetPart = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if char and hum and hum.Health > 0 then
                local part = char:FindFirstChild(Config.AimPart)
                if part then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                        if d <= radius and d < minDist then
                            minDist = d
                            closest = plr
                            targetPart = part
                        end
                    end
                end
            end
        end
    end
    return closest, targetPart
end

local function updateAimCircle()
    if not aimCircle then return end
    if not Config.AimEnabled or not Config.AimShowCircle then
        aimCircle.Visible = false
        return
    end
    local cam = workspace.CurrentCamera
    local size = cam.ViewportSize.Y * (Config.AimRange / 10)
    aimCircle.Visible = true
    aimCircle.Size = UDim2.new(0, size, 0, size)
    aimCircle.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
end

function stopAim()
    if aimConn then
        aimConn:Disconnect()
        aimConn = nil
    end
    if aimCircle then aimCircle.Visible = false end
end

local function startAim()
    stopAim()
    aimConn = RunService.RenderStepped:Connect(function()
        updateAimCircle()
        if not Config.AimEnabled then return end
        local plr, part = getClosestPlayer()
        if not part then return end
        local cam = workspace.CurrentCamera
        local camPos = cam.CFrame.Position
        local targetPos = part.Position
        local newCF = CFrame.new(camPos, targetPos)
        cam.CFrame = cam.CFrame:Lerp(newCF, 0.35)
    end)
end

local function updateAim()
    if Config.AimEnabled then startAim() else stopAim() end
end

--========== 隐身系统 (v9.3) ==========
local function activateInvis()
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    invisState.savedCF = hrp.CFrame
    invisState.hum = hum
    invisState.savedHealth = hum.Health
    invisState.savedMax = hum.MaxHealth

    pcall(function()
        hum.MaxHealth = 1e9
        hum.Health = 1e9
    end)

    local cam = workspace.CurrentCamera
    local camFocus = Instance.new("Part")
    camFocus.Name = "PotatoCamFocus"
    camFocus.Size = Vector3.new(0.1, 0.1, 0.1)
    camFocus.Transparency = 1
    camFocus.CanCollide = false
    camFocus.CanQuery = false
    camFocus.CanTouch = false
    camFocus.Anchored = true
    camFocus.CFrame = CFrame.new(cam.CFrame.Position)
    camFocus.Parent = workspace
    invisState.camFocus = camFocus

    invisState.savedCamSubject = cam.CameraSubject
    invisState.savedCamType = cam.CameraType
    cam.CameraSubject = camFocus
    cam.CameraType = Enum.CameraType.Custom

    pcall(function()
        invisState.savedMinZoom = LP.CameraMinZoomDistance
        invisState.savedMaxZoom = LP.CameraMaxZoomDistance
        LP.CameraMinZoomDistance = 0.5
        LP.CameraMaxZoomDistance = 0.5
    end)

    hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, invisState.height, 0))
    pcall(function() hrp:SetNetworkOwner(LP) end)

    invisState.conn = RunService.Heartbeat:Connect(function()
        if not invisState.active then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        local hh = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        local targetY = invisState.savedCF.Position.Y + invisState.height
        if math.abs(h.Position.Y - targetY) > 5 then
            h.CFrame = CFrame.new(h.Position.X, targetY, h.Position.Z)
        end
        if hh and hh.Health < 1e9 then
            pcall(function() hh.Health = 1e9 end)
        end
    end)

    invisState.active = true
end

local function restoreInvis()
    if invisState.conn then
        invisState.conn:Disconnect()
        invisState.conn = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        cam.CameraType = invisState.savedCamType or Enum.CameraType.Custom
        cam.CameraSubject = invisState.savedCamSubject
    end
    pcall(function()
        if invisState.savedMinZoom then LP.CameraMinZoomDistance = invisState.savedMinZoom end
        if invisState.savedMaxZoom then LP.CameraMaxZoomDistance = invisState.savedMaxZoom end
    end)
    if invisState.camFocus then
        pcall(function() invisState.camFocus:Destroy() end)
        invisState.camFocus = nil
    end
    invisState.savedCamSubject = nil
    invisState.savedCamType = nil
    invisState.savedMinZoom = nil
    invisState.savedMaxZoom = nil

    local ch = LP.Character
    if ch and invisState.hum then
        pcall(function()
            invisState.hum.MaxHealth = invisState.savedMax > 0 and invisState.savedMax or 100
            invisState.hum.Health = invisState.savedHealth > 0 and invisState.savedHealth or 100
        end)
    end
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if hrp and invisState.savedCF then
        pcall(function() hrp.CFrame = invisState.savedCF end)
    end
    invisState.hum = nil
    invisState.active = false
end

--========== 传送至地面 ==========
local function teleportToGround()
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { ch }
    params.IgnoreWater = true
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -5000, 0), params)
    if result then
        local newPos = result.Position + Vector3.new(0, 4, 0)
        hrp.CFrame = CFrame.new(newPos)
        if invisState.active and invisState.savedCF then
            invisState.savedCF = CFrame.new(newPos)
        end
    else
        local h = Instance.new("Hint")
        h.Text = "找不到地面"
        h.Parent = workspace
        wait(1.5)
        h:Destroy()
    end
end

--========== 娱乐：我卡了 (动画卡顿) ==========
local function collectLagTracks()
    lagTracks = {}
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then return end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
        table.insert(lagTracks, t)
    end
    local c = anim.AnimationPlayed:Connect(function(t)
        table.insert(lagTracks, t)
    end)
    table.insert(lagAnimatorConns, c)
end

local function startLagSim()
    if not LP.Character then return end
    collectLagTracks()
    lagCycleT = 0
    if lagConn then lagConn:Disconnect() end
    lagConn = RunService.RenderStepped:Connect(function(dt)
        if not Config.LagSim then return end
        lagCycleT = lagCycleT + dt
        if lagCycleT >= Config.LagCycle then lagCycleT = lagCycleT - Config.LagCycle end
        local phase = lagCycleT / Config.LagCycle
        local shouldFreeze = phase < Config.LagRatio
        for i = #lagTracks, 1, -1 do
            local track = lagTracks[i]
            if not track or not track.IsPlaying then
                table.remove(lagTracks, i)
            else
                pcall(function()
                    if shouldFreeze then
                        if track.Speed ~= 0 then track:AdjustSpeed(0) end
                    else
                        if track.Speed ~= 1 then track:AdjustSpeed(1) end
                    end
                end)
            end
        end
    end)
end

local function stopLagSim()
    if lagConn then lagConn:Disconnect() lagConn = nil end
    for _, c in ipairs(lagAnimatorConns) do
        pcall(function() c:Disconnect() end)
    end
    lagAnimatorConns = {}
    for _, track in ipairs(lagTracks) do
        pcall(function()
            if track and track.IsPlaying then track:AdjustSpeed(1) end
        end)
    end
    lagTracks = {}
end

--========== 娱乐：英国黄牙 ==========
local function applyYellowTeeth()
    local char = LP.Character
    if not char then return end
    pcall(function()
        local face = char:FindFirstChild("Face")
        if not face then
            local model = char:FindFirstChild("Model")
            if model then face = model:FindFirstChild("Face") end
        end
        if face then
            local target = face:FindFirstChild("Face")
            if target and target:IsA("Decal") then
                if faceOrigTextures[target] == nil then faceOrigTextures[target] = target.Texture end
                target.Texture = FACE_ID
            else
                for _, c in ipairs(face:GetDescendants()) do
                    if c:IsA("Decal") then
                        if faceOrigTextures[c] == nil then faceOrigTextures[c] = c.Texture end
                        c.Texture = FACE_ID
                    end
                end
            end
        else
            local head = char:FindFirstChild("Head")
            if head then
                for _, c in ipairs(head:GetChildren()) do
                    if c:IsA("Decal") then
                        if faceOrigTextures[c] == nil then faceOrigTextures[c] = c.Texture end
                        c.Texture = FACE_ID
                    end
                end
            end
        end
    end)
end

local function restoreFace()
    for d, orig in pairs(faceOrigTextures) do
        if d and d.Parent then
            pcall(function() d.Texture = orig end)
        end
    end
    faceOrigTextures = {}
end

RunService.Heartbeat:Connect(function()
    if Config.YellowTeeth then
        applyYellowTeeth()
    end
end)
--========== UI 工具 ==========
local function makeWaveFrame(parent, size, position, radius, zindex)
    local base = (zindex or 1) * 100

    local outerF = Instance.new("Frame")
    outerF.Size = size
    outerF.Position = position
    outerF.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outerF.BorderSizePixel = 0
    outerF.Active = true
    outerF.ZIndex = base + 1
    outerF.Parent = parent

    local ocf = Instance.new("UICorner")
    ocf.CornerRadius = UDim.new(0, radius or 12)
    ocf.Parent = outerF

    local oGrad = Instance.new("UIGradient")
    oGrad.Color = getWaveBorderSeq()
    oGrad.Rotation = 135
    oGrad.Parent = outerF

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -4, 1, -4)
    inner.Position = UDim2.new(0, 2, 0, 2)
    inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inner.BorderSizePixel = 0
    inner.ZIndex = base + 2
    inner.Parent = outerF

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, (radius or 12) - 2)
    ic.Parent = inner

    local iGrad = Instance.new("UIGradient")
    iGrad.Color = getWaveBgSeq()
    iGrad.Rotation = 135
    iGrad.Parent = inner

    registerWaveFrame(oGrad, iGrad)

    local function raiseDescendant(c)
        if c:IsA("GuiObject") then
            if c.ZIndex < base + 10 then
                c.ZIndex = base + 10 + c.ZIndex
            end
            c.ChildAdded:Connect(raiseDescendant)
            for _, g in ipairs(c:GetChildren()) do raiseDescendant(g) end
        end
    end
    inner.ChildAdded:Connect(raiseDescendant)
    for _, c in ipairs(inner:GetChildren()) do raiseDescendant(c) end

    return outerF, inner
end

local function bindDrag(dragObj, targetObj)
    local dragging = false
    local dragStart, startPos
    dragObj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = targetObj.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            targetObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function createSlider(parent, label, min, max, default, isFloat, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundTransparency = 1
    f.ZIndex = 5
    f.Parent = parent

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 16)
    t.BackgroundTransparency = 1
    t.TextColor3 = THEME.TEXT
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 12
    t.Text = label .. ": " .. tostring(default)
    t.ZIndex = 6
    t.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = THEME.TRACK
    bar.BorderSizePixel = 0
    bar.ZIndex = 6
    bar.Active = true
    bar.Parent = f

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.ACCENT
    fill.BorderSizePixel = 0
    fill.ZIndex = 7
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob.Parent = bar

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local dragging = false
    local function update(x)
        local rel = (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
        if rel < 0 then rel = 0 elseif rel > 1 then rel = 1 end
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        local v = min + (max - min) * rel
        if not isFloat then v = math.floor(v + 0.5) end
        t.Text = label .. ": " .. tostring(v)
        cb(v)
    end

    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { bar = bar, fill = fill, knob = knob, label = t }
end

local function createToggle(parent, label, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundTransparency = 1
    f.ZIndex = 5
    f.Parent = parent

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0.6, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.TextColor3 = THEME.TEXT
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamMedium
    t.TextSize = 12
    t.Text = label
    t.ZIndex = 6
    t.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 58, 0, 26)
    b.Position = UDim2.new(1, -58, 0, 3)
    b.BackgroundColor3 = default and THEME.GREEN or THEME.OFF
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 6
    b.Parent = f

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = b

    b.MouseButton1Click:Connect(function()
        local nxt = not (b.Text == "ON")
        b.Text = nxt and "ON" or "OFF"
        b.BackgroundColor3 = nxt and THEME.GREEN or THEME.OFF
        cb(nxt, b)
    end)
    return b
end

local function createSectionTitle(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 18)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "─── " .. text .. " ───"
    lbl.TextColor3 = THEME.SUBTEXT
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.ZIndex = 6
    lbl.Parent = holder
end

-- 方框/距离 同步
local function addBoxButton(b) table.insert(boxButtons, b) end
local function addDistButton(b) table.insert(distButtons, b) end
local function setBoxState(v)
    Config.Box = v
    for _, b in ipairs(boxButtons) do
        if b and b.Parent then
            b.Text = v and "ON" or "OFF"
            b.BackgroundColor3 = v and THEME.GREEN or THEME.OFF
        end
    end
end
local function setDistState(v)
    Config.Dist = v
    for _, b in ipairs(distButtons) do
        if b and b.Parent then
            b.Text = v and "ON" or "OFF"
            b.BackgroundColor3 = v and THEME.GREEN or THEME.OFF
        end
    end
end
--========== 攻击速度核心 ==========
local auraAnimatorConn = nil
local auraAttackTrack = nil
local auraRetriggerConn = nil
local auraActiveTracks = {}

local function auraIsAttackTrack(track)
    if track.Looped then return false end
    local p = track.Priority
    if p == Enum.AnimationPriority.Idle or
       p == Enum.AnimationPriority.Movement or
       p == Enum.AnimationPriority.Core then
        return false
    end
    return true
end

local function auraStartReplay(track)
    if not track or not track.Parent then return end
    if auraRetriggerConn then
        auraRetriggerConn:Disconnect()
        auraRetriggerConn = nil
    end
    auraAttackTrack = track
    pcall(function() track:AdjustSpeed(Config.AttackSpeedVal) end)
    auraRetriggerConn = track.Stopped:Connect(function()
        if not Config.AttackSpeed then return end
        if auraAttackTrack ~= track then return end
        if not track.Parent then return end
        pcall(function()
            track.TimePosition = 0
            track:Play(0, 1, Config.AttackSpeedVal)
        end)
    end)
end

local function auraStopReplay()
    if auraRetriggerConn then
        auraRetriggerConn:Disconnect()
        auraRetriggerConn = nil
    end
    if auraAttackTrack then
        pcall(function() auraAttackTrack:Stop() end)
        auraAttackTrack = nil
    end
end

local function auraOnAnimationPlayed(track)
    if auraActiveTracks[track] then return end
    auraActiveTracks[track] = true
    if auraIsAttackTrack(track) and Config.AttackSpeed then
        auraStartReplay(track)
    end
    if Config.AttackSpeed then
        pcall(function() track:AdjustSpeed(Config.AttackSpeedVal) end)
    end
    track.Stopped:Connect(function()
        auraActiveTracks[track] = nil
    end)
end

local function auraBindAnimator()
    if auraAnimatorConn then
        auraAnimatorConn:Disconnect()
        auraAnimatorConn = nil
    end
    auraActiveTracks = {}
    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
        auraOnAnimationPlayed(t)
    end
    auraAnimatorConn = animator.AnimationPlayed:Connect(auraOnAnimationPlayed)
end

local function auraUpdate()
    if Config.AttackSpeed then
        auraBindAnimator()
    else
        if auraAnimatorConn then
            auraAnimatorConn:Disconnect()
            auraAnimatorConn = nil
        end
        auraStopReplay()
    end
end

RunService.Heartbeat:Connect(function()
    if not Config.AttackSpeed then return end
    if auraAttackTrack and auraAttackTrack.Parent and auraAttackTrack.IsPlaying then
        if auraAttackTrack.Speed ~= Config.AttackSpeedVal then
            pcall(function() auraAttackTrack:AdjustSpeed(Config.AttackSpeedVal) end)
        end
    end
end)

--========== 主窗口 ==========
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
local WIN_W = math.min(460, vp.X - 40)
local WIN_H = math.min(320, vp.Y - 40)
if WIN_W < 300 then WIN_W = 300 end
if WIN_H < 220 then WIN_H = 220 end

local outer, window = makeWaveFrame(gui, UDim2.new(0, WIN_W, 0, WIN_H), UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2), 14, 1)

local dragArea = Instance.new("Frame")
dragArea.Size = UDim2.new(1, 0, 0, 38)
dragArea.BackgroundTransparency = 1
dragArea.Active = true
dragArea.ZIndex = 100
dragArea.Parent = window

local topTitle = Instance.new("TextLabel")
topTitle.Size = UDim2.new(1, -80, 1, 0)
topTitle.Position = UDim2.new(0, 16, 0, 0)
topTitle.BackgroundTransparency = 1
topTitle.Text = "土豆脚本V10.0"
topTitle.TextColor3 = THEME.YELLOW
topTitle.TextSize = 15
topTitle.Font = Enum.Font.GothamBold
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 101
topTitle.Parent = dragArea

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -34, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundTransparency = 0.8
minBtn.Text = "-"
minBtn.TextColor3 = THEME.TEXT
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 200
minBtn.Parent = dragArea

local mbc = Instance.new("UICorner")
mbc.CornerRadius = UDim.new(0, 6)
mbc.Parent = minBtn

-- 侧边栏
local sidebarBox = Instance.new("Frame")
sidebarBox.Size = UDim2.new(0, 110, 1, -38)
sidebarBox.Position = UDim2.new(0, 0, 0, 38)
sidebarBox.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
sidebarBox.BackgroundTransparency = 0.35
sidebarBox.BorderSizePixel = 0
sidebarBox.ZIndex = 5
sidebarBox.Parent = window

local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(1, 0, 1, 0)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 3
sidebar.ScrollBarImageColor3 = THEME.ACCENT
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
sidebar.ZIndex = 6
sidebar.Parent = sidebarBox

local sbl = Instance.new("UIListLayout")
sbl.Padding = UDim.new(0, 3)
sbl.SortOrder = Enum.SortOrder.LayoutOrder
sbl.Parent = sidebar

local sbp = Instance.new("UIPadding")
sbp.PaddingTop = UDim.new(0, 8)
sbp.PaddingLeft = UDim.new(0, 6)
sbp.PaddingRight = UDim.new(0, 6)
sbp.PaddingBottom = UDim.new(0, 8)
sbp.Parent = sidebar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -38)
divider.Position = UDim2.new(0, 110, 0, 38)
divider.BackgroundColor3 = Color3.fromRGB(100, 130, 220)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.ZIndex = 7
divider.Parent = window

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -130, 1, -60)
content.Position = UDim2.new(0, 120, 0, 52)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = THEME.ACCENT
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.ZIndex = 5
content.Parent = window

local cLayout = Instance.new("UIListLayout")
cLayout.Padding = UDim.new(0, 6)
cLayout.SortOrder = Enum.SortOrder.LayoutOrder
cLayout.Parent = content

local cPadding = Instance.new("UIPadding")
cPadding.PaddingBottom = UDim.new(0, 8)
cPadding.Parent = content

local function clearContent()
    if homeConn then
        homeConn:Disconnect()
        homeConn = nil
    end
    for _, c in ipairs(content:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
end
--========== 飞行小浮窗 ==========
local flyOuter, flyInner = makeWaveFrame(gui, UDim2.new(0, 170, 0, 140), UDim2.new(0, 10, 0, 60), 10, 20)
flyUI = flyOuter
flyUI.Visible = false

local flyDragArea = Instance.new("Frame")
flyDragArea.Size = UDim2.new(1, 0, 0, 24)
flyDragArea.BackgroundTransparency = 1
flyDragArea.Active = true
flyDragArea.ZIndex = 100
flyDragArea.Parent = flyInner

local flyTitle = Instance.new("TextLabel")
flyTitle.Size = UDim2.new(1, -60, 1, 0)
flyTitle.Position = UDim2.new(0, 10, 0, 0)
flyTitle.BackgroundTransparency = 1
flyTitle.Text = "飞行"
flyTitle.TextColor3 = THEME.YELLOW
flyTitle.TextSize = 12
flyTitle.Font = Enum.Font.GothamBold
flyTitle.TextXAlignment = Enum.TextXAlignment.Left
flyTitle.ZIndex = 101
flyTitle.Parent = flyDragArea

local flyMinBtn = Instance.new("TextButton")
flyMinBtn.Size = UDim2.new(0, 20, 0, 20)
flyMinBtn.Position = UDim2.new(1, -24, 0, 2)
flyMinBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
flyMinBtn.Text = "-"
flyMinBtn.TextColor3 = THEME.TEXT
flyMinBtn.TextSize = 14
flyMinBtn.Font = Enum.Font.GothamBold
flyMinBtn.BorderSizePixel = 0
flyMinBtn.ZIndex = 200
flyMinBtn.Parent = flyDragArea
Instance.new("UICorner", flyMinBtn).CornerRadius = UDim.new(0, 5)

local flySwitchLabel = Instance.new("TextLabel")
flySwitchLabel.Size = UDim2.new(0, 60, 0, 22)
flySwitchLabel.Position = UDim2.new(0, 12, 0, 30)
flySwitchLabel.BackgroundTransparency = 1
flySwitchLabel.Text = "启用"
flySwitchLabel.TextColor3 = THEME.SUBTEXT
flySwitchLabel.TextSize = 12
flySwitchLabel.Font = Enum.Font.GothamMedium
flySwitchLabel.TextXAlignment = Enum.TextXAlignment.Left
flySwitchLabel.ZIndex = 21
flySwitchLabel.Parent = flyInner

flySwitchBtn = Instance.new("TextButton")
flySwitchBtn.Size = UDim2.new(0, 52, 0, 22)
flySwitchBtn.Position = UDim2.new(1, -64, 0, 30)
flySwitchBtn.BackgroundColor3 = THEME.OFF
flySwitchBtn.Text = "OFF"
flySwitchBtn.TextColor3 = Color3.new(1, 1, 1)
flySwitchBtn.TextSize = 11
flySwitchBtn.Font = Enum.Font.GothamBold
flySwitchBtn.BorderSizePixel = 0
flySwitchBtn.ZIndex = 22
flySwitchBtn.Parent = flyInner
Instance.new("UICorner", flySwitchBtn).CornerRadius = UDim.new(1, 0)

flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, -24, 0, 12)
flySpeedLabel.Position = UDim2.new(0, 12, 0, 60)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "速度: " .. Config.FlySpeed
flySpeedLabel.TextColor3 = THEME.SUBTEXT
flySpeedLabel.TextSize = 11
flySpeedLabel.Font = Enum.Font.GothamMedium
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.ZIndex = 21
flySpeedLabel.Parent = flyInner

local flyBar = Instance.new("Frame")
flyBar.Size = UDim2.new(1, -24, 0, 8)
flyBar.Position = UDim2.new(0, 12, 0, 76)
flyBar.BackgroundColor3 = THEME.TRACK
flyBar.BorderSizePixel = 0
flyBar.Active = true
flyBar.ZIndex = 21
flyBar.Parent = flyInner
Instance.new("UICorner", flyBar).CornerRadius = UDim.new(1, 0)

flyFill = Instance.new("Frame")
flyFill.Size = UDim2.new((Config.FlySpeed - 10) / (300 - 10), 0, 1, 0)
flyFill.BackgroundColor3 = THEME.ACCENT
flyFill.BorderSizePixel = 0
flyFill.ZIndex = 22
flyFill.Parent = flyBar
Instance.new("UICorner", flyFill).CornerRadius = UDim.new(1, 0)

local flyUpBtn = Instance.new("TextButton")
flyUpBtn.Size = UDim2.new(0, 70, 0, 30)
flyUpBtn.Position = UDim2.new(0, 12, 0, 96)
flyUpBtn.BackgroundColor3 = THEME.GREEN
flyUpBtn.Text = "上 升"
flyUpBtn.TextColor3 = Color3.new(1, 1, 1)
flyUpBtn.TextSize = 12
flyUpBtn.Font = Enum.Font.GothamBold
flyUpBtn.BorderSizePixel = 0
flyUpBtn.ZIndex = 22
flyUpBtn.Parent = flyInner
Instance.new("UICorner", flyUpBtn).CornerRadius = UDim.new(0, 8)

local flyDownBtn = Instance.new("TextButton")
flyDownBtn.Size = UDim2.new(0, 70, 0, 30)
flyDownBtn.Position = UDim2.new(1, -82, 0, 96)
flyDownBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
flyDownBtn.Text = "下 降"
flyDownBtn.TextColor3 = Color3.new(1, 1, 1)
flyDownBtn.TextSize = 12
flyDownBtn.Font = Enum.Font.GothamBold
flyDownBtn.BorderSizePixel = 0
flyDownBtn.ZIndex = 22
flyDownBtn.Parent = flyInner
Instance.new("UICorner", flyDownBtn).CornerRadius = UDim.new(0, 8)

local function bindFlyHold(btn, isUp)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if isUp then flyUp = true else flyDown = true end
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if isUp then flyUp = false else flyDown = false end
        end
    end)
    btn.MouseButton1Down:Connect(function() if isUp then flyUp = true else flyDown = true end end)
    btn.MouseButton1Up:Connect(function() if isUp then flyUp = false else flyDown = false end end)
    btn.MouseLeave:Connect(function() if isUp then flyUp = false else flyDown = false end end)
end

bindFlyHold(flyUpBtn, true)
bindFlyHold(flyDownBtn, false)

local flyBarDrag = false
local function updateFlySpeed(x)
    local rel = (x - flyBar.AbsolutePosition.X) / flyBar.AbsoluteSize.X
    if rel < 0 then rel = 0 elseif rel > 1 then rel = 1 end
    flyFill.Size = UDim2.new(rel, 0, 1, 0)
    local v = math.floor(10 + (300 - 10) * rel + 0.5)
    Config.FlySpeed = v
    flySpeedLabel.Text = "速度: " .. v
end
flyBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        flyBarDrag = true
        updateFlySpeed(i.Position.X)
    end
end)
UIS.InputChanged:Connect(function(i)
    if flyBarDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        updateFlySpeed(i.Position.X)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        flyBarDrag = false
    end
end)

bindDrag(flyDragArea, flyOuter)

flySwitchBtn.MouseButton1Click:Connect(function()
    local cur = (flySwitchBtn.Text == "ON")
    setFlyEnabled(not cur)
end)

-- 飞行小标签
local flyMiniOuter, flyMiniInner = makeWaveFrame(gui, UDim2.new(0, 88, 0, 30), UDim2.new(0, 14, 0, 60), 10, 300)
flyMiniOuter.Visible = false
local flyMini = Instance.new("TextButton")
flyMini.Size = UDim2.new(1, 0, 1, 0)
flyMini.BackgroundTransparency = 1
flyMini.Text = "飞行UI"
flyMini.TextColor3 = THEME.WHITE
flyMini.TextSize = 13
flyMini.Font = Enum.Font.GothamBold
flyMini.BorderSizePixel = 0
flyMini.AutoButtonColor = false
flyMini.ZIndex = 302
flyMini.Parent = flyMiniInner

flyMinBtn.MouseButton1Click:Connect(function()
    flyMiniOuter.Position = flyOuter.Position
    flyOuter.Visible = false
    flyMiniOuter.Visible = true
end)

local fmDrag = false
local fmSP, fmSV, fmMoved, fmST
flyMini.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        fmDrag = true fmMoved = false fmST = tick()
        fmSP = i.Position fmSV = flyMiniOuter.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if fmDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - fmSP
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then fmMoved = true end
        flyMiniOuter.Position = UDim2.new(fmSV.X.Scale, fmSV.X.Offset + d.X,
                                           fmSV.Y.Scale, fmSV.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch) and fmDrag then
        fmDrag = false
        if not fmMoved and (tick() - fmST) < 1 then
            flyMiniOuter.Visible = false
            if Config.Fly then flyOuter.Visible = true end
        end
    end
end)
--========== 隐身 UI（v9.3 三态） ==========
local invisMainOuter, invisMainWin = makeWaveFrame(gui, UDim2.new(0, 200, 0, 220), UDim2.new(0.5, -100, 0.5, -110), 14, 20)
invisMainOuter.Visible = false

local invisDragArea = Instance.new("Frame")
invisDragArea.Size = UDim2.new(1, 0, 0, 30)
invisDragArea.BackgroundTransparency = 1
invisDragArea.Active = true
invisDragArea.ZIndex = 100
invisDragArea.Parent = invisMainWin

local invisTitle = Instance.new("TextLabel")
invisTitle.Size = UDim2.new(1, -60, 1, 0)
invisTitle.Position = UDim2.new(0, 12, 0, 0)
invisTitle.BackgroundTransparency = 1
invisTitle.Text = "隐身"
invisTitle.TextColor3 = THEME.YELLOW
invisTitle.TextSize = 13
invisTitle.Font = Enum.Font.GothamBold
invisTitle.TextXAlignment = Enum.TextXAlignment.Left
invisTitle.ZIndex = 101
invisTitle.Parent = invisDragArea

local invisMinBtn = Instance.new("TextButton")
invisMinBtn.Size = UDim2.new(0, 22, 0, 22)
invisMinBtn.Position = UDim2.new(1, -30, 0, 4)
invisMinBtn.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
invisMinBtn.Text = "-"
invisMinBtn.TextColor3 = THEME.TEXT
invisMinBtn.TextSize = 14
invisMinBtn.Font = Enum.Font.GothamBold
invisMinBtn.BorderSizePixel = 0
invisMinBtn.ZIndex = 200
invisMinBtn.Parent = invisDragArea
Instance.new("UICorner", invisMinBtn).CornerRadius = UDim.new(0, 6)

local invisHLbl = Instance.new("TextLabel")
invisHLbl.Size = UDim2.new(1, -24, 0, 14)
invisHLbl.Position = UDim2.new(0, 12, 0, 38)
invisHLbl.BackgroundTransparency = 1
invisHLbl.TextColor3 = THEME.TEXT
invisHLbl.TextXAlignment = Enum.TextXAlignment.Left
invisHLbl.Font = Enum.Font.GothamMedium
invisHLbl.TextSize = 12
invisHLbl.Text = "高度: " .. invisState.height
invisHLbl.ZIndex = 5
invisHLbl.Parent = invisMainWin

local invisHBar = Instance.new("Frame")
invisHBar.Size = UDim2.new(1, -24, 0, 8)
invisHBar.Position = UDim2.new(0, 12, 0, 56)
invisHBar.BackgroundColor3 = THEME.TRACK
invisHBar.BorderSizePixel = 0
invisHBar.Active = true
invisHBar.ZIndex = 5
invisHBar.Parent = invisMainWin
Instance.new("UICorner", invisHBar).CornerRadius = UDim.new(1, 0)

local invisHFill = Instance.new("Frame")
invisHFill.Size = UDim2.new((invisState.height - 1) / 999, 0, 1, 0)
invisHFill.BackgroundColor3 = THEME.ACCENT
invisHFill.BorderSizePixel = 0
invisHFill.ZIndex = 6
invisHFill.Parent = invisHBar
Instance.new("UICorner", invisHFill).CornerRadius = UDim.new(1, 0)

local invisHK = Instance.new("Frame")
invisHK.Size = UDim2.new(0, 12, 0, 12)
invisHK.AnchorPoint = Vector2.new(0.5, 0.5)
invisHK.Position = UDim2.new((invisState.height - 1) / 999, 0, 0.5, 0)
invisHK.BackgroundColor3 = Color3.new(1, 1, 1)
invisHK.BorderSizePixel = 0
invisHK.ZIndex = 7
invisHK.Parent = invisHBar
Instance.new("UICorner", invisHK).CornerRadius = UDim.new(1, 0)

local invisHDrag = false
local function invisHUpdate(x)
    local r = (x - invisHBar.AbsolutePosition.X) / invisHBar.AbsoluteSize.X
    if r < 0 then r = 0 elseif r > 1 then r = 1 end
    invisHFill.Size = UDim2.new(r, 0, 1, 0)
    invisHK.Position = UDim2.new(r, 0, 0.5, 0)
    invisState.height = math.floor(1 + 999 * r + 0.5)
    invisHLbl.Text = "高度: " .. invisState.height
end
invisHBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        invisHDrag = true
        invisHUpdate(i.Position.X)
    end
end)
UIS.InputChanged:Connect(function(i)
    if invisHDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        invisHUpdate(i.Position.X)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        invisHDrag = false
    end
end)

local invisEnableBtn = Instance.new("TextButton")
invisEnableBtn.Size = UDim2.new(1, -24, 0, 34)
invisEnableBtn.Position = UDim2.new(0, 12, 0, 80)
invisEnableBtn.BackgroundColor3 = THEME.OFF
invisEnableBtn.Text = "启用"
invisEnableBtn.TextColor3 = Color3.new(1, 1, 1)
invisEnableBtn.TextSize = 13
invisEnableBtn.Font = Enum.Font.GothamBold
invisEnableBtn.BorderSizePixel = 0
invisEnableBtn.ZIndex = 5
invisEnableBtn.Parent = invisMainWin
Instance.new("UICorner", invisEnableBtn).CornerRadius = UDim.new(1, 0)

local invisTpBtn = Instance.new("TextButton")
invisTpBtn.Size = UDim2.new(1, -24, 0, 30)
invisTpBtn.Position = UDim2.new(0, 12, 0, 120)
invisTpBtn.BackgroundColor3 = THEME.ACCENT
invisTpBtn.Text = "传送至地面"
invisTpBtn.TextColor3 = Color3.new(1, 1, 1)
invisTpBtn.TextSize = 12
invisTpBtn.Font = Enum.Font.GothamBold
invisTpBtn.BorderSizePixel = 0
invisTpBtn.ZIndex = 5
invisTpBtn.Parent = invisMainWin
Instance.new("UICorner", invisTpBtn).CornerRadius = UDim.new(0, 6)

local invisTip = Instance.new("TextLabel")
invisTip.Size = UDim2.new(1, -24, 0, 40)
invisTip.Position = UDim2.new(0, 12, 0, 156)
invisTip.BackgroundTransparency = 1
invisTip.TextColor3 = THEME.SUBTEXT
invisTip.TextXAlignment = Enum.TextXAlignment.Left
invisTip.TextYAlignment = Enum.TextYAlignment.Top
invisTip.Font = Enum.Font.GothamMedium
invisTip.TextSize = 10
invisTip.TextWrapped = true
invisTip.Text = "开启后可自由转动视角\n相机停在原地"
invisTip.ZIndex = 5
invisTip.Parent = invisMainWin

-- 状态浮窗
local invisStatusOuter, invisStatusWin = makeWaveFrame(gui, UDim2.new(0, 180, 0, 90), UDim2.new(0.5, -90, 0.5, -45), 12, 20)
invisStatusOuter.Visible = false

local invisStatusDrag = Instance.new("Frame")
invisStatusDrag.Size = UDim2.new(1, 0, 0, 26)
invisStatusDrag.BackgroundTransparency = 1
invisStatusDrag.Active = true
invisStatusDrag.ZIndex = 100
invisStatusDrag.Parent = invisStatusWin

local invisStatusTitle = Instance.new("TextLabel")
invisStatusTitle.Size = UDim2.new(1, -30, 1, 0)
invisStatusTitle.Position = UDim2.new(0, 10, 0, 0)
invisStatusTitle.BackgroundTransparency = 1
invisStatusTitle.Text = "隐身中"
invisStatusTitle.TextColor3 = THEME.GREEN
invisStatusTitle.TextSize = 12
invisStatusTitle.Font = Enum.Font.GothamBold
invisStatusTitle.TextXAlignment = Enum.TextXAlignment.Left
invisStatusTitle.ZIndex = 101
invisStatusTitle.Parent = invisStatusDrag

local invisBtnSettings = Instance.new("TextButton")
invisBtnSettings.Size = UDim2.new(0, 46, 0, 22)
invisBtnSettings.Position = UDim2.new(0, 12, 0, 34)
invisBtnSettings.BackgroundColor3 = THEME.ACCENT
invisBtnSettings.Text = "设置"
invisBtnSettings.TextColor3 = Color3.new(1, 1, 1)
invisBtnSettings.TextSize = 11
invisBtnSettings.Font = Enum.Font.GothamBold
invisBtnSettings.BorderSizePixel = 0
invisBtnSettings.ZIndex = 5
invisBtnSettings.Parent = invisStatusWin
Instance.new("UICorner", invisBtnSettings).CornerRadius = UDim.new(0, 6)

local invisBtnMin = Instance.new("TextButton")
invisBtnMin.Size = UDim2.new(0, 46, 0, 22)
invisBtnMin.Position = UDim2.new(0.5, -23, 0, 34)
invisBtnMin.BackgroundColor3 = THEME.YELLOW
invisBtnMin.Text = "最小化"
invisBtnMin.TextColor3 = Color3.fromRGB(30, 30, 30)
invisBtnMin.TextSize = 11
invisBtnMin.Font = Enum.Font.GothamBold
invisBtnMin.BorderSizePixel = 0
invisBtnMin.ZIndex = 5
invisBtnMin.Parent = invisStatusWin
Instance.new("UICorner", invisBtnMin).CornerRadius = UDim.new(0, 6)

local invisBtnClose = Instance.new("TextButton")
invisBtnClose.Size = UDim2.new(0, 46, 0, 22)
invisBtnClose.Position = UDim2.new(1, -58, 0, 34)
invisBtnClose.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
invisBtnClose.Text = "关闭"
invisBtnClose.TextColor3 = Color3.new(1, 1, 1)
invisBtnClose.TextSize = 11
invisBtnClose.Font = Enum.Font.GothamBold
invisBtnClose.BorderSizePixel = 0
invisBtnClose.ZIndex = 5
invisBtnClose.Parent = invisStatusWin
Instance.new("UICorner", invisBtnClose).CornerRadius = UDim.new(0, 6)

invisStatusTip = Instance.new("TextLabel")
invisStatusTip.Size = UDim2.new(1, -24, 0, 14)
invisStatusTip.Position = UDim2.new(0, 12, 0, 64)
invisStatusTip.BackgroundTransparency = 1
invisStatusTip.TextColor3 = THEME.SUBTEXT
invisStatusTip.TextXAlignment = Enum.TextXAlignment.Center
invisStatusTip.Font = Enum.Font.GothamMedium
invisStatusTip.TextSize = 10
invisStatusTip.Text = "高度: " .. invisState.height
invisStatusTip.ZIndex = 5
invisStatusTip.Parent = invisStatusWin

-- 隐身小标签
local invisMiniOuterX, invisMiniInnerX = makeWaveFrame(gui, UDim2.new(0, 88, 0, 30), UDim2.new(0, 120, 0, 14), 10, 500)
invisMiniOuterX.Visible = false
local invisMini = Instance.new("TextButton")
invisMini.Size = UDim2.new(1, 0, 1, 0)
invisMini.BackgroundTransparency = 1
invisMini.Text = "隐身UI"
invisMini.TextColor3 = THEME.BLUE
invisMini.TextSize = 13
invisMini.Font = Enum.Font.GothamBold
invisMini.BorderSizePixel = 0
invisMini.AutoButtonColor = false
invisMini.ZIndex = 302
invisMini.Parent = invisMiniInnerX

invisMinBtn.MouseButton1Click:Connect(function()
    local srcPos
    if invisState.active then
        srcPos = invisStatusOuter.Position
    else
        srcPos = invisMainOuter.Position
    end
    invisMiniOuterX.Position = srcPos
    invisMainOuter.Visible = false
    invisStatusOuter.Visible = false
    invisMiniOuterX.Visible = true
end)
local imDrag = false
local imSP, imSV, imMoved, imST
invisMini.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        imDrag = true imMoved = false imST = tick()
        imSP = i.Position imSV = invisMiniOuterX.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if imDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - imSP
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then imMoved = true end
        invisMiniOuterX.Position = UDim2.new(imSV.X.Scale, imSV.X.Offset + d.X,
                                              imSV.Y.Scale, imSV.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch) and imDrag then
        imDrag = false
        if not imMoved and (tick() - imST) < 1 then
            invisMiniOuterX.Visible = false
            if invisState.active then
                invisStatusOuter.Visible = true
            else
                invisMainOuter.Visible = true
            end
        end
    end
end)

bindDrag(invisDragArea, invisMainOuter)
bindDrag(invisStatusDrag, invisStatusOuter)

invisEnableBtn.MouseButton1Click:Connect(function()
    if invisState.active then
        restoreInvis()
        invisEnableBtn.Text = "启用"
        invisEnableBtn.BackgroundColor3 = THEME.OFF
        invisStatusOuter.Visible = false
        invisMainOuter.Visible = true
    else
        activateInvis()
        invisEnableBtn.Text = "关闭"
        invisEnableBtn.BackgroundColor3 = THEME.GREEN
        invisStatusTip.Text = "高度: " .. invisState.height
        invisMainOuter.Visible = false
        invisStatusOuter.Visible = true
    end
end)

invisTpBtn.MouseButton1Click:Connect(function()
    teleportToGround()
end)

invisBtnSettings.MouseButton1Click:Connect(function()
    invisStatusOuter.Visible = false
    invisMainOuter.Visible = true
end)

invisBtnMin.MouseButton1Click:Connect(function()
    invisStatusOuter.Visible = false
    invisMiniOuterX.Visible = true
    invisMiniOuterX.Position = invisStatusOuter.Position
end)

invisBtnClose.MouseButton1Click:Connect(function()
    restoreInvis()
    invisEnableBtn.Text = "启用"
    invisEnableBtn.BackgroundColor3 = THEME.OFF
    invisStatusOuter.Visible = false
    invisMainOuter.Visible = true
end)

--========== 自瞄圆框 ==========
aimCircle = Instance.new("Frame")
aimCircle.Name = "AimCircle"
aimCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
aimCircle.BackgroundTransparency = 1
aimCircle.Visible = false
aimCircle.ZIndex = 10
aimCircle.Parent = gui
Instance.new("UICorner", aimCircle).CornerRadius = UDim.new(0.5, 0)

local acStroke = Instance.new("UIStroke")
acStroke.Color = Color3.fromRGB(255, 255, 255)
acStroke.Thickness = 2
acStroke.Transparency = 0.2
acStroke.Parent = aimCircle

--========== 页面系统 ==========
local sideButtons = {}
local switchPage

local pages = {}

-- 主页
pages["主页"] = function()
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size = UDim2.new(1, 0, 0.4, 0)
    avatarFrame.BackgroundTransparency = 1
    avatarFrame.ZIndex = 5
    avatarFrame.Parent = content

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Size = UDim2.new(0, 80, 0, 80)
    avatarImg.Position = UDim2.new(0.5, -40, 0.5, -40)
    avatarImg.BackgroundColor3 = THEME.TRACK
    avatarImg.BorderSizePixel = 0
    avatarImg.Image = ""
    avatarImg.ZIndex = 6
    avatarImg.Parent = avatarFrame
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 40)

    local avStroke = Instance.new("UIStroke")
    avStroke.Color = THEME.ACCENT
    avStroke.Thickness = 2
    avStroke.Parent = avatarImg

    spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and img then avatarImg.Image = img end
    end)

    local nameRow = Instance.new("Frame")
    nameRow.Size = UDim2.new(1, 0, 0, 28)
    nameRow.BackgroundTransparency = 1
    nameRow.ZIndex = 5
    nameRow.Parent = content

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Padding = UDim.new(0, 6)
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = nameRow

    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(0, 0, 1, 0)
    userName.AutomaticSize = Enum.AutomaticSize.X
    userName.BackgroundTransparency = 1
    userName.TextColor3 = THEME.TEXT
    userName.Font = Enum.Font.GothamBold
    userName.TextSize = 14
    userName.Text = LP.Name
    userName.ZIndex = 6
    userName.LayoutOrder = 1
    userName.Parent = nameRow

    local vipLabel = Instance.new("TextLabel")
    vipLabel.Size = UDim2.new(0, 0, 1, 0)
    vipLabel.AutomaticSize = Enum.AutomaticSize.X
    vipLabel.BackgroundTransparency = 1
    vipLabel.TextColor3 = THEME.RED
    vipLabel.Font = Enum.Font.GothamBold
    vipLabel.TextSize = 20
    vipLabel.Text = "SVIP"
    vipLabel.ZIndex = 6
    vipLabel.LayoutOrder = 2
    vipLabel.Parent = nameRow

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, 0, 0, 18)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = THEME.SUBTEXT
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextSize = 12
    timeLabel.Text = "启用时间: 00:00:00"
    timeLabel.ZIndex = 6
    timeLabel.Parent = content

    local tipLabel = Instance.new("TextLabel")
    tipLabel.Size = UDim2.new(1, 0, 0, 16)
    tipLabel.BackgroundTransparency = 1
    tipLabel.TextColor3 = THEME.YELLOW
    tipLabel.TextXAlignment = Enum.TextXAlignment.Center
    tipLabel.Font = Enum.Font.GothamMedium
    tipLabel.TextSize = 12
    tipLabel.Text = "不要压力一个土豆脚本"
    tipLabel.ZIndex = 6
    tipLabel.Parent = content

    local authorLabel = Instance.new("TextLabel")
    authorLabel.Size = UDim2.new(1, 0, 0, 60)
    authorLabel.BackgroundTransparency = 1
    authorLabel.TextColor3 = THEME.SUBTEXT
    authorLabel.TextXAlignment = Enum.TextXAlignment.Center
    authorLabel.TextYAlignment = Enum.TextYAlignment.Top
    authorLabel.Font = Enum.Font.GothamMedium
    authorLabel.TextSize = 11
    authorLabel.TextWrapped = true
    authorLabel.Text = "作者:Крайности。此脚本天下无敌，禁止搬运\n闲的蛋疼创了一个QQ群:1071760297"
    authorLabel.ZIndex = 6
    authorLabel.Parent = content

    homeConn = RunService.Heartbeat:Connect(function()
        local elapsed = math.floor(tick() - homeStartTime)
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = elapsed % 60
        timeLabel.Text = string.format("启用时间: %02d:%02d:%02d", h, m, s)
    end)
end
-- 玩家
pages["玩家"] = function()
    createSectionTitle(content, "选择")

    local selectedBox = Instance.new("TextLabel")
    selectedBox.Size = UDim2.new(1, 0, 0, 32)
    selectedBox.BackgroundColor3 = THEME.TRACK
    selectedBox.BorderSizePixel = 0
    selectedBox.TextColor3 = THEME.TEXT
    selectedBox.TextXAlignment = Enum.TextXAlignment.Left
    selectedBox.Font = Enum.Font.GothamMedium
    selectedBox.TextSize = 13
    selectedBox.Text = "  未选择玩家"
    selectedBox.ZIndex = 6
    selectedBox.Parent = content
    Instance.new("UICorner", selectedBox).CornerRadius = UDim.new(0, 6)

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 160)
    listFrame.BackgroundColor3 = THEME.TRACK
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 8
    listFrame.Parent = content
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 9
    scroll.Parent = listFrame

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 3)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scroll

    local function rebuildList()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local count = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 26)
            btn.BackgroundColor3 = THEME.BG
            btn.Text = plr.Name
            btn.TextColor3 = THEME.TEXT
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.ZIndex = 10
            btn.Parent = scroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            btn.MouseButton1Click:Connect(function()
                playerSelected = plr.Name
                selectedBox.Text = "  已选择: " .. plr.Name
                listFrame.Visible = false
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, count * 29)
    end

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, 0, 0, 32)
    selectBtn.BackgroundColor3 = THEME.ACCENT
    selectBtn.Text = "选择玩家"
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.TextSize = 13
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.BorderSizePixel = 0
    selectBtn.ZIndex = 7
    selectBtn.Parent = content
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)
    selectBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then rebuildList() end
    end)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 32)
    refreshBtn.BackgroundColor3 = THEME.OFF
    refreshBtn.Text = "刷新列表"
    refreshBtn.TextColor3 = THEME.TEXT
    refreshBtn.TextSize = 13
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.BorderSizePixel = 0
    refreshBtn.ZIndex = 7
    refreshBtn.Parent = content
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    refreshBtn.MouseButton1Click:Connect(function()
        rebuildList()
        selectedBox.Text = "  列表已刷新"
    end)

    createSectionTitle(content, "传送")
    createToggle(content, "传送到指定玩家", Config.TeleportEnabled, function(v)
        Config.TeleportEnabled = v
        updateTeleport()
    end)
    createToggle(content, "甩飞选中玩家", Config.Fling, function(v)
        Config.Fling = v
        if not v then
            local ch = LP.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("FlingSelf")
                if bv then bv:Destroy() end
            end
        end
    end)

    createSectionTitle(content, "移动")
    createToggle(content, "无限跳", Config.InfJump, function(v) Config.InfJump = v end)
    createToggle(content, "启用跳跃高度", Config.JumpEnabled, function(v)
        Config.JumpEnabled = v
        applyJump()
    end)
    createSlider(content, "跳跃高度", 50, 500, Config.JumpValue, false, function(v)
        Config.JumpValue = v
        applyJump()
    end)

    createSectionTitle(content, "透视")
    createToggle(content, "玩家透视", Config.ESP, function(v) Config.ESP = v end)
    createToggle(content, "队伍识别", Config.Team, function(v) Config.Team = v end)
    local boxBtn = createToggle(content, "方框", Config.Box, function(v) setBoxState(v) end)
    addBoxButton(boxBtn)
    local distBtn = createToggle(content, "距离", Config.Dist, function(v) setDistState(v) end)
    addDistButton(distBtn)
end

-- GB
pages["GB"] = function()
    createSectionTitle(content, "僵尸透视")

    createToggle(content, "动态僵尸透视", Config.ZombieESP, function(v)
        Config.ZombieESP = v
    end)

    createToggle(content, "躯干透视", Config.ZombieBody, function(v)
        Config.ZombieBody = v
    end)

    createSlider(content, "扫描频率(秒)", 0.5, 2, Config.ZombieScanRate, true, function(v)
        Config.ZombieScanRate = v
    end)

    local boxBtn = createToggle(content, "方框", Config.Box, function(v) setBoxState(v) end)
    addBoxButton(boxBtn)

    local distBtn = createToggle(content, "距离", Config.Dist, function(v) setDistState(v) end)
    addDistButton(distBtn)

    createSectionTitle(content, "画面")
    createToggle(content, "高亮画面", Config.BrightScreen, function(v)
        Config.BrightScreen = v
        updateBright()
    end)

    createSectionTitle(content, "攻击速度")
    createToggle(content, "启用攻击速度", Config.AttackSpeed, function(v)
        Config.AttackSpeed = v
        auraUpdate()
    end)
    createSlider(content, "攻击速度值", 1, 200, Config.AttackSpeedVal, false, function(v)
        Config.AttackSpeedVal = v
    end)

    createSectionTitle(content, "隐身")
    createToggle(content, "隐身UI", Config.InvisUI, function(v)
        Config.InvisUI = v
        if v then
            if invisState.active then
                invisStatusOuter.Visible = true
            else
                invisMainOuter.Visible = true
            end
        else
            restoreInvis()
            invisMainOuter.Visible = false
            invisStatusOuter.Visible = false
            invisMiniOuterX.Visible = false
            invisEnableBtn.Text = "启用"
            invisEnableBtn.BackgroundColor3 = THEME.OFF
        end
    end)
end
-- 枪战
pages["枪战"] = function()
    createSectionTitle(content, "自瞄")

    createToggle(content, "自瞄", Config.AimEnabled, function(v)
        Config.AimEnabled = v
        updateAim()
    end)

    createToggle(content, "显示圆框", Config.AimShowCircle, function(v)
        Config.AimShowCircle = v
        updateAimCircle()
    end)

    createSlider(content, "范围", 1, 10, Config.AimRange, false, function(v)
        Config.AimRange = v
        updateAimCircle()
    end)

    createSectionTitle(content, "瞄准部位")

    local parts = {"Head", "HumanoidRootPart"}
    local labels = {"头部", "躯干"}
    local partBtns = {}

    for i, p in ipairs(parts) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 28)
        b.BackgroundColor3 = (Config.AimPart == p) and THEME.ACCENT or THEME.OFF
        b.Text = labels[i]
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 12
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.ZIndex = 7
        b.Parent = content
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        table.insert(partBtns, { btn = b, part = p })
        b.MouseButton1Click:Connect(function()
            Config.AimPart = p
            for _, item in ipairs(partBtns) do
                item.btn.BackgroundColor3 = (item.part == p) and THEME.ACCENT or THEME.OFF
            end
        end)
    end
end

-- 娱乐
pages["娱乐"] = function()
    createSectionTitle(content, "我卡了")

    createToggle(content, "我卡了", Config.LagSim, function(v)
        Config.LagSim = v
        if v then startLagSim() else stopLagSim() end
    end)

    createSlider(content, "循环时长(秒)", 0.1, 1.5, Config.LagCycle, true, function(v)
        Config.LagCycle = v
    end)

    createSlider(content, "卡顿比例(%)", 0, 100, Config.LagRatio * 100, false, function(v)
        Config.LagRatio = v / 100
    end)

    createSectionTitle(content, "整活")

    createToggle(content, "英国黄牙", Config.YellowTeeth, function(v)
        Config.YellowTeeth = v
        if not v then restoreFace() end
    end)
end

-- 飞行
pages["飞行"] = function()
    createSectionTitle(content, "飞行")
    mainFlyToggle = createToggle(content, "启用飞行", Config.Fly, function(v)
        setFlyEnabled(v)
    end)
    createSlider(content, "飞行速度", 10, 300, Config.FlySpeed, false, function(v)
        Config.FlySpeed = v
        flySpeedLabel.Text = "速度: " .. v
        flyFill.Size = UDim2.new((v - 10) / (300 - 10), 0, 1, 0)
    end)
end

-- 移速
pages["移速"] = function()
    createSectionTitle(content, "移速")
    createToggle(content, "启用移速", Config.Speed, function(v)
        Config.Speed = v
        applySpeed()
    end)
    createSlider(content, "移速值", 16, 200, Config.SpeedVal, false, function(v)
        Config.SpeedVal = v
        applySpeed()
    end)
end

-- 跳跃
pages["跳跃"] = function()
    createSectionTitle(content, "跳跃")
    createToggle(content, "启用跳跃", Config.JumpEnabled, function(v)
        Config.JumpEnabled = v
        applyJump()
    end)
    createSlider(content, "跳跃高度", 50, 500, Config.JumpValue, false, function(v)
        Config.JumpValue = v
        applyJump()
    end)
end

-- 旋转
pages["旋转"] = function()
    createSectionTitle(content, "旋转")
    createToggle(content, "启用旋转", Config.RotateEnabled, function(v)
        Config.RotateEnabled = v
        updateRotate()
    end)
    createSlider(content, "旋转速度", 10, 720, Config.RotateSpeed, false, function(v)
        Config.RotateSpeed = v
    end)
end

switchPage = function(name)
    clearContent()
    local build = pages[name]
    if build then build() end
end

local function createSideButton(name)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 30)
    wrapper.BackgroundTransparency = 1
    wrapper.ZIndex = 6
    wrapper.Parent = sidebar

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 14)
    bar.Position = UDim2.new(0, 0, 0.5, -7)
    bar.BackgroundColor3 = THEME.ACCENT
    bar.BorderSizePixel = 0
    bar.ZIndex = 8
    bar.Visible = false
    bar.Parent = wrapper

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 28, 60)
    b.BackgroundTransparency = 0.4
    b.Text = name
    b.TextColor3 = THEME.SUBTEXT
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 0
    b.ZIndex = 7
    b.Parent = wrapper
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        switchPage(name)
        for _, o in ipairs(sideButtons) do
            o.btn.BackgroundColor3 = Color3.fromRGB(20, 28, 60)
            o.btn.BackgroundTransparency = 0.4
            o.btn.TextColor3 = THEME.SUBTEXT
            o.bar.Visible = false
        end
        b.BackgroundColor3 = THEME.ACCENT
        b.BackgroundTransparency = 0.2
        b.TextColor3 = THEME.TEXT
        bar.Visible = true
    end)
    table.insert(sideButtons, { btn = b, bar = bar })
    return b
end

createSideButton("主页")
createSideButton("玩家")
createSideButton("GB")
createSideButton("枪战")
createSideButton("娱乐")
createSideButton("飞行")
createSideButton("移速")
createSideButton("跳跃")
createSideButton("旋转")
switchPage("主页")
if sideButtons[1] then
    sideButtons[1].btn.BackgroundColor3 = THEME.ACCENT
    sideButtons[1].btn.BackgroundTransparency = 0.2
    sideButtons[1].btn.TextColor3 = THEME.TEXT
    sideButtons[1].bar.Visible = true
end

bindDrag(dragArea, outer)
--========== 主窗口最小化小标签 ==========
local miniOuter, miniInner = makeWaveFrame(gui, UDim2.new(0, 106, 0, 32), UDim2.new(0, 14, 0, 14), 10, 300)
miniOuter.Visible = false

local miniLabel = Instance.new("TextButton")
miniLabel.Size = UDim2.new(1, 0, 1, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "土豆脚本UI"
miniLabel.TextColor3 = THEME.YELLOW
miniLabel.TextSize = 14
miniLabel.Font = Enum.Font.GothamBold
miniLabel.BorderSizePixel = 0
miniLabel.AutoButtonColor = false
miniLabel.ZIndex = 302
miniLabel.Parent = miniInner

local miniDrag = false
local miniStartPos = nil
local miniStartVal = nil
local miniMoved = false
local miniStartTime = 0

miniLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        miniDrag = true
        miniMoved = false
        miniStartTime = tick()
        miniStartPos = input.Position
        miniStartVal = miniOuter.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if miniDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - miniStartPos
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then miniMoved = true end
        miniOuter.Position = UDim2.new(miniStartVal.X.Scale, miniStartVal.X.Offset + d.X,
                                        miniStartVal.Y.Scale, miniStartVal.Y.Offset + d.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch) and miniDrag then
        miniDrag = false
        if not miniMoved and (tick() - miniStartTime) < 1 then
            local ww = outer.Size.X.Offset
            local wh = outer.Size.Y.Offset
            outer.Position = UDim2.new(0.5, -ww/2, 0.5, -wh/2)
            outer.Visible = true
            miniOuter.Visible = false
        end
    end
end)

minBtn.MouseButton1Click:Connect(function()
    miniOuter.Position = outer.Position
    outer.Visible = false
    miniOuter.Visible = true
end)

--========== 波光动画统一刷新 ==========
RunService.RenderStepped:Connect(function(dt)
    waveT = waveT + dt
    local bgSeq = getWaveBgSeq()
    local bdrSeq = getWaveBorderSeq()
    local offX = Vector2.new(math.sin(waveT * 0.4) * 0.3, 0)
    for _, item in ipairs(waveFrameRegistry) do
        pcall(function()
            if item.o then item.o.Color = bdrSeq end
            if item.b then
                item.b.Color = bgSeq
                item.b.Offset = offX
            end
        end)
    end
end)

--========== 窗口不超出屏幕 ==========
local function clampAllWindows()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local windows = { outer, flyOuter, invisMainOuter, invisStatusOuter, miniOuter, invisMiniOuterX, flyMiniOuter }
    for _, w in ipairs(windows) do
        if w and w.Parent and w.Visible then
            local sz = w.AbsoluteSize
            if sz.X > 0 and sz.Y > 0 then
                local p = w.Position
                local curX = p.X.Scale * vp.X + p.X.Offset
                local curY = p.Y.Scale * vp.Y + p.Y.Offset
                local maxX = math.max(0, vp.X - sz.X)
                local maxY = math.max(0, vp.Y - sz.Y)
                local nx = math.clamp(curX, 0, maxX)
                local ny = math.clamp(curY, 0, maxY)
                if math.abs(nx - curX) > 1 or math.abs(ny - curY) > 1 then
                    w.Position = UDim2.new(nx / vp.X, 0, ny / vp.Y, 0)
                end
            end
        end
    end
end

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        clampAllWindows()
    end
end)

--========== 重生处理 ==========
LP.CharacterAdded:Connect(function()
    stopFly()
    stopRotate()
    stopTeleport()
    stopAim()
    stopLagSim()
    restoreFace()
    if invisState.active then restoreInvis() end
    clearAllZombieESP()
    auraStopReplay()
    task.wait(0.6)
    applySpeed()
    applyJump()
    if Config.Fly then startFly() end
    if Config.RotateEnabled then startRotate() end
    if Config.TeleportEnabled then startTeleport() end
    if Config.BrightScreen then applyBright() end
    if Config.AimEnabled then startAim() end
    if Config.AttackSpeed then auraBindAnimator() end
end)

--========== 英国黄牙重生恢复 ==========
LP.CharacterAdded:Connect(function()
    faceOrigTextures = {}
    if Config.YellowTeeth then
        wait(1)
        applyYellowTeeth()
    end
end)

--========== 我卡了重生恢复 ==========
LP.CharacterAdded:Connect(function()
    if Config.LagSim then
        stopLagSim()
        wait(0.8)
        if Config.LagSim then startLagSim() end
    end
end)

--========== 自瞄圆框初始化 ==========
if Config.AimEnabled then
    startAim()
else
    if aimCircle then aimCircle.Visible = false end
end

--========== 初始化 ==========
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

switchPage("主页")

if Config.BrightScreen then updateBright() end
if Config.AimEnabled then startAim() end
if Config.AimShowCircle then updateAimCircle() end

--========== 最终加载提示 ==========
print("========================================")
print("[土豆脚本 v10.0] 全部加载完成 ✅")
print("作者: Крайности")
print("QQ群: 1071760297")
print("----------------------------------------")
print("分区:")
print("  主页 / 玩家 / GB / 枪战 / 娱乐")
print("  飞行 / 移速 / 跳跃 / 旋转")
print("========================================")
print("[土豆脚本 v10.0] 完整加载完成 - 祝你游戏愉快!")