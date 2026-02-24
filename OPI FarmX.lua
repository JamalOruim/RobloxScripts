--!strict

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local TrainLevelEvent = ReplicatedStorage.RemoteEvents.TrainLevel
local DoWorkEvent = ReplicatedStorage.RemoteEvents.DoWork
local FishCastEvent = ReplicatedStorage.RemoteEvents.FishCast
local EquipSkillEvent = ReplicatedStorage.RemoteEvents.EquipSkill
local StartBattleEvent = ReplicatedStorage.RemoteEvents.StartBattle
local BattleActionEvent = ReplicatedStorage.RemoteEvents.BattleAction

-- Player
local LocalPlayer = Players.LocalPlayer

-- UI Variables
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OPIFarmX_ScreenGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Draggable = true -- Enable basic drag for the main frame
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleLabel.Text = "OPI FarmX"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.TextScaled = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextWrapped = true
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local MinimizeMaximizeButton = Instance.new("TextButton")
MinimizeMaximizeButton.Name = "MinimizeMaximizeButton"
MinimizeMaximizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeMaximizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeMaximizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeMaximizeButton.Text = "_"
MinimizeMaximizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeMaximizeButton.Font = Enum.Font.SourceSansBold
MinimizeMaximizeButton.TextSize = 20
MinimizeMaximizeButton.BorderSizePixel = 0
MinimizeMaximizeButton.Parent = TitleBar

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0, 100, 1, -30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -100, 1, -30)
ContentFrame.Position = UDim2.new(0, 100, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local TabButtons = {}
local TabContents = {}

local function createTab(name, parentFrame)
    local button = Instance.new("TextButton")
    button.Name = name .. "TabButton"
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 18
    button.BorderSizePixel = 0
    button.Parent = TabFrame

    local content = Instance.new("Frame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    content.BorderSizePixel = 0
    content.Parent = parentFrame
    content.Visible = false

    TabButtons[name] = button
    TabContents[name] = content

    return button, content
end

local FarmTabButton, FarmContent = createTab("Farm", ContentFrame)
local CombatTabButton, CombatContent = createTab("Combat", ContentFrame)
local SettingsTabButton, SettingsContent = createTab("Settings", ContentFrame)

-- Layout for Tab Buttons
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabFrame

-- Initial Tab Selection
FarmContent.Visible = true
TabButtons["Farm"].BackgroundColor3 = Color3.fromRGB(90, 90, 90)

local function switchTab(selectedTabName)
    for tabName, content in pairs(TabContents) do
        content.Visible = (tabName == selectedTabName)
        if tabName == selectedTabName then
            TabButtons[tabName].BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        else
            TabButtons[tabName].BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end
end

FarmTabButton.MouseButton1Click:Connect(function() switchTab("Farm") end)
CombatTabButton.MouseButton1Click:Connect(function() switchTab("Combat") end)
SettingsTabButton.MouseButton1Click:Connect(function() switchTab("Settings") end)

-- UI Functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local isMinimized = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

MinimizeMaximizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        MainFrame.Position = originalPosition
        MinimizeMaximizeButton.Text = "_"
    else
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        MainFrame.Size = UDim2.new(0, 150, 0, 30) -- Minimized size
        MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, 0) -- Move to top
        MinimizeMaximizeButton.Text = "[]"
    end
    isMinimized = not isMinimized
end)

-- Drag Detection (for mobile and general UI)
local function setupDrag(uiElement)
    local dragging
    local dragInput
    local dragStart
    local startPosition

    uiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = uiElement.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    uiElement.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            uiElement.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

setupDrag(MainFrame)

-- Device Detection and Mobile Button
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if isMobile then
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 80, 0, 40)
    MobileToggleButton.Position = UDim2.new(0.05, 0, 0.9, 0)
    MobileToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    MobileToggleButton.Text = "Toggle UI"
    MobileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggleButton.Font = Enum.Font.SourceSansBold
    MobileToggleButton.TextSize = 16
    MobileToggleButton.BorderSizePixel = 0
    MobileToggleButton.Parent = ScreenGui
    MobileToggleButton.ZIndex = 10 -- Ensure it's on top

    setupDrag(MobileToggleButton)

    MobileToggleButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)
end

-- Settings Tab Content
local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.FillDirection = Enum.FillDirection.Vertical
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
SettingsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.Parent = SettingsContent

local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Name = "HotkeyLabel"
HotkeyLabel.Size = UDim2.new(1, -20, 0, 20)
HotkeyLabel.Position = UDim2.new(0, 10, 0, 10)
HotkeyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HotkeyLabel.Text = "Hotkey para ocultar/exibir UI: Nenhuma"
HotkeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HotkeyLabel.Font = Enum.Font.SourceSans
HotkeyLabel.TextSize = 16
HotkeyLabel.TextXAlignment = Enum.TextXAlignment.Left
HotkeyLabel.Parent = SettingsContent

local HotkeyButton = Instance.new("TextButton")
HotkeyButton.Name = "HotkeyButton"
HotkeyButton.Size = UDim2.new(0, 100, 0, 30)
HotkeyButton.Position = UDim2.new(0, 10, 0, 40)
HotkeyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
HotkeyButton.Text = "Definir Hotkey"
HotkeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HotkeyButton.Font = Enum.Font.SourceSansBold
HotkeyButton.TextSize = 16
HotkeyButton.Parent = SettingsContent

local currentHotkey = nil
local waitingForHotkey = false

HotkeyButton.MouseButton1Click:Connect(function()
    HotkeyLabel.Text = "Pressione uma tecla para definir a hotkey..."
    waitingForHotkey = true
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and waitingForHotkey then
        currentHotkey = input.KeyCode
        HotkeyLabel.Text = "Hotkey para ocultar/exibir UI: " .. currentHotkey.Name
        waitingForHotkey = false
    elseif not gameProcessedEvent and currentHotkey and input.KeyCode == currentHotkey then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Farm Tab Content
local FarmLayout = Instance.new("UIListLayout")
FarmLayout.FillDirection = Enum.FillDirection.Vertical
FarmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
FarmLayout.VerticalAlignment = Enum.VerticalAlignment.Top
FarmLayout.Padding = UDim.new(0, 10)
FarmLayout.Parent = FarmContent

local function createFarmOption(parent, name, remoteEvent, delayTime)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Size = UDim2.new(1, -20, 0, 40)
    container.Position = UDim2.new(0, 10, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("TextButton") -- Using TextButton as a simple toggle slider
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(0.2, 0, 0.8, 0)
    slider.Position = UDim2.new(0.75, 0, 0.1, 0)
    slider.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Off color
    slider.Text = "OFF"
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Font = Enum.Font.SourceSansBold
    slider.TextSize = 14
    slider.Parent = container

    local isActive = false
    local farmLoop = nil

    slider.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            slider.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- On color
            slider.Text = "ON"
            farmLoop = task.spawn(function()
                while isActive do
                    remoteEvent:FireServer()
                    if delayTime then
                        task.wait(delayTime)
                    else
                        task.wait() -- Fire as fast as possible
                    end
                end
            end)
        else
            slider.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Off color
            slider.Text = "OFF"
            if farmLoop then
                task.cancel(farmLoop)
            end
        end
    end)

    return container, isActive
end

createFarmOption(FarmContent, "Level Farm", TrainLevelEvent)
createFarmOption(FarmContent, "Haki Farm", TrainLevelEvent)

-- Beli Farm
local BeliFarmContainer = Instance.new("Frame")
BeliFarmContainer.Name = "BeliFarmContainer"
BeliFarmContainer.Size = UDim2.new(1, -20, 0, 80)
BeliFarmContainer.Position = UDim2.new(0, 10, 0, 0)
BeliFarmContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BeliFarmContainer.BorderSizePixel = 0
BeliFarmContainer.Parent = FarmContent

local BeliLabel = Instance.new("TextLabel")
BeliLabel.Name = "BeliLabel"
BeliLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
BeliLabel.Position = UDim2.new(0, 0, 0, 0)
BeliLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BeliLabel.Text = "Beli Farm"
BeliLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BeliLabel.Font = Enum.Font.SourceSans
BeliLabel.TextSize = 16
BeliLabel.TextXAlignment = Enum.TextXAlignment.Left
BeliLabel.Parent = BeliFarmContainer

local BeliSlider = Instance.new("TextButton")
BeliSlider.Name = "BeliSlider"
BeliSlider.Size = UDim2.new(0.2, 0, 0.4, 0)
BeliSlider.Position = UDim2.new(0.75, 0, 0.05, 0)
BeliSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BeliSlider.Text = "OFF"
BeliSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
BeliSlider.Font = Enum.Font.SourceSansBold
BeliSlider.TextSize = 14
BeliSlider.Parent = BeliFarmContainer

local BeliOptionLabel = Instance.new("TextLabel")
BeliOptionLabel.Name = "BeliOptionLabel"
BeliOptionLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
BeliOptionLabel.Position = UDim2.new(0, 0, 0, 40)
BeliOptionLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BeliOptionLabel.Text = "Trabalho: Odd Jobs"
BeliOptionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BeliOptionLabel.Font = Enum.Font.SourceSans
BeliOptionLabel.TextSize = 14
BeliOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
BeliOptionLabel.Parent = BeliFarmContainer

local BeliOptionButton = Instance.new("TextButton")
BeliOptionButton.Name = "BeliOptionButton"
BeliOptionButton.Size = UDim2.new(0.2, 0, 0.4, 0)
BeliOptionButton.Position = UDim2.new(0.75, 0, 0.55, 0)
BeliOptionButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
BeliOptionButton.Text = "Mudar"
BeliOptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BeliOptionButton.Font = Enum.Font.SourceSansBold
BeliOptionButton.TextSize = 14
BeliOptionButton.Parent = BeliFarmContainer

local currentBeliJob = "odd_jobs"
local beliIsActive = false
local beliFarmLoop = nil

local function updateBeliJobLabel()
    if currentBeliJob == "odd_jobs" then
        BeliOptionLabel.Text = "Trabalho: Odd Jobs (+16 Beli)"
    else
        BeliOptionLabel.Text = "Trabalho: Fishing (+40 Beli)"
    end
end

updateBeliJobLabel()

BeliOptionButton.MouseButton1Click:Connect(function()
    if currentBeliJob == "odd_jobs" then
        currentBeliJob = "fishing"
    else
        currentBeliJob = "odd_jobs"
    end
    updateBeliJobLabel()
end)

BeliSlider.MouseButton1Click:Connect(function()
    beliIsActive = not beliIsActive
    if beliIsActive then
        BeliSlider.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        BeliSlider.Text = "ON"
        beliFarmLoop = task.spawn(function()
            while beliIsActive do
                local args = {
                    [1] = currentBeliJob
                }
                DoWorkEvent:FireServer(unpack(args))
                task.wait()
            end
        end)
    else
        BeliSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        BeliSlider.Text = "OFF"
        if beliFarmLoop then
            task.cancel(beliFarmLoop)
        end
    end
end)

-- Fish Farm
createFarmOption(FarmContent, "Fish Farm", FishCastEvent, 4)

-- Combat Tab Content
local CombatLayout = Instance.new("UIListLayout")
CombatLayout.FillDirection = Enum.FillDirection.Vertical
CombatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
CombatLayout.VerticalAlignment = Enum.VerticalAlignment.Top
CombatLayout.Padding = UDim.new(0, 10)
CombatLayout.Parent = CombatContent

local AutoBattleContainer = Instance.new("Frame")
AutoBattleContainer.Name = "AutoBattleContainer"
AutoBattleContainer.Size = UDim2.new(1, -20, 0, 40)
AutoBattleContainer.Position = UDim2.new(0, 10, 0, 0)
AutoBattleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AutoBattleContainer.BorderSizePixel = 0
AutoBattleContainer.Parent = CombatContent

local AutoBattleLabel = Instance.new("TextLabel")
AutoBattleLabel.Name = "AutoBattleLabel"
AutoBattleLabel.Size = UDim2.new(0.7, 0, 1, 0)
AutoBattleLabel.Position = UDim2.new(0, 0, 0, 0)
AutoBattleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AutoBattleLabel.Text = "Auto Battle"
AutoBattleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBattleLabel.Font = Enum.Font.SourceSans
AutoBattleLabel.TextSize = 16
AutoBattleLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoBattleLabel.Parent = AutoBattleContainer

local AutoBattleSlider = Instance.new("TextButton")
AutoBattleSlider.Name = "AutoBattleSlider"
AutoBattleSlider.Size = UDim2.new(0.2, 0, 0.8, 0)
AutoBattleSlider.Position = UDim2.new(0.75, 0, 0.1, 0)
AutoBattleSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
AutoBattleSlider.Text = "OFF"
AutoBattleSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBattleSlider.Font = Enum.Font.SourceSansBold
AutoBattleSlider.TextSize = 14
AutoBattleSlider.Parent = AutoBattleContainer

local autoBattleIsActive = false
local autoBattleLoop = nil

AutoBattleSlider.MouseButton1Click:Connect(function()
    autoBattleIsActive = not autoBattleIsActive
    if autoBattleIsActive then
        AutoBattleSlider.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        AutoBattleSlider.Text = "ON"
        autoBattleLoop = task.spawn(function()
            while autoBattleIsActive do
                -- Equip Skills
                EquipSkillEvent:FireServer(unpack({[1] = "noro_sword"}))
                EquipSkillEvent:FireServer(unpack({[1] = "noro_punch"}))
                EquipSkillEvent:FireServer(unpack({[1] = "drill_thrust"}))
                EquipSkillEvent:FireServer(unpack({[1] = "boss_alvida_smash"}))

                -- Start Battle
                StartBattleEvent:FireServer(unpack({[1] = true}))

                -- Battle Actions
                BattleActionEvent:FireServer(unpack({[1] = "drill_thrust"}))
                BattleActionEvent:FireServer(unpack({[1] = "noro_sword"}))
                BattleActionEvent:FireServer(unpack({[1] = "noro_punch"}))
                BattleActionEvent:FireServer(unpack({[1] = "boss_alvida_smash"}))

                task.wait() -- Fire as fast as possible
            end
        end)
    else
        AutoBattleSlider.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        AutoBattleSlider.Text = "OFF"
        if autoBattleLoop then
            task.cancel(autoBattleLoop)
        end
    end
end)

-- Final setup: Make sure the UI is enabled by default
ScreenGui.Enabled = true
