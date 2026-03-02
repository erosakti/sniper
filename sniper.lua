--[[ 
    🛡️ SEAL SNIPER V130 (SAFE GUI & MOBILE FIX)
    Status: FIXED "Lacking capability Plugin" Error
    Fitur:
    - Smart GUI Parent (gethui -> CoreGui -> PlayerGui)
    - Anti-Stuck & Horizontal UI
]]

-- ==================================================================
-- 👇 KONFIGURASI KEY SYSTEM 👇
-- ==================================================================

local DATABASE_URL = "https://gist.githubusercontent.com/erosakti/922a8f5adcfb84f14306eb87bab72b37/raw/whitelist.txt"
local KEY_FILE_NAME = "SealSniper_Key.json"

-- ==================================================================
-- 👇 DAFTAR ITEM PRESET 👇
-- ==================================================================
local ITEM_LIST = {
    "Giant Scorpion","Rainbow Dilophosaurus","Rainbow Elephant","Raccoon"
}

-- ==================================================================
-- 🛠️ FUNGSI SISTEM AMAN (ANTI CRASH MOBILE)
-- ==================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- 🔥 FUNGSI MENCARI TEMPAT GUI YANG AMAN 🔥
local function GetSafeGuiParent()
    local success, parent = pcall(function() return gethui() end)
    if success and parent then return parent end
    
    local success2, parent2 = pcall(function() return game:GetService("CoreGui") end)
    if success2 and parent2 then return parent2 end
    
    return LocalPlayer:WaitForChild("PlayerGui") -- Fallback paling aman
end

local SafeParent = GetSafeGuiParent()

-- Bersihkan GUI Lama
if SafeParent:FindFirstChild("SealKeySystem") then SafeParent.SealKeySystem:Destroy() end
if SafeParent:FindFirstChild("SealSniperUI") then SafeParent.SealSniperUI:Destroy() end
if SafeParent:FindFirstChild("BlackScreen") then SafeParent.BlackScreen:Destroy() end

local function GetLinkData(url)
    local NoCacheUrl = url .. "?buster=" .. tostring(math.random(1, 1000000))
    local req_func = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req_func then
        local success, response = pcall(function() return req_func({Url = NoCacheUrl, Method = "GET"}) end)
        if success and response.Body then return response.Body end
    end
    return game:HttpGet(NoCacheUrl)
end

local function CheckIsValid(databaseText, userKey)
    if not databaseText or not userKey then return false end
    local cleanInput = userKey:gsub("[%s%c]+", "") 
    for _, line in ipairs(databaseText:split("\n")) do
        local cleanLine = line:gsub("[%s%c]+", "")
        if cleanLine ~= "" and cleanLine == cleanInput then return true end
    end
    return false
end

-- ==================================================================
-- 🤖 LOGIKA BOT (GLOBAL VARIABLES)
-- ==================================================================

getgenv().SniperConfig = {
    Running = false, AutoHop = true, Targets = {}, MaxPrice = 10,
    Delay = 0.0, HopDelay = 8, WebhookUrl = "" 
}
getgenv().StuckInfo = { UUID = "", Count = 0 }
getgenv().LastBuyTime = 0

local function SaveConfig()
    if writefile then pcall(function() writefile("SealSniper_Config_V130.json", HttpService:JSONEncode(getgenv().SniperConfig)) end) end
end

if isfile("SealSniper_Config_V130.json") then
    pcall(function()
        local decoded = HttpService:JSONDecode(readfile("SealSniper_Config_V130.json"))
        for k, v in pairs(decoded) do getgenv().SniperConfig[k] = v end
    end)
end
if type(getgenv().SniperConfig.Targets) ~= "table" then getgenv().SniperConfig.Targets = {} end

local function ServerHopFunc()
    SaveConfig()
    local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if httprequest then
        local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)})
        local body = HttpService:JSONDecode(req.Body)
        if body and body.data then
            local servers = {}
            for i, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, 1, v.id)
                end
            end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
        else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
end

local function SendWebhook(itemName, price, seller)
    local url = getgenv().SniperConfig.WebhookUrl
    if not url or url == "" or not string.find(url, "http") then return end
    local data = {["embeds"] = {{["title"] = "🛡️ SNIPE ALERT!", ["description"] = "Bought **" .. itemName .. "**", ["color"] = 65280, ["fields"] = {{["name"] = "💰 Price", ["value"] = tostring(price), ["inline"] = true}, {["name"] = "👤 Seller", ["value"] = seller, ["inline"] = true}}, ["footer"] = {["text"] = "Seal Sniper V130"}}}}
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then pcall(function() req({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
end

-- ==================================================================
-- 🖥️ MAIN PROGRAM (GUI + LOGIC)
-- ==================================================================

local function StartSealSniperV130()
    -- Notifikasi aman (pcall mencegah crash jika diblokir executor)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ACCESS GRANTED";
            Text = "Loading V130...";
            Duration = 3;
        })
    end)

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SealSniperUI"; ScreenGui.Parent = SafeParent
    
    local RestoreBtn = Instance.new("TextButton"); RestoreBtn.Parent = ScreenGui
    RestoreBtn.Visible = false; RestoreBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    RestoreBtn.Position = UDim2.new(0, 10, 0.5, -20); RestoreBtn.Size = UDim2.new(0, 50, 0, 40)
    RestoreBtn.Text = "OPEN"; RestoreBtn.TextColor3 = Color3.new(1,1,1); RestoreBtn.Font = Enum.Font.GothamBold; RestoreBtn.TextSize = 12
    Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 6)

    local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; 
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.Position = UDim2.new(0.5, -180, 0.5, -100); 
    MainFrame.Size = UDim2.new(0, 360, 0, 200); 
    MainFrame.Active = true; MainFrame.Draggable = true; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(0, 150, 0, 20); Title.Font = Enum.Font.GothamBold; Title.Text = "BOT V130 🛡️"; Title.TextColor3 = Color3.fromRGB(100, 255, 100); Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = MainFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local MinBtn = Instance.new("TextButton"); MinBtn.Parent = MainFrame
    MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); MinBtn.Position = UDim2.new(1, -60, 0, 5)
    MinBtn.Size = UDim2.new(0, 25, 0, 25); MinBtn.Text = "-"; MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    CloseBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.Running = false; ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; RestoreBtn.Visible = true end)
    RestoreBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; RestoreBtn.Visible = false end)

    local ScrollFrame = Instance.new("ScrollingFrame"); ScrollFrame.Parent = MainFrame; 
    ScrollFrame.Position = UDim2.new(0, 10, 0, 30); ScrollFrame.Size = UDim2.new(0, 140, 0, 160); 
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); ScrollFrame.ScrollBarThickness = 3; ScrollFrame.BorderSizePixel = 0; Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 4)
    local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Parent = ScrollFrame; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Padding = UDim.new(0, 2)
    
    local function ToggleTarget(name, button)
        local current = getgenv().SniperConfig.Targets
        local found = false
        for i, v in pairs(current) do if v == name then table.remove(current, i); found = true; break end end
        if not found then table.insert(current, name) end
        getgenv().SniperConfig.Targets = current; SaveConfig()
        if found then button.BackgroundColor3 = Color3.fromRGB(40, 40, 45); button.TextColor3 = Color3.fromRGB(200, 200, 200) else button.BackgroundColor3 = Color3.fromRGB(0, 180, 100); button.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end

    for _, item in pairs(ITEM_LIST) do
        local btn = Instance.new("TextButton"); btn.Parent = ScrollFrame; btn.Size = UDim2.new(1, -6, 0, 20); btn.Font = Enum.Font.Gotham; btn.Text = item; btn.TextSize = 10; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local isSel = false; for _,v in pairs(getgenv().SniperConfig.Targets) do if v == item then isSel = true end end
        if isSel then btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100); btn.TextColor3 = Color3.fromRGB(255, 255, 255) else btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); btn.TextColor3 = Color3.fromRGB(200, 200, 200) end
        btn.MouseButton1Click:Connect(function() ToggleTarget(item, btn) end)
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

    local X_OFFSET = 160
    local InputPrice = Instance.new("TextBox"); InputPrice.Parent = MainFrame; InputPrice.Position = UDim2.new(0, X_OFFSET, 0, 30); InputPrice.Size = UDim2.new(0, 190, 0, 25); InputPrice.Font = Enum.Font.GothamBold; InputPrice.TextSize = 10; InputPrice.Text = tostring(getgenv().SniperConfig.MaxPrice); InputPrice.PlaceholderText = "Max Price"; InputPrice.TextColor3 = Color3.fromRGB(0, 255, 0); InputPrice.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", InputPrice).CornerRadius = UDim.new(0,4)
    local InputDelay = Instance.new("TextBox"); InputDelay.Parent = MainFrame; InputDelay.Position = UDim2.new(0, X_OFFSET, 0, 60); InputDelay.Size = UDim2.new(0, 190, 0, 25); InputDelay.Font = Enum.Font.GothamBold; InputDelay.TextSize = 10; InputDelay.Text = tostring(getgenv().SniperConfig.HopDelay); InputDelay.PlaceholderText = "Hop Delay (s)"; InputDelay.TextColor3 = Color3.fromRGB(0, 200, 255); InputDelay.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", InputDelay).CornerRadius = UDim.new(0,4)
    local InputWebhook = Instance.new("TextBox"); InputWebhook.Parent = MainFrame; InputWebhook.Position = UDim2.new(0, X_OFFSET, 0, 90); InputWebhook.Size = UDim2.new(0, 190, 0, 25); InputWebhook.Font = Enum.Font.GothamBold; InputWebhook.TextSize = 9; InputWebhook.Text = getgenv().SniperConfig.WebhookUrl or ""; InputWebhook.PlaceholderText = "Webhook URL"; InputWebhook.TextColor3 = Color3.fromRGB(200, 100, 255); InputWebhook.BackgroundColor3 = Color3.fromRGB(30, 30, 35); InputWebhook.ClipsDescendants = true; InputWebhook.ClearTextOnFocus = false; Instance.new("UICorner", InputWebhook).CornerRadius = UDim.new(0,4)
    
    local HopBtn = Instance.new("TextButton"); HopBtn.Parent = MainFrame; HopBtn.Position = UDim2.new(0, X_OFFSET, 0, 120); HopBtn.Size = UDim2.new(0, 90, 0, 25); HopBtn.Font = Enum.Font.GothamBold; HopBtn.TextSize = 9; Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0,4)
    local FPSBtn = Instance.new("TextButton"); FPSBtn.Parent = MainFrame; FPSBtn.Position = UDim2.new(0, X_OFFSET + 100, 0, 120); FPSBtn.Size = UDim2.new(0, 90, 0, 25); FPSBtn.Font = Enum.Font.GothamBold; FPSBtn.TextSize = 9; Instance.new("UICorner", FPSBtn).CornerRadius = UDim.new(0,4)
    
    local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = MainFrame; ToggleBtn.Position = UDim2.new(0, X_OFFSET, 0, 150); ToggleBtn.Size = UDim2.new(0, 190, 0, 30); ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 14; Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,4)
    local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = MainFrame; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, X_OFFSET, 0, 185); StatusLbl.Size = UDim2.new(0, 190, 0, 15); StatusLbl.Font = Enum.Font.Gotham; StatusLbl.Text = "IDLE"; StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150); StatusLbl.TextSize = 10; 

    local function UpdateUI()
        if getgenv().SniperConfig.AutoHop then HopBtn.Text = "HOP: ON"; HopBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) else HopBtn.Text = "HOP: OFF"; HopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
        FPSBtn.Text = "FPS SAVER"; FPSBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); FPSBtn.TextColor3 = Color3.fromRGB(255,255,255)
        if getgenv().SniperConfig.Running then ToggleBtn.Text = "STOP"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); StatusLbl.Text = "🔥 TURBO SCAN 🔥"; StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        else ToggleBtn.Text = "START"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); StatusLbl.Text = "Ready."; StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150) end
    end
    UpdateUI()

    InputPrice.FocusLost:Connect(function() getgenv().SniperConfig.MaxPrice = tonumber(InputPrice.Text) or 0; SaveConfig() end)
    InputDelay.FocusLost:Connect(function() getgenv().SniperConfig.HopDelay = tonumber(InputDelay.Text) or 8; SaveConfig() end)
    InputWebhook.FocusLost:Connect(function() getgenv().SniperConfig.WebhookUrl = InputWebhook.Text; SaveConfig() end)
    HopBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.AutoHop = not getgenv().SniperConfig.AutoHop; SaveConfig(); UpdateUI() end)
    FPSBtn.MouseButton1Click:Connect(function() 
        if not SafeParent:FindFirstChild("BlackScreen") then
            local sg = Instance.new("ScreenGui"); sg.Name = "BlackScreen"; sg.Parent = SafeParent; sg.IgnoreGuiInset = true
            local fr = Instance.new("Frame"); fr.Parent = sg; fr.Size = UDim2.new(1,0,1,0); fr.BackgroundColor3 = Color3.new(0,0,0)
            local btn = Instance.new("TextButton"); btn.Parent = fr; btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = "FPS SAVER (TAP TO OFF)"; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 20
            btn.MouseButton1Click:Connect(function() sg:Destroy(); setfpscap(60) end); setfpscap(10)
        end
    end)
    ToggleBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.Running = not getgenv().SniperConfig.Running; SaveConfig(); UpdateUI() end)

    task.spawn(function()
        pcall(function()
            game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild("ErrorFrame") then
                    task.wait(2); TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end)
        end)
    end)
    LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

    task.spawn(function()
        local hopTimer = tick()
        local BoothController = nil; pcall(function() BoothController = require(ReplicatedStorage.Modules.TradeBoothControllers.TradeBoothController) end)
        local BuyController = nil; pcall(function() BuyController = require(ReplicatedStorage.Modules.TradeBoothControllers.TradeBoothBuyItemController) end)

        while true do
            if getgenv().SniperConfig.Running then
                pcall(function()
                    if BoothController then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local boothData = BoothController:GetPlayerBoothData(player)
                                if boothData and boothData.Listings and boothData.Items then
                                    for listingUUID, info in pairs(boothData.Listings) do
                                        local budget = getgenv().SniperConfig.MaxPrice
                                        if (budget == 0 or (info.Price and info.Price <= budget)) then
                                            local linkID = info.ItemId
                                            if linkID and boothData.Items[linkID] then
                                                local itemData = boothData.Items[linkID]
                                                local petName = itemData.PetType or (itemData.PetData and itemData.PetData.PetType)
                                                for _, target in pairs(getgenv().SniperConfig.Targets) do
                                                    if petName == target then
                                                        
                                                        if (tick() - getgenv().LastBuyTime) < 2 then 
                                                            StatusLbl.Text = "WAITING SERVER..."
                                                            task.wait(0.5); return 
                                                        end

                                                        if getgenv().StuckInfo.UUID == listingUUID then getgenv().StuckInfo.Count = getgenv().StuckInfo.Count + 1
                                                        else getgenv().StuckInfo.UUID = listingUUID; getgenv().StuckInfo.Count = 0 end

                                                        if getgenv().StuckInfo.Count > 30 then
                                                            StatusLbl.Text = "STUCK! HOPPING..."
                                                            StatusLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                                                            task.wait(0.5); ServerHopFunc(); return
                                                        end

                                                        StatusLbl.Text = "BUYING: " .. petName
                                                        StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                                                        
                                                        task.spawn(function()
                                                            if BuyController and BuyController.BuyItem then BuyController:BuyItem(player, listingUUID)
                                                            else ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing:InvokeServer(player, listingUUID) end
                                                            SendWebhook(petName, info.Price, player.Name)
                                                        end)
                                                        
                                                        getgenv().LastBuyTime = tick() 
                                                        hopTimer = tick() 
                                                        StatusLbl.Text = "PURCHASING..."; return
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                if getgenv().SniperConfig.AutoHop then
                    local durasi = tick() - hopTimer
                    local sisa = math.ceil(getgenv().SniperConfig.HopDelay - durasi)
                    if StatusLbl.Text ~= "PURCHASING..." and sisa % 1 == 0 then StatusLbl.Text = "SCAN... " .. sisa .. "s"; StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50) end
                    if sisa <= 0 then StatusLbl.Text = "HOPPING..."; getgenv().SniperConfig.Running = true; ServerHopFunc(); task.wait(10) end
                end
            else hopTimer = tick() end
            task.wait()
        end
    end)
end

-- ==================================================================
-- 🔄 AUTO-LOGIN
-- ==================================================================
local AutoLoginSuccess = false
if isfile(KEY_FILE_NAME) then
    local SavedKey = readfile(KEY_FILE_NAME)
    if SavedKey and SavedKey ~= "" then
        local dbData = GetLinkData(DATABASE_URL)
        if CheckIsValid(dbData, SavedKey) then
            AutoLoginSuccess = true
            StartSealSniperV130()
        end
    end
end
if AutoLoginSuccess then return end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SealKeySystem"; ScreenGui.Parent = SafeParent
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110); MainFrame.Size = UDim2.new(0, 320, 0, 220); MainFrame.BorderSizePixel = 0; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 0, 0, 15); Title.Size = UDim2.new(1, 0, 0, 30); Title.Font = Enum.Font.GothamBlack; Title.Text = "SEAL SNIPER HUB"; Title.TextColor3 = Color3.fromRGB(0, 255, 150); Title.TextSize = 22

local InputContainer = Instance.new("Frame"); InputContainer.Parent = MainFrame; InputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45); InputContainer.Position = UDim2.new(0.1, 0, 0.35, 0); InputContainer.Size = UDim2.new(0.8, 0, 0, 40); InputContainer.ClipsDescendants = true; Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 6)
local KeyInput = Instance.new("TextBox"); KeyInput.Parent = InputContainer; KeyInput.BackgroundTransparency = 1; KeyInput.Size = UDim2.new(1, -10, 1, 0); KeyInput.Position = UDim2.new(0, 5, 0, 0); KeyInput.Font = Enum.Font.GothamBold; KeyInput.PlaceholderText = "Paste Key Here..."; KeyInput.Text = ""; KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255); KeyInput.TextSize = 14; KeyInput.TextXAlignment = Enum.TextXAlignment.Left

local VerifyBtn = Instance.new("TextButton"); VerifyBtn.Parent = MainFrame; VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100); VerifyBtn.Position = UDim2.new(0.1, 0, 0.6, 0); VerifyBtn.Size = UDim2.new(0.8, 0, 0, 35); VerifyBtn.Font = Enum.Font.GothamBold; VerifyBtn.Text = "LOGIN & SAVE KEY"; VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); VerifyBtn.TextSize = 13; Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)
local CloseKeyBtn = Instance.new("TextButton"); CloseKeyBtn.Name = "CloseButton"; CloseKeyBtn.Parent = MainFrame; CloseKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseKeyBtn.Position = UDim2.new(1, -30, 0, 5); CloseKeyBtn.Size = UDim2.new(0, 25, 0, 25); CloseKeyBtn.Font = Enum.Font.GothamBlack; CloseKeyBtn.Text = "X"; CloseKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseKeyBtn.TextSize = 14; Instance.new("UICorner", CloseKeyBtn).CornerRadius = UDim.new(0, 6)
local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = MainFrame; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, 0, 0.85, 0); StatusLbl.Size = UDim2.new(1, 0, 0, 20); StatusLbl.Font = Enum.Font.Gotham; StatusLbl.Text = "Please login first"; StatusLbl.TextColor3 = Color3.fromRGB(100, 100, 100); StatusLbl.TextSize = 11

CloseKeyBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

VerifyBtn.MouseButton1Click:Connect(function()
    StatusLbl.Text = "Verifying..."
    StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
    local InputText = KeyInput.Text
    local success, response = pcall(function() return GetLinkData(DATABASE_URL) end)
    if success and response then
        if CheckIsValid(response, InputText) then
            if writefile then writefile(KEY_FILE_NAME, InputText:gsub("[%s%c]+", "")) end
            if ScreenGui then ScreenGui:Destroy() end
            StartSealSniperV130()
        else StatusLbl.Text = "INVALID KEY"; StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50) end
    else StatusLbl.Text = "CONNECTION ERROR"; StatusLbl.TextColor3 = Color3.fromRGB(255, 0, 0) end
end)
