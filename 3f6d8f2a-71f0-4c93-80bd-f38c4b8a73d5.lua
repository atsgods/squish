-- blazzed | Trident Survival V5 - Ключ: atsgey
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== SILENT BYPASS ==========
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

-- ========== KEY CHECK (БЕЗ ТЕКСТА В ПОЛЕ) ==========
local function ShowKeyGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyCheckGUI"
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Введите ключ доступа"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = ""   -- ПОЛЕ ВВОДА ПУСТОЕ
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame

    local cornerBox = Instance.new("UICorner")
    cornerBox.CornerRadius = UDim.new(0, 4)
    cornerBox.Parent = textBox

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.6, 0, 0, 40)
    button.Position = UDim2.new(0.2, 0, 0.7, 0)
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    button.Text = "Войти"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 4)
    cornerBtn.Parent = button

    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 25)
    errorLabel.Position = UDim2.new(0, 0, 0.85, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Visible = false
    errorLabel.Parent = frame

    local accepted = false
    button.MouseButton1Click:Connect(function()
        local key = textBox.Text
        if key == "atsgey" then
            accepted = true
            gui:Destroy()
        else
            errorLabel.Text = "Неверный ключ! Попробуйте снова."
            errorLabel.Visible = true
            textBox.Text = ""
            task.wait(2)
            errorLabel.Visible = false
        end
    end)

    repeat task.wait() until accepted == true
end

ShowKeyGUI()

-- ========== MENU ==========
local Menu = { Open = false }
local Title = Drawing.new("Text")
Title.Position = Vector2.new(20,40)
Title.Text = "blazzed | script"
Title.Size = 19
Title.Color = Color3.fromRGB(255,60,60)
Title.Outline = true

local Status = Drawing.new("Text")
Status.Position = Vector2.new(20,70)
Status.Text = "RightShift - Menu"
Status.Size = 16
Status.Color = Color3.fromRGB(180,180,180)
Status.Outline = true

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
    Title.Visible = v
    Status.Visible = v
    for _, t in pairs(Toggles) do t.Visible = v end
end

UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        Menu.Open = not Menu.Open
        UpdateMenu()
    end
end)

-- ========== SETTINGS ==========
local Settings = {
    PlayerESP = {Enabled = false},
    Chams = {Enabled = false},
    Xray = {Enabled = false, Trans = 0.5},
    Freecam = {Enabled = false, Speed = 120}
}

-- ========== VARIABLES ==========
local ESPData = {}
local ChamsList = {}
local XrayCache = {}
local LastXrayState = nil
local LastXrayTrans = nil
local LastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.033
local FreecamPos = Camera.CFrame.Position

-- Weapon detection
local WeaponCache = setmetatable({}, {__mode = "k"})
local WeaponTimeCache = setmetatable({}, {__mode = "k"})
local WeaponParts = {
    AR15             = {"AnimSaves","Barrel","Body","Bolt","ChargingHandle","Decor","Grip","Mag","Rails","Stock","Muzzle"},
    M4A1             = {"DefaultSight","Body","Bolt","ChargeHandle","Grip","Mag","Metal","mbrk","Muzzle"},
    SCAR             = {"DefaultSight","Barrel","Body","ChargingHandle","Decals","Mag","Rails","ShoulderPad","Stock"},
    SVD              = {"DefaultSight","Body","Bolt","Magazine","Magazine2","Metal2","Wood"},
    Bow              = {"Arrow","Fabric","Handle","Meshes/Bow","ADS","Mover","AnimationController"},
    CrossBow         = {"Arrow","BackMetal","Body","FrontNails","Handle","Release","SpringSteel","String","Wheel","Slide"},
    UZI              = {"DefaultSight","Body","Body2","Bolt","ChargingHandle","Decor","Grip","Mag","Stock","Muzzle"},
    Magnum           = {"Cylinder","Decor","EjectRod","EjectRodDecal","Frame","Grip"},
    PumpShotgun      = {"Barrel","Body","Handle","MainMetal","RearSight","Shell","Slider","ADS","Muzzle"},
    EnergyRifle      = {"DefaultSight","FrontCover","Glowing","Grip","Mag","Metal","Metal2","RearCover","RearDecor","Screws","Tubes"},
    GaussRifle       = {"DefaultSight","Barrel","Body","CoilHolders","Coils","Decals1","Decals2","Grip","Housing","Mag","StockBack"},
    HMAR             = {"DefaultSight","Body","Bolt","Bolts","Cover","Mag","Rails","Spring","Stock","Wood","Muzzle"},
    LeverActionRifle = {"9mm","DefaultSight","Body","Brass","Hammer","Lever","Metal","Thing","Wood","Muzzle"},
}

local function GetWeapon(model)
    local now = tick()
    local cached = WeaponCache[model]
    local cachedTime = WeaponTimeCache[model]
    if cached and cachedTime and now - cachedTime < 2 then return cached end
    local hand = model:FindFirstChild("HandModel")
    if not hand then
        WeaponCache[model] = "None"
        WeaponTimeCache[model] = now
        return "None"
    end
    local bestMatch = "None"
    local bestScore = 0
    for weaponName, parts in pairs(WeaponParts) do
        local score = 0
        for _, partName in ipairs(parts) do
            if hand:FindFirstChild(partName, true) then score = score + 1 end
        end
        if score > bestScore then bestScore = score; bestMatch = weaponName end
    end
    if bestScore < 2 then bestMatch = "None" end
    WeaponCache[model] = bestMatch
    WeaponTimeCache[model] = now
    return bestMatch
end

local function IsSleeper(model)
    local lt = model:FindFirstChild("LowerTorso")
    if lt and lt:FindFirstChild("RootRig") then
        local angle = lt.RootRig.CurrentAngle
        return typeof(angle) == "number" and math.abs(angle) > 0.1
    end
    return false
end

function CreateESP(model)
    if ESPData[model] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1.8
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    local name = Drawing.new("Text")
    name.Size = 14
    name.Color = Color3.fromRGB(255,255,255)
    name.Outline = true
    name.Center = true
    name.Visible = false
    local dist = Drawing.new("Text")
    dist.Size = 13
    dist.Color = Color3.fromRGB(200,200,200)
    dist.Outline = true
    dist.Center = true
    dist.Visible = false
    local weap = Drawing.new("Text")
    weap.Size = 13
    weap.Color = Color3.fromRGB(255,200,100)
    weap.Outline = true
    weap.Center = true
    weap.Visible = false
    ESPData[model] = {Box=box, Name=name, Dist=dist, Weap=weap}
end

game.DescendantRemoving:Connect(function(obj)
    if ESPData[obj] then
        for _, draw in pairs(ESPData[obj]) do draw:Remove() end
        ESPData[obj] = nil
    end
    if ChamsList[obj] then
        ChamsList[obj]:Destroy()
        ChamsList[obj] = nil
    end
    WeaponCache[obj] = nil
    WeaponTimeCache[obj] = nil
end)

-- XRAY
local function ApplyXray(enable, transparency)
    local targetTrans = enable and transparency or nil
    for part, origTrans in pairs(XrayCache) do
        if part and part.Parent then
            part.Transparency = targetTrans or origTrans
        else
            XrayCache[part] = nil
        end
    end
    if not enable then return end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local m = part.Material
            if m == Enum.Material.Cobblestone or m == Enum.Material.Concrete or m == Enum.Material.Brick or
               m == Enum.Material.WoodPlanks or m == Enum.Material.Metal then
                if XrayCache[part] == nil then XrayCache[part] = part.Transparency end
                part.Transparency = transparency
            end
        end
    end
end

local function UpdateXray()
    if Settings.Xray.Enabled then ApplyXray(true, Settings.Xray.Trans)
    else ApplyXray(false) end
    LastXrayState = Settings.Xray.Enabled
    LastXrayTrans = Settings.Xray.Trans
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
    local now = tick()
    if Settings.Xray.Enabled ~= LastXrayState or Settings.Xray.Trans ~= LastXrayTrans then UpdateXray() end
    
    if Settings.Chams.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                if not ChamsList[model] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.FillColor = Color3.fromRGB(0,170,255)
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.Parent = model
                    ChamsList[model] = hl
                end
                ChamsList[model].Enabled = true
            end
        end
    else
        for _, hl in pairs(ChamsList) do if hl then hl.Enabled = false end end
    end
    
    if Settings.PlayerESP.Enabled then
        if now - LastESPUpdate >= ESP_UPDATE_INTERVAL or not LastESPUpdate then
            LastESPUpdate = now
            for _, model in ipairs(workspace:GetChildren()) do
                if not model:IsA("Model") or model == Player.Character then continue end
                local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("LowerTorso")
                if not root then continue end
                CreateESP(model)
                local data = ESPData[model]
                if not data then continue end
                local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3.2,0))
                local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                if top.Z < 0 then
                    data.Box.Visible = false; data.Name.Visible = false; data.Dist.Visible = false; data.Weap.Visible = false
                else
                    local height = bot.Y - top.Y
                    local width = height * 0.65
                    local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                    local isSleeping = IsSleeper(model)
                    if isSleeping then
                        data.Box.Color = Color3.fromRGB(255,85,85)
                        data.Name.Text = model.Name .. " [SLEEP]"
                        data.Name.Color = Color3.fromRGB(255,100,100)
                    else
                        data.Box.Color = Color3.fromRGB(0,255,100)
                        data.Name.Text = model.Name
                        data.Name.Color = Color3.fromRGB(255,255,255)
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
            end
        end
    else
        for _, data in pairs(ESPData) do
            if data.Box then data.Box.Visible = false end
            if data.Name then data.Name.Visible = false end
            if data.Dist then data.Dist.Visible = false end
            if data.Weap then data.Weap.Visible = false end
        end
    end
    
    if Settings.Freecam.Enabled then
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then FreecamPos = FreecamPos + move.Unit * Settings.Freecam.Speed * dt end
        Camera.CFrame = CFrame.new(FreecamPos, FreecamPos + Camera.CFrame.LookVector)
    end
end)

-- KEYBINDS
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
        UpdateXray()
    elseif inp.KeyCode == Enum.KeyCode.F4 then
        Settings.Freecam.Enabled = not Settings.Freecam.Enabled
        Toggles.Freecam.Text = Settings.Freecam.Enabled and "[✔] Freecam" or "[ ] Freecam"
        if Settings.Freecam.Enabled then FreecamPos = Camera.CFrame.Position end
    end
end)

UpdateXray()
