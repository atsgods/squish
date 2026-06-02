-- blazzed | script | Trident Survival V5
-- Silent Version

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
            if arg:find("Ban") or arg:find("Kick") or arg:find("Detect") then return end
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
    OreESP    = CreateToggle("Ore ESP (F2)", 130),
    Chams     = CreateToggle("Chams (F3)", 150),
    Xray      = CreateToggle("Xray (F4)", 170),
    Freecam   = CreateToggle("Freecam (F5)", 190),
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
    OreESP = {Enabled = false},
    Chams = {Enabled = false},
    Xray = {Enabled = false, Trans = 0.5},
    Freecam = {Enabled = false, Speed = 100}
}

-- ==================== PLAYER ESP ====================
local PlayerESPData = {}

local function GetWeapon(model)
    local hand = model:FindFirstChild("HandModel")
    if not hand then return "None" end
    local weapons = {"AR15","M4A1","SCAR","SVD","Bow","CrossBow","UZI","Magnum","PumpShotgun","EnergyRifle"}
    for _, w in ipairs(weapons) do
        if hand:FindFirstChild(w, true) then return w end
    end
    return "Unknown"
end

local function CreatePlayerESP(plr)
    if PlayerESPData[plr] then return end
    local box = Drawing.new("Square"); box.Thickness=1.5; box.Color=Color3.fromRGB(0,255,100); box.Filled=false; box.Visible=false
    local name = Drawing.new("Text"); name.Size=14; name.Color=Color3.fromRGB(255,255,255); name.Outline=true; name.Center=true; name.Visible=false
    local dist = Drawing.new("Text"); dist.Size=13; dist.Color=Color3.fromRGB(200,200,200); dist.Outline=true; dist.Center=true; dist.Visible=false
    local weap = Drawing.new("Text"); weap.Size=13; weap.Color=Color3.fromRGB(255,200,100); weap.Outline=true; weap.Center=true; weap.Visible=false

    PlayerESPData[plr] = {Box=box, Name=name, Dist=dist, Weap=weap}
end

-- ==================== ORE ESP ====================
local OreData = {}

local function CreateOreESP(model, oreType)
    if OreData[model] then return end
    local t = Drawing.new("Text")
    t.Size = 14; t.Outline = true; t.Center = true; t.Visible = false
    t.Color = oreType == "Iron" and Color3.fromRGB(255,215,0) or oreType == "Nitrate" and Color3.fromRGB(100,255,150) or Color3.fromRGB(200,200,200)
    OreData[model] = {Text = t, Type = oreType}
end

-- ==================== CHAMS ====================
local Chams = {}

-- ==================== XRAY ====================
local XrayCache = {}

local function ApplyXray(state)
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local m = part.Material
            if m == Enum.Material.Cobblestone or m == Enum.Material.Concrete or m == Enum.Material.Brick or m == Enum.Material.WoodPlanks then
                if not XrayCache[part] then XrayCache[part] = part.Transparency end
                part.Transparency = state and Settings.Xray.Trans or XrayCache[part]
            end
        end
    end
end

-- ==================== FREECAM ====================
local FreecamPos = Camera.CFrame.Position

-- ==================== MAIN LOOP ====================
RunService.RenderStepped:Connect(function(dt)
    -- Player ESP
    if Settings.PlayerESP.Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == Player or not plr.Character then continue end
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            CreatePlayerESP(plr)
            local d = PlayerESPData[plr]

            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
            local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            local h = bot.Y - top.Y
            local w = h * 0.65

            d.Box.Size = Vector2.new(w, h)
            d.Box.Position = Vector2.new(top.X - w/2, top.Y)
            d.Box.Visible = true

            d.Name.Text = plr.Name
            d.Name.Position = Vector2.new(top.X, top.Y - 20)
            d.Name.Visible = true

            d.Dist.Text = math.floor((root.Position - Camera.CFrame.Position).Magnitude) .. "m"
            d.Dist.Position = Vector2.new(top.X, bot.Y + 5)
            d.Dist.Visible = true

            d.Weap.Text = GetWeapon(plr.Character)
            d.Weap.Position = Vector2.new(top.X, bot.Y + 22)
            d.Weap.Visible = true
        end
    else
        for _, d in pairs(PlayerESPData) do
            d.Box.Visible = false; d.Name.Visible = false; d.Dist.Visible = false; d.Weap.Visible = false
        end
    end

    -- Ore ESP
    if Settings.OreESP.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") then
                local mp = model:FindFirstChildOfClass("MeshPart")
                if mp then
                    local color = mp.Color
                    local oreType = nil
                    if color == Color3.fromRGB(72,72,72) then oreType = "Stone"
                    elseif color == Color3.fromRGB(199,172,120) or color == Color3.fromRGB(255,215,0) then oreType = "Iron"
                    elseif color == Color3.fromRGB(248,248,248) then oreType = "Nitrate" end

                    if oreType then
                        CreateOreESP(model, oreType)
                        local data = OreData[model]
                        local pos, onScreen = Camera:WorldToViewportPoint(mp.Position)
                        if onScreen then
                            data.Text.Position = Vector2.new(pos.X, pos.Y - 5)
                            data.Text.Visible = true
                        else
                            data.Text.Visible = false
                        end
                    end
                end
            end
        end
    else
        for _, data in pairs(OreData) do data.Text.Visible = false end
    end

    -- Chams
    if Settings.Chams.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and not Chams[model] then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0
                hl.FillColor = Color3.fromRGB(0, 180, 255)
                hl.Parent = model
                Chams[model] = hl
            end
        end
        for _, hl in pairs(Chams) do hl.Enabled = true end
    else
        for _, hl in pairs(Chams) do hl.Enabled = false end
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
            FreecamPos = FreecamPos + (move.Unit * Settings.Freecam.Speed * dt)
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
        Settings.OreESP.Enabled = not Settings.OreESP.Enabled
        Toggles.OreESP.Text = Settings.OreESP.Enabled and "[✔] Ore ESP" or "[ ] Ore ESP"
    elseif inp.KeyCode == Enum.KeyCode.F3 then
        Settings.Chams.Enabled = not Settings.Chams.Enabled
        Toggles.Chams.Text = Settings.Chams.Enabled and "[✔] Chams" or "[ ] Chams"
    elseif inp.KeyCode == Enum.KeyCode.F4 then
        Settings.Xray.Enabled = not Settings.Xray.Enabled
        ApplyXray(Settings.Xray.Enabled)
        Toggles.Xray.Text = Settings.Xray.Enabled and "[✔] Xray" or "[ ] Xray"
    elseif inp.KeyCode == Enum.KeyCode.F5 then
        Settings.Freecam.Enabled = not Settings.Freecam.Enabled
        Toggles.Freecam.Text = Settings.Freecam.Enabled and "[✔] Freecam" or "[ ] Freecam"
    end
end)
