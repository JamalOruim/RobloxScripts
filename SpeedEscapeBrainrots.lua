-- LocalScript Final para Roblox
-- Este script busca a Part com o maior número no nome dentro de Workspace.Map.EntityZones

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Função para obter o HumanoidRootPart de forma segura
local function getRootPart()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart", 5)
end

-- Função para encontrar a Part com o maior número no nome
local function findHighestNumberedPart()
	local entityZones = Workspace:FindFirstChild("Map")
	if entityZones then
		entityZones = entityZones:FindFirstChild("EntityZones")
	end
	
	if not entityZones then
		warn("Pasta 'EntityZones' não encontrada em Workspace.Map")
		return nil
	end
	
	local highestPart = nil
	local highestNumber = -1
	
	for _, child in ipairs(entityZones:GetChildren()) do
		if child:IsA("BasePart") then
			local num = tonumber(child.Name)
			if num and num > highestNumber then
				highestNumber = num
				highestPart = child
			end
		end
	end
	
	return highestPart, highestNumber
end

-- Configurações da UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 110)
frame.Position = UDim2.new(0.5, -110, 0.5, -55)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

-- Botão de Teletransporte
local tpButton = Instance.new("TextButton")
tpButton.Name = "TPButton"
tpButton.Size = UDim2.new(0, 200, 0, 40)
tpButton.Position = UDim2.new(0, 10, 0, 10)
tpButton.Text = "Teleportar (Maior Nº)"
tpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 14
tpButton.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpButton

-- Botão de Deletar UI
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 200, 0, 40)
deleteButton.Position = UDim2.new(0, 10, 0, 60)
deleteButton.Text = "Fechar Script"
deleteButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.GothamBold
deleteButton.TextSize = 14
deleteButton.Parent = frame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 8)
deleteCorner.Parent = deleteButton

-- Lógica de Teletransporte
tpButton.MouseButton1Click:Connect(function()
	local targetPart, targetNum = findHighestNumberedPart()
	
	if targetPart then
		local rootPart = getRootPart()
		if rootPart then
			print("Teleportando para a Part '" .. targetPart.Name .. "' (Maior encontrada)")
			
			local tweenInfo = TweenInfo.new(
				1.5,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			)
			
			-- Destino: CFrame da peça + 3 studs de altura
			local goal = {CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)}
			local tween = TweenService:Create(rootPart, tweenInfo, goal)
			
			-- Feedback visual
			local originalColor = tpButton.BackgroundColor3
			tpButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
			tpButton.Text = "Indo para a Part " .. targetNum .. "..."
			
			tween:Play()
			
			tween.Completed:Connect(function()
				tpButton.BackgroundColor3 = originalColor
				tpButton.Text = "Teleportar (Maior Nº)"
			end)
		end
	else
		tpButton.Text = "Nenhuma Part encontrada!"
		task.wait(2)
		tpButton.Text = "Teleportar (Maior Nº)"
	end
end)

-- Lógica de Deletar UI
deleteButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

print("Script de Teletransporte Dinâmico Carregado!")
