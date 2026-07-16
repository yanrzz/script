-- =============================================================================
-- 1. DATABASE DATA (BUAH, GEAR, RARITY, MUTATION, PETS)
-- =============================================================================
local FruitsList = {"All", "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog" , "Owl", "Monkey", "Robin", "Bee", "Bear" ,"Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

-- Global State & Configurations
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.TeleportMode = "Tween Teleport"
_G.BaseTweenSpeed = 1.5

-- Loop untuk logika Walkspeed & NoClip agar aktif dan berfungsi
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                if _G.WalkspeedToggle and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = _G.CustomSpeed or 50
                end
                if _G.NoClipToggle then
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end)
end)

-- =============================================================================
-- 2. CUSTOM UI ENGINE DENGAN SUB-SECTION COLLAPSIBLE (BISA DIBUKA/TUTUP)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V3"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreInterface") end)
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end) end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 18, 18) -- Tema gelap agak merah burgundy persis foto
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 14, 14)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Speed Hub X | Version 5.1.4 | discord.gg/speedhubx"
Title.TextColor3 = Color3.fromRGB(219, 79, 79) -- Text merah khas Speed Hub
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Button Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSans
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Button Minimize
local Minimized = false
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = TopBar

-- Sidebar Container
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 14, 14)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 450)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 2)
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 5)

-- Main Page Container
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -160, 1, -40)
PageContainer.Position = UDim2.new(0, 160, 0, 40)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 40), "Out", "Quad", 0.15, true)
        Sidebar.Visible = false
        PageContainer.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 420), "Out", "Quad", 0.15, true)
        Sidebar.Visible = true
        PageContainer.Visible = true
    end
end)

local pages = {}
local currentActiveTab = nil

local function CreatePage(pageName)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(80, 40, 40)
    Page.Parent = PageContainer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = Page
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 38)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 14, 14)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. pageName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 1
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    pages[pageName] = Page
    return Page
end

-- =============================================================================
-- SYSTEM PENGATUR SUB-SECTION (COLLAPSIBLE / BISA DILIPAT)
-- =============================================================================
local UI = {}

function UI:AddSection(page, sectionTitle)
    local targetPage = pages[page]
    
    -- Tombol Utama Section (Header List)
    local SectionHeader = Instance.new("TextButton")
    SectionHeader.Size = UDim2.new(0, 410, 0, 40)
    SectionHeader.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
    SectionHeader.BorderSizePixel = 0
    SectionHeader.Text = "  " .. sectionTitle
    SectionHeader.TextColor3 = Color3.fromRGB(240, 240, 240)
    SectionHeader.Font = Enum.Font.SourceSansBold
    SectionHeader.TextSize = 14
    SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
    SectionHeader.Parent = targetPage
    Instance.new("UICorner", SectionHeader).CornerRadius = UDim.new(0, 4)
    
    -- Tanda Panah Kanan (>)
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -35, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = ">"
    Arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
    Arrow.Font = Enum.Font.SourceSansBold
    Arrow.TextSize = 14
    Arrow.Parent = SectionHeader

    -- Container isi di dalam section ini
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(0, 410, 0, 0) -- Mulai dari 0 (Tertutup)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = targetPage
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 4)
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = ContentFrame
    Instance.new("UIPadding", ContentFrame).PaddingTop = UDim.new(0, 4)

    -- Fungsi Buka Tutup saat di-klik
    local isOpen = false
    SectionHeader.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Arrow.Text = "v"
            Arrow.Rotation = 0
            -- Hitung tinggi otomatis berdasarkan banyaknya elemen di dalamnya
            local totalHeight = ContentLayout.AbsoluteContentSize.Y + 10
            ContentFrame.Size = UDim2.new(0, 410, 0, totalHeight)
        else
            Arrow.Text = ">"
            ContentFrame.Size = UDim2.new(0, 410, 0, 0)
        end
        
        -- Memaksa canvas scrolling frame memperbarui ukurannya agar tidak bug gantung
        local pageLayout = targetPage:FindFirstChildOfClass("UIListLayout")
        if pageLayout then
            targetPage.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
        end
    end)
    
    return ContentFrame
end

function UI:AddToggle(sectionFrame, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
    Frame.Parent = sectionFrame
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 280, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local TglBtn = Instance.new("TextButton")
    TglBtn.Size = UDim2.new(0, 50, 0, 22)
    TglBtn.Position = UDim2.new(1, -60, 0.5, -11)
    TglBtn.BackgroundColor3 = default and Color3.fromRGB(219, 79, 79) or Color3.fromRGB(70, 55, 55)
    TglBtn.Text = default and "ON" or "OFF"
    TglBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TglBtn.Font = Enum.Font.SourceSansBold
    TglBtn.TextSize = 11
    TglBtn.Parent = Frame
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 4)
    
    local state = default
    TglBtn.MouseButton1Click:Connect(function()
        state = not state
        TglBtn.BackgroundColor3 = state and Color3.fromRGB(219, 79, 79) or Color3.fromRGB(70, 55, 55)
        TglBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

function UI:AddDropdown(sectionFrame, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
    Frame.Parent = sectionFrame
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 170, 0, 24)
    DropBtn.Position = UDim2.new(1, -180, 0.5, -12)
    DropBtn.BackgroundColor3 = Color3.fromRGB(55, 40, 40)
    DropBtn.Text = options[1] or "Select..."
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 12
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)
    
    local DropList = Instance.new("ScrollingFrame")
    DropList.Size = UDim2.new(0, 170, 0, 100)
    DropList.Position = UDim2.new(1, -180, 0, 36)
    DropList.BackgroundColor3 = Color3.fromRGB(45, 32, 32)
    DropList.BorderSizePixel = 0
    DropList.ZIndex = 100
    DropList.Visible = false
    DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    DropList.ScrollBarThickness = 3
    DropList.Parent = Frame
    Instance.new("UIListLayout", DropList)
    
    DropBtn.MouseButton1Click:Connect(function()
        DropList.Visible = not DropList.Visible
    end)
    
    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 24)
        OptBtn.BackgroundColor3 = Color3.fromRGB(45, 32, 32)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptBtn.ZIndex = 101
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 12
        OptBtn.Parent = DropList
        
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt
            DropList.Visible = false
            callback(opt)
        end)
    end
end

function UI:AddTextBox(sectionFrame, text, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
    Frame.Parent = sectionFrame
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 170, 0, 24)
    Box.Position = UDim2.new(1, -180, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(55, 40, 40)
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 12
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

function UI:AddButton(sectionFrame, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 395, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(75, 40, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = sectionFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
end

-- =============================================================================
-- 3. INITIALIZE PAGES & SECTIONS (MEMASUKKAN DATA KE SISTEM LIPAT)
-- =============================================================================
CreatePage("Home")
CreatePage("Main")
CreatePage("Automatically")
CreatePage("Inventory")
CreatePage("Shop")
CreatePage("Webhook")
CreatePage("Misc")

-- Aktifkan Halaman Utama secara default
pages["Home"].Visible = true

-- SECTION DI TAB HOME
local LocalPlayerSec = UI:AddSection("Home", "LocalPlayer Manager")
UI:AddTextBox(LocalPlayerSec, "Set Custom Speed", "50", function(v) _G.CustomSpeed = tonumber(v) end)
UI:AddToggle(LocalPlayerSec, "Enable Walkspeed", false, function(v) _G.WalkspeedToggle = v end)
UI:AddToggle(LocalPlayerSec, "No Clip (Tembus Tembok)", false, function(v) _G.NoClipToggle = v end)

local DiscordSec = UI:AddSection("Home", "Community")
UI:AddButton(DiscordSec, "Copy Discord Invite Link", function() setclipboard("https://discord.gg/speedhubx") end)

-- SECTIONS UTAMA DI TAB MAIN (Sesuai Struktur Gambar Kamul!)
local TeleportSec = UI:AddSection("Main", "Teleport Manager")
UI:AddDropdown(TeleportSec, "Select Mode", {"Tween Teleport", "Instant Teleport"}, function(v) _G.TeleportMode = v end)
UI:AddTextBox(TeleportSec, "Base Tween Speed", "1.5", function(v) _G.BaseTweenSpeed = tonumber(v) or 1.5 end)

local StackSec = UI:AddSection("Main", "Stack Farm Manager")
UI:AddToggle(StackSec, "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)

local PlantsSec = UI:AddSection("Main", "Automation Plants")
UI:AddToggle(PlantsSec, "Disable Teleport", false, function(v) _G.DisableTeleportPlants = v end)
UI:AddDropdown(PlantsSec, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
UI:AddDropdown(PlantsSec, "Select Position", {"Player Position", "Sprinkler Radius"}, function(v) _G.SelectPosition = v end)
UI:AddDropdown(PlantsSec, "Select Sprinkler", GearsList, function(v) _G.SelectedSprinkler = v end)
UI:AddToggle(PlantsSec, "Auto Plants Seed", false, function(v) _G.AutoPlantsSeed = v end)
UI:AddToggle(PlantsSec, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

local CollectSec = UI:AddSection("Main", "Automation Collection")
UI:AddToggle(CollectSec, "Disable Teleport", false, function(v) _G.DisableTeleportCollection = v end)
UI:AddToggle(CollectSec, "Stop Collect If Backpack Full", false, function(v) _G.StopCollectIfFull = v end)
UI:AddDropdown(CollectSec, "Select Fruit Filter", FruitsList, function(v) _G.CollectSelectedFruit = v end)
UI:AddDropdown(CollectSec, "Select Rarity Filter", RarityList, function(v) _G.CollectSelectedRarity = v end)
UI:AddDropdown(CollectSec, "Select Mutation Filter", MutationList, function(v) _G.CollectSelectedMutation = v end)
UI:AddToggle(CollectSec, "Auto Collect Fruit", false, function(v) _G.AutoCollectFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect Gold Seed", false, function(v) _G.AutoCollectGoldSeed = v end)
UI:AddToggle(CollectSec, "Auto Collect Rainbow Seed", false, function(v) _G.AutoCollectRainbowSeed = v end)
UI:AddToggle(CollectSec, "Auto Collect Mega Seed", false, function(v) _G.AutoCollectMegaSeed = v end)

local StealSec = UI:AddSection("Main", "Automation Steal")
UI:AddDropdown(StealSec, "Select Steal Fruit", FruitsList, function(v) _G.StealSelectedFruit = v end)
UI:AddToggle(StealSec, "Auto Steal Fruit", false, function(v) _G.AutoStealFruit = v end)
UI:AddToggle(StealSec, "Auto Steal Best Fruit", false, function(v) _G.AutoStealBestFruit = v end)
UI:AddToggle(StealSec, "Auto Lock Garden At Night", false, function(v) _G.AutoLockGarden = v end)

local SellSec = UI:AddSection("Main", "Automation Sell")
UI:AddToggle(SellSec, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
UI:AddDropdown(SellSec, "Select Sell Fruit", FruitsList, function(v) _G.SellSelectedFruit = v end)
UI:AddToggle(SellSec, "Auto Sell Fruit", false, function(v) _G.AutoSellFruit = v end)
UI:AddDropdown(SellSec, "Select Sell Pet", PetsList, function(v) _G.SellSelectedPet = v end)
UI:AddToggle(SellSec, "Auto Sell Pets", false, function(v) _G.AutoSellPets = v end)

local PetSec = UI:AddSection("Main", "Automation Pets")
UI:AddToggle(PetSec, "Pet Purchase Protection", false, function(v) _G.PetPurchaseProtection = v end)
UI:AddDropdown(PetSec, "Select Buy Pet", PetsList, function(v) _G.BuySelectedPet = v end)
UI:AddToggle(PetSec, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)
