-- =============================================================================
-- 1. DATABASE DATA (BUAH, GEAR, RARITY, MUTATION, PETS)
-- =============================================================================
local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", 
    "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", 
    "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", 
    "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", 
    "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local GearsList = {
    "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", 
    "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", 
    "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", 
    "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"
}

local RarityList = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"
}

local MutationList = {
    "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"
}

local PetsList = {
    "Bunny", "Frog" , "Owl", "Monkey", "Robin", "Bee", "Bear" ,"Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"
}

-- Global Configurations
_G.TeleportMode = "Tween Teleport"
_G.BaseTweenSpeed = 1.5

-- =============================================================================
-- 2. CUSTOM UI ENGINE (BUATAN SENDIRI - ANTI NOT FOUND)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_CustomUI"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = game:GetService("CoreInterface") end)
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Top Bar (Header)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Speed Hub X | Version 5.1.4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar Container
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.Parent = Sidebar

-- Halaman Container
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -140, 1, -40)
PageContainer.Position = UDim2.new(0, 140, 0, 40)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local pages = {}

local function CreatePage(pageName)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 2200)
    Page.ScrollBarThickness = 4
    Page.Parent = PageContainer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = Page
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.Parent = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TabBtn.Text = pageName
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        Page.Visible = true
    end)
    
    pages[pageName] = Page
    return Page
end

local UI = {}

function UI:AddLabel(page, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 380, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = pages[page]
end

function UI:AddSection(page, text)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 380, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    Frame.BorderSizePixel = 0
    Frame.Parent = pages[page]
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
end

function UI:AddToggle(page, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 380, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Frame.Parent = pages[page]
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 280, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 50, 0, 22)
    TglBtn.Position = UDim2.new(1, -60, 0.5, -11)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 80)
    TglBtn.Text = default and "ON" or "OFF"
    TglBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TglBtn.Font = Enum.Font.SourceSansBold
    TglBtn.TextSize = 12
    TglBtn.Parent = Frame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 4)
    
    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        TglBtn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 80)
        TglBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

function UI:AddDropdown(page, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 380, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Frame.Parent = pages[page]
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local RealBtn = Instance.new("TextBox")
    RealBtn.Size = UDim2.new(0, 170, 0, 25)
    RealBtn.Position = UDim2.new(1, -180, 0.5, -12)
    RealBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    RealBtn.Text = options[1] or "Click to type"
    RealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RealBtn.Font = Enum.Font.SourceSans
    RealBtn.TextSize = 13
    RealBtn.Parent = Frame
    Instance.new("UICorner", RealBtn).CornerRadius = UDim.new(0, 4)
    
    RealBtn.FocusLost:Connect(function()
        callback(RealBtn.Text)
    end)
end

function UI:AddTextBox(page, text, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 380, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Frame.Parent = pages[page]
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 170, 0, 25)
    Box.Position = UDim2.new(1, -180, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 13
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

function UI:AddButton(page, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 380, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 80, 160)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.Parent = pages[page]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
end

-- =============================================================================
-- 3. ALOKASI KONTEN KE STRUKTUR HALAMAN
-- =============================================================================
CreatePage("Home")
CreatePage("Main")
CreatePage("Automatically")
CreatePage("Inventory")
CreatePage("Shop")
CreatePage("Webhook")
CreatePage("Misc")

pages["Home"].Visible = true

-- ISI TAB: HOME
UI:AddLabel("Home", "Welcome to Speed Hub X Custom Engine")
UI:AddSection("Home", "Discord")
UI:AddButton("Home", "Discord Invite", function()
    setclipboard("https://discord.gg/speedhubx")
end)

UI:AddSection("Home", "LocalPlayer")
UI:AddTextBox("Home", "Set Speed", "Write speed number...", function(v)
    local num = tonumber(v)
    if num and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
    end
end)
UI:AddToggle("Home", "Enable Walkspeed", false, function(v) _G.WalkspeedToggle = v end)
UI:AddToggle("Home", "No Clip", false, function(v) _G.NoClipToggle = v end)

-- ISI TAB: MAIN
UI:AddSection("Main", "Teleport Manager")
UI:AddDropdown("Main", "Select Mode", {"Tween Teleport", "Instant Teleport"}, function(v) _G.TeleportMode = v end)
UI:AddTextBox("Main", "Base Tween Speed", "1.5", function(v) _G.BaseTweenSpeed = tonumber(v) or 1.5 end)

UI:AddSection("Main", "Stack Farm Manager")
UI:AddToggle("Main", "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)

UI:AddSection("Main", "Automation Plants")
UI:AddToggle("Main", "Disable Teleport", false, function(v) _G.DisableTeleportPlants = v end)
UI:AddDropdown("Main", "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
UI:AddDropdown("Main", "Select Position", {"Player Position", "Sprinkler Radius"}, function(v) _G.SelectPosition = v end)
UI:AddDropdown("Main", "Select Sprinkler", GearsList, function(v) _G.SelectedSprinkler = v end)
UI:AddToggle("Main", "Auto Plants Seed", false, function(v) _G.AutoPlantsSeed = v end)
UI:AddToggle("Main", "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

UI:AddSection("Main", "Automation Collection")
UI:AddToggle("Main", "Disable Teleport", false, function(v) _G.DisableTeleportCollection = v end)
UI:AddToggle("Main", "Stop Collect If Backpack Full", false, function(v) _G.StopCollectIfFull = v end)
UI:AddDropdown("Main", "Select Fruit Filter", FruitsList, function(v) _G.CollectSelectedFruit = v end)
UI:AddDropdown("Main", "Select Rarity Filter", RarityList, function(v) _G.CollectSelectedRarity = v end)
UI:AddDropdown("Main", "Select Mutation Filter", MutationList, function(v) _G.CollectSelectedMutation = v end)
UI:AddToggle("Main", "Auto Collect Fruit", false, function(v) _G.AutoCollectFruit = v end)
UI:AddToggle("Main", "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)
UI:AddToggle("Main", "Auto Collect Gold Seed", false, function(v) _G.AutoCollectGoldSeed = v end)
UI:AddToggle("Main", "Auto Collect Rainbow Seed", false, function(v) _G.AutoCollectRainbowSeed = v end)
UI:AddToggle("Main", "Auto Collect Mega Seed", false, function(v) _G.AutoCollectMegaSeed = v end)

UI:AddSection("Main", "Automation Steal")
UI:AddDropdown("Main", "Select Steal Fruit", FruitsList, function(v) _G.StealSelectedFruit = v end)
UI:AddToggle("Main", "Auto Steal Fruit", false, function(v) _G.AutoStealFruit = v end)
UI:AddToggle("Main", "Auto Steal Best Fruit", false, function(v) _G.AutoStealBestFruit = v end)
UI:AddToggle("Main", "Auto Lock Garden At Night", false, function(v) _G.AutoLockGarden = v end)

UI:AddSection("Main", "Automation Sell")
UI:AddToggle("Main", "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
UI:AddDropdown("Main", "Select Sell Fruit", FruitsList, function(v) _G.SellSelectedFruit = v end)
UI:AddToggle("Main", "Auto Sell Fruit", false, function(v) _G.AutoSellFruit = v end)
UI:AddDropdown("Main", "Select Sell Pet", PetsList, function(v) _G.SellSelectedPet = v end)
UI:AddToggle("Main", "Auto Sell Pets", false, function(v) _G.AutoSellPets = v end)

UI:AddSection("Main", "Automation Pets")
UI:AddToggle("Main", "Pet Purchase Protection", false, function(v) _G.PetPurchaseProtection = v end)
UI:AddDropdown("Main", "Select Buy Pet", PetsList, function(v) _G.BuySelectedPet = v end)
UI:AddToggle("Main", "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)

-- TAB LAINNYA
UI:AddLabel("Automatically", "Fitur Auto Farm GAG 2 akan ditaruh di sini.")
UI:AddLabel("Inventory", "Fitur Inventory ditaruh di sini.")
UI:AddLabel("Shop", "Fitur Shop ditaruh di sini.")
UI:AddLabel("Webhook", "Fitur Webhook ditaruh di sini.")
UI:AddLabel("Misc", "Fitur Misc ditaruh di sini.")
