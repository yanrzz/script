-- =============================================================================
-- SPEED HUB X v8.5 - GAG2 INDONESIAN EDITION (100% FIX ALL FEATURES WORK)
-- =============================================================================

-- 1. DATABASE ITEM (Mendukung Bahasa Indonesia & Inggris)
local FruitsList = {
    "Wortel", "Carrot", "Stroberi", "Strawberry", "Blueberry", "Tulip", "Tomat", "Tomato", "Bambu", "Bamboo",
    "Jagung", "Corn", "Apel", "Apple", "Mangga", "Mango", "Jamur", "Mushroom", "Pisang", "Banana", "Anggur", "Grape",
    "Acorn", "Rocket Pop", "Nanas", "Pineapple", "Kaktus", "Cactus", "Buah Naga", "Dragon Fruit", "Ceri", "Cherry",
    "Pakis Api", "Fire Fern", "Buncis", "Green Bean", "Kelapa", "Coconut", "Bunga Matahari", "Sunflower", 
    "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local GearsList = {
    "Sekop", "Penyiram Biasa", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", 
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
_G.SelectedSeed = "Wortel"
_G.AutoBuyGear = false
_G.SelectedGear = "Sekop"
_G.AutoSellAll = false

-- 3. PLAYER & SERVICES
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Helper: Deteksi Plot Taman Milik Player secara Akurat
local function getMyGarden()
    for _, obj in pairs(Workspace:GetChildren()) do
        if string.find(string.lower(obj.Name), "taman") and string.find(string.lower(obj.Name), string.lower(Player.Name)) then
            return obj
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            if string.find(string.lower(obj.Name), "taman") and string.find(string.lower(obj.Name), string.lower(Player.Name)) then
                return obj
            end
        end
    end
    return nil
end

-- Helper: Klik Tombol GUI Game dengan Berbagai Metode (Anti-Gagal)
local function clickButton(btn)
    if not btn then return end
    pcall(function()
        btn:Activate()
    end)
    pcall(function()
        firesignal(btn.MouseButton1Click)
    end)
    pcall(function()
        firesignal(btn.MouseButton1Down)
    end)
    pcall(function()
        for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
            connection:Fire()
        end
    end)
end

-- Helper: Simulasi Klik Tombol Menu Atas (Biji-bijian, Jual, dll)
local function clickGuiButton(textKeyword)
    pcall(function()
        for _, v in pairs(Player:WaitForChild("PlayerGui"):GetDescendants()) do
            if v:IsA("TextButton") and string.find(string.lower(v.Text), string.lower(textKeyword)) then
                clickButton(v)
            end
        end
    end)
end

-- Helper: Deteksi & Klik Pilihan Dialog Chat NPC
local function clickDialogueOption(keyword)
    local success = false
    pcall(function()
        for _, v in pairs(Player:WaitForChild("PlayerGui"):GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) and string.find(string.lower(v.Text), string.lower(keyword)) then
                if v:IsA("TextButton") then
                    clickButton(v)
                    success = true
                else
                    -- Jika berupa label teks, cari tombol pembungkusnya (Parent)
                    local parent = v.Parent
                    for i = 1, 3 do
                        if parent and (parent:IsA("TextButton") or parent:IsA("ImageButton")) then
                            clickButton(parent)
                            success = true
                            break
                        end
                        parent = parent.Parent
                    end
                end
            end
        end
    end)
    return success
end

-- Helper: Cari Buah Jatuh di Tanah
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

-- =============================================================================
-- 4. BYPASS & CORE ENGINE (WALKSPEED & NOCLIP)
-- =============================================================================

-- Walkspeed Bypass Engine (Anti-Reset Game)
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
    if _G.WalkspeedToggle then
        enableWalkspeed()
    end
end)

-- Noclip Loop (Stepped Physics)
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
-- 5. AUTOMATION GARDENING ENGINE
-- =============================================================================

-- Loop Utama: Auto Collect, Plant, & Harvest (Setiap 0.2 Detik - Sangat Cepat)
task.spawn(function()
    while task.wait(0.2) do
        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        
        local myGarden = getMyGarden()
        if myGarden then
            -- Bypass Jarak ProximityPrompt agar bisa diakses dari jauh
            for _, prompt in pairs(myGarden:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.MaxActivationDistance = 999999
                    prompt.HoldDuration = 0
                    
                    local action = string.lower(prompt.ActionText)
                    local object = string.lower(prompt.ObjectText)
                    
                    -- A. AUTO HARVEST (Panen)
                    if _G.AutoHarvest then
                        if string.find(action, "panen") or string.find(action, "harvest") or 
                           string.find(action, "ambil") or string.find(action, "pick") or 
                           string.find(object, "panen") or string.find(object, "harvest") then
                            fireproximityprompt(prompt)
                        end
                    end
                    
                    -- B. AUTO PLANT (Tanam)
                    if _G.AutoPlant then
                        if string.find(action, "tanam") or string.find(action, "plant") or 
                           string.find(object, "tanam") or string.find(object, "plant") or
                           string.find(action, "biji") or string.find(object, "biji") then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end

        -- C. AUTO COLLECT (Sapu Bersih Buah di Tanah)
        if _G.AutoCollect then
            local fruits = getDroppedFruits()
            for _, fruit in pairs(fruits) do
                pcall(function()
                    firetouchinterest(hrp, fruit, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, fruit, 1)
                end)
            end
        end
    end
end)

-- Loop Toko & Jual NPC (Setiap 0.6 Detik)
task.spawn(function()
    while task.wait(0.6) do
        -- A. AUTO BUY SEED (Membaca Tombol "Umum" / "Rarity" Toko Benih)
        if _G.AutoBuySeed and _G.SelectedSeed then
            pcall(function()
                clickGuiButton("Biji-bijian")
                task.wait(0.2)
                for _, gui in pairs(Player.PlayerGui:GetDescendants()) do
                    if gui:IsA("TextLabel") and string.find(string.lower(gui.Text), string.lower(_G.SelectedSeed)) then
                        local parent = gui.Parent
                        if parent then
                            -- Klik semua tombol di baris benih tersebut (Bypass teks "Umum")
                            for _, child in pairs(parent:GetDescendants()) do
                                if child:IsA("TextButton") or child:IsA("ImageButton") then
                                    clickButton(child)
                                end
                            end
                        end
                    end
                end
            end)
        end

        -- B. AUTO BUY GEAR (Beli Peralatan)
        if _G.AutoBuyGear and _G.SelectedGear then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and string.find(string.lower(prompt.Parent.Name), string.lower(_G.SelectedGear)) then
                        prompt.MaxActivationDistance = 999999
                        prompt.HoldDuration = 0
                        fireproximityprompt(prompt)
                    end
                end
            end)
        end

        -- C. AUTO SELL ALL (Sistem Dialog NPC Jual Terintegrasi)
        if _G.AutoSellAll then
            pcall(function()
                -- 1. Cek apakah dialog "Jual" / "Inventaris" aktif di layar
                local dialogAktif = false
                for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                    if (v:IsA("TextButton") or v:IsA("TextLabel")) and string.find(string.lower(v.Text), "jual") then
                        dialogAktif = true
                        break
                    end
                end

                if dialogAktif then
                    -- 2. Jika aktif, langsung klik opsi Jual Inventaris secara instan
                    clickDialogueOption("jual inventaris")
                    clickDialogueOption("jual ini")
                else
                    -- 3. Jika belum aktif, tembak ProximityPrompt dari NPC Jual terdekat
                    for _, prompt in pairs(Workspace:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") then
                            local name = string.lower(prompt.Parent.Name)
                            local action = string.lower(prompt.ActionText)
                            local objText = string.lower(prompt.ObjectText)
                            
                            if string.find(name, "jual") or string.find(action, "jual") or string.find(objText, "jual") or
                               string.find(name, "sell") or string.find(action, "sell") or string.find(objText, "sell") then
                                prompt.MaxActivationDistance = 999999
                                prompt.HoldDuration = 0
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- UI SYSTEM (ULTRA COMPACT DESIGN - 440 x 350)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX"
ScreenGui.ResetOnSpawn = false
local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 350)
Main.Position = UDim2.new(0.5, -220, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(18, 13, 16)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
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
Close.TextSize = 14
Close.Parent = Top
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- SIDEBAR KIRI
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

-- PAGE CONTAINER KANAN
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -120, 1, -35)
Pages.Position = UDim2.new(0, 120, 0, 35)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

-- Tab Register System
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

-- =============================================================================
-- UI RESPONSIVE HELPERS
-- =============================================================================
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
-- 6. BUILD PAGES (GARDENING SPECIAL WITH AUTO-SELL)
-- =============================================================================

-- TAB 1: AUTO FARM
local farmPage = CreateTab("Auto Farm")
AddSection(farmPage, "🌾 Fitur Kebun")
AddToggle(farmPage, "Auto Sapu Bersih Buah (Collect)", false, function(v) _G.AutoCollect = v end)
AddToggle(farmPage, "Auto Tanam (Plant)", false, function(v) _G.AutoPlant = v end)
AddToggle(farmPage, "Auto Panen (Harvest)", false, function(v) _G.AutoHarvest = v end)
AddToggle(farmPage, "Auto Jual Semua (NPC Dialogue)", false, function(v) _G.AutoSellAll = v end)

-- TAB 2: SHOP BUY
local shopPage = CreateTab("Auto Belanja")
AddSection(shopPage, "🌱 Beli Biji-Bijian")
AddDropdown(shopPage, "Pilih Biji", FruitsList, function(v) _G.SelectedSeed = v end)
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

-- =============================================================================
-- 7. INITIALIZER & AUTO-SCROLL CANVAS ENGINE
-- =============================================================================

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

-- Auto Menghitung Tinggi Scroll Page (Menghindari Dropdown Terpotong)
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
