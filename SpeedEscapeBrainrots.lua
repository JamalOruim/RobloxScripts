-- LocalScript para Roblox
-- Coloque este script dentro de StarterPlayerScripts ou StarterGui

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configurações da UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- Botão de Teletransporte
local tpButton = Instance.new("TextButton")
tpButton.Name = "TPButton"
tpButton.Size = UDim2.new(0, 180, 0, 35)
tpButton.Position = UDim2.new(0, 10, 0, 10)
tpButton.Text = "Teleportar para '29'"
tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.Font = Enum.Font.SourceSansBold
tpButton.TextSize = 18
tpButton.Parent = frame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 6)
tpCorner.Parent = tpButton

-- Botão de Deletar UI
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 180, 0, 35)
deleteButton.Position = UDim2.new(0, 10, 0, 55)
deleteButton.Text = "Fechar UI"
deleteButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.SourceSansBold
deleteButton.TextSize = 18
deleteButton.Parent = frame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteButton

-- Lógica de Teletransporte com TweenService
tpButton.MouseButton1Click:Connect(function()
	local targetPart = Workspace:FindFirstChild("Map")
	if targetPart then
		targetPart = targetPart:FindFirstChild("EntityZones")
		if targetPart then
			targetPart = targetPart:FindFirstChild("29")
		end
	end

	if targetPart and targetPart:IsA("BasePart") then
		local tweenInfo = TweenInfo.new(
			2, -- Tempo em segundos
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		
		local goal = {CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)} -- Offset para não spawnar dentro da part
		local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
		
		tween:Play()
	else
		warn("A Part '29' não foi encontrada no caminho Workspace > Map > EntityZones")
	end
end)

-- Lógica de Deletar UI
deleteButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)
