local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService") -- Adicionado para evitar chamadas repetidas
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Adicionado para evitar chamadas repetidas

local Device
local function checkDevice()
    if LocalPlayer then
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            Device = UDim2.fromOffset(480, 360)
        else
            Device = UDim2.fromOffset(580, 460)
        end
    end
end
checkDevice()

-- Constantes para o caminho do serviço de flags
local FLAGS_SERVICE_PATH = {"Packages", "Knit", "Services", "FlagsService", "RF", "Solve"}

-- Configuração inicial da pasta e arquivo de opções
local FOLDER_NAME = "GTCFOD"
local OPTIONS_FILE = FOLDER_NAME .. "/options.json"

if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
if not isfile(OPTIONS_FILE) then
    writefile(OPTIONS_FILE, '{"MenuKeybind":"LeftControl","Transparency":false,"Theme":"Darker","Acrylic":false}')
end

local Window = Fluent:CreateWindow({
    Title = "GTCFOD",
    SubTitle = "by nvkob1",
    TabWidth = 160,
    Size = Device,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local currentFlagName = "Searching..."

local FlagLabel = Tabs.Main:AddParagraph({
    Title = "Flag Name",
    Content = currentFlagName
})

-- Função auxiliar para invocar o serviço de flags
local function invokeFlagsService(flagName)
    local service = ReplicatedStorage
    for _, part in ipairs(FLAGS_SERVICE_PATH) do
        service = service:WaitForChild(part)
    end
    service:InvokeServer(flagName)
end

Tabs.Main:AddButton({
    Title = "Answer",
    Description = "Submit the flag answer",
    Callback = function()
        if currentFlagName ~= "Searching..." and currentFlagName ~= "Unknown" and currentFlagName ~= "Error" then
            invokeFlagsService(currentFlagName)
            Fluent:Notify({
                Title = "Answered",
                Content = "Submitted: " .. currentFlagName,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Não foi possível submeter a resposta: nome da flag inválido.",
                Duration = 3
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Copy Flag Name",
    Description = "Copy flag name to clipboard",
    Callback = function()
        setclipboard(currentFlagName)
        Fluent:Notify({
            Title = "Copied",
            Content = "Flag name copied to clipboard!",
            Duration = 3
        })
    end
})

local AutoAnswerToggle = Tabs.Main:AddToggle("AutoAnswer", {
    Title = "Auto Answer",
    Default = false
})

local DelaySlider = Tabs.Main:AddSlider("AnswerDelay", {
    Title = "Delay Before Answer",
    Description = "Delay in seconds",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1
})

Tabs.Misc:AddButton({
    Title = "Rejoin",
    Description = "Rejoin current server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        local success, serversData = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)

        if success and serversData and serversData.data then
            for _, server in pairs(serversData.data) do
                if server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return -- Sai da função após encontrar um servidor
                end
            end
            Fluent:Notify({
                Title = "Server Hop",
                Content = "Nenhum servidor diferente encontrado.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Falha ao obter lista de servidores ou erro na requisição HTTP.",
                Duration = 3
            })
        end
    end
})

local AntiAfkToggle = Tabs.Misc:AddToggle("AntiAfk", {
    Title = "Anti-Afk",
    Default = true
})

-- Função auxiliar para extrair o ID numérico de uma string de imagem
local function extractImageId(imageString)
    local id = imageString:match("%d+")
    return id
end

local function getFlagName()
    local success, result = pcall(function()
        local playerGui = LocalPlayer.PlayerGui
        if not playerGui then warn("PlayerGui not found"); return "Error: PlayerGui not found" end

        local gameUI = playerGui:FindFirstChild("GameUI")
        if not gameUI then warn("GameUI not found"); return "Error: GameUI not found" end

        local topFlagFrame = gameUI:FindFirstChild("REFERENCED__GameUIFrame")
        if not topFlagFrame then warn("REFERENCED__GameUIFrame not found"); return "Error: REFERENCED__GameUIFrame not found" end

        local topFlag = topFlagFrame:FindFirstChild("TopFlag")
        if not topFlag then warn("TopFlag not found"); return "Error: TopFlag not found" end

        local actualTopFlagImage = topFlag:FindFirstChild("FlagImage")
        if not actualTopFlagImage then warn("Actual Top FlagImage not found"); return "Error: FlagImage not found" end

        local targetAssetId = extractImageId(actualTopFlagImage.Image)
        if not targetAssetId then warn("Target Asset ID not found in: " .. actualTopFlagImage.Image); return "Error: Target Asset ID not found" end
        warn("Target Asset ID: " .. targetAssetId)
        
        local practise = playerGui:FindFirstChild("Practise")
        if not practise then warn("Practise not found"); return "Error: Practise not found" end

        local practiseFrame = practise:FindFirstChild("REFERENCED__PractiseFrame")
        if not practiseFrame then warn("REFERENCED__PractiseFrame not found"); return "Error: REFERENCED__PractiseFrame not found" end

        local contents = practiseFrame:FindFirstChild("Contents")
        if not contents then warn("Contents not found"); return "Error: Contents not found" end

        local scrollFrame = contents:FindFirstChild("ScrollingFrame")
        if not scrollFrame then warn("ScrollingFrame not found"); return "Error: ScrollingFrame not found" end
        
        local foundFlag = false
        for _, child in ipairs(scrollFrame:GetDescendants()) do 
            if child:IsA("ImageLabel") and child.Name == "FlagImage" then
                local assetId = extractImageId(child.Image)
                warn("Comparing: " .. assetId .. " with " .. targetAssetId .. " (Parent: " .. child.Parent.Name .. ")")
                if assetId == targetAssetId then
                    foundFlag = true
                    return child.Parent.Name
                end
            end
        end
        
        if not foundFlag then
            warn("No matching flag found in ScrollingFrame descendants.")
        end
        return "Unknown"
    end)
    
    if success then
        return result
    else
        warn("Erro em getFlagName (pcall): " .. tostring(result)) -- Logar o erro real do pcall
        return "Error"
    end
end

local function isInRound()
    local success, result = pcall(function()
        local blocksRef = workspace:FindFirstChild("References")
        if not blocksRef then return false end
        local blocks = blocksRef:FindFirstChild("Blocks")
        if not blocks then return false end
        return blocks:FindFirstChild(LocalPlayer.Name) ~= nil
    end)
    if not success then
        warn("Erro em isInRound: " .. tostring(result))
    end
    return success and result
end

local function submitAnswer()
    if currentFlagName ~= "Searching..." and currentFlagName ~= "Unknown" and currentFlagName ~= "Error" then
        invokeFlagsService(currentFlagName)
    end
end

task.spawn(function()
    while task.wait(1) do -- Usar task.wait no loop
        local flagName = getFlagName()
        if flagName ~= currentFlagName then -- Atualizar apenas se houver mudança
            currentFlagName = flagName
            FlagLabel:SetDesc(flagName)
        end
    end
end)

task.spawn(function()
    local currentConnection
    local wasInRound = false
    
    while task.wait(0.5) do -- Usar task.wait no loop
        local inRound = isInRound()
        
        if Options.AutoAnswer.Value and inRound and not wasInRound then
            if currentConnection then
                currentConnection:Disconnect()
                currentConnection = nil -- Limpar a conexão antiga
            end
            
            local success, guessTimer = pcall(function()
                local gameUI = LocalPlayer.PlayerGui:FindFirstChild("GameUI")
                if not gameUI then return nil end
                local gameUIFrame = gameUI:FindFirstChild("REFERENCED__GameUIFrame")
                if not gameUIFrame then return nil end
                local topFlag = gameUIFrame:FindFirstChild("TopFlag")
                if not topFlag then return nil end
                return topFlag:FindFirstChild("GuessTimer")
            end)
            
            if success and guessTimer and guessTimer:IsA("TextLabel") then -- Verificar se é um TextLabel
                currentConnection = guessTimer:GetPropertyChangedSignal("Text"):Connect(function()
                    if guessTimer.Text == "00:30" and Options.AutoAnswer.Value then
                        local delay = Options.AnswerDelay.Value
                        task.wait(delay)
                        submitAnswer()
                    end
                end)
            else
                warn("GuessTimer não encontrado ou não é um TextLabel.")
            end
        end
        
        if not inRound and wasInRound then
            if currentConnection then
                currentConnection:Disconnect()
                currentConnection = nil
            end
        end
        
        wasInRound = inRound
    end
end)

LocalPlayer.Idled:Connect(function()
    if Options.AntiAfk.Value then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new()) -- Simula um clique para evitar AFK
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder(FOLDER_NAME)
SaveManager:SetFolder(FOLDER_NAME)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/nvkob1/rbxscripts/refs/heads/main/FluentUIToggle.lua"))()
Fluent:Notify({
    Title = "GTCFOD",
    Content = "The script has been loaded.",
    Duration = 5
})
