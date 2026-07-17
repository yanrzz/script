-- =============================================================================
-- SPEED HUB X v17.0 - ULTIMATE ANTI-GUILD & SCREEN-BOUNDARY LOCK
-- =============================================================================

-- 1. DATABASE ITEM
local FruitsList = {
    "Wortel", "Carrot", "Stroberi", "Strawberry", "Blueberry", "Tulip", "Tomat", "Tomato", "Bambu", "Bamboo",
    "Jagung", "Corn", "Apel", "Apple", "Mangga", "Mango", "Jamur", "Mushroom", "Pisang", "Banana", "Anggur", "Grape",
    "Acorn", "Rocket Pop", "Nanas", "Pineapple", "Kaktus", "Cactus", "Buah Naga", "Dragon Fruit", "Ceri", "Cherry",
    "Pakis Api", "Fire Fern", "Buncis", "Green Bean", "Kelapa", "Coconut", "Bunga Matahari", "Sunflower", 
    "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local GearsList = {
    "Sekop", "Shovel", "Penyiram Biasa", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", 
    "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", 
    "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"
}

-- 2. GLOBAL STATE
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50

-- Fitur Otomatis
_G.AutoCollect = false
_G.AutoPlant = false
_G.AutoHarvest = false
_G.AutoBuySeed = false
_G.SelectedSeeds = { ["Wortel"] = true }
_G.BuyAllSeeds = false
_G.AutoBuyGear = false
_G.SelectedGear = "Sekop"
_G.AutoSellAll = false

-- 3. PLAYER & SERVICES
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

-- =============================================================================
-- PENYARINGAN UI TINGKAT TINGGI (ANTI-GUILD & BOUNDARY DETECTOR)
-- =============================================================================

-- Cek apakah UI benar-benar berada di dalam layar (Mengatasi menu yang digeser keluar layar)
local function isOnScreen(gui)
    if not gui:IsA("GuiObject") then return true end
    local pos = gui.AbsolutePosition
    local size = gui.AbsoluteSize
    if size.X <= 1 or size.Y <= 1 then return false end
    
    local camera = Workspace.CurrentCamera
    if camera then
        local viewport = camera.ViewportSize
        if pos.X + size.X < 0 or pos.Y + size.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then
            return false
        end
    end
    return true
end

-- Cek transparansi nyata (Mengatasi menu yang di-fadeout via CanvasGroup)
local function getActualTransparency(gui)
    local current = gui
    while current do
        if current:IsA("CanvasGroup") and current.GroupTransparency >= 0.9 then
            return 1
        end
        current = current.Parent
    end
    return 0
end

-- Cek visibilitas dasar
local function isFullyVisible(gui)
    if not gui then return false end
    if not gui.Visible then return false end
    
    local current = gui.Parent
    while current do
        if current:IsA("ScreenGui") then
            if not current.Enabled then return false end
            break
        elseif current:IsA("GuiObject") then
            if not current.Visible then return false end
        end
        current = current.Parent
    end
    return true
end

-- Blacklist Kata Kunci Terkait Guild Secara Menyeluruh
local GuildBlacklist = {
    "guild", "clan", "member", "slot", "crew", "grup", "group", 
    "squad", "alliance", "faction", "union", "association", "club", "family"
}

local function isGuildRelated(obj)
    if not obj then return false end
    local current = obj
    while current and current ~= Player.PlayerGui do
        local name = string.lower(current.Name)
        for _, word in ipairs(GuildBlacklist) do
            if string.find(name, word) then return true end
        end
        
        if current:IsA("TextLabel") or current:IsA("TextButton") then
            local text = string.lower(current.Text)
            for _, word in ipairs(GuildBlacklist) do
                if string.find(text, word) then return true end
            end
        end
        
        for _, child in pairs(current:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                local text = string.lower(child.Text)
                for _, word in ipairs(GuildBlacklist) do
                    if string.find(text, word) then return true end
                end
            end
        end
        current = current.Parent
    end
    return false
end

-- =============================================================================
-- DETEKTOR KHUSUS & VALIDASI TOKO BENIH (100% BEBAS SALAH SASARAN)
-- =============================================================================

-- Verifikasi Toko Benih yang Valid (Harus Berisi Minimal 2 Nama Buah dari FruitsList)
local function getRealSeedShopFrame()
    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
        if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("CanvasGroup") or v:IsA("ScrollingFrame")) 
            and isFullyVisible(v) and isOnScreen(v) and getActualTransparency(v) < 0.5 and not isGuildRelated(v) then
            
            local matchCount = 0
            local checkedSeeds = {}
            for _, child in pairs(v:GetDescendants()) do
                if child:IsA("TextLabel") and isFullyVisible(child) and isOnScreen(child) then
                    local text = string.lower(child.Text)
                    for _, fruit in ipairs(FruitsList) do
                        local fruitLower = string.lower(fruit)
                        if string.find(text, fruitLower) and not checkedSeeds[fruitLower] then
                            checkedSeeds[fruitLower] = true
                            matchCount = matchCount + 1
                            break
                        end
                    end
                end
                if matchCount >= 2 then
                    return v -- Valid, ini adalah Toko Benih asli!
                end
            end
        end
    end
    return nil
end

-- Verifikasi Frame Jual yang Valid
local function getRealSellFrame()
    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
        if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("CanvasGroup")) 
            and isFullyVisible(v) and isOnScreen(v) and getActualTransparency(v) < 0.5 and not isGuildRelated(v) then
            
            if v.AbsoluteSize.X > 150 and v.AbsoluteSize.Y > 150 then
                for _, child in pairs(v:GetChildren()) do
                    if child:IsA("TextLabel") and isFullyVisible(child) then
                        local txt = string.lower(child.Text)
                        if string.find(txt, "jual") or string.find(txt, "sell") then
                            if not child.Parent:IsA("GuiButton") then
                                return v
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Deteksi Tombol Navigasi Atas
local function getTopNavButton(keyword)
    local lowerKey = string.lower(keyword)
    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
        if v:IsA("GuiButton") and isFullyVisible(v) and isOnScreen(v) and not isGuildRelated(v) then
            local text = ""
            if v:IsA("TextButton") then text = string.lower(v.Text) end
            for _, child in pairs(v:GetChildren()) do
                if child:IsA("TextLabel") then text = text .. " " .. string.lower(child.Text) end
            end
            if string.find(text, lowerKey) then
                return v
            end
        end
    end
    return nil
end

-- Deteksi Koin/Coin Buy Button
local function getCoinBuyButton(shopFrame)
    if not shopFrame then return nil end
    local candidates = {}
    
    for _, child in pairs(shopFrame:GetDescendants()) do
        if child:IsA("GuiButton") and isFullyVisible(child) and isOnScreen(child) and not isGuildRelated(child) then
            local inScroll = child:FindFirstAncestorOfClass("ScrollingFrame")
            local cName = string.lower(child.Name)
            if not inScroll and cName ~= "close" and not string.find(cName, "refill") and not string.find(cName, "isi") then
                if child.AbsolutePosition.Y > (shopFrame.AbsolutePosition.Y + (shopFrame.AbsoluteSize.Y * 0.5)) then
                    table.insert(candidates, child)
                end
            end
        end
    end
    
    local coinCandidates = {}
    for _, btn in ipairs(candidates) do
        local isRobux = false
        local text = ""
        if btn:IsA("TextButton") then text = string.lower(btn.Text) end
        for _, label in pairs(btn:GetDescendants()) do
            if label:IsA("TextLabel") then text = text .. " " .. string.lower(label.Text) end
        end
        
        if string.find(text, "robux") or string.find(text, "r$") or string.find(string.lower(btn.Name), "robux") then
            isRobux = true
        end
        for _, img in pairs(btn:GetDescendants()) do
            if img:IsA("ImageLabel") and (string.find(string.lower(img.Image), "robux") or string.find(img.Image, "13079943209")) then
                isRobux = true
            end
        end
        
        if not isRobux then
            table.insert(coinCandidates, btn)
        end
    end
    
    if #coinCandidates > 1 then
        table.sort(coinCandidates, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
        return coinCandidates[1]
    elseif #coinCandidates == 1 then
        return coinCandidates[1]
    end
    
    if #candidates > 0 then
        table.sort(candidates, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
        return candidates[1]
    end
    return nil
end

-- Deteksi Dialog Konfirmasi Pembelian
local function getConfirmationFrame()
    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
        if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("CanvasGroup")) and isFullyVisible(v) and isOnScreen(v) and not isGuildRelated(v) then
            local name = string.lower(v.Name)
            local isMainShopOrSell = string.find(name, "seed") or string.find(name, "toko") or 
                                     string.find(name, "shop") or string.find(name, "benih") or
                                     string.find(name, "jual") or string.find(name, "sell")
            
            if not isMainShopOrSell and v.AbsoluteSize.X < 500 and v.AbsoluteSize.Y < 400 then
                local hasConfirmQuestion = false
                for _, child in pairs(v:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Visible then
                        local txt = string.lower(child.Text)
                        if string.find(txt, "yakin") or string.find(txt, "sure") or 
                           string.find(txt, "confirm") or string.find(txt, "beli") or 
                           string.find(txt, "buy") or string.find(txt, "purchase") then
                            hasConfirmQuestion = true
                            break
                        end
                    end
                end
                if hasConfirmQuestion then
                    return v
                end
            end
        end
    end
    return nil
end

-- Helper: Trigger Proximity Prompt
local function triggerPrompt(prompt)
    if not prompt or not prompt.Enabled then return end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            task.spawn(function()
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.05)
                prompt:InputHoldEnd()
            end)
        end
    end)
end

-- Helper: Click Simulator
local function pressButton(btn)
    if not btn or not isFullyVisible(btn) or not isOnScreen(btn) or isGuildRelated(btn) then return end
    pcall(function() GuiService.SelectedObject = btn end)
    pcall(function() btn:Activate() end)
    pcall(function()
        local events = {"MouseButton1Click", "MouseButton1Down", "MouseButton1Up", "TouchTap", "Activated"}
        for _, event in ipairs(events) do
            firesignal(btn[event])
        end
    end)
end

-- Deteksi Stok Habis
local function isOutOfStock(shopFrame)
    if not shopFrame then return false end
    for _, child in pairs(shopFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local text = string.lower(child.Text)
            if string.find(text, "tidak ada stok") or string.find(text, "out of stock") or string.find(text, "habis") or string.find(text, "no stock") then
                return true
            end
        end
    end
    return false
end

-- Dapatkan Prompts Terdekat
local function getNearbyPrompts()
    local prompts = {}
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return prompts end
    local myPos = char.HumanoidRootPart.Position
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
                local partPos = parent:GetPivot().Position
                local dist = (myPos - partPos).Magnitude
                if dist <= 120 then
                    table.insert(prompts, obj)
                end
            end
        end
    end
    return prompts
end

-- Dapatkan Buah Jatuh
local function getDroppedFruits()
    local fruits = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            for _, name in pairs(FruitsList) do
                if string.find(string.lower(obj.Name), string.lower(name)) then
                    table.insert(fruits, obj)
                end
            end
        end
    end
    return fruits
end

-- Cari Proximity Prompt Peralatan
local function findGearPrompt(gearName)
    local lowerGear = string.lower(gearName)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            local parentName = parent and string.lower(parent.Name) or ""
            local grandParentName = (parent and parent.Parent) and string.lower(parent.Parent.Name) or ""
            local objText = string.lower(obj.ObjectText)
            local actText = string.lower(obj.ActionText)
            
            if string.find(parentName, lowerGear) or 
               string.find(grandParentName, lowerGear) or 
               string.find(objText, lowerGear) or 
               string.find(actText, lowerGear) then
                return obj
            end
        end
    end
    return nil
end

-- =============================================================================
-- WALK SPEED & NO CLIP BYPASS
-- =============================================================================
local speedConnection
local function enableWalkspeed()
    if speedConnection then speedConnection:Disconnect() end
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    speedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if _G.WalkspeedToggle and hum.WalkSpeed ~= _G.CustomSpeed then
            hum.WalkSpeed = _G.CustomSpeed
        end
    end)
    if _G.WalkspeedToggle then
        hum.WalkSpeed = _G.CustomSpeed
    end
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.WalkspeedToggle then enableWalkspeed() end
end)

RunService.Stepped:Connect(function()
    if _G.NoClipToggle and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- =============================================================================
-- LOOP UTAMA AUTOMATION
-- =============================================================================

-- Loop Panen, Tanam, Collect
task.spawn(function()
    while task.wait(0.15) do
        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        
        if _G.AutoHarvest or _G.AutoPlant then
            local prompts = getNearbyPrompts()
            for _, prompt in ipairs(prompts) do
                local action = string.lower(prompt.ActionText)
                local object = string.lower(prompt.ObjectText)
                
                local isHarvest = string.find(action, "panen") or string.find(action, "harvest") or 
                                  string.find(action, "ambil") or string.find(action, "pick") or 
                                  string.find(object, "panen") or string.find(object, "harvest")
                                  
                local isPlant = string.find(action, "tanam") or string.find(action, "plant") or 
                                string.find(object, "tanam") or string.find(object, "plant") or
                                string.find(action, "biji") or string.find(object, "biji")
                
                if (_G.AutoHarvest and isHarvest) or (_G.AutoPlant and isPlant) then
                    local targetPos = prompt.Parent:GetPivot().Position
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.5, 0))
                    task.wait(0.1)
                    triggerPrompt(prompt)
                    task.wait(0.05)
                end
            end
        end

        if _G.AutoCollect then
            local fruits = getDroppedFruits()
            for _, fruit in ipairs(fruits) do
                if _G.AutoCollect and fruit.Parent then
                    hrp.CFrame = fruit.CFrame
                    task.wait(0.05)
                    firetouchinterest(hrp, fruit, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, fruit, 1)
                end
            end
        end
    end
end)

-- Loop Belanja & Jual Otomatis (Setiap 0.8 Detik)
task.spawn(function()
    while task.wait(0.8) do
        if _G.AutoBuySeed then
            pcall(function()
                local seedShopFrame = getRealSeedShopFrame()
                if not seedShopFrame then
                    local openBtn = getTopNavButton("benih") or getTopNavButton("biji") or getTopNavButton("seed")
                    if openBtn then
                        pressButton(openBtn)
                        task.wait(0.4)
                        seedShopFrame = getRealSeedShopFrame()
                    end
                end

                if seedShopFrame then
                    local targetSeeds = {}
                    if _G.BuyAllSeeds then
                        for _, gui in pairs(seedShopFrame:GetDescendants()) do
                            if gui:IsA("TextLabel") and isFullyVisible(gui) and isOnScreen(gui) and not isGuildRelated(gui) then
                                for _, seed in pairs(FruitsList) do
                                    if string.find(string.lower(gui.Text), string.lower(seed)) then
                                        if not table.find(targetSeeds, seed) then
                                            table.insert(targetSeeds, seed)
                                        end
                                    end
                                end
                            end
                        end
                    else
                        for seedName, isSelected in pairs(_G.SelectedSeeds) do
                            if isSelected then table.insert(targetSeeds, seedName) end
                        end
                    end

                    for _, seedName in ipairs(targetSeeds) do
                        local targetRow = nil
                        for _, gui in pairs(seedShopFrame:GetDescendants()) do
                            if gui:IsA("TextLabel") and isFullyVisible(gui) and isOnScreen(gui) and not isGuildRelated(gui) then
                                if string.lower(gui.Text) == string.lower(seedName) or string.find(string.lower(gui.Text), string.lower(seedName)) then
                                    targetRow = gui.Parent
                                    break
                                end
                            end
                        end

                        if targetRow then
                            local clickTarget = targetRow:IsA("GuiButton") and targetRow or nil
                            if not clickTarget then
                                for _, child in pairs(targetRow:GetChildren()) do
                                    if child:IsA("GuiButton") and isFullyVisible(child) and isOnScreen(child) and not isGuildRelated(child) then
                                        clickTarget = child
                                        break
                                    end
                                end
                            end
                            if clickTarget then
                                pressButton(clickTarget)
                                task.wait(0.25)
                            end

                            if not isOutOfStock(seedShopFrame) then
                                local buyBtn = getCoinBuyButton(seedShopFrame)
                                if buyBtn then
                                    pressButton(buyBtn)
                                    task.wait(0.35)

                                    local confirmFrame = getConfirmationFrame()
                                    if confirmFrame then
                                        for _, confirmBtn in pairs(confirmFrame:GetDescendants()) do
                                            if confirmBtn:IsA("GuiButton") and isFullyVisible(confirmBtn) and isOnScreen(confirmBtn) and not isGuildRelated(confirmBtn) then
                                                local confirmText = confirmBtn:IsA("TextButton") and string.lower(confirmBtn.Text) or ""
                                                for _, textLabel in pairs(confirmBtn:GetChildren()) do
                                                    if textLabel:IsA("TextLabel") then
                                                        confirmText = confirmText .. " " .. string.lower(textLabel.Text)
                                                    end
                                                end
                                                
                                                local isConfirmWord = string.find(confirmText, "beli") or string.find(confirmText, "buy") or 
                                                                      string.find(confirmText, "yes") or string.find(confirmText, "confirm") or 
                                                                      string.find(confirmText, "ya") or string.find(confirmText, "setuju")
                                                
                                                if isConfirmWord then
                                                    pressButton(confirmBtn)
                                                    task.wait(0.15)
                                                    break
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
        end

        if _G.AutoBuyGear and _G.SelectedGear then
            pcall(function()
                local prompt = findGearPrompt(_G.SelectedGear)
                if prompt then
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = prompt.Parent:GetPivot() * CFrame.new(0, 1.5, 1)
                        task.wait(0.25)
                        triggerPrompt(prompt)
                    end
                end
            end)
        end

        if _G.AutoSellAll then
            pcall(function()
                local sellFrame = getRealSellFrame()
                if not sellFrame then
                    local openBtn = getTopNavButton("jual") or getTopNavButton("sell")
                    if openBtn then
                        pressButton(openBtn)
                        task.wait(0.4)
                        sellFrame = getRealSellFrame()
                    end
                end
                
                if sellFrame then
                    local sellAllBtn = nil
                    for _, child in pairs(sellFrame:GetDescendants()) do
                        if child:IsA("GuiButton") and isFullyVisible(child) and isOnScreen(child) and not isGuildRelated(child) then
                            local text = ""
                            if child:IsA("TextButton") then text = string.lower(child.Text) end
                            for _, c in pairs(child:GetChildren()) do
                                if c:IsA("TextLabel") then text = text .. " " .. string.lower(c.Text) end
                            end
                            
                            if string.find(text, "jual semua") or string.find(text, "sell all") or 
                               string.find(text, "jual inventaris") or string.find(text, "sell inventory") or
                               (string.find(text, "jual") and string.find(text, "semua")) then
                                sellAllBtn = child
                                break
                            end
                        end
                    end
                    
                    if sellAllBtn then
                        pressButton(sellAllBtn)
                        task.wait(0.2)
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- UI SYSTEM (SPEED HUB X STANDARD COMPACT DESIGN)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX"
ScreenGui.ResetOnSpawn = false
local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 350)
Main.Position = UDim2.new(0.5, -220, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(18, 13, 16)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -27)
OpenBtn.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "Speed\nHub"
OpenBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 11
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 28)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 70, 70)
stroke.Thickness = 1.5
stroke.Parent = OpenBtn

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X | Grow a Garden 2"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.AnchorPoint = Vector2.new(1, 0)
Close.Position = UDim2.new(1, -5, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(200,200,200)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 13
Close.Parent = Top
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.AnchorPoint = Vector2.new(1, 0)
Minimize.Position = UDim2.new(1, -35, 0, 2)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.TextColor3 = Color3.fromRGB(200,200,200)
Minimize.Font = Enum.Font.SourceSansBold
Minimize.TextSize = 15
Minimize.Parent = Top

Minimize.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenBtn.Visible = false
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 120, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 18)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

local Spacer = Instance.new("Frame")
Spacer.Size = UDim2.new(1, 0, 0, 5)
Spacer.BackgroundTransparency = 1
Spacer.Parent = Sidebar

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -120, 1, -35)
Pages.Position = UDim2.new(0, 120, 0, 35)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

local tabButtons = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 170, 175)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local dot = Instance.new("TextLabel")
    dot.Size = UDim2.new(0, 20, 1, 0)
    dot.Position = UDim2.new(0, 5, 0, 0)
    dot.BackgroundTransparency = 1
    dot.Text = "•"
    dot.TextColor3 = Color3.fromRGB(255,80,80)
    dot.TextSize = 16
    dot.Visible = false
    dot.Parent = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(70,50,55)
    page.Parent = Pages
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabButtons) do
            t.Page.Visible = false
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Color3.fromRGB(180,170,175)
            local d = t.Button:FindFirstChild("TextLabel")
            if d then d.Visible = false end
        end
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(45,30,38)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        dot.Visible = true
    end)
    
    table.insert(tabButtons, {Button = btn, Page = page, Layout = layout})
    return page
end

local function AddSection(parent, title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, -5, 0, 26)
    sec.BackgroundColor3 = Color3.fromRGB(35,25,30)
    sec.BorderSizePixel = 0
    sec.Parent = parent
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. title
    lbl.TextColor3 = Color3.fromRGB(230,220,225)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec
    return sec
end

local function AddToggle(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -5, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -65, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 18)
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -8, 0.5, 0)
    b.BackgroundColor3 = default and Color3.fromRGB(200,50,50) or Color3.fromRGB(60,45,50)
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 9
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    
    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(200,50,50) or Color3.fromRGB(60,45,50)
        b.Text = state and "ON" or "OFF"
        if cb then cb(state) end
    end)
end

local function AddInput(parent, text, placeholder, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -5, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -100, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 80, 0, 20)
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -8, 0.5, 0)
    box.BackgroundColor3 = Color3.fromRGB(45,35,40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 10
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    
    box.FocusLost:Connect(function(ep)
        if ep and cb then cb(tonumber(box.Text) or 0) end
    end)
end

local function AddMultiDropdown(parent, text, options, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -5, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -110, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 20)
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.Position = UDim2.new(1, -8, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(45,35,40)
    btn.Text = "Pilih Benih"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 10
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    
    local isOpen = false
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -16, 0, 100)
    list.Position = UDim2.new(0, 8, 0, 28)
    list.BackgroundColor3 = Color3.fromRGB(35,25,30)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2
    list.Visible = false
    list.Parent = f
    
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 1)
    
    local fullOptions = {"[ ALL SEEDS ]"}
    for _, opt in ipairs(options) do table.insert(fullOptions, opt) end
    list.CanvasSize = UDim2.new(0, 0, 0, #fullOptions * 20)
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        f.Size = isOpen and UDim2.new(1, -5, 0, 135) or UDim2.new(1, -5, 0, 28)
    end)
    
    local optButtons = {}
    local function updateDisplay()
        if _G.BuyAllSeeds then
            btn.Text = "ALL SEEDS"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            local selectedText = {}
            for name, active in pairs(_G.SelectedSeeds) do
                if active then table.insert(selectedText, name) end
            end
            if #selectedText == 0 then
                btn.Text = "Pilih Benih"
                btn.TextColor3 = Color3.fromRGB(255,255,255)
            else
                btn.Text = table.concat(selectedText, ", ")
                btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
        
        for _, item in ipairs(optButtons) do
            local isOptAll = (item.OptionName == "[ ALL SEEDS ]")
            local isSelected = isOptAll and _G.BuyAllSeeds or (_G.SelectedSeeds[item.OptionName] == true and not _G.BuyAllSeeds)
            if isSelected then
                item.Button.TextColor3 = Color3.fromRGB(255, 70, 70)
                item.Button.Text = "✓ " .. item.OptionName
            else
                item.Button.TextColor3 = Color3.fromRGB(200,200,200)
                item.Button.Text = "  " .. item.OptionName
            end
        end
    end
    
    for _, opt in ipairs(fullOptions) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 18)
        optBtn.BackgroundColor3 = Color3.fromRGB(40,30,36)
        optBtn.BorderSizePixel = 0
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Color3.fromRGB(200,200,200)
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 10
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = list
        
        table.insert(optButtons, {Button = optBtn, OptionName = opt})
        optBtn.MouseButton1Click:Connect(function()
            if opt == "[ ALL SEEDS ]" then
                _G.BuyAllSeeds = not _G.BuyAllSeeds
                if _G.BuyAllSeeds then _G.SelectedSeeds = {} end
            else
                _G.BuyAllSeeds = false
                _G.SelectedSeeds[opt] = not _G.SelectedSeeds[opt]
            end
            updateDisplay()
            if cb then cb() end
        end)
    end
    updateDisplay()
end

local function AddDropdown(parent, text, options, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -5, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -110, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 20)
    btn.AnchorPoint = Vector2.new(1, 0)
    btn.Position = UDim2.new(1, -8, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(45,35,40)
    btn.Text = options[1] or "Select"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 10
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    
    local isOpen = false
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -16, 0, 75)
    list.Position = UDim2.new(0, 8, 0, 28)
    list.BackgroundColor3 = Color3.fromRGB(35,25,30)
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    list.ScrollBarThickness = 2
    list.Visible = false
    list.Parent = f
    
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 1)
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        f.Size = isOpen and UDim2.new(1, -5, 0, 110) or UDim2.new(1, -5, 0, 28)
    end)
    
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 18)
        optBtn.BackgroundColor3 = Color3.fromRGB(40,30,36)
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(200,200,200)
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 10
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            isOpen = false
            list.Visible = false
            f.Size = UDim2.new(1, -5, 0, 28)
            if cb then cb(opt) end
        end)
    end
end

-- =============================================================================
-- PENYUSUNAN TAB HALAMAN SPEED HUB X
-- =============================================================================

-- TAB 1: AUTO FARM
local farmPage = CreateTab("Auto Farm")
AddSection(farmPage, "🌾 Fitur Kebun")
AddToggle(farmPage, "Auto Sapu Bersih Buah (Collect)", false, function(v) _G.AutoCollect = v end)
AddToggle(farmPage, "Auto Tanam (Plant)", false, function(v) _G.AutoPlant = v end)
AddToggle(farmPage, "Auto Panen (Harvest)", false, function(v) _G.AutoHarvest = v end)
AddToggle(farmPage, "Auto Jual Semua (Fast Sell)", false, function(v) _G.AutoSellAll = v end)

-- TAB 2: SHOP BUY
local shopPage = CreateTab("Auto Belanja")
AddSection(shopPage, "🌱 Beli Biji-Bijian")
AddMultiDropdown(shopPage, "Pilih Biji (Bisa Multi / All)", FruitsList)
AddToggle(shopPage, "Aktifkan Auto Beli Biji", false, function(v) _G.AutoBuySeed = v end)

AddSection(shopPage, "🔧 Beli Peralatan")
AddDropdown(shopPage, "Pilih Alat", GearsList, function(v) _G.SelectedGear = v end)
AddToggle(shopPage, "Aktifkan Auto Beli Alat", false, function(v) _G.AutoBuyGear = v end)

-- TAB 3: SETTINGS
local settingsPage = CreateTab("Pengaturan")
AddSection(settingsPage, "⚡ Karakter")
AddToggle(settingsPage, "Aktifkan Walkspeed", false, function(v) 
    _G.WalkspeedToggle = v 
    if v then enableWalkspeed() else
        pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end)
    end
end)
AddInput(settingsPage, "Kecepatan (Speed)", "50", function(v) 
    _G.CustomSpeed = v 
    if _G.WalkspeedToggle then enableWalkspeed() end
end)
AddToggle(settingsPage, "No Clip (Tembus Tembok)", false, function(v) _G.NoClipToggle = v end)

-- TAB 4: DEBUG CONSOLE
local debugPage = CreateTab("Debug Console")
AddSection(debugPage, "⚙️ Status Sistem Real-Time")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "  Sistem: Siap"
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = debugPage

local promptsLabel = Instance.new("TextLabel")
promptsLabel.Size = UDim2.new(1, -10, 0, 20)
promptsLabel.BackgroundTransparency = 1
promptsLabel.Text = "  Tanaman Terdeteksi: 0"
promptsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
promptsLabel.Font = Enum.Font.SourceSans
promptsLabel.TextSize = 11
promptsLabel.TextXAlignment = Enum.TextXAlignment.Left
promptsLabel.Parent = debugPage

local executorLabel = Instance.new("TextLabel")
executorLabel.Size = UDim2.new(1, -10, 0, 20)
executorLabel.BackgroundTransparency = 1
executorLabel.Text = "  Mode Eksekusi: Safe-Sandbox v17.0"
executorLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
executorLabel.Font = Enum.Font.SourceSans
executorLabel.TextSize = 11
executorLabel.TextXAlignment = Enum.TextXAlignment.Left
executorLabel.Parent = debugPage

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local count = #getNearbyPrompts()
            promptsLabel.Text = "  Tanaman Terdeteksi (Radius 120m): " .. tostring(count)
            
            if fireproximityprompt then
                executorLabel.Text = "  Fungsi Trigger: FireProximityPrompt (Aktif!)"
                executorLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            else
                executorLabel.Text = "  Fungsi Trigger: Virtual-Input Simulation"
                executorLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            
            if _G.AutoHarvest or _G.AutoPlant or _G.AutoCollect or _G.AutoBuySeed or _G.AutoSellAll then
                statusLabel.Text = "  Sistem: Sedang Bekerja Aktif..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            else
                statusLabel.Text = "  Sistem: Idle (Menunggu Perintah)"
                statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            end
        end)
    end
end)

-- INITIALIZER CANVAS AUTO-RESIZE
task.spawn(function()
    task.wait(0.1)
    if #tabButtons > 0 then
        local firstTab = tabButtons[1]
        firstTab.Button.BackgroundTransparency = 0
        firstTab.Button.BackgroundColor3 = Color3.fromRGB(45,30,38)
        firstTab.Button.TextColor3 = Color3.fromRGB(255,255,255)
        firstTab.Page.Visible = true
        local dot = firstTab.Button:FindFirstChild("TextLabel")
        if dot then dot.Visible = true end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, t in pairs(tabButtons) do
                local page = t.Page
                local layout = page:FindFirstChildOfClass("UIListLayout")
                if layout then
                    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
                end
            end
        end)
    end
end)
