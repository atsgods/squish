-- blazzed | Trident Survival V5 - Silent & Optimized + Container/Ore ESP Fixed
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
    ContainerESP = CreateToggle("Container ESP (F5)", 190),
    OreESP = CreateToggle("Ore ESP (F6)", 210),
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
    Freecam = {Enabled = false, Speed = 120},
    ContainerESP = {Enabled = false, MaxDist = 750, TextSize = 12},
    OreESP = {Enabled = false, MaxDist = 750, TextSize = 12},
}

-- Container типы (настройки цвета и видимости)
local ContainerTypes = {
    Bucket   = { label = "Bucket",   color = Color3.fromRGB(255,165,0),   enabled = true },
    Box      = { label = "Box",      color = Color3.fromRGB(230,182,0),   enabled = true },
    Chest    = { label = "Chest",    color = Color3.fromRGB(150,150,150), enabled = true },
    Crafting = { label = "Craft",    color = Color3.fromRGB(255,0,207),   enabled = true },
    Crate    = { label = "Crate",    color = Color3.fromRGB(44,97,0),     enabled = true },
    Vault    = { label = "Vault",    color = Color3.fromRGB(100,100,100), enabled = true },
    Gas      = { label = "Gasoline", color = Color3.fromRGB(200,0,0),      enabled = true },
}

-- Ore типы
local OreTypes = {
    Stone   = { label = "Stone",   color = Color3.fromRGB(120,120,120), enabled = true },
    Iron    = { label = "Iron",    color = Color3.fromRGB(255,215,0),   enabled = true },
    Nitrate = { label = "Nitrate", color = Color3.fromRGB(200,255,200), enabled = true },
}

-- ========== OPTIMIZED VARIABLES ==========
local ESPData = {}
local ChamsList = {}
local XrayCache = {}
local LastXrayState = nil
local LastXrayTrans = nil
local LastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.033
local FreecamPos = Camera.CFrame.Position

-- Container & Ore кеш
local ContainerData = setmetatable({}, {__mode = "k"})  -- model -> {text, anchor, kind}
local OreData = setmetatable({}, {__mode = "k"})        -- model -> {text, part, oreType}
local OreCache = setmetatable({}, {__mode = "k"})       -- model -> {t, p}

-- Weapon detection cache (из Goose)
local WeaponCache = setmetatable({}, {__mode = "k"})
local WeaponTimeCache = setmetatable({}, {__mode = "k"})

-- Таблица оружия и их характерных частей (из Goose)
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

-- ========== UTILITIES ==========
-- Улучшенное определение оружия (по Goose)
local function GetWeapon(model)
    local now = tick()
    local cached = WeaponCache[model]
    local cachedTime = WeaponTimeCache[model]
    if cached and cachedTime and now - cachedTime < 2 then
        return cached
    end
    
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
            if hand:FindFirstChild(partName, true) then
                score = score + 1
            end
        end
        if score > bestScore then
            bestScore = score
            bestMatch = weaponName
        end
    end
    
    if bestScore < 2 then
        bestMatch = "None"
    end
    
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

-- ========== ESP PLAYERS ==========
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
        for _, draw in pairs(ESPData[obj]) do
            draw:Remove()
        end
        ESPData[obj] = nil
    end
    if ChamsList[obj] then
        ChamsList[obj]:Destroy()
        ChamsList[obj] = nil
    end
    -- Container / Ore cleanup
    if ContainerData[obj] then
        if ContainerData[obj].text then ContainerData[obj].text:Remove() end
        ContainerData[obj] = nil
    end
    if OreData[obj] then
        if OreData[obj].text then OreData[obj].text:Remove() end
        OreData[obj] = nil
    end
    OreCache[obj] = nil
    WeaponCache[obj] = nil
    WeaponTimeCache[obj] = nil
end)

-- ========== XRAY ==========
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
                if XrayCache[part] == nil then
                    XrayCache[part] = part.Transparency
                end
                part.Transparency = transparency
            end
        end
    end
end

local function UpdateXray()
    if Settings.Xray.Enabled then
        ApplyXray(true, Settings.Xray.Trans)
    else
        ApplyXray(false)
    end
    LastXrayState = Settings.Xray.Enabled
    LastXrayTrans = Settings.Xray.Trans
end

-- ========== CONTAINER ESP (из Goose) ==========
local function DetectContainer(model)
    if not model:IsA("Model") then return false end
    -- Bucket
    if model:FindFirstChild("default") then
        local n = 0
        for _, c in ipairs(model:GetChildren()) do
            if c:IsA("BasePart") and c.Name == "Part" then n = n + 1 end
        end
        if n >= 10 then return "Bucket" end
    end
    -- Box
    local boxM = model:FindFirstChild("box")
    local trash = model:FindFirstChild("trash")
    if boxM and boxM:IsA("MeshPart") and trash and trash:IsA("MeshPart") then return "Box" end
    -- Chest
    local bodyM = model:FindFirstChild("Body")
    local defP = model:FindFirstChild("default")
    if bodyM and bodyM:IsA("MeshPart") and defP and defP:IsA("BasePart") then return "Chest" end
    -- Crafting
    if model:FindFirstChild("Dispenser") and model:FindFirstChild("Machine") and model:FindFirstChild("Sign") then return "Crafting" end
    -- Crate
    if model:FindFirstChild("Bottom") and model:FindFirstChild("Handles") and model:FindFirstChild("Top") then return "Crate" end
    -- Vault
    if model:FindFirstChild("Body") and model:FindFirstChild("Bolts") and
       model:FindFirstChild("Dials") and model:FindFirstChild("Hinge") and
       model:FindFirstChild("Pins") and model:FindFirstChild("Wheel") then return "Vault" end
    -- Gas
    local prim = model:FindFirstChild("Prim")
    if prim and prim:FindFirstChildWhichIsA("SpecialMesh") then return "Gas" end
    return false
end

local function AddContainerESP(model)
    if ContainerData[model] then return end
    local kind = DetectContainer(model)
    if not kind then return end
    local anchor = model:FindFirstChildWhichIsA("BasePart")
    if not anchor then return end
    local text = Drawing.new("Text")
    text.Text = ContainerTypes[kind].label
    text.Size = Settings.ContainerESP.TextSize
    text.Center = true
    text.Font = 2
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0,0,0)
    text.Color = ContainerTypes[kind].color
    text.Visible = false
    ContainerData[model] = {text=text, anchor=anchor, kind=kind}
end

local function RemoveContainerESP(model)
    local data = ContainerData[model]
    if data and data.text then data.text:Remove() end
    ContainerData[model] = nil
end

-- ========== ORE ESP (из Goose) ==========
local STONE_C   = Color3.fromRGB(72,72,72)
local IRON_C1   = Color3.fromRGB(199,172,120)
local NITRATE_C = Color3.fromRGB(248,248,248)

local function DetectOre(model)
    local cached = OreCache[model]
    if cached ~= nil then return cached.t, cached.p end
    local fp = model:FindFirstChildOfClass("MeshPart")
    if not fp then OreCache[model] = {t=nil,p=nil}; return nil, nil end
    local parts = {fp}
    for _, c in ipairs(model:GetChildren()) do
        if c:IsA("MeshPart") and c ~= fp then
            table.insert(parts, c)
            if #parts >= 2 then break end
        end
    end
    local oreType, anchorPart
    if #parts == 1 and fp.Color == STONE_C then
        oreType, anchorPart = "Stone", fp
    elseif #parts == 2 then
        local c1, c2 = parts[1].Color, parts[2].Color
        if (c1 == STONE_C and c2 == IRON_C1) or (c2 == STONE_C and c1 == IRON_C1) then
            oreType, anchorPart = "Iron", parts[1]
        elseif (c1 == NITRATE_C and c2 == STONE_C) or (c2 == NITRATE_C and c1 == STONE_C) then
            oreType, anchorPart = "Nitrate", parts[1]
        end
    end
    OreCache[model] = {t=oreType, p=anchorPart}
    return oreType, anchorPart
end

local function AddOreESP(model)
    if OreData[model] then return end
    local oreType, part = DetectOre(model)
    if not oreType or not part then return end
    local text = Drawing.new("Text")
    text.Text = oreType
    text.Size = Settings.OreESP.TextSize
    text.Center = true
    text.Font = 2
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0,0,0)
    text.Color = OreTypes[oreType].color
    text.Visible = false
    OreData[model] = {text=text, part=part, oreType=oreType}
end

local function RemoveOreESP(model)
    local data = OreData[model]
    if data and data.text then data.text:Remove() end
    OreData[model] = nil
    OreCache[model] = nil
end

-- ========== СКАНИРОВАНИЕ МИРА ДЛЯ КОНТЕЙНЕРОВ И РУД ==========
local function ScanWorld()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            if DetectContainer(obj) then AddContainerESP(obj) end
            local oreType, _ = DetectOre(obj)
            if oreType then AddOreESP(obj) end
        end
    end
end

workspace.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if child:IsA("Model") then
        if DetectContainer(child) then AddContainerESP(child) end
        local oreType, _ = DetectOre(child)
        if oreType then AddOreESP(child) end
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") then
        RemoveContainerESP(child)
        RemoveOreESP(child)
    end
end)

task.spawn(ScanWorld)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function(dt)
    local now = tick()
    
    -- Xray
    if Settings.Xray.Enabled ~= LastXrayState or Settings.Xray.Trans ~= LastXrayTrans then
        UpdateXray()
    end
    
    -- Player Chams
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
        for _, hl in pairs(ChamsList) do
            if hl then hl.Enabled = false end
        end
    end
    
    -- Player ESP
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
                    data.Box.Visible = false
                    data.Name.Visible = false
                    data.Dist.Visible = false
                    data.Weap.Visible = false
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
                    
                    local weaponName = GetWeapon(model)
                    data.Weap.Text = weaponName
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
    
    -- ===== CONTAINER ESP (с принудительным скрытием при отключении) =====
    if Settings.ContainerESP.Enabled then
        local maxDistSq = Settings.ContainerESP.MaxDist ^ 2
        local camPos = Camera.CFrame.Position
        local viewSize = Camera.ViewportSize
        for model, data in pairs(ContainerData) do
            if not model or not model.Parent or not data.anchor or not data.anchor.Parent then
                RemoveContainerESP(model)
                continue
            end
            local kind = data.kind
            if not ContainerTypes[kind].enabled then
                if data.text then data.text.Visible = false end
                continue
            end
            local pos = data.anchor.Position
            local diff = pos - camPos
            if diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z <= maxDistSq then
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    data.text.Text = ContainerTypes[kind].label
                    data.text.Position = Vector2.new(
                        math.clamp(screenPos.X, 20, viewSize.X - 20),
                        math.clamp(screenPos.Y - 20, 20, viewSize.Y - 20)
                    )
                    data.text.Color = ContainerTypes[kind].color
                    data.text.Visible = true
                else
                    data.text.Visible = false
                end
            else
                data.text.Visible = false
            end
        end
    else
        -- Принудительно скрываем все тексты контейнеров
        for _, data in pairs(ContainerData) do
            if data and data.text then data.text.Visible = false end
        end
    end
    
    -- ===== ORE ESP (с принудительным скрытием при отключении) =====
    if Settings.OreESP.Enabled then
        local maxDistSq = Settings.OreESP.MaxDist ^ 2
        local camPos = Camera.CFrame.Position
        for model, data in pairs(OreData) do
            if not model or not model.Parent or not data.part or not data.part.Parent then
                RemoveOreESP(model)
                continue
            end
            local oreType = data.oreType
            if not OreTypes[oreType].enabled then
                if data.text then data.text.Visible = false end
                continue
            end
            local pos = data.part.Position
            local diff = pos - camPos
            if diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z <= maxDistSq then
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    data.text.Position = Vector2.new(screenPos.X, screenPos.Y)
                    data.text.Color = OreTypes[oreType].color
                    data.text.Visible = true
                else
                    data.text.Visible = false
                end
            else
                data.text.Visible = false
            end
        end
    else
        -- Принудительно скрываем все тексты руд
        for _, data in pairs(OreData) do
            if data and data.text then data.text.Visible = false end
        end
    end
end)

-- ========== KEYBINDS ==========
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
        if Settings.Freecam.Enabled then
            FreecamPos = Camera.CFrame.Position
        end
    elseif inp.KeyCode == Enum.KeyCode.F5 then
        Settings.ContainerESP.Enabled = not Settings.ContainerESP.Enabled
        Toggles.ContainerESP.Text = Settings.ContainerESP.Enabled and "[✔] Container ESP" or "[ ] Container ESP"
        -- Принудительно обновляем видимость
        if not Settings.ContainerESP.Enabled then
            for _, data in pairs(ContainerData) do
                if data and data.text then data.text.Visible = false end
            end
        end
    elseif inp.KeyCode == Enum.KeyCode.F6 then
        Settings.OreESP.Enabled = not Settings.OreESP.Enabled
        Toggles.OreESP.Text = Settings.OreESP.Enabled and "[✔] Ore ESP" or "[ ] Ore ESP"
        if not Settings.OreESP.Enabled then
            for _, data in pairs(OreData) do
                if data and data.text then data.text.Visible = false end
            end
        end
    end
end)

UpdateXray()
