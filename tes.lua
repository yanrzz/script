-- ============================================================ --
-- Script Auto-Farm + Sell + Buy + Collect untuk Grow a Garden 2 --
-- Versi 2.0 dengan UI lebih rapi dan fitur perbaikan           --
-- ============================================================ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ================= DATA ================= --
local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo",
    "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn",
    "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry",
    "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap",
    "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom",
    "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local FruitOptions = {"All"}
for _, fruit in ipairs(FruitsList) do table.insert(FruitOptions, fruit) end

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
    AutoPlant = false,
    AutoSteal = false,
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
ScreenGui.Name = "GaG2AutoFarmGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 380, 0, 550)
Frame.Position = UDim2.new(0.5, -190, 0.5, -275)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

-- Title Bar dengan tombol Close & Minimize
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "🌱 GaG2 Auto Farm v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TitleBar

-- Tombol Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(0.9, 0, 0, 2)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.95, 0, 0, 2)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame.Size = minimized and UDim2.new(0, 380, 0, 30) or UDim2.new(0, 380, 0, 550)
    MinBtn.Text = minimized and "+" or "−"
    for _, child in ipairs(Frame:GetChildren()) do
        if child ~= TitleBar and child ~= Corner then
            child.Visible = not minimized
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ScrollingFrame untuk konten agar tidak bertabrakan
local Scroller = Instance.new("ScrollingFrame")
Scroller.Size = UDim2.new(1, 0, 1, -30)
Scroller.Position = UDim2.new(0, 0, 0, 30)
Scroller.BackgroundTransparency = 1
Scroller.CanvasSize = UDim2.new(0, 0, 0, 520)
Scroller.ScrollBarThickness = 6
Scroller.Parent = Frame

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
    toggle.Size = UDim2.new(0, 45, 0, 20)
    toggle.Position = UDim2.new(0.78, 0, 0.5, -10)
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
    menu.Size = UDim2.new(0.5, 0, 0, math.min(#options, 6) * 22)
    menu.Position = UDim2.new(0.5, 0, 1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = container

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, 0)
    list.BackgroundTransparency = 1
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
    list.Parent = menu

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 22)
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

-- Toggle
local yPos = 5
createToggle(Scroller, yPos, "Auto Farming", function(v) Settings.AutoFarm = v end) yPos = yPos + 30
createToggle(Scroller, yPos, "Auto Collect Fruit", function(v) Settings.AutoCollect = v end) yPos = yPos + 30
createToggle(Scroller, yPos, "Auto Selling", function(v) Settings.AutoSell = v end) yPos = yPos + 30
createToggle(Scroller, yPos, "Auto Buying", function(v) Settings.AutoBuy = v end) yPos = yPos + 30
createToggle(Scroller, yPos, "Auto Plant Seeds", function(v) Settings.AutoPlant = v end) yPos = yPos + 30
createToggle(Scroller, yPos, "Auto Steal (Night)", function(v) Settings.AutoSteal = v end) yPos = yPos + 35

-- Dropdown
createDropdown(Scroller, yPos, "Fruit Filter", FruitOptions, function(v)
    if v == "All" then Settings.SelectedFruits = FruitsList
    else Settings.SelectedFruits = {v} end
end) yPos = yPos + 30

createDropdown(Scroller, yPos, "Rarity", RarityList, function(v) Settings.SelectedRarity = v end) yPos = yPos + 30
createDropdown(Scroller, yPos, "Mutation", MutationList, function(v) Settings.SelectedMutation = v end) yPos = yPos + 30
createDropdown(Scroller, yPos, "Pets", PetsList, function(v) Settings.SelectedPets = v end) yPos = yPos + 30
createDropdown(Scroller, yPos, "Gear to Buy", GearsList, function(v) Settings.SelectedGear = v end) yPos = yPos + 35

-- Threshold
local thContainer = Instance.new("Frame")
thContainer.Size = UDim2.new(1, -20, 0, 25)
thContainer.Position = UDim2.new(0, 10, 0, yPos)
thContainer.BackgroundTransparency = 1
thContainer.Parent = Scroller

local thLabel = Instance.new("TextLabel")
thLabel.Size = UDim2.new(0.4, 0, 1, 0)
thLabel.Text = "Sell Threshold"
thLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
thLabel.BackgroundTransparency = 1
thLabel.TextXAlignment = Enum.TextXAlignment.Left
thLabel.Font = Enum.Font.Gotham
thLabel.TextSize = 13
thLabel.Parent = thContainer

local thresholdBox = Instance.new("TextBox")
thresholdBox.Size = UDim2.new(0.3, 0, 1, 0)
thresholdBox.Position = UDim2.new(0.6, 0, 0, 0)
thresholdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
thresholdBox.Text = "0"
thresholdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
thresholdBox.Font = Enum.Font.Gotham
thresholdBox.TextSize = 12
thresholdBox.BorderSizePixel = 0
thresholdBox.Parent = thContainer

thresholdBox.FocusLost:Connect(function()
    Settings.SellThreshold = tonumber(thresholdBox.Text) or 0
end)
yPos = yPos + 35

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, yPos)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.Parent = Scroller
yPos = yPos + 30

Scroller.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

-- ================= FUNGSI UTILITY ================= --

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

local function teleportTo(position)
    RootPart.CFrame = CFrame.new(position)
    task.wait(0.15)
end

-- Fungsi interaksi yang lebih serbaguna
local function interactWith(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    
    -- Metode 1: Coba semua remote event yang umum
    local remoteNames = {"CollectFruit", "Harvest", "Gather", "Pickup", "Collect", "HarvestFruit"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(obj)
            return true
        end
    end
    
    -- Metode 2: Coba klik pada objek dengan VirtualUser (simulasi mouse)
    local success, err = pcall(function()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
    if success then return true end
    
    -- Metode 3: Coba fire remote dengan argumen objek (beberapa game pakai argumen)
    for _, remote in ipairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") and remote.Name:lower():find("collect") or remote.Name:lower():find("harvest") then
            pcall(function() remote:FireServer(obj) end)
            return true
        end
    end
    
    return false
end

-- Fungsi jual
local function sellAll()
    -- Metode 1: Remote event
    local sellRemotes = {"SellFruit", "SellAll", "Sell", "SellCrops", "SellAllFruits"}
    for _, name in ipairs(sellRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer()
            return true
        end
    end
    
    -- Metode 2: Tombol GUI
    local sellBtn = Player.PlayerGui:FindFirstChild("SellButton", true) or 
                    Player.PlayerGui:FindFirstChild("SellAll", true) or
                    Player.PlayerGui:FindFirstChild("SellFruit", true)
    if sellBtn and sellBtn:IsA("TextButton") then
        sellBtn:Click()
        return true
    end
    
    -- Metode 3: Klik pada tombol sell di screen dengan VirtualUser (jika tombol terlihat)
    for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Name:lower():find("sell") then
            gui:Click()
            return true
        end
    end
    
    return false
end

-- Fungsi beli
local function buyGear(gearName)
    if gearName == "All" then return false end
    
    -- Metode 1: Remote event
    local buyRemotes = {"BuyItem", "Purchase", "Buy"}
    for _, name in ipairs(buyRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(gearName, Settings.BuyAmount)
            return true
        end
    end
    
    -- Metode 2: Cari objek shop dan klik tombol buy
    local shop = Workspace:FindFirstChild("Shop") or Workspace:FindFirstChild("Store") or Workspace:FindFirstChild("SeedShop")
    if shop then
        local item = shop:FindFirstChild(gearName)
        if item then
            for _, btn in ipairs(item:GetDescendants()) do
                if btn:IsA("TextButton") and btn.Name:lower():find("buy") then
                    btn:Click()
                    return true
                end
            end
        end
    end
    
    -- Metode 3: Cari tombol buy di GUI
    for _, gui in ipairs(Player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Name:lower():find("buy") then
            gui:Click()
            return true
        end
    end
    
    return false
end

-- Fungsi tanam benih
local function plantSeed(plot)
    local plantRemotes = {"PlantSeed", "Plant", "Sow"}
    for _, name in ipairs(plantRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(plot)
            return true
        end
    end
    -- Alternatif klik
    VirtualUser:ClickButton2(Vector2.new(0,0))
    return false
end

-- Cek apakah malam
local function isNight()
    local lighting = game:GetService("Lighting")
    return lighting.ClockTime >= 18 or lighting.ClockTime <= 6
end

-- ================= MAIN LOOP ================= --
local lastSellTime = 0
local lastBuyTime = 0

RunService.Heartbeat:Connect(function()
    local status = "Idle"
    
    -- Auto Farm
    if Settings.AutoFarm then
        status = "Farming..."
        local target = getNearestFruit()
        if target then
            teleportTo(target.Position)
            interactWith(target)
            task.wait(0.1)
        end
    end
    
    -- Auto Collect
    if Settings.AutoCollect then
        status = "Collecting..."
        local nearby = getNearbyFruits(30)
        for _, fruit in ipairs(nearby) do
            interactWith(fruit)
            task.wait(0.06)
        end
    end
    
    -- Auto Sell (dengan cooldown)
    if Settings.AutoSell and tick() - lastSellTime > 2 then
        status = "Selling..."
        local success = sellAll()
        if success then
            lastSellTime = tick()
        end
        task.wait(0.5)
    end
    
    -- Auto Buy
    if Settings.AutoBuy and Settings.SelectedGear ~= "All" and tick() - lastBuyTime > 3 then
        status = "Buying..."
        local success = buyGear(Settings.SelectedGear)
        if success then
            lastBuyTime = tick()
        end
        task.wait(0.5)
    end
    
    -- Auto Plant
    if Settings.AutoPlant then
        status = "Planting..."
        for _, plot in ipairs(Workspace:GetDescendants()) do
            if plot:IsA("BasePart") and (plot.Name:lower():find("plot") or plot.Name:lower():find("soil") or plot.Name:lower():find("bed") or plot.Name:lower():find("pot")) then
                local hasPlant = false
                for _, child in ipairs(plot:GetChildren()) do
                    if child:IsA("BasePart") and child.Name and table.find(FruitsList, child.Name) then
                        hasPlant = true
                        break
                    end
                end
                if not hasPlant then
                    plantSeed(plot)
                    task.wait(0.2)
                end
            end
        end
    end
    
    -- Auto Steal
    if Settings.AutoSteal and isNight() then
        status = "Stealing..."
        for _, plant in ipairs(Workspace:GetDescendants()) do
            if plant:IsA("BasePart") and plant.Name and table.find(FruitsList, plant.Name) then
                local owner = plant:GetAttribute("Owner") or plant:GetAttribute("owner")
                if owner and owner ~= Player.Name then
                    teleportTo(plant.Position)
                    interactWith(plant)
                    task.wait(0.2)
                end
            end
        end
    end
    
    statusLabel.Text = "Status: " .. status
end)

-- ================= ANTI-AFK ================= --
Player.Idled:Connect(function()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("🌱 GaG2 Auto Farm Script v2 Loaded!")
print("📌 Atur toggle dan filter di GUI.")
print("⚠️ Gunakan dengan bijak - resiko ban tetap ada.")
