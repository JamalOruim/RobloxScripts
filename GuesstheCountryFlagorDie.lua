local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    SubTitle = "ptbr por Jhony",
    TabWidth = 160,
    Size = Device,
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Principal", Icon = "home" }),
    Misc = Window:AddTab({ Title = "Diversos", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

local Options = Fluent.Options
local currentFlagName = "Procurando..."

local FlagLabel = Tabs.Main:AddParagraph({
    Title = "Nome da Bandeira",
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
    Title = "Responder",
    Description = "Enviar a resposta da bandeira",
    Callback = function()
        if currentFlagName ~= "Procurando..." and currentFlagName ~= "Desconhecido" and currentFlagName ~= "Erro" then
            invokeFlagsService(currentFlagName)
            Fluent:Notify({
                Title = "Respondido",
                Content = "Enviado: " .. currentFlagName,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Não foi possível enviar a resposta: nome inválido.",
                Duration = 3
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Copiar Nome",
    Description = "Copiar nome da bandeira para a área de transferência",
    Callback = function()
        setclipboard(currentFlagName)
        Fluent:Notify({
            Title = "Copiado",
            Content = "Nome da bandeira copiado!",
            Duration = 3
        })
    end
})

local AutoAnswerToggle = Tabs.Main:AddToggle("AutoAnswer", {
    Title = "Auto Resposta",
    Default = false
})

local DelaySlider = Tabs.Main:AddSlider("AnswerDelay", {
    Title = "Atraso na Resposta",
    Description = "Atraso em segundos",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1
})

Tabs.Misc:AddButton({
    Title = "Reconectar",
    Description = "Entrar novamente no servidor atual",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Trocar Servidor",
    Description = "Entrar em um servidor diferente",
    Callback = function()
        local success, serversData = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)

        if success and serversData and serversData.data then
            for _, server in pairs(serversData.data) do
                if server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            Fluent:Notify({
                Title = "Trocar Servidor",
                Content = "Nenhum servidor diferente encontrado.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Falha ao obter lista de servidores.",
                Duration = 3
            })
        end
    end
})

local AntiAfkToggle = Tabs.Misc:AddToggle("AntiAfk", {
    Title = "Anti-AFK",
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
        local gameUI = playerGui:FindFirstChild("GameUI")
        if not gameUI then return "Erro: GameUI não encontrado" end

        local topFlagFrame = gameUI:FindFirstChild("REFERENCED__GameUIFrame")
        if not topFlagFrame then return "Erro: Frame principal não encontrado" end

        local topFlag = topFlagFrame:FindFirstChild("TopFlag")
        if not topFlag then return "Erro: TopFlag não encontrado" end

        local actualTopFlagImage = topFlag:FindFirstChild("FlagImage")
        if not actualTopFlagImage then return "Erro: Imagem da bandeira não encontrada" end

        local targetAssetId = extractImageId(actualTopFlagImage.Image)
        if not targetAssetId then return "Erro: ID da imagem não encontrado" end
        
        local practise = playerGui:FindFirstChild("Practise")
        if not practise then return "Erro: Practise não encontrado" end

        local practiseFrame = practise:FindFirstChild("REFERENCED__PractiseFrame")
        if not practiseFrame then return "Erro: Frame de prática não encontrado" end

        local contents = practiseFrame:FindFirstChild("Contents")
        if not contents then return "Erro: Conteúdo não encontrado" end

        local scrollFrame = contents:FindFirstChild("ScrollingFrame")
        if not scrollFrame then return "Erro: ScrollingFrame não encontrado" end
        
        for _, child in ipairs(scrollFrame:GetDescendants()) do 
            if child:IsA("ImageLabel") and child.Name == "FlagImage" then
                local assetId = extractImageId(child.Image)
                if assetId == targetAssetId then
                    return child.Parent.Name
                end
            end
        end
        
        return "Desconhecido"
    end)
    
    if success then
        return result
    else
        return "Erro"
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
    return success and result
end

local function submitAnswer()
    if currentFlagName ~= "Procurando..." and currentFlagName ~= "Desconhecido" and currentFlagName ~= "Erro" then
        invokeFlagsService(currentFlagName)
    end
end

task.spawn(function()
    while task.wait(1) do
        local flagName = getFlagName()
        if flagName ~= currentFlagName then
            currentFlagName = flagName
            FlagLabel:SetDesc(flagName)
        end
    end
end)

task.spawn(function()
    local currentConnection
    local wasInRound = false
    
    while task.wait(0.5) do
        local inRound = isInRound()
        
        if Options.AutoAnswer.Value and inRound and not wasInRound then
            if currentConnection then
                currentConnection:Disconnect()
                currentConnection = nil
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
            
            if success and guessTimer and guessTimer:IsA("TextLabel") then
                currentConnection = guessTimer:GetPropertyChangedSignal("Text"):Connect(function()
                    if guessTimer.Text == "00:30" and Options.AutoAnswer.Value then
                        local delay = Options.AnswerDelay.Value
                        task.wait(delay)
                        submitAnswer()
                    end
                end)
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
        VirtualUser:ClickButton2(Vector2.new())
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
    Content = "O script foi carregado com sucesso.",
    Duration = 5
})
