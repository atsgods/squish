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

-- ========== KEY CHECK (ГАРАНТИРОВАННО ВИДИМОЕ ПОЛЕ) ==========
local function ShowKeyGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyCheckGUI"
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 180)
    frame.Position = UDim2.new(0.5, -175, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Visible = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Введите ключ доступа"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- ПОЛЕ ВВОДА (гарантированно видимое)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 45)
    textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 18
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = ""      -- Нет подсказки
    textBox.Text = ""                 -- Полностью пусто
    textBox.ClearTextOnFocus = true
    textBox.Visible = true
    textBox.Parent = frame

    local cornerBox = Instance.new("UICorner")
    cornerBox.CornerRadius = UDim.new(0, 6)
    cornerBox.Parent = textBox

    -- Кнопка
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.5, 0, 0, 45)
    button.Position = UDim2.new(0.25, 0, 0.7, 0)
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    button.Text = "Войти"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Visible = true
    button.Parent = frame

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 6)
    cornerBtn.Parent = button

    -- Ошибка
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 30)
    errorLabel.Position = UDim2.new(0, 0, 0.88, 0)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    errorLabel.TextSize = 14
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

    -- Также можно нажать Enter
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
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
        end
    end)

    repeat task.wait() until accepted == true
end

ShowKeyGUI()

-- ========== ОСТАЛЬНОЙ КОД (БЕЗ ИЗМЕНЕНИЙ) ==========
-- ... (весь остальной ваш скрипт с ESP, Xray, Freecam и т.д.)
-- Ниже вставьте весь код, который был после ShowKeyGUI()
