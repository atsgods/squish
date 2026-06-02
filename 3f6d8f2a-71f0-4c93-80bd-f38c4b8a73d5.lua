-- blazzed | Trident Survival V5 - Ключ: atsgey (кнопка по центру)
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

-- ========== КЛЮЧЕВАЯ ЗАЩИТА (исправленное позиционирование) ==========
local inputString = ""
local waitingForKey = true

-- Фон (высота 220)
local bg = Drawing.new("Square")
bg.Size = Vector2.new(400, 220)
bg.Position = Vector2.new((Camera.ViewportSize.X - 400) / 2, (Camera.ViewportSize.Y - 220) / 2)
bg.Color = Color3.fromRGB(20, 20, 30)
bg.Filled = true
bg.Thickness = 0
bg.Visible = true

-- Заголовок
local title = Drawing.new("Text")
title.Text = "Введите ключ доступа"
title.Size = 20
title.Color = Color3.fromRGB(255, 255, 255)
title.Position = Vector2.new(bg.Position.X + 200, bg.Position.Y + 30)
title.Center = true
title.Outline = true
title.Visible = true

-- Поле ввода
local inputFieldBg = Drawing.new("Square")
inputFieldBg.Size = Vector2.new(300, 40)
inputFieldBg.Position = Vector2.new(bg.Position.X + 50, bg.Position.Y + 70)
inputFieldBg.Color = Color3.fromRGB(50, 50, 60)
inputFieldBg.Filled = true
inputFieldBg.Thickness = 1
inputFieldBg.Visible = true

local inputText = Drawing.new("Text")
inputText.Text = ""
inputText.Size = 18
inputText.Color = Color3.fromRGB(255, 255, 255)
inputText.Position = Vector2.new(inputFieldBg.Position.X + 10, inputFieldBg.Position.Y + 8)
inputText.Center = false
inputText.Outline = false
inputText.Visible = true

-- Кнопка "Войти" (теперь точно по центру)
-- Поле ввода заканчивается на Y = 70+40 = 110
-- Свободное место до низа: 220 - 110 = 110
-- Центр этого места: 110 + (110-40)/2 = 110 + 35 = 145
local buttonBg = Drawing.new("Square")
buttonBg.Size = Vector2.new(140, 40)
buttonBg.Position = Vector2.new(bg.Position.X + (400 - 140) / 2, bg.Position.Y + 145)
buttonBg.Color = Color3.fromRGB(0, 120, 255)
buttonBg.Filled = true
buttonBg.Thickness = 0
buttonBg.Visible = true

local buttonText = Drawing.new("Text")
buttonText.Text = "Войти"
buttonText.Size = 18
buttonText.Color = Color3.fromRGB(255, 255, 255)
buttonText.Position = Vector2.new(buttonBg.Position.X + 70, buttonBg.Position.Y + 20)
buttonText.Center = true
buttonText.Outline = false
buttonText.Visible = true

-- Сообщение об ошибке (под кнопкой, на расстоянии 10 пикселей)
local errorMsg = Drawing.new("Text")
errorMsg.Text = ""
errorMsg.Size = 14
errorMsg.Color = Color3.fromRGB(255, 80, 80)
errorMsg.Position = Vector2.new(bg.Position.X + 200, bg.Position.Y + 200)
errorMsg.Center = true
errorMsg.Visible = true

-- Обновление позиций
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    bg.Position = Vector2.new((Camera.ViewportSize.X - 400) / 2, (Camera.ViewportSize.Y - 220) / 2)
    title.Position = Vector2.new(bg.Position.X + 200, bg.Position.Y + 30)
    inputFieldBg.Position = Vector2.new(bg.Position.X + 50, bg.Position.Y + 70)
    inputText.Position = Vector2.new(inputFieldBg.Position.X + 10, inputFieldBg.Position.Y + 8)
    buttonBg.Position = Vector2.new(bg.Position.X + (400 - 140) / 2, bg.Position.Y + 145)
    buttonText.Position = Vector2.new(buttonBg.Position.X + 70, buttonBg.Position.Y + 20)
    errorMsg.Position = Vector2.new(bg.Position.X + 200, bg.Position.Y + 200)
end)

-- Проверка ключа
local function checkKey()
    if inputString == "atsgey" then
        waitingForKey = false
        for _, obj in pairs({bg, title, inputFieldBg, inputText, buttonBg, buttonText, errorMsg}) do
            obj.Visible = false
            obj:Remove()
        end
    else
        errorMsg.Text = "Неверный ключ!"
        inputString = ""
        inputText.Text = ""
        task.wait(2)
        errorMsg.Text = ""
    end
end

-- Обработка ввода
local function onInput(input, gameProcessed)
    if gameProcessed then return end
    if not waitingForKey then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.Return or key == Enum.KeyCode.KeypadEnter then
            checkKey()
        elseif key == Enum.KeyCode.Backspace then
            inputString = inputString:sub(1, -2)
            inputText.Text = inputString
        else
            local char = key.Name
            if #char == 1 and char:match("[a-zA-Z0-9]") then
                inputString = inputString .. char:lower()
                inputText.Text = inputString
            end
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mp = Vector2.new(input.Position.X, input.Position.Y)
        if mp.X >= buttonBg.Position.X and mp.X <= buttonBg.Position.X + buttonBg.Size.X and
           mp.Y >= buttonBg.Position.Y and mp.Y <= buttonBg.Position.Y + buttonBg.Size.Y then
            checkKey()
        end
    end
end

UIS.InputBegan:Connect(onInput)
repeat task.wait() until not waitingForKey

-- ========== ОСНОВНАЯ ЧАСТЬ (ESP, CHAMS, XRAY, FREECAM) ==========
local Menu = { Open = false }
local MenuTitle = Drawing.new("Text")
MenuTitle.Position = Vector2.new(20,40)
MenuTitle.Text = "blazzed | script"
MenuTitle.Size = 19
MenuTitle.Color = Color3.fromRGB(255,60,60)
MenuTitle.Outline = true

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
    MenuTitle.Visible = v
    Status.Visible = v
    for _, t in pairs(Toggles) do t.Visible = v end
end

UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        Menu.Open = not Menu.Open
        UpdateMenu()
    end
end)

local Settings = {
    PlayerESP = {Enabled = false},
    Chams = {Enabled = false},
    Xray = {Enabled = false, Trans = 0.5},
    Freecam = {Enabled = false, Speed = 120}
}

local ESPData = {}
local ChamsList = {}
local XrayCache = {}
local LastXrayState = nil
local LastXrayTrans = nil
local LastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.033
local FreecamPos = Camera.CFrame.Position

-- Weapon detection (сокращено для читаемости)
local WeaponCache = setmetatable({}, {__mode = "k"})
local WeaponTimeCache = setmetatable({}, {__mode = "k"})
local WeaponParts = {
    AR15 = {"AnimSaves","Barrel","Body","Bolt","ChargingHandle","Decor","Grip","Mag","Rails","Stock","Muzzle"},
    M4A1 = {"DefaultSight","Body","Bolt","ChargeHandle","Grip","Mag","Metal","mbrk","Muzzle"},
    SCAR = {"DefaultSight","Barrel","Body","ChargingHandle","Decals","Mag","Rails","ShoulderPad","Stock"},
    SVD = {"DefaultSight","Body","Bolt","Magazine","Magazine2","Metal2","Wood"},
    Bow = {"Arrow","Fabric","Handle","Meshes/Bow","ADS","Mover","AnimationController"},
    CrossBow = {"Arrow","BackMetal","Body","FrontNails","Handle","Release","SpringSteel","String","Wheel","Slide"},
    UZI = {"DefaultSight","Body","Body2","Bolt","ChargingHandle","Decor","Grip","Mag","Stock","Muzzle"},
    Magnum = {"Cylinder","Decor","EjectRod","EjectRodDecal","Frame","Grip"},
    PumpShotgun = {"Barrel","Body","Handle","MainMetal","RearSight","Shell","Slider","ADS","Muzzle"},
    EnergyRifle = {"DefaultSight","FrontCover","Glowing","Grip","Mag","Metal","Metal2","RearCover","RearDecor","Screws","Tubes"},
    GaussRifle = {"DefaultSight","Barrel","Body","CoilHolders","Coils","Decals1","Decals2","Grip","Housing","Mag","StockBack"},
    HMAR = {"DefaultSight","Body","Bolt","Bolts","Cover","Mag","Rails","Spring","Stock","Wood","Muzzle"},
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
