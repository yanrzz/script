-- =============================================================================
-- SPEED HUB X REMAKE - STRICT SILENT FRUIT-ONLY (ANTI POHON EDITION)
-- =============================================================================

-- 1. DATABASE DATA COMPLETE
local FruitsList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog" , "Owl", "Monkey", "Robin", "Bee", "Bear" ,"Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

-- 2. GLOBAL STATES
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.TeleportMode = "Tween Teleport"

-- State Automation
_G.AutoPlantsSeed = false
_G.AutoPlantsAllSeeds = false
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.AutoBuyPet = false
_G.SilentModeGlobal = true 

-- Variabel Filter
_G.SelectedSeed = "Carrot"
_G.SelectedSprinkler = "All"
_G.CollectSelectedFruit = "All"
_G.SellSelectedFruit = "All"
_G.BuySelectedPet = "All"

-- Webhook Settings
_G.WebhookURL = ""
_G.WebhookToggle = false

-- Helper function super ketat: Hanya deteksi buah asli, abaikan pohon/kotak surat/daun
local function isRealFruitOnly(item)
    if not item or not item:IsA("BasePart") then return false end
    
    local name = item.Name:lower()
    
    -- Blacklist objek besar pengganggu (Pohon, Kotak surat, pot, dll)
    if string.find(name, "tree") or string.find(name, "pohon") or string.find(name, "trunk") or 
       string.find(name, "leaf") or string.find(name, "stem") or string.find(name, "box") or 
       string.find(name, "mail") or string.find(name, "pot") or string.find(name, "plot") then
        return false
    end
    
    -- Validasi ukuran (Buah asli harusnya kecil, pohon itu besar)
    if item.Size.Y > 7 or item.Size.X > 7 then
        return false
    end
    
    -- Cek kecocokan nama dengan daftar buah resmi
    for _, fruit in pairs(FruitsList) do
        if string.find(name, fruit:lower()) then
            return true
        end
    end
    
    if string.find(name, "fruit") or string.find(name, "seed") or string.find(name, "harvest") then
        return true
    end
    
    return false
end

-- =============================================================================
-- 3. CORE LOGIC ENGINE (ALL WORKING LOOPS - SILENT FUNCTIONALITY)
-- =============================================================================
local Player = game.Players.LocalPlayer

-- Loop Walkspeed & NoClip
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            local character = Player.Character
            if character then
                if _G.WalkspeedToggle and character:FindFirstChild("Humanoid") then
                    character.Humanoid.WalkSpeed = _G.CustomSpeed
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

-- Loop Auto Collect & Auto Harvest (Silent Mode - Buah Only)
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoCollectFruit or _G.AutoCollectAllFruit then
            pcall(function()
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end
                    
                    if obj:IsA("TouchTransmitter") and obj.Parent then
                        local item = obj.Parent
                        if isRealFruitOnly(item) then
                            local isMatch = _G.AutoCollectAllFruit or (_G.CollectSelectedFruit == "All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower()))
                            
                            if isMatch then
                                if _G.SilentModeGlobal then
                                    firetouchinterest(hrp, item, 0)
                                    task.wait()
                                    firetouchinterest(hrp, item, 1)
                                else
                                    hrp.CFrame = item.CFrame
                                    task.wait(0.1)
                                end
                            end
                        end
                    elseif obj:IsA("ProximityPrompt") and obj.Parent then
                        local prompt = obj
                        local item = prompt.Parent
                        local promptText = (prompt.ObjectText .. prompt.ActionText):lower()
                        
                        -- Pastikan bukan prompt nebang pohon atau interaksi kotak surat
                        if not string.find(promptText, "chop") and not string.find(promptText, "cut") and not string.find(promptText, "pohon") then
                            if isRealFruitOnly(item) or string.find(promptText, "harvest") or string.find(promptText, "pick") then
                                local isMatch = _G.AutoCollectAllFruit or (_G.CollectSelectedFruit == "All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower()))
                                
                                if isMatch then
                                    if _G.SilentModeGlobal then
                                        fireproximityprompt(prompt)
                                    else
                                        hrp.CFrame = item.CFrame
                                        task.wait(0.15)
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop Auto Plants (Tanam Benih Otomatis)
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoPlantsSeed or _G.AutoPlantsAllSeeds then
            pcall(function()
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then break end

                    if obj:IsA("ProximityPrompt") and (string.find(obj.ObjectText:lower(), "pot") or string.find(obj.ActionText:lower(), "plant") or string.find(obj.ObjectText:lower(), "soil")) then
                        if _G.SilentModeGlobal then
                            fireproximityprompt(obj)
                        else
                            hrp.CFrame = obj.Parent.CFrame
                            task.wait(0.2)
                            fireproximityprompt(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop Auto Sell (Jual Buah)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoSellAll or _G.AutoSellFruit then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and (string.find(obj.ObjectText:lower(), "merchant") or string.find(obj.ActionText:lower(), "sell") or string.find(obj.ObjectText:lower(), "shop")) then
                        fireproximityprompt(obj) 
                    end
                end
            end)
        end
    end
end)

-- Loop Auto Buy Pet
task.spawn(function()
    while task.wait(1.5) do
        if _G.AutoBuyPet then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and string.find(obj.ObjectText:lower(), "egg") then
                        fireproximityprompt(obj)
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- 4. ALL-IN-ONE MASTER UI GENERATOR (100% CLEAN STABLE)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V11_NoTreeBug"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreInterface") end)
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = Player:WaitForChild("PlayerGui") end) end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 410)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -205)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Speed Hub X | V5.1.4 COMPLETE (ANTI-POHON BUG)"
Title.TextColor3 = Color3.fromRGB(225, 65, 65)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 450)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 2)

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -150, 1, -40)
PageContainer.Position = UDim2.new(0, 150, 0, 40)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local pages = {}
local function CreatePage(pageName)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1500)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(70, 35, 35)
    Page.Parent = PageContainer
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.Parent = Page
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 36)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "   " .. pageName
    TabBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 1
                btn.TextColor3 = Color3.fromRGB(170, 170, 170)
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

local UI = {}

function UI:AddSection(page, sectionTitle)
    local targetPage = pages[page]
    
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(0, 410, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(32, 24, 24)
    Header.BorderSizePixel = 0
    Header.Text = "  " .. sectionTitle
    Header.TextColor3 = Color3.fromRGB(230, 230, 230)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 13
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = targetPage
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 4)
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -35, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = ">"
    Arrow.TextColor3 = Color3.fromRGB(160, 160, 160)
    Arrow.Font = Enum.Font.SourceSansBold
    Arrow.TextSize = 13
    Arrow.Parent = Header

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(0, 410, 0, 0)
    Content.BackgroundColor3 = Color3.fromRGB(26, 18, 18)
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = targetPage
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 4)
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = Content
    Instance.new("UIPadding", Content).PaddingTop = UDim.new(0, 4)

    local isOpen = false
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Arrow.Text = "v"
            Content.Size = UDim2.new(0, 410, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        else
            Arrow.Text = ">"
            Content.Size = UDim2.new(0, 410, 0, 0)
        end
        
        local pLayout = targetPage:FindFirstChildOfClass("UIListLayout")
        if pLayout then
            targetPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 40)
        end
    end)
    
    return Content
end

function UI:AddToggle(section, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(36, 26, 26)
    Frame.Parent = section
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 280, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 22)
    Btn.Position = UDim2.new(1, -60, 0.5, -11)
    Btn.BackgroundColor3 = default and Color3.fromRGB(225, 65, 65) or Color3.fromRGB(65, 50, 50)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 11
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(225, 65, 65) or Color3.fromRGB(65, 50, 50)
        Btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

function UI:AddDropdown(section, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(36, 26, 26)
    Frame.ClipsDescendants = true
    Frame.Parent = section
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 0, 36)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 170, 0, 24)
    DropBtn.Position = UDim2.new(1, -180, 0, 6)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 36, 36)
    DropBtn.Text = options[1] or "Select..."
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 12
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)
    
    local ListContainer = Instance.new("ScrollingFrame")
    ListContainer.Size = UDim2.new(0, 375, 0, 100)
    ListContainer.Position = UDim2.new(0, 10, 0, 42)
    ListContainer.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
    ListContainer.BorderSizePixel = 0
    ListContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    ListContainer.ScrollBarThickness = 3
    ListContainer.Parent = Frame
    local ListLayout = Instance.new("UIListLayout", ListContainer)
    ListLayout.Padding = UDim.new(0, 2)
    
    local isDropped = false
    DropBtn.MouseButton1Click:Connect(function()
        isDropped = not isDropped
        if isDropped then
            Frame.Size = UDim2.new(0, 395, 0, 150)
        else
            Frame.Size = UDim2.new(0, 395, 0, 36)
        end
        
        local layout = section:FindFirstChildOfClass("UIListLayout")
        if layout then
            section.Size = UDim2.new(0, 410, 0, layout.AbsoluteContentSize.Y + 10)
        end
    end)
    
    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 22)
        OptBtn.BackgroundColor3 = Color3.fromRGB(34, 24, 24)
        OptBtn.BorderSizePixel = 0
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 12
        OptBtn.Parent = ListContainer
        
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt
            isDropped = false
            Frame.Size = UDim2.new(0, 395, 0, 36)
            
            local layout = section:FindFirstChildOfClass("UIListLayout")
            if layout then
                section.Size = UDim2.new(0, 410, 0, layout.AbsoluteContentSize.Y + 10)
            end
            callback(opt)
        end)
    end
end

function UI:AddTextBox(section, text, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(36, 26, 26)
    Frame.Parent = section
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 170, 0, 24)
    Box.Position = UDim2.new(1, -180, 0.5, -12)
    Box.BackgroundColor3 = Color3.fromRGB(50, 36, 36)
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 12
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

-- =============================================================================
-- 5. INITIALIZE ALL TABS & COMPLETE REGISTER FEATURES
-- =============================================================================
CreatePage("Home")
CreatePage("Main")
CreatePage("Automatically")
CreatePage("Inventory")
CreatePage("Shop")
CreatePage("Webhook")
CreatePage("Misc")

pages["Home"].Visible = true

-- --- TAB: HOME ---
local LocalPlayerSec = UI:AddSection("Home", "LocalPlayer Manager")
UI:AddTextBox(LocalPlayerSec, "Set Custom Speed", "50", function(v) _G.CustomSpeed = tonumber(v) or 50 end)
UI:AddToggle(LocalPlayerSec, "Enable Walkspeed", false, function(v) _G.WalkspeedToggle = v end)
UI:AddToggle(LocalPlayerSec, "No Clip", false, function(v) _G.NoClipToggle = v end)

local ConfigSec = UI:AddSection("Home", "Engine Mode Control")
UI:AddToggle(ConfigSec, "Silent Global Engine (Diem di Tempat)", true, function(v) _G.SilentModeGlobal = v end)

-- --- TAB: MAIN ---
local TeleportSec = UI:AddSection("Main", "Teleport Manager")
UI:AddDropdown(TeleportSec, "Select Mode", {"Tween Teleport", "Instant Teleport"}, function(v) _G.TeleportMode = v end)

local PlantsSec = UI:AddSection("Main", "Automation Plants")
UI:AddDropdown(PlantsSec, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
UI:AddDropdown(PlantsSec, "Select Sprinkler", GearsList, function(v) _G.SelectedSprinkler = v end)
UI:AddToggle(PlantsSec, "Auto Plants Selected Seed", false, function(v) _G.AutoPlantsSeed = v end)
UI:AddToggle(PlantsSec, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

local CollectSec = UI:AddSection("Main", "Automation Collection")
local listFilter = {"All"} for _, f in pairs(FruitsList) do table.insert(listFilter, f) end
UI:AddDropdown(CollectSec, "Select Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect Fruit Filter", false, function(v) _G.AutoCollectFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

-- --- TAB: AUTOMATICALLY ---
local AutoMainSec = UI:AddSection("Automatically", "Farm Automation Extended")
UI:AddToggle(AutoMainSec, "Auto Sell All Harvest", false, function(v) _G.AutoSellAll = v end)
UI:AddDropdown(AutoMainSec, "Select Fruit to Sell", listFilter, function(v) _G.SellSelectedFruit = v end)
UI:AddToggle(AutoMainSec, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)

-- --- TAB: SHOP ---
local ShopSec = UI:AddSection("Shop", "Pet Shop Automation")
UI:AddDropdown(ShopSec, "Select Pet Egg Type", PetsList, function(v) _G.BuySelectedPet = v end)
UI:AddToggle(ShopSec, "Auto Gacha / Buy Pet Egg", false, function(v) _G.AutoBuyPet = v end)

-- --- TAB: WEBHOOK ---
local WebhookSec = UI:AddSection("Webhook", "Discord Logging Notification")
UI:AddTextBox(WebhookSec, "Paste Webhook URL Here", "https://discord.com/api/webhooks/...", function(v) _G.WebhookURL = v end)
UI:AddToggle(WebhookSec, "Enable Webhook Logging", false, function(v) _G.WebhookToggle = v end)
