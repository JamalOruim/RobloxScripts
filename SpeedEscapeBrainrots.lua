-- LocalScript Corrigido para Roblox
-- Coloque este script dentro de StarterPlayerScripts ou StarterGui

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Função para obter o HumanoidRootPart de forma segura
local function getRootPart()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart", 5)
end

-- Configurações da UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportUI_V2"
screenGui.ResetOnSpawn = false -- Mantém a UI mesmo se o player morrer
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 110)
frame.Position = UDim2.new(0.5, -110, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- Permite arrastar a UI
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

-- Botão de Teletransporte
local tpButton = Instance.new("TextButton")
tpButton.Name = "TPButton"
tpButton.Size = UDim2.new(0, 200, 0, 40)
tpButton.Position = UDim2.new(0, 10, 0, 10)
tpButton.Text = "Teleportar para '29'"
tpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 16
tpButton.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpButton

-- Botão de Deletar UI
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 200, 0, 40)
deleteButton.Position = UDim2.new(0, 10, 0, 60)
deleteButton.Text = "Fechar Interface"
deleteButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.GothamBold
deleteButton.TextSize = 16
deleteButton.Parent = frame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 8)
deleteCorner.Parent = deleteButton

-- Lógica de Teletransporte com TweenService
tpButton.MouseButton1Click:Connect(function()
	-- Caminho exato: Workspace > Map > EntityZones > 29
	local target = Workspace:FindFirstChild("Map")
	if target then
		target = target:FindFirstChild("EntityZones")
		if target then
			target = target:FindFirstChild("29")
		end
	end

	if target and target:IsA("BasePart") then
		local rootPart = getRootPart()
		if rootPart then
			print("Iniciando teletransporte para: " .. target:GetFullName())
			
			-- Configuração do Tween
			local tweenInfo = TweenInfo.new(
				1.5, -- Duração em segundos
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			)
			
			-- Destino (3 studs acima da peça para não bugar no chão)
			local goal = {CFrame = target.CFrame * CFrame.new(0, 3, 0)}
			
			-- Criar e tocar o Tween
			local tween = TweenService:Create(rootPart, tweenInfo, goal)
			tween:Play()
			
			-- Feedback visual no botão
			local originalColor = tpButton.BackgroundColor3
			tpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
			tpButton.Text = "Teleportando..."
			
			tween.Completed:Connect(function()
				tpButton.BackgroundColor3 = originalColor
				tpButton.Text = "Teleportar para '29'"
			end)
		else
			warn("Erro: HumanoidRootPart não encontrado!")
		end
	else
		warn("ERRO: A Part '29' não foi encontrada no caminho: Workspace.Map.EntityZones.29")
		tpButton.Text = "ERRO: Part não encontrada"
		task.wait(2)
		tpButton.Text = "Teleportar para '29'"
	end
end)

-- Lógica de Deletar UI
deleteButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

print("Script de Teletransporte Carregado com Sucesso!")
