--[[ 
    🛡️ SEAL SNIPER V120 (ULTIMATE MOBILE FIX + CUSTOM PRICE)
    Base: Source Code V120 Original
    Modifikasi: Dropdown UI & Daftar Pet Urut Abjad (A-Z)
]]

-- ==================================================================
-- 👇 KONFIGURASI KEY SYSTEM 👇
-- ==================================================================

local DATABASE_URL = "https://gist.githubusercontent.com/erosakti/922a8f5adcfb84f14306eb87bab72b37/raw/whitelist.txt"
local KEY_FILE_NAME = "SealSniper_Key.json"

-- ==================================================================
-- 👇 DAFTAR ITEM PRESET (URUT ABJAD) 👇
-- ==================================================================
local ITEM_LIST = {
    "Flamingo", 
    "Ghostly Headless Horseman", 
    "Ghostly Spider", 
    "Giant Scorpion", 
    "Gilded Choc Peryton", 
    "Kitsune", 
    "Mimic Octopus", 
    "Orang Utan", 
    "Peryton", 
    "Raccoon", 
    "Rainbow Birb", 
    "Rainbow Dilophosaurus", 
    "Rainbow Elephant", 
    "Sea Turtle", 
    "Seal", 
    "Toucan"
}

-- ==================================================================
-- 🛠️ FUNGSI SISTEM (SAFE MOBILE EXECUTOR)
-- ==================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local SafeGuiParent = LocalPlayer:WaitForChild("PlayerGui")

if SafeGuiParent:FindFirstChild("SealKeySystem") then SafeGuiParent.SealKeySystem:Destroy() end
if SafeGuiParent:FindFirstChild("SealSniperUI") then SafeGuiParent.SealSniperUI:Destroy() end
if SafeGuiParent:FindFirstChild("BlackScreen") then SafeGuiParent.BlackScreen:Destroy() end

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
-- 🤖 MAIN BOT FUNCTION
-- ==================================================================

local function StartSealSniperV120()
    if SafeGuiParent:FindFirstChild("SealKeySystem") then SafeGuiParent.SealKeySystem:Destroy() end
    
    task.wait(1)

    local DefaultConfig = {
        Running = false, AutoHop = true, Targets = {}, MaxPrice = 10,
        Delay = 0.0, HopDelay = 8, WebhookUrl = "" 
    }
    
    local stuckCounter = 0
    local lastListingUUID = ""
    local lastBuyTime = 0

    local ConfigFile = "Sniper_Config_V120.json"
    getgenv().SniperConfig = DefaultConfig 
    if isfile(ConfigFile) then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile(ConfigFile))
            for k, v in pairs(decoded) do getgenv().SniperConfig[k] = v end
        end)
    end
    
    if type(getgenv().SniperConfig.Targets) ~= "table" then getgenv().SniperConfig.Targets = {} end

    -- 🔥 AUTO-MIGRASI DATA
    local cleanTargets = {}
    for k, v in pairs(getgenv().SniperConfig.Targets) do
        if type(k) == "number" and type(v) == "string" then
            cleanTargets[v] = 0
        elseif type(k) == "string" then
            cleanTargets[k] = tonumber(v) or 0
        end
    end
    getgenv().SniperConfig.Targets = cleanTargets

    local function SaveConfig()
        if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(getgenv().SniperConfig)) end) end
    end

    if SafeGuiParent:FindFirstChild("SealSniperUI") then SafeGuiParent.SealSniperUI:Destroy() end
    if not game:IsLoaded() then game.Loaded:Wait() end

    task.spawn(function()
        pcall(function()
            local promptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            if promptGui then
                promptGui.promptOverlay.ChildAdded:Connect(function(child)
                    if child.Name == 'ErrorPrompt' then
                        task.wait(2)
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                end)
            end
        end)
    end)

    LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

    local function ServerHop()
        SaveConfig() 
        local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if httprequest then
            local servers = {}
            local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)})
            local body = HttpService:JSONDecode(req.Body)
            if body and body.data then
                for i, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, 1, v.id)
                    end
                end
            end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
        else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
    end

    local function ToggleFPS(state)
        if state then
            if not SafeGuiParent:FindFirstChild("BlackScreen") then
                local sg = Instance.new("ScreenGui"); sg.Name = "BlackScreen"; sg.Parent = SafeGuiParent; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false
                local fr = Instance.new("Frame"); fr.Parent = sg; fr.Size = UDim2.new(1,0,1,0); fr.BackgroundColor3 = Color3.new(0,0,0); 
                local btn = Instance.new("TextButton"); btn.Parent = fr; btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = "FPS MODE ON (TAP TO OFF)"; btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 20
                btn.MouseButton1Click:Connect(function() sg:Destroy() setfpscap(60) end)
            end
            setfpscap(10)
        else
            if SafeGuiParent:FindFirstChild("BlackScreen") then SafeGuiParent.BlackScreen:Destroy() end
            setfpscap(60)
        end
    end

    local function SendWebhook(itemName, price, seller)
        local url = getgenv().SniperConfig.WebhookUrl
        if not url or url == "" or not string.find(url, "http") then return end
        local data = {["embeds"] = {{["title"] = "🛡️ SNIPE ALERT!", ["description"] = "Bought **" .. itemName .. "**", ["color"] = 65280, ["fields"] = {{["name"] = "💰 Price", ["value"] = tostring(price), ["inline"] = true}, {["name"] = "👤 Seller", ["value"] = seller, ["inline"] = true}}, ["footer"] = {["text"] = "Seal Sniper V120"}}}}
        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then pcall(function() req({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)}) end) end
    end

    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SealSniperUI"; ScreenGui.Parent = SafeGuiParent; ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -115)
    MainFrame.Size = UDim2.new(0, 380, 0, 230)
    MainFrame.Active = true; MainFrame.Draggable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local RestoreBtn = Instance.new("TextButton"); RestoreBtn.Parent = ScreenGui; RestoreBtn.Visible = false; RestoreBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); RestoreBtn.Position = UDim2.new(0.02, 0, 0.25, 0); RestoreBtn.Size = UDim2.new(0, 35, 0, 35); RestoreBtn.Text = "OPEN"; RestoreBtn.TextColor3 = Color3.new(1,1,1); RestoreBtn.Font = Enum.Font.GothamBold; RestoreBtn.TextSize = 10; Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 10, 0, 5); Title.Size = UDim2.new(0, 150, 0, 20); Title.Font = Enum.Font.GothamBold; Title.Text = "BOT V120 🛡️"; Title.TextColor3 = Color3.fromRGB(100, 255, 100); Title.TextSize = 13; Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = MainFrame; CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.Position = UDim2.new(1, -25, 0, 5); CloseBtn.Size = UDim2.new(0, 20, 0, 20); CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)
    local MinBtn = Instance.new("TextButton"); MinBtn.Parent = MainFrame; MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100); MinBtn.Position = UDim2.new(1, -50, 0, 5); MinBtn.Size = UDim2.new(0, 20, 0, 20); MinBtn.Text = "-"; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,4)

    -- 🔥 [NEW] RENDER UI DROPDOWN CUSTOM PRICE 🔥
    local SelectedPet = ITEM_LIST[1]
    
    local function IsSelected(name)
        return getgenv().SniperConfig.Targets[name] ~= nil
    end

    -- 1. Tombol Dropdown Utama
    local DropdownBtn = Instance.new("TextButton"); DropdownBtn.Parent = MainFrame; DropdownBtn.Position = UDim2.new(0, 10, 0, 35); DropdownBtn.Size = UDim2.new(0, 160, 0, 25); DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); DropdownBtn.Font = Enum.Font.GothamSemibold; DropdownBtn.TextSize = 10; DropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 220); DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 4)

    -- 2. Tombol Toggle Target & Price Box untuk Pet Terpilih
    local PetToggleBtn = Instance.new("TextButton"); PetToggleBtn.Parent = MainFrame; PetToggleBtn.Position = UDim2.new(0, 10, 0, 65); PetToggleBtn.Size = UDim2.new(0, 95, 0, 25); PetToggleBtn.Font = Enum.Font.GothamBold; PetToggleBtn.TextSize = 10; Instance.new("UICorner", PetToggleBtn).CornerRadius = UDim.new(0, 4)
    
    local PetPriceBox = Instance.new("TextBox"); PetPriceBox.Parent = MainFrame; PetPriceBox.Position = UDim2.new(0, 110, 0, 65); PetPriceBox.Size = UDim2.new(0, 60, 0, 25); PetPriceBox.Font = Enum.Font.GothamBold; PetPriceBox.TextSize = 10; PetPriceBox.PlaceholderText = "Max"; PetPriceBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25); PetPriceBox.TextColor3 = Color3.fromRGB(255, 255, 0); Instance.new("UICorner", PetPriceBox).CornerRadius = UDim.new(0, 4)

    -- 3. Info List Target Aktif
    local ActiveTargetsLbl = Instance.new("TextLabel"); ActiveTargetsLbl.Parent = MainFrame; ActiveTargetsLbl.Position = UDim2.new(0, 10, 0, 95); ActiveTargetsLbl.Size = UDim2.new(0, 160, 0, 120); ActiveTargetsLbl.BackgroundTransparency = 1; ActiveTargetsLbl.Font = Enum.Font.Gotham; ActiveTargetsLbl.TextSize = 9; ActiveTargetsLbl.TextColor3 = Color3.fromRGB(150, 150, 150); ActiveTargetsLbl.TextXAlignment = Enum.TextXAlignment.Left; ActiveTargetsLbl.TextYAlignment = Enum.TextYAlignment.Top; ActiveTargetsLbl.TextWrapped = true

    -- 4. Panel Scroll Dropdown (Hidden by Default)
    local DropListScroll = Instance.new("ScrollingFrame"); DropListScroll.Parent = MainFrame; DropListScroll.Position = UDim2.new(0, 10, 0, 62); DropListScroll.Size = UDim2.new(0, 160, 0, 155); DropListScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 40); DropListScroll.ScrollBarThickness = 3; DropListScroll.BorderSizePixel = 0; DropListScroll.Visible = false; DropListScroll.ZIndex = 10; Instance.new("UICorner", DropListScroll).CornerRadius = UDim.new(0, 4)
    local UIListLayout = Instance.new("UIListLayout"); UIListLayout.Parent = DropListScroll; UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function UpdateActiveTargetsText()
        local txt = "🎯 ACTIVE TARGETS:\n"
        local count = 0
        for k, v in pairs(getgenv().SniperConfig.Targets) do
            txt = txt .. "- " .. k .. " (" .. (v > 0 and v or "Max") .. ")\n"
            count = count + 1
        end
        if count == 0 then txt = txt .. "None" end
        ActiveTargetsLbl.Text = txt
    end

    local function RefreshDropdownUI()
        DropdownBtn.Text = "  " .. SelectedPet .. "  ▼"
        if IsSelected(SelectedPet) then
            PetToggleBtn.Text = "SNIPE: ON"
            PetToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            PetToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PetPriceBox.Visible = true
            local savedPrice = getgenv().SniperConfig.Targets[SelectedPet]
            PetPriceBox.Text = (savedPrice and savedPrice > 0) and tostring(savedPrice) or ""
        else
            PetToggleBtn.Text = "SNIPE: OFF"
            PetToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            PetToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            PetPriceBox.Visible = false
        end
        
        -- Warna list hijau jika pet sudah masuk target
        for _, child in pairs(DropListScroll:GetChildren()) do
            if child:IsA("TextButton") then
                if IsSelected(child.Name) then child.TextColor3 = Color3.fromRGB(0, 255, 100)
                else child.TextColor3 = Color3.fromRGB(220, 220, 220) end
            end
        end
        UpdateActiveTargetsText()
    end

    -- Isi Dropdown (Telah diurutkan)
    for _, item in ipairs(ITEM_LIST) do
        local btn = Instance.new("TextButton"); btn.Name = item; btn.Parent = DropListScroll; btn.Size = UDim2.new(1, -10, 0, 20); btn.BackgroundTransparency = 1; btn.Text = "  " .. item; btn.Font = Enum.Font.Gotham; btn.TextSize = 10; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 11
        btn.MouseButton1Click:Connect(function()
            SelectedPet = item
            DropListScroll.Visible = false
            RefreshDropdownUI()
        end)
    end
    DropListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

    -- Logika Interaksi UI Dropdown
    DropdownBtn.MouseButton1Click:Connect(function() DropListScroll.Visible = not DropListScroll.Visible end)
    
    PetToggleBtn.MouseButton1Click:Connect(function()
        if IsSelected(SelectedPet) then getgenv().SniperConfig.Targets[SelectedPet] = nil
        else getgenv().SniperConfig.Targets[SelectedPet] = tonumber(PetPriceBox.Text) or 0 end
        SaveConfig(); RefreshDropdownUI()
    end)
    
    PetPriceBox.FocusLost:Connect(function()
        if IsSelected(SelectedPet) then
            getgenv().SniperConfig.Targets[SelectedPet] = tonumber(PetPriceBox.Text) or 0
            SaveConfig(); RefreshDropdownUI()
        end
    end)
    
    RefreshDropdownUI()

    -- ==========================================
    -- MENU SEBELAH KANAN (Global Settings)
    -- ==========================================
    local X_OFFSET = 180 

    local InputPrice = Instance.new("TextBox"); InputPrice.Parent = MainFrame; InputPrice.Position = UDim2.new(0, X_OFFSET, 0, 35); InputPrice.Size = UDim2.new(0, 190, 0, 25); InputPrice.Font = Enum.Font.GothamBold; InputPrice.TextSize = 10; InputPrice.Text = tostring(getgenv().SniperConfig.MaxPrice); InputPrice.PlaceholderText = "Global Max Price"; InputPrice.TextColor3 = Color3.fromRGB(0, 255, 0); InputPrice.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", InputPrice).CornerRadius = UDim.new(0,4)
    InputPrice.FocusLost:Connect(function() getgenv().SniperConfig.MaxPrice = tonumber(InputPrice.Text) or 0; SaveConfig() end)
    
    local InputDelay = Instance.new("TextBox"); InputDelay.Parent = MainFrame; InputDelay.Position = UDim2.new(0, X_OFFSET, 0, 65); InputDelay.Size = UDim2.new(0, 190, 0, 25); InputDelay.Font = Enum.Font.GothamBold; InputDelay.TextSize = 10; InputDelay.Text = tostring(getgenv().SniperConfig.HopDelay); InputDelay.PlaceholderText = "Hop Delay (s)"; InputDelay.TextColor3 = Color3.fromRGB(0, 200, 255); InputDelay.BackgroundColor3 = Color3.fromRGB(30, 30, 35); Instance.new("UICorner", InputDelay).CornerRadius = UDim.new(0,4)
    InputDelay.FocusLost:Connect(function() getgenv().SniperConfig.HopDelay = tonumber(InputDelay.Text) or 8; SaveConfig() end)
    
    local InputWebhook = Instance.new("TextBox"); InputWebhook.Parent = MainFrame; InputWebhook.Position = UDim2.new(0, X_OFFSET, 0, 95); InputWebhook.Size = UDim2.new(0, 190, 0, 25); InputWebhook.Font = Enum.Font.GothamBold; InputWebhook.TextSize = 9; InputWebhook.Text = getgenv().SniperConfig.WebhookUrl or ""; InputWebhook.PlaceholderText = "Webhook URL"; InputWebhook.TextColor3 = Color3.fromRGB(200, 100, 255); InputWebhook.BackgroundColor3 = Color3.fromRGB(30, 30, 35); InputWebhook.ClipsDescendants = true; InputWebhook.ClearTextOnFocus = false; Instance.new("UICorner", InputWebhook).CornerRadius = UDim.new(0,4)
    InputWebhook.FocusLost:Connect(function() getgenv().SniperConfig.WebhookUrl = InputWebhook.Text; SaveConfig() end)

    local HopBtn = Instance.new("TextButton"); HopBtn.Parent = MainFrame; HopBtn.Position = UDim2.new(0, X_OFFSET, 0, 125); HopBtn.Size = UDim2.new(0, 90, 0, 25); HopBtn.Font = Enum.Font.GothamBold; HopBtn.TextSize = 9; Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0,4)
    local FPSBtn = Instance.new("TextButton"); FPSBtn.Parent = MainFrame; FPSBtn.Position = UDim2.new(0, X_OFFSET + 100, 0, 125); FPSBtn.Size = UDim2.new(0, 90, 0, 25); FPSBtn.Font = Enum.Font.GothamBold; FPSBtn.TextSize = 9; Instance.new("UICorner", FPSBtn).CornerRadius = UDim.new(0,4)
    
    local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = MainFrame; ToggleBtn.Position = UDim2.new(0, X_OFFSET, 0, 155); ToggleBtn.Size = UDim2.new(0, 190, 0, 30); ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 14; Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0,4)
    
    local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = MainFrame; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, X_OFFSET, 0, 195); StatusLbl.Size = UDim2.new(0, 190, 0, 15); StatusLbl.Font = Enum.Font.Gotham; StatusLbl.Text = "IDLE"; StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150); StatusLbl.TextSize = 10; StatusLbl.TextWrapped = true; StatusLbl.TextYAlignment = Enum.TextYAlignment.Top

    local function UpdateUI()
        if getgenv().SniperConfig.AutoHop then HopBtn.Text = "HOP: ON"; HopBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200) else HopBtn.Text = "HOP: OFF"; HopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
        FPSBtn.Text = "FPS SAVER"; FPSBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); FPSBtn.TextColor3 = Color3.fromRGB(255,255,255)
        if getgenv().SniperConfig.Running then 
            ToggleBtn.Text = "STOP"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); StatusLbl.Text = "🔥 TURBO SCAN 🔥"; StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        else 
            ToggleBtn.Text = "START"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); StatusLbl.Text = "Ready."; StatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    UpdateUI()

    HopBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.AutoHop = not getgenv().SniperConfig.AutoHop; SaveConfig(); UpdateUI() end)
    FPSBtn.MouseButton1Click:Connect(function() ToggleFPS(true) end)
    ToggleBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.Running = not getgenv().SniperConfig.Running; SaveConfig(); UpdateUI() end)
    CloseBtn.MouseButton1Click:Connect(function() getgenv().SniperConfig.Running = false; ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; RestoreBtn.Visible = true end)
    RestoreBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; RestoreBtn.Visible = false end)

    local hopTimer = tick()
    local BoothController = nil; pcall(function() BoothController = require(ReplicatedStorage.Modules.TradeBoothControllers.TradeBoothController) end)
    local BuyController = nil; pcall(function() BuyController = require(ReplicatedStorage.Modules.TradeBoothControllers.TradeBoothBuyItemController) end)

    local function processBoothData(player, data)
        if not getgenv().SniperConfig.Running then return end
        if not data.Listings or not data.Items then return end
        
        local globalBudget = getgenv().SniperConfig.MaxPrice
        for listingUUID, info in pairs(data.Listings) do
            local linkID = info.ItemId
            if linkID and data.Items[linkID] then
                local itemData = data.Items[linkID]
                local petName = itemData.PetType or (itemData.PetData and itemData.PetData.PetType)
                
                -- 🔥 LOGIC CEK TARGET & CUSTOM PRICE 🔥
                local targetData = getgenv().SniperConfig.Targets[petName]
                if targetData ~= nil then
                    local customBudget = tonumber(targetData) or 0
                    local activeBudget = (customBudget > 0) and customBudget or globalBudget
                    
                    local priceOk = false
                    if activeBudget == 0 then priceOk = true 
                    elseif info.Price and info.Price <= activeBudget then priceOk = true end
                    
                    if priceOk then
                        if (tick() - lastBuyTime) < 1.5 then 
                            StatusLbl.Text = "WAITING SERVER..."
                            return 
                        end

                        if lastListingUUID == listingUUID then
                            stuckCounter = stuckCounter + 1
                        else
                            lastListingUUID = listingUUID
                            stuckCounter = 0
                        end

                        if stuckCounter > 15 then
                            StatusLbl.Text = "BUGGED! HOPPING..."
                            StatusLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                            task.wait(0.5)
                            ServerHop()
                            return 
                        end

                        StatusLbl.Text = "BUYING: " .. petName
                        StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                        
                        task.spawn(function()
                            if player ~= LocalPlayer then
                                pcall(function()
                                    if BuyController and BuyController.BuyItem then BuyController:BuyItem(player, listingUUID) 
                                    else ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing:InvokeServer(player, listingUUID) end
                                end)
                            end
                            SendWebhook(petName, info.Price, player.Name)
                        end)
                        
                        lastBuyTime = tick() 
                        if stuckCounter < 5 then hopTimer = tick() end 
                        StatusLbl.Text = "PURCHASING..."
                        return 
                    end
                end
            end
        end
    end

    task.spawn(function()
        while true do
            if getgenv().SniperConfig.Running then
                pcall(function() if BoothController then for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then local boothData = BoothController:GetPlayerBoothData(player); if boothData then processBoothData(player, boothData) end end end end end)
                
                if getgenv().SniperConfig.AutoHop then
                    local durasi = tick() - hopTimer
                    local sisa = math.ceil(getgenv().SniperConfig.HopDelay - durasi)
                    
                    if StatusLbl.Text ~= "PURCHASING..." and StatusLbl.Text ~= "WAITING SERVER..." then
                       if sisa % 1 == 0 then 
                           StatusLbl.Text = "SCANNING... Hop: " .. sisa .. "s"
                           StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
                       end
                    end

                    if sisa <= 0 then 
                        StatusLbl.Text = "HOPPING..."
                        getgenv().SniperConfig.Running = true 
                        ServerHop()
                        task.wait(10)
                    end
                end
            else
                hopTimer = tick()
            end
            task.wait() 
        end
    end)
end

-- ==================================================================
-- 🔄 AUTO-LOGIN LOGIC
-- ==================================================================
local AutoLoginSuccess = false

if isfile(KEY_FILE_NAME) then
    local SavedKey = readfile(KEY_FILE_NAME)
    if SavedKey and SavedKey ~= "" then
        local dbData = GetLinkData(DATABASE_URL)
        if CheckIsValid(dbData, SavedKey) then
            AutoLoginSuccess = true
            StartSealSniperV120()
        end
    end
end

if AutoLoginSuccess then return end

-- ==================================================================
-- 🎨 GUI KEY SYSTEM
-- ==================================================================
if SafeGuiParent:FindFirstChild("SealKeySystem") then SafeGuiParent.SealKeySystem:Destroy() end

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "SealKeySystem"; ScreenGui.Parent = SafeGuiParent; ScreenGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110); MainFrame.Size = UDim2.new(0, 320, 0, 220); MainFrame.BorderSizePixel = 0; Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 0, 0, 15); Title.Size = UDim2.new(1, 0, 0, 30); Title.Font = Enum.Font.GothamBlack; Title.Text = "SEAL SNIPER HUB"; Title.TextColor3 = Color3.fromRGB(0, 255, 150); Title.TextSize = 22

local InputContainer = Instance.new("Frame"); InputContainer.Parent = MainFrame; InputContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45); InputContainer.Position = UDim2.new(0.1, 0, 0.35, 0); InputContainer.Size = UDim2.new(0.8, 0, 0, 40); InputContainer.ClipsDescendants = true; Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 6)

local KeyInput = Instance.new("TextBox"); KeyInput.Parent = InputContainer; KeyInput.BackgroundTransparency = 1; KeyInput.Position = UDim2.new(0, 5, 0, 0); KeyInput.Size = UDim2.new(1, -10, 1, 0); KeyInput.Font = Enum.Font.GothamBold; KeyInput.PlaceholderText = "Paste Key Here..."; KeyInput.Text = ""; KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255); KeyInput.TextSize = 14; KeyInput.TextXAlignment = Enum.TextXAlignment.Left

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
            if writefile then pcall(function() writefile(KEY_FILE_NAME, InputText:gsub("[%s%c]+", "")) end) end
            ScreenGui:Destroy()
            StartSealSniperV120()
        else
            StatusLbl.Text = "INVALID KEY"
            StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        StatusLbl.Text = "CONNECTION ERROR"
        StatusLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)
