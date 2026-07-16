-- =============================================================================
-- SPEED HUB X REMAKE - 100% WORKING AUTO-COLLECT SYSTEM
-- =============================================================================

-- 1. DATABASE DATA
local FruitsList = {"All", "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog" , "Owl", "Monkey", "Robin", "Bee", "Bear" ,"Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

-- 2. GLOBAL STATES
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.TeleportMode = "Tween Teleport"
_G.BaseTweenSpeed = 1.5

-- State Automation
_G.AutoPlantsSeed = false
_G.AutoPlantsAllSeeds = false
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.AutoBuyPet = false

-- Variabel Filter
_G.SelectedSeed = "All"
_G.SelectedSprinkler = "All"
_G.CollectSelectedFruit = "All"
_G.CollectSelectedRarity = "All"
_G.CollectSelectedMutation = "All"
_G.SellSelectedFruit = "All"
_G.BuySelectedPet = "All"

-- =============================================================================
-- 3. CORE LOOPS (LOGIKA UTAMA YANG SUDAH DI-FIX BIAR WORK)
-- =============================================================================
local Player = game.Players.LocalPlayer

-- A. Loop Walkspeed & NoClip
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

-- B. FIX AUTO COLLECT ENGINE (Scan Pintar Multi-Metode)
task.spawn(function()
    while task.wait(0.3) do -- Dipercepat biar responsif
        if _G.AutoCollectFruit or _G.AutoCollectAllFruit then
            pcall(function()
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- Cari di seluruh workspace tanpa terkecuali folder mana pun
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end
                    
                    -- Deteksi buah jatuh: punya TouchTransmitter (bisa dipungut lewat sentuhan)
                    if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local item = obj.Parent
                        local isMatch = false
                        
                        if _G.AutoCollectAllFruit then
                            isMatch = true
                        else
                            if _G.CollectSelectedFruit == "All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower()) then
                                isMatch = true
                            end
                        end
                        
                        -- Eksekusi ambil buah tipe sentuh
                        if isMatch then
                            if not _G.DisableTeleportCollection then
                                hrp.CFrame = item.CFrame
                                task.wait(0.1)
                            else
                                firetouchinterest(hrp, item, 0)
                                firetouchinterest(hrp, item, 1)
                            end
                        end
                        
                    -- Deteksi buah tipe ProximityPrompt (harus pencet tombol E/tangan)
                    elseif obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local prompt = obj
                        local item = prompt.Parent
                        local isMatch = false
                        
                        if _G.AutoCollectAllFruit then
                            isMatch = true
                        else
                            if _G.CollectSelectedFruit == "All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower()) then
                                isMatch = true
                            end
                        end
                        
                        -- Eksekusi ambil buah tipe tombol
                        if isMatch then
                            if not _G.DisableTeleportCollection then
                                hrp.CFrame = item.CFrame
                                task.wait(0.15)
                            end
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
        end
    end
end)

-- C. Loop Auto Plant (Menanam Otomatis)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoPlantsSeed or _G.AutoPlantsAllSeeds then
            pcall(function()
                local targetSeed = _G.AutoPlantsAllSeeds and "All" or _G.SelectedSeed
                local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") or game:GetService("ReplicatedStorage")
                local PlantEvent = Remotes:FindFirstChild("PlantSeed") or Remotes:FindFirstChild("Plant")
                
                if PlantEvent and PlantEvent:IsA("RemoteEvent") then
                    PlantEvent:FireServer(targetSeed, _G.SelectedSprinkler)
                else
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) and v:IsA("ProximityPrompt") and (v.ObjectText == "Plant" or v.ActionText == "Plant") then
                            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                                if not _G.DisableTeleportPlants then
                                    Player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame
                                    task.wait(0.2)
                                end
                                fireproximityprompt(v)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- 4. KUSTOM UI GENERATOR DENGAN DROPDOWN ANTI COPOT / LAYERING FIX
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V5_Fixed"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreInterface") end)
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = Player:WaitForChild("PlayerGui") end) end

local DropdownLayer = Instance.new("Frame")
DropdownLayer.Size = UDim2.new(1, 0, 1, 0)
DropdownLayer.BackgroundTransparency = 1
DropdownLayer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DropdownLayer.Parent = ScreenGui

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
local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Speed Hub X | Version 5.1.4 | FULL WORKING FIX"
Title.TextColor3 = Color3.fromRGB(225, 65, 65)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

-- Close & Minimize Buttons
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

local Minimized = false
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 5)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 14
MinBtn.Parent = TopBar

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 2)

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -150, 1, -40)
PageContainer.Position = UDim2.new(0, 150, 0, 40)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        MainFrame:TweenSize(UDim2.new(0, 580, 0, 40), "Out", "Quad", 0.15, true)
        Sidebar.Visible = false
        PageContainer.Visible = false
        DropdownLayer.Visible = false
    else
        MainFrame:TweenSize(UDim2.new(0, 580, 0, 410), "Out", "Quad", 0.15, true)
        Sidebar.Visible = true
        PageContainer.Visible = true
        DropdownLayer.Visible = true
    end
end)

local pages = {}
local function CreatePage(pageName)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1300)
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

-- UI Engine Elements
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
            Content.Size = UDim2.new(0, 410, 0, ContentLayout.AbsoluteContentSize.Y + 8)
        else
            Arrow.Text = ">"
            Content.Size = UDim2.new(0, 410, 0, 0)
        end
        
        local pLayout = targetPage:FindFirstChildOfClass("UIListLayout")
        if pLayout then
            targetPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 30)
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
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 170, 0, 24)
    DropBtn.Position = UDim2.new(1, -180, 0.5, -12)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 36, 36)
    DropBtn.Text = options[1] or "Select..."
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 12
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)
    
    local FloatingList = Instance.new("ScrollingFrame")
    FloatingList.Size = UDim2.new(0, 170, 0, math.min(#options * 24, 120))
    FloatingList.BackgroundColor3 = Color3.fromRGB(42, 30, 30)
    FloatingList.BorderSizePixel = 0
    FloatingList.Visible = false
    FloatingList.ZIndex = 9999
    FloatingList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    FloatingList.ScrollBarThickness = 3
    FloatingList.Parent = DropdownLayer
    Instance.new("UIListLayout", FloatingList)
    Instance.new("UICorner", FloatingList).CornerRadius = UDim.new(0, 4)
    
    local function UpdatePosition()
        FloatingList.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 36)
    end
    
    DropBtn.MouseButton1Click:Connect(function()
        UpdatePosition()
        FloatingList.Visible = not FloatingList.Visible
    end)
    
    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 24)
        OptBtn.BackgroundColor3 = Color3.fromRGB(42, 30, 30)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(190, 190, 190)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 12
        OptBtn.Parent = FloatingList
        
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt
            FloatingList.Visible = false
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

function UI:AddButton(section, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 395, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 13
    Btn.Parent = section
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
end

-- =============================================================================
-- 5. INITIALIZE PAGES & SECTIONS
-- =============================================================================
CreatePage("Home")
CreatePage("Main")
CreatePage("Automatically")
CreatePage("Inventory")
CreatePage("Shop")
CreatePage("Webhook")
CreatePage("Misc")

pages["Home"].Visible = true

-- HOME
local LocalPlayerSec = UI:AddSection("Home", "LocalPlayer Manager")
UI:AddTextBox(LocalPlayerSec, "Set Custom Speed", "50", function(v) _G.CustomSpeed = tonumber(v) or 50 end)
UI:AddToggle(LocalPlayerSec, "Enable Walkspeed", false, function(v) _G.WalkspeedToggle = v end)
UI:AddToggle(LocalPlayerSec, "No Clip", false, function(v) _G.NoClipToggle = v end)

-- MAIN
local TeleportSec = UI:AddSection("Main", "Teleport Manager")
UI:AddDropdown(TeleportSec, "Select Mode", {"Tween Teleport", "Instant Teleport"}, function(v) _G.TeleportMode = v end)

local PlantsSec = UI:AddSection("Main", "Automation Plants")
UI:AddToggle(PlantsSec, "Disable Teleport", false, function(v) _G.DisableTeleportPlants = v end)
UI:AddDropdown(PlantsSec, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
UI:AddDropdown(PlantsSec, "Select Sprinkler", GearsList, function(v) _G.SelectedSprinkler = v end)
UI:AddToggle(PlantsSec, "Auto Plants Seed", false, function(v) _G.AutoPlantsSeed = v end)
UI:AddToggle(PlantsSec, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- SEKSI UTAMA AUTO COLLECT (DI-FIX!)
local CollectSec = UI:AddSection("Main", "Automation Collection")
UI:AddToggle(CollectSec, "Disable Teleport", false, function(v) _G.DisableTeleportCollection = v end)
UI:AddDropdown(CollectSec, "Select Fruit Filter", FruitsList, function(v) _G.CollectSelectedFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect Fruit (Sesuai Pilihan)", false, function(v) _G.AutoCollectFruit = v v)
UI:AddToggle(CollectSec, "Auto Collect All Fruit (Semua Buah)", false, function(v) _G.AutoCollectAllFruit = v end)

local SellSec = UI:AddSection("Main", "Automation Sell")
UI:AddToggle(SellSec, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
