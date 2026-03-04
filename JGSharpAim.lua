-- JG Sharp Aim v3.6 (CoreGui Fix)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Settings = {
    Enabled = false,
    ShowFOV = true,
    FOV = 150,
    Color = Color3.fromRGB(255, 255, 255),
    ToggleKey = Enum.KeyCode.E
}

-- FOV Drawing (Verifica se o executor suporta)
local FOVCircle = nil
local drawingSuccess, drawingErr = pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Settings.Color
    FOVCircle.Visible = false
end)

-- Criando a UI no CoreGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JGSharpAim_UI"
ScreenGui.ResetOnSpawn = false
-- Tenta proteger a UI se o executor permitir
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "JG SHARP AIM"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.BorderSizePixel = 0

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

-- Funções de Lógica
local function ToggleAim()
    Settings.Enabled = not Settings.Enabled
    ToggleButton.Text = "Silent Aim: " .. (Settings.Enabled and "ON" or "OFF")
    ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
end

ToggleButton.MouseButton1Click:Connect(ToggleAim)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Settings.ToggleKey then
        ToggleAim()
    end
end)

-- Silent Aim Logic
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild("Head")
            if part then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        target = player.Character
                    end
                end
            end
        end
    end
    return target
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    local name = tostring(self)

    if method == "FireServer" and Settings.Enabled then
        local target = GetClosestPlayer()
        if target then
            if name == "MadworkCombat_CombatUpdate" then -- Faca
                local hitPart = target:FindFirstChild("HumanoidRootPart")
                if hitPart then
                    args[1][2][4] = hitPart
                    args[1][2][5] = "HumanoidRootPart"
                    args[1][2][6] = hitPart.Position
                end
            elseif name == "MadworkCombat_CombatEvent" then -- Pistola
                local hitPart = target:FindFirstChild("Head")
                if hitPart and args[1] and args[1][3] and args[1][3][1] then
                    args[1][3][1][2][4] = hitPart
                    args[1][3][1][2][5] = "Head"
                    args[1][3][1][2][6] = hitPart.Position
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = Settings.Enabled and Settings.ShowFOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOV
    end
end)

print("JG Sharp Aim v3.6 carregado com sucesso!")
