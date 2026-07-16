-- =============================================================================
-- SPEED HUB X v8.2 - PRIORITY SYSTEM IMPLEMENTED
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ========================== DATABASE ==========================
local FruitsList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}

local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}

-- ========================== GLOBAL STATE ==========================
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.SilentModeGlobal = true

-- Priority System
_G.EnableStackFarming = false
_G.PriorityLevel = {}  -- Feature -> Priority (1 = highest)

-- Register features with priorities
local function RegisterPriority(feature, level)
    _G.PriorityLevel[feature] = level
end

RegisterPriority("AutoPlantsSeed", 3)
RegisterPriority("AutoPlantsAllSeeds", 3)
RegisterPriority("AutoCollectFruit", 2)
RegisterPriority("AutoCollectAllFruit", 1)
RegisterPriority("AutoCollectBestFruit", 1)
RegisterPriority("AutoStealFruit", 4)
RegisterPriority("AutoStealBestFruit", 3)
RegisterPriority("AutoSellAll", 5)
RegisterPriority("AutoBuyPet", 6)
RegisterPriority("AutoPlaceSprinkler", 4)

-- Current active high-priority task
local CurrentHighPriority = nil

local function IsHigherPriorityActive(currentFeature)
    if not _G.EnableStackFarming then return false end
    local myPriority = _G.PriorityLevel[currentFeature] or 10
    for feature, active in pairs(_G) do
        if typeof(active) == "boolean" and active and feature:find("Auto") then
            local prio = _G.PriorityLevel[feature] or 10
            if prio < myPriority then
                return true
            end
        end
    end
    return false
end

-- ========================== FRUIT DETECTION ==========================
local function isRealFruit(item)
    if not item or not item:IsA("BasePart") then return false end
    local name = item.Name:lower()
    local blackList = {"tree","trunk","branch","leaf","stem","wood","log","mail","box","pot","plot","soil","ground","terrain"}
    for _, v in ipairs(blackList) do
        if name:find(v) then return false end
    end
    if item.Size.Magnitude > 15 then return false end
    for _, f in ipairs(FruitsList) do
        if name:find(f:lower()) then return true end
    end
    return name:find("fruit") or name:find("berry") or name:find("harvest")
end

-- ========================== UI (Same as before, abbreviated) ==========================
-- ... (Keep your existing UI code here - I recommend using the cleaned version from previous response)

-- Example: Add priority info in Stack Farm section
-- AddToggle(stackSection, "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)

-- ========================== CORE LOOPS WITH PRIORITY ==========================

-- WalkSpeed + NoClip (No priority needed)
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if _G.WalkspeedToggle and hum then
        hum.WalkSpeed = _G.CustomSpeed
    end
    if _G.NoClipToggle then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Auto Collect Loop (Priority Aware)
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit or _G.AutoCollectBestFruit) then continue end
        if IsHigherPriorityActive("AutoCollectAllFruit") then continue end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        if _G.StopCollectIfFull and #Player.Backpack:GetChildren() >= 10 then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") then
                local item = obj.Parent
                if item and isRealFruit(item) then
                    if _G.SilentModeGlobal then
                        firetouchinterest(root, item, 0)
                        task.wait(0.02)
                        firetouchinterest(root, item, 1)
                    else
                        root.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.08)
                    end
                end
            end
        end
    end
end)

-- Auto Plant Loop (Priority Aware)
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then continue end
        if IsHigherPriorityActive("AutoPlantsAllSeeds") then continue end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                if txt:find("plant") or txt:find("seed") then
                    if _G.SilentModeGlobal then
                        fireproximityprompt(obj)
                        task.wait(_G.DelayToPlants or 0.5)
                    else
                        local parent = obj.Parent
                        if parent and parent:IsA("BasePart") then
                            root.CFrame = parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            fireproximityprompt(obj)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Sell (Example)
task.spawn(function()
    while task.wait(0.8) do
        if not _G.AutoSellAll then continue end
        if IsHigherPriorityActive("AutoSellAll") then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                if txt:find("sell") or txt:find("merchant") then
                    fireproximityprompt(obj)
                    task.wait(0.3)
                end
            end
        end
    end
end)

-- Auto Steal Placeholder
task.spawn(function()
    while task.wait(0.6) do
        if not (_G.AutoStealFruit or _G.AutoStealBestFruit) then continue end
        if IsHigherPriorityActive("AutoStealBestFruit") then continue end
        -- TODO: Implement steal logic (find other players' fruits)
        print("🔍 Auto Steal checking...")
    end
end)

print("✅ Speed Hub X v8.2 - Priority System Loaded!")
print("📌 Stack Farming is now active when toggled.")
