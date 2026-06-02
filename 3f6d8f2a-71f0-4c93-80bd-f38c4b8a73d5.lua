-- blazzed | script | Trident Survival V5
-- Silent Version (No Console Logs)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== SILENT BYPASS ====================
pcall(function()
    hookfunction(game:GetService("Stats").GetMemoryUsageMb, function() return math.random(140, 260) end)
    
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local arg1 = tostring(select(1, ...))
            if arg1:find("Ban") or arg1:find("Kick") or arg1:find("Detect") or arg1:find("Report") then
                return
            end
        end
        if method == "Kick" then return end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ==================== DRAWING MENU ====================
local Menu = { Open = false }

local Title  = Drawing.new("Text"); Title.Position = Vector2.new(20, 40);  Title.Text = "blazzed | script"; Title.Size = 19; Title.Color = Color3.fromRGB(255, 80, 80); Title.Outline = true
local Status = Drawing.new("Text"); Status.Position = Vector2.new(20, 70); Status.Text = "RightShift - Menu"; Status.Size = 16; Status.Color = Color3.fromRGB(180,180,180); Status.Outline = true

local function CreateToggle(name, y)
    local t = Drawing.new("Text")
    t.Position = Vector2.new(30, y)
    t.Text = "[ ] " .. name
    t.Size = 16
    t.Color = Color3.fromRGB(255,255,255)
    t.Outline = true
    t.Visible = false
    return t
end

local TogglesUI = {
    PlayerESP = CreateToggle("Player ESP (F1)", 110),
    OreESP    = CreateToggle("Ore ESP (F2)", 130),
    Chams     = CreateToggle("Chams (F3)", 150),
    Xray      = CreateToggle("Xray (F4)", 170),
    Freecam   = CreateToggle("Freecam (F5)", 190),
}

local function UpdateMenu()
    local visible = Menu.Open
    Title.Visible = visible
    Status.Visible = visible
    for _, v in pairs(TogglesUI) do v.Visible = visible end
end

UIS.InputBegan:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Menu.Open = not Menu.Open
        UpdateMenu()
    end
end)

-- ==================== SETTINGS ====================
local Settings = {
    PlayerESP = {Enabled = false},
    OreESP = {Enabled = false, Stone = true, Iron = true, Nitrate = true},
    Chams = {Enabled = false},
    Xray = {Enabled = false, Transparency = 0.5},
    Freecam = {Enabled = false, Speed = 100},
}

-- ==================== PLAYERS ESP ====================
local PlayerESP = {Items = {}}

local function CreatePlayerESP(plr)
    if PlayerESP.Items[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1.5; box.Color = Color3.fromRGB(0, 255, 100); box.Filled = false; box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 14; name.Color = Color3.fromRGB(255,255,255); name.Outline = true; name.Center = true; name.Visible = false

    PlayerESP.Items[plr] = {Box = box, Name = name}
end

-- ==================== ORE ESP ====================
local OreESP = {Items = {}}

local function CreateOreESP(model, oreType)
    if OreESP.Items[model] then return end
    local text = Drawing.new("Text")
    text.Size = 14
    text.Outline = true
    text.Center = true
    text.Visible = false
    if oreType == "Iron" then text.Color = Color3.fromRGB(255,215,0)
    elseif oreType == "Nitrate" then text.Color = Color3.fromRGB(0,255,150)
    else text.Color = Color3.fromRGB(180,180,180) end
    
    OreESP.Items[model] = {Text = text, Type = oreType}
end

-- ==================== CHAMS ====================
local ChamsCache = {}

local function UpdateChams()
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
            if not ChamsCache[model] then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0
                hl.FillColor = Color3.fromRGB(0, 200, 255)
                hl.Parent = model
                ChamsCache[model] = hl
            end
            ChamsCache[model].Enabled = Settings.Chams.Enabled
        end
    end
end

-- ==================== XRAY ====================
local xrayCache = {}

local function ApplyXray()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            local mat = part.Material
            if mat == Enum.Material.Cobblestone or mat == Enum.Material.Concrete or mat == Enum.Material.Brick or mat == Enum.Material.WoodPlanks then
                if not xrayCache[part] then xrayCache[part] = part.Transparency end
                part.Transparency = Settings.Xray.Enabled and Settings.Xray.Transparency or (xrayCache[part] or 0)
            end
        end
    end
end

-- ==================== FREECAM ====================
local FreecamPos = Camera.CFrame.Position

-- ==================== MAIN RENDER LOOP ====================
RunService.RenderStepped:Connect(function(dt)
    -- Player ESP
    if Settings.PlayerESP.Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == Player or not plr.Character then continue end
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            CreatePlayerESP(plr)
            local data = PlayerESP.Items[plr]
            local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
            local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            local h = bot.Y - top.Y
            local w = h * 0.65

            data.Box.Size = Vector2.new(w, h)
            data.Box.Position = Vector2.new(top.X - w/2, top.Y)
            data.Box.Visible = true

            data.Name.Text = plr.Name
            data.Name.Position = Vector2.new(top.X, top.Y - 20)
            data.Name.Visible = true
        end
    end

    -- Ore ESP
    if Settings.OreESP.Enabled then
        for _, model in ipairs(workspace:GetChildren()) do
            if model:IsA("Model") then
                local mesh = model:FindFirstChildOfClass("MeshPart")
                if mesh then
                    local oreType = nil
                    if mesh.Color == Color3.fromRGB(72,72,72) then oreType = "Stone"
                    elseif #model:GetChildren() >= 2 then
                        if mesh.Color == Color3.fromRGB(199,172,120) or mesh.Color == Color3.fromRGB(255,215,0) then oreType = "Iron"
                        elseif mesh.Color == Color3.fromRGB(248,248,248) then oreType = "Nitrate" end
                    end

                    if oreType and Settings.OreESP[oreType] then
                        CreateOreESP(model, oreType)
                        local data = OreESP.Items[model]
                        local pos, onScreen = Camera:WorldToViewportPoint(mesh.Position)
                        if onScreen then
                            data.Text.Position = Vector2.new(pos.X, pos.Y)
                            data.Text.Visible = true
                        else
                            data.Text.Visible = false
                        end
                    end
                end
            end
        end
    end

    -- Chams
    if Settings.Chams.Enabled then UpdateChams() end

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
        TogglesUI.PlayerESP.Text = (Settings.PlayerESP.Enabled and "[✔] " or "[ ] ") .. "Player ESP"
    elseif inp.KeyCode == Enum.KeyCode.F2 then
        Settings.OreESP.Enabled = not Settings.OreESP.Enabled
        TogglesUI.OreESP.Text = (Settings.OreESP.Enabled and "[✔] " or "[ ] ") .. "Ore ESP"
    elseif inp.KeyCode == Enum.KeyCode.F3 then
        Settings.Chams.Enabled = not Settings.Chams.Enabled
        TogglesUI.Chams.Text = (Settings.Chams.Enabled and "[✔] " or "[ ] ") .. "Chams"
    elseif inp.KeyCode == Enum.KeyCode.F4 then
        Settings.Xray.Enabled = not Settings.Xray.Enabled
        ApplyXray()
        TogglesUI.Xray.Text = (Settings.Xray.Enabled and "[✔] " or "[ ] ") .. "Xray"
    elseif inp.KeyCode == Enum.KeyCode.F5 then
        Settings.Freecam.Enabled = not Settings.Freecam.Enabled
        TogglesUI.Freecam.Text = (Settings.Freecam.Enabled and "[✔] " or "[ ] ") .. "Freecam"
    end
end)

-- Полная тишина
