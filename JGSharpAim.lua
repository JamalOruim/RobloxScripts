-- JG Sharp Aim v3.7 (Error Fix & Stability)
-- Desenvolvido por Manus

-- Serviços do Jogo
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

-- Círculo de FOV (com verificação de segurança)
local FOVCircle
pcall(function() FOVCircle = Drawing.new("Circle") end)
if FOVCircle then
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Settings.Color
    FOVCircle.Visible = false
end

-- Interface Gráfica (Criada de forma segura no CoreGui)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "JGSharpAim_UI_Manus"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "JG SHARP AIM v3.7"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ToggleButton.Text = "Silent Aim: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

-- Lógica da UI e Atalho
local function ToggleAim()
    Settings.Enabled = not Settings.Enabled
    local status = Settings.Enabled and "ON" or "OFF"
    local color = Settings.Enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 70)
    ToggleButton.Text = "Silent Aim: " .. status
    ToggleButton.BackgroundColor3 = color
end

ToggleButton.MouseButton1Click:Connect(ToggleAim)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Settings.ToggleKey then ToggleAim() end
end)

-- Função de Mira (Mais Segura)
local function GetClosestPlayer()
    local target, shortestDist = nil, Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    local currentCamera = workspace.CurrentCamera -- Referência segura

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild("Head")
            if part then
                local vec, onScreen = currentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(vec.X, vec.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = player.Character
                    end
                end
            end
        end
    end
    return target
end

-- Hooking com Verificação de Segurança
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    -- A verificação 'checkcaller' impede que o script intercepte eventos do próprio jogo
    if not checkcaller() and Settings.Enabled and getnamecallmethod() == "FireServer" then
        local name = tostring(self)
        local target = GetClosestPlayer()
        local args = {...}

        if target then
            if name == "MadworkCombat_CombatUpdate" then -- Faca
                local hitPart = target:FindFirstChild("HumanoidRootPart")
                if hitPart and args[1] and args[1][1] and args[1][1][2] then
                    args[1][1][2][4] = hitPart
                    args[1][1][2][5] = "HumanoidRootPart"
                    args[1][1][2][6] = hitPart.Position
                end
            elseif name == "MadworkCombat_CombatEvent" then -- Pistola
                local hitPart = target:FindFirstChild("Head")
                if hitPart and args[1] and args[1][3] and args[1][3][1] and args[1][3][1][2] then
                    args[1][3][1][2][4] = hitPart
                    args[1][3][1][2][5] = "Head"
                    args[1][3][1][2][6] = hitPart.Position
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)

-- Loop de Renderização
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = Settings.Enabled and Settings.ShowFOV
        if FOVCircle.Visible then
            FOVCircle.Position = UserInputService:GetMouseLocation()
            FOVCircle.Radius = Settings.FOV
        end
    end
end)

print("JG Sharp Aim v3.7 (Stable) carregado! Pressione E para ativar.")
