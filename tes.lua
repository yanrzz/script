-- =============================================================================
-- SPEED HUB X REMAKE - STRICT SILENT FRUIT-ONLY (ANTI POHON EDITION) v5.2.1
-- =============================================================================

-- 1. DATABASE DATA COMPLETE
local FruitsList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

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

-- =============================================================================
-- 3. PLAYER SETUP
-- =============================================================================
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- =============================================================================
-- 4. IMPROVED FRUIT DETECTION (ANTI-POHON SUPER KETAT)
-- =============================================================================
local function isRealFruitOnly(item)
    if not item or not item:IsA("BasePart") then return false end
    
    local name = item.Name:lower()
    local size = item.Size
    local parentName = item.Parent and item.Parent.Name:lower() or ""
    
    -- Blacklist ketat - kata kunci objek yang pasti bukan buah
    local blacklistKeywords = {
        "tree", "pohon", "trunk", "leaf", "leaves", "stem", "branch", "wood", "log", 
        "mail", "box", "pot", "plot", "soil", "ground", "terrain", "wall", "rimbun",
        "floor", "roof", "door", "window", "fence", "gate", "sign", "board", "kayu", "batang"
    }
    
    for _, keyword in pairs(blacklistKeywords) do
        if string.find(name, keyword) or string.find(parentName, keyword) then
            return false
        end
    end
    
    -- Validasi Ukuran: Buah asli di Roblox sangat jarang berukuran besar.
    -- Kita cek total volumenya (lebar x tinggi x panjang). Jika lebih dari 30 stud kubik, dipastikan itu pohon/daun.
    local volume = size.X * size.Y * size.Z
    if volume > 30 or size.X > 3.5 or size.Y > 3.5 or size.Z > 3.5 then
        return false
    end
    
    -- Cek kecocokan nama dengan daftar buah resmi
    for _, fruit in pairs(FruitsList) do
        if string.find(name, fruit:lower()) then
            return true
        end
    end
    
    -- Fallback detection untuk objek buah generik
    if string.find(name, "fruit") or string.find(name, "berry") or 
       string.find(name, "apple") or string.find(name, "melon") or
       string.find(name, "pear") or string.find(name, "peach") or
       string.find(name, "harvest") then
        return true
    end
    
    return false
end

-- =============================================================================
-- 5. CORE LOGIC ENGINE (IMPROVED LOOPS)
-- =============================================================================

-- 5.1 Walkspeed & NoClip Loop
task.spawn(function()
    local heartbeat = RunService.Heartbeat
    heartbeat:Connect(function()
        pcall(function()
            local character = Player.Character
            if not character then return end
            
            if _G.WalkspeedToggle then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = _G.CustomSpeed
                end
            end
            
            if _G.NoClipToggle then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

-- 5.2 Auto Collect & Harvest (IMPROVED - Hanya Buah)
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then 
            task.wait(0.5)
            continue 
        end
        
        pcall(function()
            local char = Player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local collectedFruits = {}
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end
                
                -- Cek TouchTransmitter (untuk pickup berbasis touch)
                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if isRealFruitOnly(item) then
                        local fruitName = item.Name
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())
                        
                        if isMatch and not collectedFruits[item] then
                            collectedFruits[item] = true
                            
                            if _G.SilentModeGlobal then
                                firetouchinterest(hrp, item, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, item, 1)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, item, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, item, 1)
                            end
                        end
                    end
                end
                
                -- Cek ProximityPrompt (untuk harvest/interact)
                if obj:IsA("ProximityPrompt") then
                    local prompt = obj
                    local item = prompt.Parent
                    
                    local promptText = (prompt.ObjectText or "") .. (prompt.ActionText or "")
                    promptText = promptText:lower()
                    
                    -- Skip total kalau prompt berurusan dengan penebangan/pohon
                    if string.find(promptText, "chop") or 
                       string.find(promptText, "cut") or 
                       string.find(promptText, "tree") or
                       string.find(promptText, "pohon") or
                       string.find(promptText, "wood") then
                        continue
                    end
                    
                    if isRealFruitOnly(item) or 
                       string.find(promptText, "harvest") or 
                       string.find(promptText, "pick") or
                       string.find(promptText, "collect") then
                        
                        local itemName = item and item.Name or ""
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(itemName:lower(), _G.CollectSelectedFruit:lower())
                        
                        if isMatch and prompt.Enabled then
                            if _G.SilentModeGlobal then
                                fireproximityprompt(prompt)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0, 1, 0)
                                task.wait(0.1)
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 5.3 Auto Plants Seed (IMPROVED)
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then 
            task.wait(0.5)
            continue 
        end
        
        pcall(function()
            local char = Player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then break end
                
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()
                    
                    if string.find(promptText, "plant") or 
                       string.find(promptText, "seed") or
                       string.find(promptText, "pot") or
                       string.find(promptText, "soil") or
                       string.find(promptText, "garden") then
                        
                        if _G.SilentModeGlobal then
                            fireproximityprompt(obj)
                        else
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                hrp.CFrame = parent.CFrame + Vector3.new(0, 1, 0)
                                task.wait(0.1)
                                fireproximityprompt(obj)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 5.4 Auto Sell (IMPROVED)
task.spawn(function()
    while task.wait(1) do
        if not (_G.AutoSellAll or _G.AutoSellFruit) then 
            task.wait(0.5)
            continue 
        end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()
                    
                    if string.find(promptText, "merchant") or 
                       string.find(promptText, "sell") or 
                       string.find(promptText, "shop") or
                       string.find(promptText, "trade") then
                        
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- 5.5 Auto Buy Pet (IMPROVED)
task.spawn(function()
    while task.wait(1.5) do
        if not _G.AutoBuyPet then 
            task.wait(0.5)
            continue 
        end
        
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()
                    
                    if string.find(promptText, "egg") or 
                       string.find(promptText, "pet") or 
                       string.find(promptText, "gacha") or
                       string.find(promptText, "hatch") then
                        
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- =============================================================================
-- 6. UI GENERATOR (IMPROVED)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V5.2.1"
ScreenGui.ResetOnSpawn = false

local guiParent = nil
if game:GetService("CoreGui") then
    guiParent = game:GetService("CoreGui")
elseif Player:FindFirstChild("PlayerGui") then
    guiParent = Player.PlayerGui
else
    guiParent = Player:WaitForChild("PlayerGui")
end
pcall(function() ScreenGui.Parent = guiParent end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 420)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.Position = UDim2.new(0, 3, 0, 3)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = MainFrame
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 8)

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
Title.Text = "Speed Hub X | v5.2.1 FIXED"
Title.TextColor3 = Color3.fromRGB(225, 65, 65)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 150, 1, 0)
StatusLabel.Position = UDim2.new(1, -160, 0, 0)
StatusLabel.Text = "● ONLINE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16
MinBtn.Parent = TopBar
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 500)
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
    Page.CanvasSize = UDim2.new(0, 0, 0, 1200)
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
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Position = UDim2.new(0, 5, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "•"
    Icon.TextColor3 = Color3.fromRGB(225, 65, 65)
    Icon.TextSize = 18
    Icon.Visible = false
    Icon.Parent = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundTransparency = 1
                btn.TextColor3 = Color3.fromRGB(170, 170, 170)
                local icon = btn:FindFirstChild("TextLabel")
                if icon then icon.Visible = false end
            end
        end
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Icon.Visible = true
    end)
    
    pages[pageName] = Page
    return Page
end

local UI = {}

function UI:AddSection(page, sectionTitle)
    local targetPage = pages[page]
    if not targetPage then return end
    
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
    Arrow.Text = "▶"
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

    local isOpen = true
    
    local function toggleContent()
        isOpen = not isOpen
        if isOpen then
            Arrow.Text = "▼"
            Content.Size = UDim2.new(0, 410, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        else
            Arrow.Text = "▶"
            Content.Size = UDim2.new(0, 410, 0, 0)
        end
        
        local pLayout = targetPage:FindFirstChildOfClass("UIListLayout")
        if pLayout then
            targetPage.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 40)
        end
    end
    
    Header.MouseButton1Click:Connect(toggleContent)
    task.wait(0.05)
    toggleContent()
    
    return Content
end

function UI:AddToggle(section, text, default, callback)
    if not section then return end
    
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
        if callback then callback(state) end
    end)
end

function UI:AddDropdown(section, text, options, callback)
    if not section then return end
    
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
    ListContainer.Visible = false
    ListContainer.Parent = Frame
    local ListLayout = Instance.new("UIListLayout", ListContainer)
    ListLayout.Padding = UDim.new(0, 2)
    
    local isDropped = false
    DropBtn.MouseButton1Click:Connect(function()
        isDropped = not isDropped
        ListContainer.Visible = isDropped
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
            ListContainer.Visible = false
            Frame.Size = UDim2.new(0, 395, 0, 36)
            
            local layout = section:FindFirstChildOfClass("UIListLayout")
            if layout then
                section.Size = UDim2.new(0, 410, 0, layout.AbsoluteContentSize.Y + 10)
            end
            if callback then callback(opt) end
        end)
    end
end

function UI:AddTextBox(section, text, placeholder, callback)
    if not section then return end
    
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
    Box.PlaceholderText = placeholder or ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 12
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    
    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(Box.Text)
        end
    end)
end

-- =============================================================================
-- 7. INITIALIZE ALL TABS & REGISTER FEATURES
-- =============================================================================
CreatePage("Home")
CreatePage("Main")
CreatePage("Automatically")
CreatePage("Shop")
CreatePage("Misc")

-- Set default page
pages["Home"].Visible = true
for _, btn in pairs(Sidebar:GetChildren()) do
    if btn:IsA("TextButton") and btn.Text:find("Home") then
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        local icon = btn:FindFirstChild("TextLabel")
        if icon then icon.Visible = true end
    end
end

-- --- TAB: HOME ---
local PlayerSec = UI:AddSection("Home", "⛏️ Local Player Manager")
UI:AddTextBox(PlayerSec, "Custom Speed", "50", function(v) _G.CustomSpeed = tonumber(v) or 50 end)
UI:AddToggle(PlayerSec, "Enable Walkspeed", false, function(v) _G.WalkspeedToggle = v end)
UI:AddToggle(PlayerSec, "No Clip", false, function(v) _G.NoClipToggle = v end)

local ConfigSec = UI:AddSection("Home", "⚙️ Engine Mode")
UI:AddToggle(ConfigSec, "Silent Mode (Diem di Tempat)", true, function(v) _G.SilentModeGlobal = v end)

-- --- TAB: MAIN ---
local PlantsSec = UI:AddSection("Main", "🌱 Auto Plants")
UI:AddDropdown(PlantsSec, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
UI:AddDropdown(PlantsSec, "Select Sprinkler", GearsList, function(v) _G.SelectedSprinkler = v end)
UI:AddToggle(PlantsSec, "Auto Plants Selected Seed", false, function(v) _G.AutoPlantsSeed = v v end)
UI:AddToggle(PlantsSec, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

local CollectSec = UI:AddSection("Main", "🍓 Auto Collect")
local listFilter = {"All"}
for _, f in pairs(FruitsList) do table.insert(listFilter, f) end

-- FIX: Menutup string dan parameter dropdown yang terputus di Line 482
UI:AddDropdown(CollectSec, "Select Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect Fruit Filter", false, function(v) _G.AutoCollectFruit = v end)
UI:AddToggle(CollectSec, "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)
