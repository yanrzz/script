-- =============================================================================
-- SPEED HUB X REMAKE - ULTRA STRICT FRUIT DETECTION v6.0
-- =============================================================================

-- 1. DATABASE DATA COMPLETE
local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", 
    "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", 
    "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", 
    "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", 
    "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", 
    "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

-- 2. GLOBAL STATES
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50

_G.AutoPlantsSeed = false
_G.AutoPlantsAllSeeds = false
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.AutoBuyPet = false
_G.SilentModeGlobal = true 

_G.SelectedSeed = "Carrot"
_G.CollectSelectedFruit = "All"
_G.SellSelectedFruit = "All"
_G.BuySelectedPet = "All"

-- =============================================================================
-- 3. ULTRA STRICT FRUIT DETECTION - ANTI POHON 100%
-- =============================================================================
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Daftar hitam SUPER KETAT
local BLACKLIST_NAMES = {
    "tree", "pohon", "trunk", "branch", "leaf", "stem", "wood", "log", "bark",
    "mail", "box", "pot", "plot", "soil", "dirt", "ground", "terrain", 
    "wall", "floor", "roof", "door", "window", "fence", "gate", "sign", 
    "board", "plank", "wooden", "oak", "pine", "maple", "birch", "spruce",
    "bush", "shrub", "grass", "weed", "flower", "tulip", "rose", "daisy"
}

-- Daftar putih yang pasti buah (case sensitive)
local WHITELIST_PATTERNS = {
    "fruit", "berry", "apple", "mango", "melon", "pear", "peach", "grape",
    "banana", "orange", "lemon", "lime", "coconut", "pineapple", "carrot",
    "tomato", "corn", "mushroom", "bean", "nut", "acorn", "cherry", "cactus",
    "sunflower", "pomegranate", "dragon", "venus", "bloom", "breath", "star"
}

local function isRealFruitOnly(item)
    if not item then return false end
    
    -- Cek apakah item adalah BasePart
    if not item:IsA("BasePart") then 
        -- Cek apakah parentnya BasePart
        if item.Parent and item.Parent:IsA("BasePart") then
            item = item.Parent
        else
            return false
        end
    end
    
    local name = item.Name:lower()
    local size = item.Size
    local parentName = item.Parent and item.Parent.Name:lower() or ""
    local className = item.ClassName:lower()
    
    -- ===== LEVEL 1: BLACKLIST KETAT =====
    -- Cek nama item
    for _, black in pairs(BLACKLIST_NAMES) do
        if string.find(name, black) or string.find(parentName, black) then
            return false
        end
    end
    
    -- ===== LEVEL 2: UKURAN (Buah kecil, pohon besar) =====
    -- Buah normal size: max 5 studs
    if size.X > 5 or size.Y > 5 or size.Z > 5 then
        return false
    end
    
    -- ===== LEVEL 3: MATERIAL (Pohon biasanya terbuat dari kayu) =====
    local material = item.Material
    if material == Enum.Material.Wood or material == Enum.Material.WoodPlanks or 
       material == Enum.Material.Grass or material == Enum.Material.Sandstone then
        return false
    end
    
    -- ===== LEVEL 4: Cek nama lengkap dari parent chain =====
    local fullPath = ""
    local current = item
    for i = 1, 5 do
        if current then
            fullPath = fullPath .. (current.Name or "") .. "."
            current = current.Parent
        end
    end
    fullPath = fullPath:lower()
    
    for _, black in pairs(BLACKLIST_NAMES) do
        if string.find(fullPath, black) then
            return false
        end
    end
    
    -- ===== LEVEL 5: WHITELIST - Cek kecocokan dengan daftar buah =====
    -- Cek exact match dengan FruitsList
    for _, fruit in pairs(FruitsList) do
        if string.find(name, fruit:lower()) then
            return true
        end
    end
    
    -- Cek dengan whitelist patterns
    for _, pattern in pairs(WHITELIST_PATTERNS) do
        if string.find(name, pattern) then
            return true
        end
    end
    
    -- ===== LEVEL 6: FALLBACK - Cek ada kata "fruit" di nama =====
    if string.find(name, "fruit") or string.find(name, "berry") or 
       string.find(name, "harvest") or string.find(name, "pick") then
        return true
    end
    
    return false
end

-- =============================================================================
-- 4. CORE LOGIC ENGINE - IMPROVED
-- =============================================================================

-- 4.1 Walkspeed & NoClip
task.spawn(function()
    RunService.Heartbeat:Connect(function()
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

-- 4.2 AUTO COLLECT - ULTRA SELECTIVE (HANYA BUAH ASLI)
task.spawn(function()
    while task.wait(0.15) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then 
            task.wait(0.5)
            continue 
        end
        
        pcall(function()
            local char = Player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- Kumpulkan semua objek yang valid
            local validTargets = {}
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end
                
                -- SKIP SEMUA yang berhubungan dengan pohon
                local objName = (obj.Name or ""):lower()
                local parentName = (obj.Parent and obj.Parent.Name or ""):lower()
                
                -- Skip cepat untuk objek pohon
                local skipKeywords = {"tree", "pohon", "trunk", "branch", "leaf", "stem", "wood", "log"}
                local shouldSkip = false
                for _, keyword in pairs(skipKeywords) do
                    if string.find(objName, keyword) or string.find(parentName, keyword) then
                        shouldSkip = true
                        break
                    end
                end
                if shouldSkip then continue end
                
                -- PROSES TOUCH TRANSMITTER
                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if item and isRealFruitOnly(item) then
                        local fruitName = item.Name
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())
                        
                        if isMatch then
                            table.insert(validTargets, {type = "touch", item = item})
                        end
                    end
                end
                
                -- PROSES PROXIMITY PROMPT
                if obj:IsA("ProximityPrompt") then
                    local prompt = obj
                    local item = prompt.Parent
                    
                    -- Skip prompt yang berhubungan dengan pohon
                    local promptText = (prompt.ObjectText or "") .. (prompt.ActionText or "")
                    promptText = promptText:lower()
                    
                    local promptSkip = {"chop", "cut", "tree", "pohon", "wood", "log", "branch"}
                    local isTreePrompt = false
                    for _, keyword in pairs(promptSkip) do
                        if string.find(promptText, keyword) then
                            isTreePrompt = true
                            break
                        end
                    end
                    if isTreePrompt then continue end
                    
                    -- Cek apakah prompt untuk harvest buah
                    if item and isRealFruitOnly(item) then
                        local fruitName = item.Name
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())
                        
                        if isMatch and prompt.Enabled then
                            table.insert(validTargets, {type = "prompt", prompt = prompt, item = item})
                        end
                    end
                end
            end
            
            -- Proses semua target yang valid
            for _, target in pairs(validTargets) do
                if target.type == "touch" then
                    if _G.SilentModeGlobal then
                        firetouchinterest(hrp, target.item, 0)
                        task.wait(0.02)
                        firetouchinterest(hrp, target.item, 1)
                        task.wait(0.02)
                    else
                        hrp.CFrame = target.item.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, target.item, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, target.item, 1)
                    end
                elseif target.type == "prompt" then
                    if _G.SilentModeGlobal then
                        fireproximityprompt(target.prompt)
                        task.wait(0.05)
                    else
                        hrp.CFrame = target.item.CFrame + Vector3.new(0, 1, 0)
                        task.wait(0.1)
                        fireproximityprompt(target.prompt)
                    end
                end
            end
        end)
    end
end)

-- 4.3 AUTO PLANTS (TANAM BENIH)
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
                    
                    -- Hanya deteksi prompt untuk menanam
                    if string.find(promptText, "plant") or 
                       string.find(promptText, "seed") or
                       string.find(promptText, "pot") or
                       string.find(promptText, "soil") then
                        
                        if _G.SilentModeGlobal then
                            fireproximityprompt(obj)
                            task.wait(0.05)
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

-- 4.4 AUTO SELL
task.spawn(function()
    while task.wait(0.5) do
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

-- 4.5 AUTO BUY PET
task.spawn(function()
    while task.wait(1) do
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
-- 5. UI GENERATOR - SIMPLE & CLEAN
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V6"
ScreenGui.ResetOnSpawn = false

local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
pcall(function() ScreenGui.Parent = guiParent end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 12, 12)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X v6 - ANTI POHON"
Title.TextColor3 = Color3.fromRGB(225, 65, 65)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Scroll Container
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -45)
ScrollFrame.Position = UDim2.new(0, 10, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 35, 35)
ScrollFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = ScrollFrame

-- =============================================================================
-- 6. UI HELPER FUNCTIONS
-- =============================================================================
function CreateSection(title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0, 460, 0, 0)
    Section.BackgroundColor3 = Color3.fromRGB(26, 18, 18)
    Section.BorderSizePixel = 0
    Section.ClipsDescendants = true
    Section.Parent = ScrollFrame
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
    
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Color3.fromRGB(32, 24, 24)
    Header.BorderSizePixel = 0
    Header.Text = "  " .. title
    Header.TextColor3 = Color3.fromRGB(230, 230, 230)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 13
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 4)
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = Section
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 4)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = Content
    Instance.new("UIPadding", Content).PaddingTop = UDim.new(0, 4)
    
    local isOpen = true
    
    local function UpdateSize()
        if isOpen then
            Section.Size = UDim2.new(0, 460, 0, 35 + ContentLayout.AbsoluteContentSize.Y + 10)
        else
            Section.Size = UDim2.new(0, 460, 0, 35)
        end
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end
    
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)
    
    task.wait(0.1)
    UpdateSize()
    
    return Content
end

function CreateToggle(section, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 440, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(36, 26, 26)
    Frame.Parent = section
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 320, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 22)
    Btn.Position = UDim2.new(1, -58, 0.5, -11)
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

function CreateDropdown(section, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 440, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(36, 26, 26)
    Frame.ClipsDescendants = true
    Frame.Parent = section
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 0, 32)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 160, 0, 24)
    DropBtn.Position = UDim2.new(1, -168, 0, 4)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 36, 36)
    DropBtn.Text = options[1] or "Select"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 12
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 4)
    
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(0, 420, 0, 80)
    List.Position = UDim2.new(0, 8, 0, 32)
    List.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
    List.BorderSizePixel = 0
    List.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    List.ScrollBarThickness = 3
    List.Visible = false
    List.Parent = Frame
    
    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 2)
    
    local isOpen = false
    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        List.Visible = isOpen
        Frame.Size = isOpen and UDim2.new(0, 440, 0, 120) or UDim2.new(0, 440, 0, 32)
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
        OptBtn.Parent = List
        
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt
            isOpen = false
            List.Visible = false
            Frame.Size = UDim2.new(0, 440, 0, 32)
            if callback then callback(opt) end
        end)
    end
end

-- =============================================================================
-- 7. BUILD UI
-- =============================================================================

-- HOME SECTION
local homeSec = CreateSection("⚙️ Player Settings")
CreateToggle(homeSec, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
CreateToggle(homeSec, "No Clip", false, function(v) _G.NoClipToggle = v end)
CreateToggle(homeSec, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- COLLECT SECTION
local collectSec = CreateSection("🍓 Auto Collect")
local listFilter = {"All"}
for _, f in pairs(FruitsList) do 
    table.insert(listFilter, f) 
end
CreateDropdown(collectSec, "Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)
CreateToggle(collectSec, "Auto Collect Filter Fruit", false, function(v) _G.AutoCollectFruit = v end)
CreateToggle(collectSec, "Auto Collect ALL Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

-- PLANT SECTION
local plantSec = CreateSection("🌱 Auto Plant")
CreateDropdown(plantSec, "Select Seed", FruitsList, function(v) _G.SelectedSeed = v end)
CreateToggle(plantSec, "Auto Plant Selected Seed", false, function(v) _G.AutoPlantsSeed = v end)
CreateToggle(plantSec, "Auto Plant All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- SELL SECTION
local sellSec = CreateSection("💰 Auto Sell")
CreateDropdown(sellSec, "Sell Filter", listFilter, function(v) _G.SellSelectedFruit = v end)
CreateToggle(sellSec, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
CreateToggle(sellSec, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)

-- PET SECTION
local petSec = CreateSection("🐣 Auto Pet")
CreateDropdown(petSec, "Pet Type", PetsList, function(v) _G.BuySelectedPet = v end)
CreateToggle(petSec, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)

print("✅ Speed Hub X v6 - ANTI POHON Loaded!")
print("📌 100% Tidak akan mengcollect pohon!")
