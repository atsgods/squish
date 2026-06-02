-- blazzed | script | Trident Survival V5
-- Silent Version - Fixed & Improved

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== SILENT BYPASS ====================
pcall(function()
    hookfunction(game:GetService("Stats").GetMemoryUsageMb, function() return math.random(140, 260) end)
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local arg = tostring(select(1, ...))
            if arg:find("Ban") or arg:find("Kick") or arg:find("Detect") or arg:find("Report") then return end
        end
        if method == "Kick" then return end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ==================== MENU ====================
local Menu = { Open = false }
local Title = Drawing.new("Text"); Title.Position = Vector2.new(20,40); Title.Text = "blazzed | script"; Title.Size = 19; Title.Color = Color3.fromRGB(255,60,60); Title.Outline = true
local Status = Drawing.new("Text"); Status.Position = Vector2.new(20,70); Status.Text = "RightShift - Menu"; Status.Size = 16; Status.Color = Color3.fromRGB(180,180,180); Status.Outline = true

local function CreateToggle(text, y)
    local t = Drawing.new("Text")
    t.Position = Vector2.new(30, y)
    t.Text = "[ ] " .. text
    t.Size = 16
    t.Color = Color3.fromRGB(255,255,255)
    t.Outline = true
    t.Visible = false
    return t
end

local Toggles = {
    PlayerESP = CreateToggle("Player ESP (F1)", 110),
    Chams = CreateToggle("Chams (F2)", 130),
    Xray = CreateToggle("Xray (F3)", 150),
    Freecam = CreateToggle("Freecam (F4)", 170),
}

local function UpdateMenu()
    local v = Menu.Open
    Title.Visible = v; Status.Visible = v
    for _, t in pairs(Toggles) do t.Visible = v end
end

UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        Menu.Open = not Menu.Open
        UpdateMenu()
    end
end)

-- ==================== SETTINGS ====================
local Settings = {
    PlayerESP = {Enabled = false},
    Chams = {Enabled = false},
    Xray = {Enabled = false, Trans = 0.5},
    Freecam = {Enabled = false, Speed = 120}
}

-- ==================== VARIABLES ====================
local ESPData = {}
local Chams = {}          -- ← Исправлено
local XrayCache = {}      -- ← Исправлено
local FreecamPos = Camera.CFrame.Position

-- ==================== PLAYER ESP ====================
local function GetWeapon(model)
    local hand = model:FindFirstChild("HandModel")
    if not hand then return "None" end
    local weapons = {"AR15","M4A1","SCAR","SVD","Bow","CrossBow","UZI","Magnum","PumpShotgun","EnergyRifle","GaussRifle","HMAR","LeverActionRifle"}
    for _, w in ipairs(weapons) do
        if hand:FindFirstChild(w, true) then return w end
    end
    return "Unknown"
end

local function IsSleeper(model)
    local lt = model:FindFirstChild("LowerTorso")
    if lt and lt:FindFirstChild("RootRig") then
        local angle = lt.RootRig.CurrentAngle
        return typeof(angle) == "number" and math.abs(angle) > 0.1
    end
    return false
end

local function CreateESP(model)
    if ESPData[model] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1.8
    box.Filled = false
    box.Transparency = 1
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Outline = true
    name.Center = true
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Size = 13
    dist.Color = Color3.fromRGB(200, 200, 200)
    dist.Outline = true
    dist.Center = true
    dist.Visible = false

    local weap = Drawing.new("Text")
    weap.Size = 13
    weap.Color = Color3.fromRGB(255, 200, 100)
    weap.Outline = true
    weap.Center = true
    weap.Visible = false

    ESPData[model] = {Box = box, Name = name, Dist = dist, Weap = weap}
end

-- ==================== XRAY ====================
local function ApplyXray(state)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local m = part.Material
            if m == Enum.Material.Cobblestone or m == Enum.Material.Concrete or m == Enum.Material.Brick or 
               m == Enum.Material.WoodPlanks or m == Enum.Material.Metal then
                if not XrayCache[part] then 
                    XrayCache[part] = part.Transparency 
                end
                part.Transparency = state and Settings.Xray.Trans or XrayCache[part]
            end
        end
    end
end

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function(dt)
    -- Player ESP
    if Settings.PlayerESP.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if not model:IsA("Model") or model == Player.Character then continue end
            local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("LowerTorso")
            if not root then continue end

            CreateESP(model)
            local data = ESPData[model]

            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
            local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

            if top.Z < 0 then 
                data.Box.Visible = false; data.Name.Visible = false
                data.Dist.Visible = false; data.Weap.Visible = false
                continue 
            end

            local height = bot.Y - top.Y
            local width = height * 0.65
            local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
            local isSleeping = IsSleeper(model)

            if isSleeping then
                data.Box.Color = Color3.fromRGB(255, 85, 85)
                data.Name.Text = model.Name .. " [SLEEP]"
                data.Name.Color = Color3.fromRGB(255, 100, 100)
            else
                data.Box.Color = Color3.fromRGB(0, 255, 100)
                data.Name.Text = model.Name
                data.Name.Color = Color3.fromRGB(255, 255, 255)
            end

            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(top.X - width/2, top.Y)
            data.Box.Visible = true

            data.Name.Position = Vector2.new(top.X, top.Y - 22)
            data.Name.Visible = true

            data.Dist.Text = distance .. "m"
            data.Dist.Position = Vector2.new(top.X, bot.Y + 6)
            data.Dist.Visible = true

            data.Weap.Text = GetWeapon(model)
            data.Weap.Position = Vector2.new(top.X, bot.Y + 24)
            data.Weap.Visible = true
        end
    else
        for _, data in pairs(ESPData) do
            data.Box.Visible = false
            data.Name.Visible = false
            data.Dist.Visible = false
            data.Weap.Visible = false
        end
    end

    -- Chams
    if Settings.Chams.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                if not Chams[model] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.FillColor = Color3.fromRGB(0, 170, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = model
                    Chams[model] = hl
                end
                Chams[model].Enabled = true
            end
        end
    else
        for _, hl in pairs(Chams) do
            if hl and hl.Parent then hl.Enabled = false end
        end
    end

    -- Xray
    if Settings.Xray.Enabled then
        ApplyXray(true)
    else
        ApplyXray(false)
    end

    -- Freecam
    if Settings.Freecam.Enabled then
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            FreecamPos = FreecamPos + move.Unit * Settings.Freecam.Speed * dt
        end
        Camera.CFrame = CFrame.new(FreecamPos, FreecamPos + Camera.CFrame.LookVector)
    end
end)

-- ==================== KEYBINDS ====================
UIS.InputBegan:Connect(function(inp)
    if not Menu.Open then return end
    if inp.KeyCode == Enum.KeyCode.F1 then
        Settings.PlayerESP.Enabled = not Settings.PlayerESP.Enabled
        Toggles.PlayerESP.Text = Settings.PlayerESP.Enabled and "[✔] Player ESP" or "[ ] Player ESP"
    elseif inp.KeyCode == Enum.KeyCode.F2 then
        Settings.Chams.Enabled = not Settings.Chams.Enabled
        Toggles.Chams.Text = Settings.Chams.Enabled and "[✔] Chams" or "[ ] Chams"
    elseif inp.KeyCode == Enum.KeyCode.F3 then
        Settings.Xray.Enabled = not Settings.Xray.Enabled
        Toggles.Xray.Text = Settings.Xray.Enabled and "[✔] Xray" or "[ ] Xray"
    elseif inp.KeyCode == Enum.KeyCode.F4 then
        Settings.Freecam.Enabled = not Settings.Freecam.Enabled
        Toggles.Freecam.Text = Settings.Freecam.Enabled and "[✔] Freecam" or "[ ] Freecam"
    end
end)
