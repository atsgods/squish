-- Goose | Trident Survival V5 | Drawing Menu + ESP + Xray + Freecam
-- RightShift = Toggle Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== BYPASS ====================
pcall(function()
    hookfunction(game:GetService("Stats").GetMemoryUsageMb, function() return math.random(140, 260) end)
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local meth = getnamecallmethod()
        if meth == "FireServer" or meth == "InvokeServer" then
            local str = tostring(select(1, ...))
            if str:find("Ban") or str:find("Kick") or str:find("Detect") then return end
        end
        if meth == "Kick" then return end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

-- ==================== DRAWING MENU ====================
local Menu = { Open = false }

local Title   = Drawing.new("Text"); Title.Position = Vector2.new(20, 40);  Title.Text = "Goose | Trident V5"; Title.Size = 18; Title.Color = Color3.fromRGB(0,255,100); Title.Outline = true
local Status  = Drawing.new("Text"); Status.Position = Vector2.new(20, 70); Status.Text = "RightShift - Menu"; Status.Size = 16; Status.Color = Color3.fromRGB(200,200,200); Status.Outline = true

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

local Toggles = {
    ESP     = CreateToggle("ESP (F1)", 110),
    Xray    = CreateToggle("Xray (F2)", 130),
    Freecam = CreateToggle("Freecam (F3)", 150),
}

local function UpdateMenu()
    local visible = Menu.Open
    Title.Visible = visible
    Status.Visible = visible
    for _, v in pairs(Toggles) do v.Visible = visible end
end

UIS.InputBegan:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Menu.Open = not Menu.Open
        UpdateMenu()
    end
end)

-- ==================== PLAYERS ESP ====================
local ESP = { Enabled = false, Items = {} }

local function CreateESP(plr)
    if ESP.Items[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(0, 255, 100)
    box.Transparency = 1
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Color = Color3.fromRGB(255,255,255)
    name.Outline = true
    name.Center = true
    name.Visible = false

    ESP.Items[plr] = {Box = box, Name = name}
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Player or not plr.Character then continue end
        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local _, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then 
            if ESP.Items[plr] then
                ESP.Items[plr].Box.Visible = false
                ESP.Items[plr].Name.Visible = false
            end
            continue 
        end

        CreateESP(plr)
        local data = ESP.Items[plr]

        local top = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bot = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local h = bot.Y - top.Y
        local w = h * 0.6

        data.Box.Size = Vector2.new(w, h)
        data.Box.Position = Vector2.new(top.X - w/2, top.Y)
        data.Box.Visible = true

        data.Name.Text = plr.Name
        data.Name.Position = Vector2.new(top.X, top.Y - 18)
        data.Name.Visible = true
    end
end)

-- ==================== XRAY ====================
local Xray = { Enabled = false, Transparency = 0.5 }
local xrayParts = {}

local function ApplyXray()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Material == Enum.Material.Cobblestone or part.Material == Enum.Material.Concrete or part.Material == Enum.Material.Brick) then
            if not xrayParts[part] then xrayParts[part] = part.Transparency end
            part.Transparency = Xray.Enabled and Xray.Transparency or (xrayParts[part] or 0)
        end
    end
end

-- ==================== FREECAM ====================
local Freecam = { Enabled = false, Speed = 100, Pos = Camera.CFrame.Position }

RunService.RenderStepped:Connect(function(dt)
    if not Freecam.Enabled then return end
    local move = Vector3.new()
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end

    if move.Magnitude > 0 then
        Freecam.Pos = Freecam.Pos + move.Unit * Freecam.Speed * dt
    end
    Camera.CFrame = CFrame.new(Freecam.Pos, Freecam.Pos + Camera.CFrame.LookVector)
end)

-- ==================== УПРАВЛЕНИЕ ====================
UIS.InputBegan:Connect(function(inp)
    if not Menu.Open then return end

    if inp.KeyCode == Enum.KeyCode.F1 then
        ESP.Enabled = not ESP.Enabled
        Toggles.ESP.Text = (ESP.Enabled and "[✔] " or "[ ] ") .. "ESP"
        print("ESP:", ESP.Enabled)
    elseif inp.KeyCode == Enum.KeyCode.F2 then
        Xray.Enabled = not Xray.Enabled
        ApplyXray()
        Toggles.Xray.Text = (Xray.Enabled and "[✔] " or "[ ] ") .. "Xray"
        print("Xray:", Xray.Enabled)
    elseif inp.KeyCode == Enum.KeyCode.F3 then
        Freecam.Enabled = not Freecam.Enabled
        Toggles.Freecam.Text = (Freecam.Enabled and "[✔] " or "[ ] ") .. "Freecam"
        print("Freecam:", Freecam.Enabled)
    end
end)

print("Goose Drawing Menu загружен!")
print("RightShift - меню | F1 - ESP | F2 - Xray | F3 - Freecam")
