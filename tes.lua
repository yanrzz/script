-- ==========================================
-- 1. SETUP & KONFIGURASI
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Status Fitur (Setiap fitur punya kontrol On/Off masing-masing)
_G.AutoHarvest = false
_G.AutoWater = false
_G.AutoBuy = false

-- ==========================================
-- 2. MEMBUAT UI PANEL & TOMBOL
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAG2_MultiFarm"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (Panel Background)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 200, 0, 230)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Supaya panelnya bisa digeser-geser di layar HP/PC

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Judul Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "GAG 2 AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

-- Fungsi Pembantu untuk Membuat Tombol Toggle
local function createToggleButton(name, text, positionY)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 170, 0, 45)
    Button.Position = UDim2.new(0.5, -85, 0, positionY)
    Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Default Merah (OFF)
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansBold
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    return Button
end

-- Membuat 3 Tombol Berdasarkan Posisi Y
local btnHarvest = createToggleButton("BtnHarvest", "Auto Harvest", 50)
local btnWater = createToggleButton("BtnWater", "Auto Water", 110)
local btnBuy = createToggleButton("BtnBuy", "Auto Buy", 170)

-- ==========================================
-- 3. LOGIKA UTAMA INTERAKSI GAME
-- ==========================================
local function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt, 1) -- Fungsi executor untuk menekan tombol 'E'
    end
end

-- Loop Terpisah untuk Auto Harvest & Auto Water
task.spawn(function()
    while true do
        task.wait(0.3) -- Jeda ringan agar tidak lag

        -- Jalankan hanya jika minimal salah satu fitur aktif
        if _G.AutoHarvest or _G.AutoWater then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    
                    -- Aksi 1: AUTO HARVEST
                    if _G.AutoHarvest and (obj.ActionText == "Harvest" or obj.ObjectText == "Harvest") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            firePrompt(obj)
                            task.wait(0.2)
                        end
                    end

                    -- Aksi 2: AUTO WATER
                    if _G.AutoWater and (obj.ActionText == "Water" or obj.ObjectText == "Water" or obj.ActionText == "Siram") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            firePrompt(obj)
                            task.wait(0.2)
                        end
                    end
                    
                end
            end
        end
    end
end)

-- Loop Terpisah untuk Auto Buy (Jika Anda ingin membeli otomatis)
task.spawn(function()
    while true do
        task.wait(1) -- Cek pembelian setiap 1 detik sekali jika aktif
        if _G.AutoBuy then
            -- Tempatkan logika pembelian seed GAG 2 Anda di sini.
            -- Contoh simulasi menekan tombol beli di toko jika menggunakan ProximityPrompt:
            for _, obj in pairs(workspace:GetDescendants()) do
                if _G.AutoBuy and obj:IsA("ProximityPrompt") and (obj.ActionText == "Buy" or obj.ActionText == "Beli") then
                    -- Teleport ke NPC/Mesin Toko lalu beli
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.1)
                        firePrompt(obj)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 4. KONTROL INTERAKSI TOMBOL (TOGGLE)
-- ==========================================

-- Toggle Auto Harvest
btnHarvest.MouseButton1Click:Connect(function()
    _G.AutoHarvest = not _G.AutoHarvest
    if _G.AutoHarvest then
        btnHarvest.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnHarvest.Text = "Auto Harvest: ON"
    else
        btnHarvest.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnHarvest.Text = "Auto Harvest: OFF"
    end
end)

-- Toggle Auto Water
btnWater.MouseButton1Click:Connect(function()
    _G.AutoWater = not _G.AutoWater
    if _G.AutoWater then
        btnWater.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnWater.Text = "Auto Water: ON"
    else
        btnWater.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnWater.Text = "Auto Water: OFF"
    end
end)

-- Toggle Auto Buy
btnBuy.MouseButton1Click:Connect(function()
    _G.AutoBuy = not _G.AutoBuy
    if _G.AutoBuy then
        btnBuy.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnBuy.Text = "Auto Buy: ON"
    else
        btnBuy.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnBuy.Text = "Auto Buy: OFF"
    end
end)
