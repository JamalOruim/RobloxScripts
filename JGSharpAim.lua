-- JG Sharp Aim v2 - com Círculo de FOV
-- Desenvolvido por Manus para SAHRP

-- Serviços do Jogo
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Configurações Iniciais
local Settings = {
    Enabled = false,         -- Silent Aim começa desligado
    ShowFOV = true,          -- Círculo de FOV começa ligado
    TargetPart = "Head",
    FOV = 150                -- Raio do círculo (em pixels)
}

-- Criação da Interface (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JGSharpAim_UI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.Size = UDim2.new(0, 250, 0, 200) -- Aumentei o tamanho da UI
MainFrame.Active = true
MainFrame.Draggable = true

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "JG SHARP AIM v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Botão para Ligar/Desligar o Silent Aim
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Botão para Ligar/Desligar o Círculo de FOV
local FOVToggleButton = Instance.new("TextButton")
FOVToggleButton.Name = "FOVToggleButton"
FOVToggleButton.Parent = MainFrame
FOVToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
FOVToggleButton.Position = UDim2.new(0.1, 0, 0.55, 0)
FOVToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
FOVToggleButton.Font = Enum.Font.GothamSemibold
FOVToggleButton.Text = "FOV Circle: ON"
FOVToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Lógica dos Botões
ToggleButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    ToggleButton.Text = "Silent Aim: " .. (Settings.Enabled and "ON" or "OFF")
    ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
end)

FOVToggleButton.MouseButton1Click:Connect(function()
    Settings.ShowFOV = not Settings.ShowFOV
    FOVToggleButton.Text = "FOV Circle: " .. (Settings.ShowFOV and "ON" or "OFF")
    FOVToggleButton.BackgroundColor3 = Settings.ShowFOV and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(80, 80, 80)
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Criação do Círculo de FOV (usando Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.NumSides = 64

-- Atualiza a visibilidade e posição do círculo a cada frame
RunService.RenderStepped:Connect(function()
    local mouseLocation = LocalPlayer:GetMouse()
    FOVCircle.Visible = Settings.Enabled and Settings.ShowFOV
    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y)
    end
end)

-- Lógica Principal do Silent Aim
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV
    local mouseLocation = LocalPlayer:GetMouse()

    for i, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            if targetPart then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Hook para interceptar o RemoteEvent
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.Enabled and method == "FireServer" and tostring(self) == "MadworkCombat_CombatUpdate" then
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild(Settings.TargetPart) then
            local hitPart = target.Character[Settings.TargetPart]
            args[1][1][2][4] = hitPart
            args[1][1][2][5] = hitPart.Name
            args[1][1][2][6] = hitPart.Position
        end
    end

    return oldNamecall(self, unpack(args))
end)

print("JG Sharp Aim v2 (com FOV) carregado!")
