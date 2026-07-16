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
    "Bunny", "Frog" , "Owl", "Monkey", "Robin", "Bee", "Bear" ,"Unicorn", "Golden Dragonfly", "Raccoon", "Turtle", 
}

-- =============================================================================
-- 2. LOAD UI LIBRARY & WINDOW UTAMA
-- =============================================================================
local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDZ7710/REDZ4.0/main/redzui", true))()

local Window = RedzLib:MakeWindow({
    Title = "Speed Hub X | Version 5.1.4",
    SubTitle = "discord.gg/speedhubx",
    FontFace = Enum.Font.SourceSansBold
})

-- =============================================================================
-- 3. PEMBUATAN TAB SIDEBAR
-- =============================================================================
local HomeTab          = Window:MakeTab({"Home", "rbxassetid://4483345998"})
local MainTab          = Window:MakeTab({"Main", "rbxassetid://4483345998"})
local AutomaticallyTab = Window:MakeTab({"Automatically", "rbxassetid://4483345998"})
local InventoryTab     = Window:MakeTab({"Inventory", "rbxassetid://4483345998"})
local ShopTab          = Window:MakeTab({"Shop", "rbxassetid://4483345998"})
local WebhookTab       = Window:MakeTab({"Webhook", "rbxassetid://4483345998"})
local MiscTab          = Window:MakeTab({"Misc", "rbxassetid://4483345998"})

-- =============================================================================
-- 4. ISI KONTEN: HOME TAB
-- =============================================================================
HomeTab:AddLabel("Home")

-- Discord Section
HomeTab:AddSection({"Discord"})
HomeTab:AddButton({
    Name = "Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/speedhubx")
        RedzLib:SetNotification({
            Title = "Speed Hub X",
            Description = "Discord link copied to clipboard!",
            Time = 3
        })
    end
})

-- LocalPlayer Section
HomeTab:AddSection({"LocalPlayer"})
HomeTab:AddTextBox({
    Name = "Set Speed",
    Default = "",
    PlaceholderText = "Write your input there",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
        end
    end
})

HomeTab:AddToggle({
    Name = "Enable Walkspeed",
    Default = false,
    Callback = function(Value)
        _G.WalkspeedToggle = Value
        task.spawn(function()
            while _G.WalkspeedToggle do
                task.wait()
                pcall(function()
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50 
                    end
                end)
            end
        end)
    end
})

HomeTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        _G.NoClipToggle = Value
        task.spawn(function()
            while _G.NoClipToggle do
                task.wait()
                pcall(function()
                    if game.Players.LocalPlayer.Character then
                        for _, part in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = not _G.NoClipToggle
                            end
                        end
                    end
                end)
            end
        end)
    end
})


-- =============================================================================
-- 5. ISI KONTEN: MAIN TAB (SISTEM COLLAPSIBLE SECTIONS)
-- =============================================================================
MainTab:AddLabel("Main")

-- -----------------------------------------------------------------------------
-- [ SECTION 1 ]: TELEPORT MANAGER
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Teleport Manager"})

MainTab:AddDropdown({
    Name = "Select Mode",
    Options = {"Tween Teleport", "Instant Teleport"},
    Default = "Tween Teleport",
    Callback = function(Value)
        _G.TeleportMode = Value
    end
})

MainTab:AddTextBox({
    Name = "Base Tween Speed",
    Default = "1.5",
    PlaceholderText = "e.g. 1.5",
    Callback = function(Value)
        _G.BaseTweenSpeed = tonumber(Value) or 1.5
    end
})

-- -----------------------------------------------------------------------------
-- [ SECTION 2 ]: STACK FARM MANAGER
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Stack Farm Manager"})

MainTab:AddLabel("- [ Priority Selection ] -")

MainTab:AddDropdown({ Name = "Priority Auto Plants Seed", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityPlantSeed = v end })
MainTab:AddDropdown({ Name = "Priority Auto Plants All Seeds", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityPlantAll = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Fruit", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityCollectFruit = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect All Fruit", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityCollectAll = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Best Fruit", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityCollectBest = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Gold Seed", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityGoldSeed = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Rainbow Seed", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityRainbowSeed = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Mega Seed", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityMegaSeed = v end })
MainTab:AddDropdown({ Name = "Priority Auto Steal Fruit", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PrioritySteal = v end })
MainTab:AddDropdown({ Name = "Priority Auto Steal Best Fruit", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityStealBest = v end })
MainTab:AddDropdown({ Name = "Priority Auto Lock Garden At Night", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityLockGarden = v end })
MainTab:AddDropdown({ Name = "Priority Auto Buy Pet", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityBuyPet = v end })
MainTab:AddDropdown({ Name = "Priority Auto Place Sprinkler", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PrioritySprinkler = v end })
MainTab:AddDropdown({ Name = "Priority Auto Place All Sprinkler", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityAllSprinkler = v end })
MainTab:AddDropdown({ Name = "Priority Auto Collect Dropped Item", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityDropped = v end })
MainTab:AddDropdown({ Name = "Priority Auto Hit Player Stolen", Options = {"1", "2", "3", "None"}, Default = "None", Callback = function(v) _G.PriorityHitStolen = v end })

MainTab:AddLabel("- [ Stack Manager ] -")

MainTab:AddToggle({
    Name = "Enable Stack Farming",
    Default = false,
    Callback = function(Value)
        _G.EnableStackFarming = Value
    end
})

MainTab:AddLabel("How Enable Stack Farming Priority does work?\nBasically,\nYou can set a priority number for each feature.\n\nA lower number means a higher priority:\n- Priority 1 is higher than 2\n- Priority 2 is higher than 3\n- And so on.")

-- -----------------------------------------------------------------------------
-- [ SECTION 3 ]: AUTOMATION PLANTS
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Automation Plants"})

MainTab:AddLabel("- [ Config ] -")
MainTab:AddToggle({ Name = "Disable Teleport", Default = false, Callback = function(v) _G.DisableTeleportPlants = v end })

MainTab:AddLabel("- [ Plants ] -")
MainTab:AddDropdown({ Name = "Select Seeds", Options = FruitsList, Default = "", Callback = function(v) _G.SelectedSeed = v end })
MainTab:AddDropdown({ Name = "Select Position", Options = {"Player Position", "Sprinkler Radius", "Custom Coordinate"}, Default = "Player Position", Callback = function(v) _G.SelectPosition = v end })
MainTab:AddDropdown({ Name = "Select Sprinkler For Plants", Options = GearsList, Default = "", Callback = function(v) _G.SelectedSprinkler = v end })

MainTab:AddButton({ Name = "Save Position", Callback = function() print("Position Saved!") end })
MainTab:AddTextBox({ Name = "Delay To Plants", Default = "0", PlaceholderText = "0", Callback = function(v) _G.DelayToPlants = tonumber(v) or 0 end })

MainTab:AddToggle({ Name = "Auto Plants Seed", Default = false, Callback = function(v) _G.AutoPlantsSeed = v end })
MainTab:AddToggle({ Name = "Auto Plants All Seeds", Default = false, Callback = function(v) _G.AutoPlantsAllSeeds = v end })

-- -----------------------------------------------------------------------------
-- [ SECTION 4 ]: AUTOMATION COLLECTION
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Automation Collection"})

MainTab:AddLabel("- [ Config ] -")
MainTab:AddToggle({ Name = "Disable Teleport", Default = false, Callback = function(v) _G.DisableTeleportCollection = v end })
MainTab:AddToggle({ Name = "Stop Collect If Backpack Is Full Max", Default = false, Callback = function(v) _G.StopCollectIfFull = v end })
MainTab:AddTextBox({ Name = "Delay To Collect", Default = "0", PlaceholderText = "0", Callback = function(v) _G.DelayToCollect = tonumber(v) or 0 end })
MainTab:AddToggle({ Name = "Disable Collect Prompt", Default = false, Callback = function(v) _G.DisableCollectPrompt = v end })

MainTab:AddLabel("- [ Collects ] -")
MainTab:AddDropdown({ Name = "Select Filter", Options = {"Whitelist", "Blacklist"}, Default = "Whitelist", Callback = function(v) _G.CollectFilter = v end })
MainTab:AddDropdown({ Name = "Select Fruit", Options = FruitsList, Default = "", Callback = function(v) _G.CollectSelectedFruit = v end })
MainTab:AddDropdown({ Name = "Select Rarity", Options = RarityList, Default = "", Callback = function(v) _G.CollectSelectedRarity = v end })
MainTab:AddDropdown({ Name = "Select Mutation", Options = MutationList, Default = "", Callback = function(v) _G.CollectSelectedMutation = v end })
MainTab:AddDropdown({ Name = "Select Threshold Mode", Options = {"Below", "Above"}, Default = "Below", Callback = function(v) _G.CollectThresholdMode = v end })
MainTab:AddTextBox({ Name = "Weight Threshold", Default = "100", PlaceholderText = "100", Callback = function(v) _G.CollectWeightThreshold = tonumber(v) or 100 end })

MainTab:AddToggle({ Name = "Only Mutated Fruit", Default = false, Callback = function(v) _G.OnlyMutatedFruit = v end })
MainTab:AddToggle({ Name = "Auto Collect Fruit", Default = false, Callback = function(v) _G.AutoCollectFruit = v end })
MainTab:AddToggle({ Name = "Auto Collect All Fruit", Default = false, Callback = function(v) _G.AutoCollectAllFruit = v end })
MainTab:AddToggle({ Name = "Enable Filters", Default = false, Callback = function(v) _G.EnableCollectionFilters = v end })
MainTab:AddToggle({ Name = "Auto Collect Best Fruit", Default = false, Callback = function(v) _G.AutoCollectBestFruit = v end })

MainTab:AddLabel("- [ Collect Event Seed ] -")
MainTab:AddToggle({ Name = "Auto Collect Gold Seed", Default = false, Callback = function(v) _G.AutoCollectGoldSeed = v end })
MainTab:AddToggle({ Name = "Auto Collect Rainbow Seed", Default = false, Callback = function(v) _G.AutoCollectRainbowSeed = v end })
MainTab:AddToggle({ Name = "Auto Collect Mega Seed", Default = false, Callback = function(v) _G.AutoCollectMegaSeed = v end })

MainTab:AddLabel("- [ Collect Dropped Item ] -")
MainTab:AddToggle({ Name = "Auto Collect Dropped Item", Default = false, Callback = function(v) _G.AutoCollectDroppedItem = v end })

-- -----------------------------------------------------------------------------
-- [ SECTION 5 ]: AUTOMATION STEAL
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Automation Steal"})

MainTab:AddLabel("- [ Steal Fruits ] -")
MainTab:AddDropdown({ Name = "Select Filter", Options = {"Whitelist", "Blacklist"}, Default = "Whitelist", Callback = function(v) _G.StealFilter = v end })
MainTab:AddDropdown({ Name = "Select Fruit", Options = FruitsList, Default = "", Callback = function(v) _G.StealSelectedFruit = v end })
MainTab:AddDropdown({ Name = "Select Rarity", Options = RarityList, Default = "", Callback = function(v) _G.StealSelectedRarity = v end })
MainTab:AddDropdown({ Name = "Select Mutation", Options = MutationList, Default = "", Callback = function(v) _G.StealSelectedMutation = v end })
MainTab:AddToggle({ Name = "Auto Steal Fruit", Default = false, Callback = function(v) _G.AutoStealFruit = v end })

MainTab:AddLabel("- [ Steal Best Fruit ] -")
MainTab:AddToggle({ Name = "Auto Steal Best Fruit", Default = false, Callback = function(v) _G.AutoStealBestFruit = v end })

MainTab:AddLabel("- [ Locks Garden ] -")
MainTab:AddToggle({ Name = "Auto Lock Garden At Night", Default = false, Callback = function(v) _G.AutoLockGarden = v end })

MainTab:AddLabel("- [ Hit Players ] -")
MainTab:AddToggle({ Name = "Auto Hit Player Stolen", Default = false, Callback = function(v) _G.AutoHitStolen = v end })

-- -----------------------------------------------------------------------------
-- [ SECTION 6 ]: AUTOMATION SELL
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Automation Sell"})

MainTab:AddLabel("- [ Sell All ] -")
MainTab:AddToggle({ Name = "Auto Sell All", Default = false, Callback = function(v) _G.AutoSellAll = v end })
MainTab:AddButton({ Name = "Sell All", Callback = function() print("Selling everything!") end })

MainTab:AddLabel("- [ Sell Fruits ] -")
MainTab:AddDropdown({ Name = "Select Sell Fruit", Options = FruitsList, Default = "", Callback = function(v) _G.SellSelectedFruit = v end })
MainTab:AddDropdown({ Name = "Select Sell Rarity", Options = RarityList, Default = "", Callback = function(v) _G.SellSelectedRarity = v end })
MainTab:AddDropdown({ Name = "Select Sell Mutation", Options = MutationList, Default = "", Callback = function(v) _G.SellSelectedMutation = v end })
MainTab:AddDropdown({ Name = "Select Threshold Mode", Options = {"Below", "Above"}, Default = "Below", Callback = function(v) _G.SellThresholdMode = v end })
MainTab:AddTextBox({ Name = "Weight Threshold", Default = "100", PlaceholderText = "100", Callback = function(v) _G.SellWeightThreshold = tonumber(v) or 100 end })
MainTab:AddToggle({ Name = "Auto Sell Fruit", Default = false, Callback = function(v) _G.AutoSellFruit = v end })

MainTab:AddLabel("- [ Sell Pets ] -")
MainTab:AddDropdown({ Name = "Select Pets", Options = PetsList, Default = "", Callback = function(v) _G.SellSelectedPet = v end })
MainTab:AddDropdown({ Name = "Select Rarity Pets", Options = RarityList, Default = "", Callback = function(v) _G.SellSelectedPetRarity = v end })
MainTab:AddDropdown({ Name = "Select Size Pets", Options = {"Small", "Medium", "Large", "Huge"}, Default = "Small", Callback = function(v) _G.SellSelectedPetSize = v end })
MainTab:AddToggle({ Name = "Auto Sell Pets", Default = false, Callback = function(v) _G.AutoSellPets = v end })

-- -----------------------------------------------------------------------------
-- [ SECTION 7 ]: AUTOMATION PETS
-- -----------------------------------------------------------------------------
MainTab:AddSection({"Automation Pets"})

MainTab:AddToggle({ Name = "Pet Purchase Protection", Default = false, Callback = function(v) _G.PetPurchaseProtection = v end })

MainTab:AddLabel("- [ Buys Pets ] -")
MainTab:AddDropdown({ Name = "Select Pets", Options = PetsList, Default = "", Callback = function(v) _G.BuySelectedPet = v end })
MainTab:AddDropdown({ Name = "Select Rarity Pets", Options = RarityList, Default = "", Callback = function(v) _G.BuySelectedPetRarity = v end })
MainTab:AddDropdown({ Name = "Select Size Pets", Options = {"Small", "Medium", "Large", "Huge"}, Default = "Small", Callback = function(v) _G.BuySelectedPetSize = v end })
MainTab:AddTextBox({ Name = "Pet Sheckle Limit", Default = "0", PlaceholderText = "0", Callback = function(v) _G.PetSheckleLimit = tonumber(v) or 0 end })
MainTab:AddToggle({ Name = "Auto Buy Pet", Default = false, Callback = function(v) _G.AutoBuyPet = v end })


-- =============================================================================
-- 6. PLACEHOLDER UNTUK TAB LAINNYA
-- =============================================================================
AutomaticallyTab:AddLabel("Fitur Auto Farm GAG 2 akan ditaruh di sini.")
InventoryTab:AddLabel("Fitur Inventory ditaruh di sini.")
ShopTab:AddLabel("Fitur Shop ditaruh di sini.")
WebhookTab:AddLabel("Fitur Webhook ditaruh di sini.")
MiscTab:AddLabel("Fitur Misc ditaruh di sini.")
