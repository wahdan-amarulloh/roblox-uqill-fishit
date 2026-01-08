-- Rod & Inventory Structure Analyzer (FIXED)
-- Safe version with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 ROD & INVENTORY ANALYZER (SAFE)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- Helper: Deep scan object
local function DeepScan(obj, indent, maxDepth, currentDepth)
    indent = indent or ""
    maxDepth = maxDepth or 4
    currentDepth = currentDepth or 0
    
    if currentDepth >= maxDepth then return indent .. "  [Max depth]" end
    
    local result = ""
    
    for _, child in pairs(obj:GetChildren()) do
        local info = indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")"
        
        -- Get value if possible
        if child:IsA("ValueBase") then
            local ok, val = pcall(function() return child.Value end)
            if ok and val ~= nil then
                info = info .. " = " .. tostring(val)
            end
        end
        
        -- Check attributes
        local attrs = child:GetAttributes()
        if next(attrs) then
            info = info .. "\n" .. indent .. "│  📋 Attributes:"
            for k, v in pairs(attrs) do
                info = info .. "\n" .. indent .. "│    • " .. k .. " = " .. tostring(v)
            end
        end
        
        result = result .. info .. "\n"
        
        if #child:GetChildren() > 0 then
            result = result .. DeepScan(child, indent .. "│  ", maxDepth, currentDepth + 1)
        end
    end
    
    return result
end

-- METHOD 1: Replion Data (SAFE VERSION)
print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📦 METHOD 1: REPLION INVENTORY DATA")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local replionOk, replionResult = pcall(function()
    local Replion = require(ReplicatedStorage.Packages.Replion)
    
    -- Wait dengan timeout
    local startTime = tick()
    local Data = nil
    
    while not Data and (tick() - startTime) < 5 do
        local ok, result = pcall(function()
            return Replion.Client:WaitReplion("Data")
        end)
        
        if ok then
            Data = result
            break
        end
        
        task.wait(0.5)
    end
    
    if not Data then
        error("Timeout waiting for Data replion")
    end
    
    local inventory = Data:Get("Inventory")
    return inventory
end)

if replionOk and replionResult then
    local inventory = replionResult
    
    if inventory and inventory.Items then
        print("\n✅ Found Inventory Data!")
        
        local rodCount = 0
        for uuid, item in pairs(inventory.Items) do
            -- Simple check: look for "Rod" in any property
            local isRod = false
            
            -- Check Type field
            if item.Type == "Rod" then
                isRod = true
            end
            
            -- Check if ID corresponds to a rod in Items folder
            if not isRod and item.Id then
                local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(item.Id))
                if itemModule then
                    local ok, data = pcall(require, itemModule)
                    if ok and data.Data and data.Data.Type == "Rod" then
                        isRod = true
                    end
                end
            end
            
            if isRod then
                rodCount = rodCount + 1
                print("\n🎣 ROD #" .. rodCount .. " (Replion Data)")
                print("UUID: " .. tostring(uuid))
                print("ID: " .. tostring(item.Id))
                
                -- Print all properties
                for key, value in pairs(item) do
                    if type(value) == "table" then
                        print("  " .. key .. ":")
                        for k, v in pairs(value) do
                            if type(v) == "table" then
                                print("    " .. k .. " = {table}")
                            else
                                print("    " .. k .. " = " .. tostring(v))
                            end
                        end
                    else
                        print("  " .. key .. " = " .. tostring(value))
                    end
                end
            end
        end
        
        print("\n📊 Total Rods in Inventory: " .. rodCount)
    else
        print("⚠️ Inventory structure unexpected")
    end
else
    print("⚠️ Replion method failed:", replionResult)
    print("Trying backpack method instead...")
end

-- METHOD 2: Backpack Physical Rods (ALWAYS RUN)
print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎒 METHOD 2: BACKPACK PHYSICAL RODS")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local Backpack = LocalPlayer.Backpack
local Character = LocalPlayer.Character

local function ScanForRods(container, containerName)
    local found = 0
    
    for _, tool in pairs(container:GetChildren()) do
        if tool:IsA("Tool") and (
            tool.Name:lower():find("rod") or 
            tool.Name:lower():find("pole")
        ) then
            found = found + 1
            print("\n🎣 Rod #" .. found .. " in " .. containerName)
            print("Name: " .. tool.Name)
            print("Full Path: " .. tool:GetFullName())
            
            -- Check attributes
            local attrs = tool:GetAttributes()
            if next(attrs) then
                print("\n📋 Tool Attributes:")
                for k, v in pairs(attrs) do
                    print("  • " .. k .. " = " .. tostring(v))
                end
            end
            
            print("\n📁 Children Structure:")
            print(DeepScan(tool, "", 4, 0))
        end
    end
    
    return found
end

-- Scan backpack
local backpackRods = ScanForRods(Backpack, "Backpack")

-- Scan character (equipped)
local charRods = 0
if Character then
    charRods = ScanForRods(Character, "Character (Equipped)")
end

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ SCAN COMPLETE!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 Results:")
print("  • Backpack Rods: " .. backpackRods)
print("  • Equipped Rods: " .. charRods)
print("  • Total: " .. (backpackRods + charRods))

if backpackRods + charRods == 0 then
    print("\n⚠️ No rods found!")
    print("💡 Make sure you have a fishing rod in your backpack or equipped")
else
    print("\n💡 Next: Look for 'Enchants' or 'EnchantSlots' in the output above")
end