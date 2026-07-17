-- ============================================================ --
-- Script Auto-Farm + Sell + Buy + Collect untuk Grow a Garden 2 --
-- Berdasarkan wiki GAG2.gg dan sumber terpercaya lainnya       --
-- ============================================================ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ================= DATA DARI GAME ================= --
-- Berdasarkan wiki GAG2.gg dan sumber lainnya

local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo",
    "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn",
    "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry",
    "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap",
    "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom",
    "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}

-- ================= SETTINGS ================= --
local Settings = {
    AutoFarm = false,
    AutoCollect = false,
    AutoSell = false,
    AutoBuy = false,
    AutoPlant = false,        -- Fitur tambahan: menanam benih otomatis
    AutoSteal = false,        -- Fitur tambahan: mencuri buah di malam hari
    SelectedFruits = FruitsList,
    SelectedRarity = "All",
    SelectedMutation = "All",
    SelectedPets = "All",
    SelectedGear = "All",
    SellThreshold = 0,
    BuyAmount = 1,
}

-- ================= GUI ================= --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 360, 0, 520)
Frame.Position = UDim2.new(0.5, -180, 0.5, -260)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🌱 GaG2 Auto Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

-- ================= FUNGSI GUI ================= --
local function createToggle(parent, y, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 18)
    toggle.Position = UDim2.new(0.8, 0, 0.5, -9)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return toggle
end

local function createDropdown(parent, y, labelText, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Position = UDim2.new(0, 10, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 1, 0)
    dropdown.Position = UDim2.new(0.5, 0, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdown.Text = options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 12
    dropdown.BorderSizePixel = 0
    dropdown.Parent = container

    local selected = options[1]
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0.5, 0, 0, #options * 20)
    menu.Position = UDim2.new(0.5, 0, 1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = container

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, 0)
    list.BackgroundTransparency = 1
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    list.Parent = menu

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.Text = opt
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = list
        btn.MouseButton1Click:Connect(function()
            selected = opt
            dropdown.Text = opt
            menu.Visible = false
            callback(opt)
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
    end)

    return dropdown
end

-- ================= MEMBUAT GUI ================= --
-- Toggle Utama
createToggle(Frame, 35, "Auto Farming", function(v) Settings.AutoFarm = v end)
createToggle(Frame, 65, "Auto Collect Fruit", function(v) Settings.AutoCollect = v end)
createToggle(Frame, 95, "Auto Selling", function(v) Settings.AutoSell = v end)
createToggle(Frame, 125, "Auto Buying", function(v) Settings.AutoBuy = v end)
createToggle(Frame, 155, "Auto Plant Seeds", function(v) Settings.AutoPlant = v end)
createToggle(Frame, 185, "Auto Steal (Night)", function(v) Settings.AutoSteal = v end)

-- Dropdown Filter
createDropdown(Frame, 220, "Fruit Filter", FruitsList, function(v)
    if v == "All" then Settings.SelectedFruits = FruitsList
    else Settings.SelectedFruits = {v} end
end)

createDropdown(Frame, 250, "Rarity", RarityList, function(v) Settings.SelectedRarity = v end)
createDropdown(Frame, 280, "Mutation", MutationList, function(v) Settings.SelectedMutation = v end)
createDropdown(Frame, 310, "Pets", PetsList, function(v) Settings.SelectedPets = v end)
createDropdown(Frame, 340, "Gear to Buy", GearsList, function(v) Settings.SelectedGear = v end)

-- Threshold
local thresholdBox = Instance.new("TextBox")
thresholdBox.Size = UDim2.new(0.4, 0, 0, 25)
thresholdBox.Position = UDim2.new(0.5, 0, 0, 375)
thresholdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
thresholdBox.Text = "0"
thresholdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
thresholdBox.Font = Enum.Font.Gotham
thresholdBox.TextSize = 12
thresholdBox.BorderSizePixel = 0
thresholdBox.Parent = Frame

local thLabel = Instance.new("TextLabel")
thLabel.Size = UDim2.new(0.4, 0, 0, 25)
thLabel.Position = UDim2.new(0.1, 0, 0, 375)
thLabel.Text = "Sell Threshold"
thLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
thLabel.BackgroundTransparency = 1
thLabel.Font = Enum.Font.Gotham
thLabel.TextSize = 12
thLabel.Parent = Frame

thresholdBox.FocusLost:Connect(function()
    Settings.SellThreshold = tonumber(thresholdBox.Text) or 0
end)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 410)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = Frame

-- ================= FUNGSI UTILITY ================= --

-- Cari buah terdekat berdasarkan daftar yang dipilih
local function getNearestFruit()
    local nearest = nil
    local minDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and table.find(Settings.SelectedFruits, obj.Name) then
            local dist = (obj.Position - RootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
            end
        end
    end
    return nearest
end

-- Cari semua buah di sekitar
local function getNearbyFruits(radius)
    local fruits = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and table.find(Settings.SelectedFruits, obj.Name) then
            local dist = (obj.Position - RootPart.Position).Magnitude
            if dist < radius then
                table.insert(fruits, obj)
            end
        end
    end
    return fruits
end

-- Teleport ke posisi
local function teleportTo(position)
    RootPart.CFrame = CFrame.new(position)
    task.wait(0.2)
end

-- Interaksi dengan objek (panen / collect)
local function interactWith(obj)
    if obj and obj:IsA("BasePart") then
        -- Coba beberapa remote event umum di GaG2
        local remotes = {
            ReplicatedStorage:FindFirstChild("CollectFruit"),
            ReplicatedStorage:FindFirstChild("Harvest"),
            ReplicatedStorage:FindFirstChild("Gather"),
            ReplicatedStorage:FindFirstChild("Pickup"),
        }
        for _, remote in ipairs(remotes) do
            if remote then
                remote:FireServer(obj)
                return true
            end
        end
        -- Alternatif: klik dengan VirtualUser
        VirtualUser:ClickButton2(Vector2.new(0,0))
        return true
    end
    return false
end

-- Cek apakah buah layak dijual (filter rarity & mutation)
local function shouldSell(fruit)
    local rarity = fruit:GetAttribute("Rarity") or fruit:GetAttribute("rarity") or "Common"
    local mutation = fruit:GetAttribute("Mutation") or fruit:GetAttribute("mutation") or "None"
    
    if Settings.SelectedRarity ~= "All" and rarity ~= Settings.SelectedRarity then
        return false
    end
    if Settings.SelectedMutation ~= "All" and mutation ~= Settings.SelectedMutation then
        return false
    end
    return true
end

-- Cek apakah malam (untuk auto steal)
local function isNight()
    local lighting = game:GetService("Lighting")
    return lighting:GetPropertyChangedSignal("ClockTime") or lighting.ClockTime >= 18 or lighting.ClockTime <= 6
end

-- ================= MAIN LOOP ================= --

RunService.Heartbeat:Connect(function()
    local status = "Idle"
    
    -- === AUTO FARM === --
    if Settings.AutoFarm then
        status = "Farming..."
        local target = getNearestFruit()
        if target then
            teleportTo(target.Position)
            task.wait(0.15)
            interactWith(target)
        end
    end
    
    -- === AUTO COLLECT === --
    if Settings.AutoCollect then
        status = "Collecting..."
        local nearby = getNearbyFruits(25)
        for _, fruit in ipairs(nearby) do
            interactWith(fruit)
            task.wait(0.08)
        end
    end
    
    -- === AUTO SELL === --
    if Settings.AutoSell then
        status = "Selling..."
        -- Coba berbagai remote sell yang mungkin ada
        local sellRemotes = {
            ReplicatedStorage:FindFirstChild("SellFruit"),
            ReplicatedStorage:FindFirstChild("SellAll"),
            ReplicatedStorage:FindFirstChild("Sell"),
            ReplicatedStorage:FindFirstChild("SellCrops"),
        }
        local sold = false
        for _, remote in ipairs(sellRemotes) do
            if remote then
                remote:FireServer()
                sold = true
                break
            end
        end
        
        if not sold then
            -- Cari tombol GUI Sell
            local sellBtn = Player.PlayerGui:FindFirstChild("SellButton", true) or 
                            Player.PlayerGui:FindFirstChild("SellAll", true)
            if sellBtn and sellBtn:IsA("TextButton") then
                sellBtn:Click()
            end
        end
        task.wait(1)
    end
    
    -- === AUTO BUY === --
    if Settings.AutoBuy and Settings.SelectedGear ~= "All" then
        status = "Buying..."
        local shop = Workspace:FindFirstChild("Shop") or Workspace:FindFirstChild("Store") or Workspace:FindFirstChild("SeedShop")
        if shop then
            local item = shop:FindFirstChild(Settings.SelectedGear)
            if item and item:IsA("BasePart") then
                local buyRemote = ReplicatedStorage:FindFirstChild("BuyItem") or 
                                  ReplicatedStorage:FindFirstChild("Purchase")
                if buyRemote then
                    buyRemote:FireServer(Settings.SelectedGear, Settings.BuyAmount)
                end
                task.wait(0.5)
            end
        end
    end
    
    -- === AUTO PLANT === --
    if Settings.AutoPlant then
        status = "Planting..."
        -- Cari bedengan kosong (biasanya berupa plot atau tanah)
        for _, plot in ipairs(Workspace:GetDescendants()) do
            if plot:IsA("BasePart") and (plot.Name:lower():find("plot") or plot.Name:lower():find("soil") or plot.Name:lower():find("bed")) then
                -- Cek apakah plot kosong (tidak ada tanaman)
                local hasPlant = false
                for _, child in ipairs(plot:GetChildren()) do
                    if child:IsA("BasePart") and child.Name and table.find(FruitsList, child.Name) then
                        hasPlant = true
                        break
                    end
                end
                if not hasPlant then
                    -- Coba tanam dengan remote atau klik
                    local plantRemote = ReplicatedStorage:FindFirstChild("PlantSeed")
                    if plantRemote then
                        plantRemote:FireServer(plot)
                    else
                        VirtualUser:ClickButton2(Vector2.new(0,0))
                    end
                    task.wait(0.3)
                end
            end
        end
    end
    
    -- === AUTO STEAL (Night Only) === --
    if Settings.AutoSteal and isNight() then
        status = "Stealing..."
        -- Cari tanaman di kebun pemain lain
        for _, plant in ipairs(Workspace:GetDescendants()) do
            if plant:IsA("BasePart") and plant.Name and table.find(FruitsList, plant.Name) then
                -- Cek apakah ini milik pemain lain (biasanya ada atribut Owner)
                local owner = plant:GetAttribute("Owner") or plant:GetAttribute("owner")
                if owner and owner ~= Player.Name then
                    teleportTo(plant.Position)
                    task.wait(0.15)
                    interactWith(plant)
                    task.wait(0.3)
                end
            end
        end
    end
    
    -- Update status
    statusLabel.Text = "Status: " .. status
end)

-- ================= ANTI-AFK ================= --
Player.Idled:Connect(function()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ================= NOTIFIKASI ================= --
print("🌱 GaG2 Auto Farm Script Loaded!")
print("📌 Atur toggle dan filter di GUI.")
print("⚠️ Gunakan dengan bijak - resiko ban tetap ada.")
