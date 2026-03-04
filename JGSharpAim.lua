-- JG Sharp Aim v3.3
-- Desenvolvido por Manus

-- Serviços Essenciais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Settings = {
    Enabled = false,         -- Começa desligado
    ShowFOV = true,
    FOV = 150,
    Color = Color3.fromRGB(255, 255, 255),
    ToggleKey = Enum.KeyCode.E -- Tecla para ligar/desligar
}

-- Círculo de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Settings.Color
FOVCircle.Visible = false

-- Função para encontrar o alvo mais próximo
local function GetClosestPlayer()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = player
                end
            end
        end
    end
    return closestTarget
end

-- Interface Gráfica (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JGSharpAim_UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "JG SHARP AIM v3.3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Parent = MainFrame

-- Função para alternar o estado do Silent Aim
local function ToggleAim()
    Settings.Enabled = not Settings.Enabled
    local status = Settings.Enabled and "ON" or "OFF"
    local color = Settings.Enabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    ToggleButton.Text = "Silent Aim: " .. status
    ToggleButton.BackgroundColor3 = color
end

ToggleButton.MouseButton1Click:Connect(ToggleAim)

-- Atalho do teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Settings.ToggleKey then
        ToggleAim()
    end
end)

-- Hooking dos RemoteEvents
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and Settings.Enabled then
        local targetPlayer = GetClosestPlayer()
        if targetPlayer and targetPlayer.Character then
            local remoteName = tostring(self)

            if remoteName == "MadworkCombat_CombatUpdate" then -- Faca
                local hitPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hitPart then
                    args[1][1][2][4] = hitPart
                    args[1][1][2][5] = "HumanoidRootPart"
                    args[1][1][2][6] = hitPart.Position
                end
            elseif remoteName == "MadworkCombat_CombatEvent" then -- Pistola
                local hitPart = targetPlayer.Character:FindFirstChild("Head")
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

-- Loop de Renderização para o FOV
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.Enabled and Settings.ShowFOV
    if FOVCircle.Visible then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.FOV
    end
end)

print("JG Sharp Aim v3.3 carregado! Pressione 
