-- ============================================================ --
-- Script Auto-Farm + Sell + Buy + Collect untuk Grow a Garden 2 --
-- UI Modern, Ringkas, Tidak Full Layar                        --
-- ============================================================ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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
    Cooldown = 0.3,
}

-- ================= GUI ================= --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GaG2GUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 370, 0, 480)
Frame.Position = UDim2.new(0.5, -185, 0.5, -240)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
Frame.BackgroundTransparency = 0.05
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

-- Shadow / Glow effect
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.Position = UDim2.new(0, 0, 0, 0)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.BorderSizePixel = 0
Shadow.Parent = Frame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "🌱 GaG2 Auto"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 1, 0)
MinBtn.Position = UDim2.new(0.88, 0, 0, 0)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TitleBar

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Frame.Size = isMinimized and UDim2.new(0, 370, 0, 32) or UDim2.new(0, 370, 0, 480)
    MainContainer.Visible = not isMinimized
end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 1, 0)
CloseBtn.Position = UDim2.new(0.94, 0, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Main Container (Scrolling)
local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Size = UDim2.new(1, -10, 1, -42)
MainContainer.Position = UDim2.new(0, 5, 0, 36)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 700)
MainContainer.ScrollBarThickness = 3
MainContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
MainContainer.Parent = Frame

-- ================= UI COMPONENTS ================= --
local function createToggle(parent, y, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 26)
    container.Position = UDim2.new(0, 5, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 20)
    toggle.Position = UDim2.new(0.78, 0, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 11
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(200, 50, 50)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return toggle
end

local function createDropdown(parent, y, labelText, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 26)
    container.Position = UDim2.new(0, 5, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = container

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 1, 0)
    dropdown.Position = UDim2.new(0.45, 0, 0, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    dropdown.Text = options[1]
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 11
    dropdown.BorderSizePixel = 0
    dropdown.Parent = container

    local selected = options[1]
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0.5, 0, 0, math.min(#options, 5) * 22)
    menu.Position = UDim2.new(0.45, 0, 1, 1)
    menu.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = container

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, 0)
    list.BackgroundTransparency = 1
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
    list.ScrollBarThickness = 2
    list.Parent = menu

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.Text = opt
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
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

local function createInput(parent, y, labelText, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 26)
    container.Position = UDim2.new(0, 5, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.3, 0, 1, 0)
    input.Position = UDim2.new(0.5, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    input.Text = default
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.BorderSizePixel = 0
    input.Parent = container

    input.FocusLost:Connect(function()
        callback(tonumber(input.Text) or default)
    end)
    return input
end

-- ================= BUILD UI ================= --
local y = 5

-- === SECTION: Automation ===
local section1 = Instance.new("TextLabel")
section1.Size = UDim2.new(1, -10, 0, 20)
section1.Position = UDim2.new(0, 5, 0, y)
section1.Text = "⚡ Automation"
section1.TextColor3 = Color3.fromRGB(100, 200, 255)
section1.BackgroundTransparency = 1
section1.Font = Enum.Font.GothamBold
section1.TextSize = 14
section1.TextXAlignment = Enum.TextXAlignment.Left
section1.Parent = MainContainer
y = y + 24

createToggle(MainContainer, y, "Auto Farm", function(v) Settings.AutoFarm = v end)
y = y + 30
createToggle(MainContainer, y, "Auto Collect", function(v) Settings.AutoCollect = v end)
y = y + 30
createToggle(MainContainer, y, "Auto Sell", function(v) Settings.AutoSell = v end)
y = y + 30
createToggle(MainContainer, y, "Auto Buy", function(v) Settings.AutoBuy = v end)
y = y + 30
createToggle(MainContainer, y, "Auto Plant", function(v) Settings.AutoPlant = v end)
y = y + 30
createToggle(MainContainer, y, "Auto Steal (Night)", function(v) Settings.AutoSteal = v end)
y = y + 38

-- === SECTION: Filters ===
local section2 = Instance.new("TextLabel")
section2.Size = UDim2.new(1, -10, 0, 20)
section2.Position = UDim2.new(0, 5, 0, y)
section2.Text = "🎯 Filters"
section2.TextColor3 = Color3.fromRGB(100, 200, 255)
section2.BackgroundTransparency = 1
section2.Font = Enum.Font.GothamBold
section2.TextSize = 14
section2.TextXAlignment = Enum.TextXAlignment.Left
section2.Parent = MainContainer
y = y + 24

createDropdown(MainContainer, y, "Fruit", FruitOptions, function(v)
    Settings.SelectedFruits = (v == "All") and FruitsList or {v}
end)
y = y + 30
createDropdown(MainContainer, y, "Rarity", RarityList, function(v) Settings.SelectedRarity = v end)
y = y + 30
createDropdown(MainContainer, y, "Mutation", MutationList, function(v) Settings.SelectedMutation = v end)
y = y + 30
createDropdown(MainContainer, y, "Pet", PetsList, function(v) Settings.SelectedPets = v end)
y = y + 30
createDropdown(MainContainer, y, "Gear to Buy", GearsList, function(v) Settings.SelectedGear = v end)
y = y + 38

-- === SECTION: Settings ===
local section3 = Instance.new("TextLabel")
section3.Size = UDim2.new(1, -10, 0, 20)
section3.Position = UDim2.new(0, 5, 0, y)
section3.Text = "⚙️ Settings"
section3.TextColor3 = Color3.fromRGB(100, 200, 255)
section3.BackgroundTransparency = 1
section3.Font = Enum.Font.GothamBold
section3.TextSize = 14
section3.TextXAlignment = Enum.TextXAlignment.Left
section3.Parent = MainContainer
y = y + 24

createInput(MainContainer, y, "Sell Threshold", "0", function(v) Settings.SellThreshold = v end)
y = y + 30
createInput(MainContainer, y, "Buy Amount", "1", function(v) Settings.BuyAmount = math.max(1, v) end)
y = y + 30
createInput(MainContainer, y, "Cooldown (s)", "0.3", function(v) Settings.Cooldown = math.max(0.1, v) end)
y = y + 38

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0, 22)
statusLabel.Position = UDim2.new(0, 5, 0, y)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(150, 200, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.Parent = MainContainer

MainContainer.CanvasSize = UDim2.new(0, 0, 0, y + 30)

-- ================= FUNGSI UTILITY ================= --

local function getNearestFruit()
    local nearest, minDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and table.find(Settings.SelectedFruits, obj.Name) then
            local dist = (obj.Position - RootPart.Position).Magnitude
            if dist < minDist then minDist, nearest = dist, obj end
        end
    end
    return nearest
end

local function getNearbyFruits(radius)
    local fruits = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name and table.find(Settings.SelectedFruits, obj.Name) then
            if (obj.Position - RootPart.Position).Magnitude < radius then
                table.insert(fruits, obj)
            end
        end
    end
    return fruits
end

local function teleportTo(pos)
    RootPart.CFrame = CFrame.new(pos)
    task.wait(0.15)
end

local function interactWith(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    local remoteNames = {"CollectFruit", "Harvest", "Gather", "Pickup", "Collect", "HarvestFruit"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(obj)
            return true
        end
    end
    VirtualUser:ClickButton2(Vector2.new(0,0))
    return true
end

local function sellAll()
    local remoteNames = {"SellFruit", "SellAll", "Sell", "SellCrops", "SellAllFruits"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer()
            return true
        end
    end
    local gui = Player.PlayerGui
    local btnNames = {"SellButton", "SellAll", "SellFruits", "Sell"}
    for _, name in ipairs(btnNames) do
        local btn = gui:FindFirstChild(name, true)
        if btn and btn:IsA("TextButton") then
            btn:Click()
            return true
        end
    end
    VirtualUser:ClickButton2(Vector2.new(0,0))
    return false
end

local function buyGear(gearName)
    if not gearName or gearName == "All" then return false end
    local remoteNames = {"BuyItem", "Purchase", "Buy", "BuyGear"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(gearName, Settings.BuyAmount)
            return true
        end
    end
    local shop = Workspace:FindFirstChild("Shop") or Workspace:FindFirstChild("Store") or Workspace:FindFirstChild("SeedShop")
    if shop then
        local item = shop:FindFirstChild(gearName)
        if item and item:IsA("BasePart") then
            VirtualUser:ClickButton2(Vector2.new(0,0))
            return true
        end
    end
    local gui = Player.PlayerGui
    local btn = gui:FindFirstChild("BuyButton", true) or gui:FindFirstChild("Purchase", true)
    if btn and btn:IsA("TextButton") then
        btn:Click()
        return true
    end
    return false
end

local function isNight()
    return game:GetService("Lighting").ClockTime >= 18 or game:GetService("Lighting").ClockTime <= 6
end

-- ================= MAIN LOOP ================= --
local lastActionTime = 0

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastActionTime < Settings.Cooldown then return end
    local status = "Idle"

    if Settings.AutoFarm then
        status = "Farming..."
        local target = getNearestFruit()
        if target then
            teleportTo(target.Position)
            interactWith(target)
            lastActionTime = now
        end
    end

    if Settings.AutoCollect then
        status = "Collecting..."
        local nearby = getNearbyFruits(30)
        for _, fruit in ipairs(nearby) do
            interactWith(fruit)
            lastActionTime = now
            task.wait(0.08)
        end
    end

    if Settings.AutoSell then
        status = "Selling..."
        sellAll()
        lastActionTime = now
        task.wait(0.5)
    end

    if Settings.AutoBuy and Settings.SelectedGear ~= "All" then
        status = "Buying..."
        buyGear(Settings.SelectedGear)
        lastActionTime = now
        task.wait(0.5)
    end

    if Settings.AutoPlant then
        status = "Planting..."
        for _, plot in ipairs(Workspace:GetDescendants()) do
            if plot:IsA("BasePart") and (plot.Name:lower():find("plot") or plot.Name:lower():find("soil") or plot.Name:lower():find("bed")) then
                local hasPlant = false
                for _, child in ipairs(plot:GetChildren()) do
                    if child:IsA("BasePart") and child.Name and table.find(FruitsList, child.Name) then
                        hasPlant = true
                        break
                    end
                end
                if not hasPlant then
                    local remote = ReplicatedStorage:FindFirstChild("PlantSeed") or ReplicatedStorage:FindFirstChild("Plant")
                    if remote then remote:FireServer(plot) else VirtualUser:ClickButton2(Vector2.new(0,0)) end
                    lastActionTime = now
                    task.wait(0.3)
                end
            end
        end
    end

    if Settings.AutoSteal and isNight() then
        status = "Stealing..."
        for _, plant in ipairs(Workspace:GetDescendants()) do
            if plant:IsA("BasePart") and plant.Name and table.find(FruitsList, plant.Name) then
                local owner = plant:GetAttribute("Owner") or plant:GetAttribute("owner")
                if owner and owner ~= Player.Name then
                    teleportTo(plant.Position)
                    interactWith(plant)
                    lastActionTime = now
                    task.wait(0.3)
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

print("🌱 GaG2 Auto Farm Loaded!")
print("📌 Atur toggle dan filter di GUI.")
print("⚠️ Resiko ban tetap ada - gunakan bijak.")
