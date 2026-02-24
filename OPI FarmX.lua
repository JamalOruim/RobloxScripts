--!strict

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Remote Events
local TrainLevelEvent = ReplicatedStorage.RemoteEvents.TrainLevel
local DoWorkEvent = ReplicatedStorage.RemoteEvents.DoWork
local FishCastEvent = ReplicatedStorage.RemoteEvents.FishCast
local EquipSkillEvent = ReplicatedStorage.RemoteEvents.EquipSkill
local StartBattleEvent = ReplicatedStorage.RemoteEvents.StartBattle
local BattleActionEvent = ReplicatedStorage.RemoteEvents.BattleAction

-- Player
local LocalPlayer = Players.LocalPlayer

-- UI Constants (Modern Design)
local UI_BACKGROUND_COLOR = Color3.fromRGB(20, 20, 28)
local UI_PRIMARY_COLOR = Color3.fromRGB(30, 30, 40)
local UI_SECONDARY_COLOR = Color3.fromRGB(45, 45, 55)
local UI_ACCENT_COLOR = Color3.fromRGB(0, 150, 255) -- Brighter Blue
local UI_HOVER_COLOR = Color3.fromRGB(0, 180, 255)
local UI_TEXT_COLOR = Color3.fromRGB(230, 230, 230)
local UI_DISABLED_TEXT_COLOR = Color3.fromRGB(150, 150, 150)
local UI_SUCCESS_COLOR = Color3.fromRGB(0, 200, 0)
local UI_ERROR_COLOR = Color3.fromRGB(200, 0, 0)
local UI_CORNER_RADIUS = UDim.new(0, 12)
local UI_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local UI_TWEEN_INFO_LONG = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- UI Variables
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OPIFarmX_ScreenGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.BackgroundColor3 = UI_PRIMARY_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainFrameCorner = Instance.new("UICorner")
MainFrameCorner.CornerRadius = UI_CORNER_RADIUS
MainFrameCorner.Parent = MainFrame

local MainFrameStroke = Instance.new("UIStroke")
MainFrameStroke.Color = UI_SECONDARY_COLOR
MainFrameStroke.Thickness = 2
MainFrameStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = UI_SECONDARY_COLOR
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UI_CORNER_RADIUS
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -150, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundColor3 = UI_SECONDARY_COLOR
TitleLabel.Text = "OPI FarmX"
TitleLabel.TextColor3 = UI_TEXT_COLOR
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 28
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextWrapped = true
TitleLabel.BorderSizePixel = 0
TitleLabel.Parent = TitleBar

local function createTitleBarButton(name, text, bgColor, positionOffset)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 45, 1, 0)
    button.Position = UDim2.new(1, positionOffset, 0, 0)
    button.BackgroundColor3 = bgColor
    button.Text = text
    button.TextColor3 = UI_TEXT_COLOR
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 24
    button.BorderSizePixel = 0
    button.Parent = TitleBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_CORNER_RADIUS
    corner.Parent = button

    local originalColor = bgColor
    button.MouseEnter:Connect(function()
        TweenService:Create(button, UI_TWEEN_INFO, {BackgroundColor3 = originalColor:Lerp(Color3.new(1,1,1), 0.3)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, UI_TWEEN_INFO, {BackgroundColor3 = originalColor}):Play()
    end)

    return button
end

local CloseButton = createTitleBarButton("CloseButton", "X", UI_ERROR_COLOR, -50)
local MinimizeMaximizeButton = createTitleBarButton("MinimizeMaximizeButton", "_", UI_ACCENT_COLOR, -100)

-- Tab System
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(0, 180, 1, -50)
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.BackgroundColor3 = UI_SECONDARY_COLOR
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local TabContentFrame = Instance.new("Frame")
TabContentFrame.Name = "TabContentFrame"
TabContentFrame.Size = UDim2.new(1, -180, 1, -50)
TabContentFrame.Position = UDim2.new(0, 180, 0, 50)
TabContentFrame.BackgroundColor3 = UI_PRIMARY_COLOR
TabContentFrame.BorderSizePixel = 0
TabContentFrame.Parent = MainFrame

local TabContentCorner = Instance.new("UICorner")
TabContentCorner.CornerRadius = UI_CORNER_RADIUS
TabContentCorner.Parent = TabContentFrame

local TabContentStroke = Instance.new("UIStroke")
TabContentStroke.Color = UI_SECONDARY_COLOR
TabContentStroke.Thickness = 2
TabContentStroke.Parent = TabContentFrame

local TabButtons = {}
local TabContents = {}

local function createTab(name, parentFrame)
    local button = Instance.new("TextButton")
    button.Name = name .. "TabButton"
    button.Size = UDim2.new(1, 0, 0, 55)
    button.BackgroundColor3 = UI_SECONDARY_COLOR
    button.Text = name
    button.TextColor3 = UI_TEXT_COLOR
    button.Font = Enum.Font.SourceSans
    button.TextSize = 22
    button.BorderSizePixel = 0
    button.Parent = TabFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_CORNER_RADIUS
    corner.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, UI_TWEEN_INFO, {BackgroundColor3 = UI_HOVER_COLOR}):Play()
    end)
    button.MouseLeave:Connect(function()
        if TabButtons[name].BackgroundColor3 ~= UI_ACCENT_COLOR then
            TweenService:Create(button, UI_TWEEN_INFO, {BackgroundColor3 = UI_SECONDARY_COLOR}):Play()
        end
    end)

    local content = Instance.new("Frame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundColor3 = UI_PRIMARY_COLOR
    content.BorderSizePixel = 0
    content.Parent = parentFrame
    content.Visible = false

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = content

    TabButtons[name] = button
    TabContents[name] = content

    return button, content
end

local FarmTabButton, FarmContent = createTab("Farm", TabContentFrame)
local CombatTabButton, CombatContent = createTab("Combat", TabContentFrame)
local SettingsTabButton, SettingsContent = createTab("Settings", TabContentFrame)

-- Layout for Tab Buttons
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabFrame

-- Initial Tab Selection
FarmContent.Visible = true
TweenService:Create(TabButtons["Farm"], UI_TWEEN_INFO, {BackgroundColor3 = UI_ACCENT_COLOR}):Play()

local function switchTab(selectedTabName)
    for tabName, content in pairs(TabContents) do
        content.Visible = (tabName == selectedTabName)
        if tabName == selectedTabName then
            TweenService:Create(TabButtons[tabName], UI_TWEEN_INFO, {BackgroundColor3 = UI_ACCENT_COLOR}):Play()
        else
            TweenService:Create(TabButtons[tabName], UI_TWEEN_INFO, {BackgroundColor3 = UI_SECONDARY_COLOR}):Play()
        end
    end
end

FarmTabButton.MouseButton1Click:Connect(function() switchTab("Farm") end)
CombatTabButton.MouseButton1Click:Connect(function() switchTab("Combat") end)
SettingsTabButton.MouseButton1Click:Connect(function() switchTab("Settings") end)

-- UI Functionality
CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, UI_TWEEN_INFO_LONG, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(UI_TWEEN_INFO_LONG.Time)
    ScreenGui.Enabled = false
end)

local isMinimized = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

MinimizeMaximizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        TweenService:Create(MainFrame, UI_TWEEN_INFO_LONG, {Size = originalSize, Position = originalPosition}):Play()
        MinimizeMaximizeButton.Text = "_"
    else
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        TweenService:Create(MainFrame, UI_TWEEN_INFO_LONG, {Size = UDim2.new(0, 200, 0, 50), Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, 0)}):Play()
        MinimizeMaximizeButton.Text = "[]"
    end
    isMinimized = not isMinimized
end)

-- Robust Drag Detection
local function setupDrag(uiElement, dragHandle)
    dragHandle = dragHandle or uiElement -- If no specific handle, use the element itself
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local initialPosition = UDim2.new(0, 0, 0, 0)

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            initialPosition = uiElement.Position

            -- Bring to front when dragging
            uiElement.ZIndex = 10
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                local newX = initialPosition.X.Offset + delta.X
                local newY = initialPosition.Y.Offset + delta.Y

                -- Clamp to screen bounds
                local screenX = game.Workspace.CurrentCamera.ViewportSize.X
                local screenY = game.Workspace.CurrentCamera.ViewportSize.Y

                newX = math.max(0, math.min(newX, screenX - uiElement.AbsoluteSize.X))
                newY = math.max(0, math.min(newY, screenY - uiElement.AbsoluteSize.Y))

                uiElement.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            uiElement.ZIndex = 1 -- Reset ZIndex
        end
    end)
end

setupDrag(MainFrame, TitleBar) -- MainFrame is dragged by TitleBar

-- Device Detection and Mobile Button
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if isMobile then
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 140, 0, 60)
    MobileToggleButton.Position = UDim2.new(0.05, 0, 0.9, 0)
    MobileToggleButton.BackgroundColor3 = UI_ACCENT_COLOR
    MobileToggleButton.Text = "Toggle UI"
    MobileToggleButton.TextColor3 = UI_TEXT_COLOR
    MobileToggleButton.Font = Enum.Font.SourceSansBold
    MobileToggleButton.TextSize = 22
    MobileToggleButton.BorderSizePixel = 0
    MobileToggleButton.Parent = ScreenGui
    MobileToggleButton.ZIndex = 10 -- Ensure it's on top

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_CORNER_RADIUS
    corner.Parent = MobileToggleButton

    local stroke = Instance.new("UIStroke")
    stroke.Color = UI_SECONDARY_COLOR
    stroke.Thickness = 2
    stroke.Parent = MobileToggleButton

    setupDrag(MobileToggleButton) -- Mobile button is dragged by itself

    MobileToggleButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)
end

-- Settings Tab Content
local HotkeyLabel = Instance.new("TextLabel")
HotkeyLabel.Name = "HotkeyLabel"
HotkeyLabel.Size = UDim2.new(1, -30, 0, 35)
HotkeyLabel.Position = UDim2.new(0, 15, 0, 0)
HotkeyLabel.BackgroundColor3 = UI_PRIMARY_COLOR
HotkeyLabel.Text = "Hotkey para ocultar/exibir UI: Nenhuma"
HotkeyLabel.TextColor3 = UI_TEXT_COLOR
HotkeyLabel.Font = Enum.Font.SourceSans
HotkeyLabel.TextSize = 18
HotkeyLabel.TextXAlignment = Enum.TextXAlignment.Left
HotkeyLabel.Parent = SettingsContent

local HotkeyButton = Instance.new("TextButton")
HotkeyButton.Name = "HotkeyButton"
HotkeyButton.Size = UDim2.new(0, 180, 0, 45)
HotkeyButton.Position = UDim2.new(0, 15, 0, 40)
HotkeyButton.BackgroundColor3 = UI_ACCENT_COLOR
HotkeyButton.Text = "Definir Hotkey"
HotkeyButton.TextColor3 = UI_TEXT_COLOR
HotkeyButton.Font = Enum.Font.SourceSansBold
HotkeyButton.TextSize = 18
HotkeyButton.Parent = SettingsContent

local HotkeyButtonCorner = Instance.new("UICorner")
HotkeyButtonCorner.CornerRadius = UI_CORNER_RADIUS
HotkeyButtonCorner.Parent = HotkeyButton

HotkeyButton.MouseEnter:Connect(function()
    TweenService:Create(HotkeyButton, UI_TWEEN_INFO, {BackgroundColor3 = UI_HOVER_COLOR}):Play()
end)
HotkeyButton.MouseLeave:Connect(function()
    TweenService:Create(HotkeyButton, UI_TWEEN_INFO, {BackgroundColor3 = UI_ACCENT_COLOR}):Play()
end)

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
local function createFarmOption(parent, name, remoteEvent, delayTime)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Size = UDim2.new(1, -30, 0, 70)
    container.Position = UDim2.new(0, 15, 0, 0)
    container.BackgroundColor3 = UI_SECONDARY_COLOR
    container.BorderSizePixel = 0
    container.Parent = parent

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UI_CORNER_RADIUS
    containerCorner.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundColor3 = UI_SECONDARY_COLOR
    label.Text = name
    label.TextColor3 = UI_TEXT_COLOR
    label.Font = Enum.Font.SourceSans
    label.TextSize = 22
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("TextButton")
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(0.2, 0, 0.7, 0)
    slider.Position = UDim2.new(0.75, 0, 0.15, 0)
    slider.BackgroundColor3 = UI_ERROR_COLOR
    slider.Text = "OFF"
    slider.TextColor3 = UI_TEXT_COLOR
    slider.Font = Enum.Font.SourceSansBold
    slider.TextSize = 20
    slider.Parent = container

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UI_CORNER_RADIUS
    sliderCorner.Parent = slider

    local isActive = false
    local farmLoop = nil

    slider.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            TweenService:Create(slider, UI_TWEEN_INFO, {BackgroundColor3 = UI_SUCCESS_COLOR}):Play()
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
            TweenService:Create(slider, UI_TWEEN_INFO, {BackgroundColor3 = UI_ERROR_COLOR}):Play()
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
BeliFarmContainer.Size = UDim2.new(1, -30, 0, 120)
BeliFarmContainer.Position = UDim2.new(0, 15, 0, 0)
BeliFarmContainer.BackgroundColor3 = UI_SECONDARY_COLOR
BeliFarmContainer.BorderSizePixel = 0
BeliFarmContainer.Parent = FarmContent

local BeliFarmContainerCorner = Instance.new("UICorner")
BeliFarmContainerCorner.CornerRadius = UI_CORNER_RADIUS
BeliFarmContainerCorner.Parent = BeliFarmContainer

local BeliLabel = Instance.new("TextLabel")
BeliLabel.Name = "BeliLabel"
BeliLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
BeliLabel.Position = UDim2.new(0, 15, 0, 0)
BeliLabel.BackgroundColor3 = UI_SECONDARY_COLOR
BeliLabel.Text = "Beli Farm"
BeliLabel.TextColor3 = UI_TEXT_COLOR
BeliLabel.Font = Enum.Font.SourceSans
BeliLabel.TextSize = 22
BeliLabel.TextXAlignment = Enum.TextXAlignment.Left
BeliLabel.Parent = BeliFarmContainer

local BeliSlider = Instance.new("TextButton")
BeliSlider.Name = "BeliSlider"
BeliSlider.Size = UDim2.new(0.2, 0, 0.4, 0)
BeliSlider.Position = UDim2.new(0.75, 0, 0.05, 0)
BeliSlider.BackgroundColor3 = UI_ERROR_COLOR
BeliSlider.Text = "OFF"
BeliSlider.TextColor3 = UI_TEXT_COLOR
BeliSlider.Font = Enum.Font.SourceSansBold
BeliSlider.TextSize = 20
BeliSlider.Parent = BeliFarmContainer

local BeliSliderCorner = Instance.new("UICorner")
BeliSliderCorner.CornerRadius = UI_CORNER_RADIUS
BeliSliderCorner.Parent = BeliSlider

local BeliOptionLabel = Instance.new("TextLabel")
BeliOptionLabel.Name = "BeliOptionLabel"
BeliOptionLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
BeliOptionLabel.Position = UDim2.new(0, 15, 0, 60)
BeliOptionLabel.BackgroundColor3 = UI_SECONDARY_COLOR
BeliOptionLabel.Text = "Trabalho: Odd Jobs (+16 Beli)"
BeliOptionLabel.TextColor3 = UI_TEXT_COLOR
BeliOptionLabel.Font = Enum.Font.SourceSans
BeliOptionLabel.TextSize = 18
BeliOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
BeliOptionLabel.Parent = BeliFarmContainer

local BeliOptionButton = Instance.new("TextButton")
BeliOptionButton.Name = "BeliOptionButton"
BeliOptionButton.Size = UDim2.new(0.2, 0, 0.4, 0)
BeliOptionButton.Position = UDim2.new(0.75, 0, 0.55, 0)
BeliOptionButton.BackgroundColor3 = UI_ACCENT_COLOR
BeliOptionButton.Text = "Mudar"
BeliOptionButton.TextColor3 = UI_TEXT_COLOR
BeliOptionButton.Font = Enum.Font.SourceSansBold
BeliOptionButton.TextSize = 18
BeliOptionButton.Parent = BeliFarmContainer

local BeliOptionButtonCorner = Instance.new("UICorner")
BeliOptionButtonCorner.CornerRadius = UI_CORNER_RADIUS
BeliOptionButtonCorner.Parent = BeliOptionButton

BeliOptionButton.MouseEnter:Connect(function()
    TweenService:Create(BeliOptionButton, UI_TWEEN_INFO, {BackgroundColor3 = UI_HOVER_COLOR}):Play()
end)
BeliOptionButton.MouseLeave:Connect(function()
    TweenService:Create(BeliOptionButton, UI_TWEEN_INFO, {BackgroundColor3 = UI_ACCENT_COLOR}):Play()
end)

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
        TweenService:Create(BeliSlider, UI_TWEEN_INFO, {BackgroundColor3 = UI_SUCCESS_COLOR}):Play()
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
        TweenService:Create(BeliSlider, UI_TWEEN_INFO, {BackgroundColor3 = UI_ERROR_COLOR}):Play()
        BeliSlider.Text = "OFF"
        if beliFarmLoop then
            task.cancel(beliFarmLoop)
        end
    end
end)

-- Fish Farm
createFarmOption(FarmContent, "Fish Farm", FishCastEvent, 4)

-- Combat Tab Content
local AutoBattleContainer = Instance.new("Frame")
AutoBattleContainer.Name = "AutoBattleContainer"
AutoBattleContainer.Size = UDim2.new(1, -30, 0, 70)
AutoBattleContainer.Position = UDim2.new(0, 15, 0, 0)
AutoBattleContainer.BackgroundColor3 = UI_SECONDARY_COLOR
AutoBattleContainer.BorderSizePixel = 0
AutoBattleContainer.Parent = CombatContent

local AutoBattleContainerCorner = Instance.new("UICorner")
AutoBattleContainerCorner.CornerRadius = UI_CORNER_RADIUS
AutoBattleContainerCorner.Parent = AutoBattleContainer

local AutoBattleLabel = Instance.new("TextLabel")
AutoBattleLabel.Name = "AutoBattleLabel"
AutoBattleLabel.Size = UDim2.new(0.7, 0, 1, 0)
AutoBattleLabel.Position = UDim2.new(0, 15, 0, 0)
AutoBattleLabel.BackgroundColor3 = UI_SECONDARY_COLOR
AutoBattleLabel.Text = "Auto Battle"
AutoBattleLabel.TextColor3 = UI_TEXT_COLOR
AutoBattleLabel.Font = Enum.Font.SourceSans
AutoBattleLabel.TextSize = 22
AutoBattleLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoBattleLabel.Parent = AutoBattleContainer

local AutoBattleSlider = Instance.new("TextButton")
AutoBattleSlider.Name = "AutoBattleSlider"
AutoBattleSlider.Size = UDim2.new(0.2, 0, 0.7, 0)
AutoBattleSlider.Position = UDim2.new(0.75, 0, 0.15, 0)
AutoBattleSlider.BackgroundColor3 = UI_ERROR_COLOR
AutoBattleSlider.Text = "OFF"
AutoBattleSlider.TextColor3 = UI_TEXT_COLOR
AutoBattleSlider.Font = Enum.Font.SourceSansBold
AutoBattleSlider.TextSize = 20
AutoBattleSlider.Parent = AutoBattleContainer

local AutoBattleSliderCorner = Instance.new("UICorner")
AutoBattleSliderCorner.CornerRadius = UI_CORNER_RADIUS
AutoBattleSliderCorner.Parent = AutoBattleSlider

local autoBattleIsActive = false
local autoBattleLoop = nil

AutoBattleSlider.MouseButton1Click:Connect(function()
    autoBattleIsActive = not autoBattleIsActive
    if autoBattleIsActive then
        TweenService:Create(AutoBattleSlider, UI_TWEEN_INFO, {BackgroundColor3 = UI_SUCCESS_COLOR}):Play()
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
        TweenService:Create(AutoBattleSlider, UI_TWEEN_INFO, {BackgroundColor3 = UI_ERROR_COLOR}):Play()
        AutoBattleSlider.Text = "OFF"
        if autoBattleLoop then
            task.cancel(autoBattleLoop)
        end
    end
end)

-- Final setup: Make sure the UI is enabled by default
ScreenGui.Enabled = true
