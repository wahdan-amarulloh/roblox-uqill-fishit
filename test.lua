-- Real Rod Finder (Based on Game Architecture)
-- Uses EquippedItems + Player Attributes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Webhook
local WEBHOOK_URL = "https://discord.com/api/webhooks/1455588039152767159/eFMjdTcF7MA_Yi3wE4UggQa6nFQMtBpCdY4Qo0A5OP_EAR8Yhkc4cNV4_kQLYStiyirP"
local HttpRequest = syn and syn.request or http_request or request or 
                    (fluxus and fluxus.request) or (krnl and krnl.request)

local function SendWebhook(payload)
    pcall(function()
        HttpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

local function SendMessage(text)
    SendWebhook({
        username = "UQiLL Rod Analyzer",
        avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
        embeds = {{
            description = "```lua\n" .. text .. "```",
            color = 0x30ff6a
        }}
    })
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎣 REAL ROD FINDER (Game Architecture)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎣 EQUIPPED ROD ANALYSIS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

-- METHOD 1: Player Attributes (Most Direct)
output = output .. "📋 METHOD 1: PLAYER ATTRIBUTES\n\n"

local rodName = LocalPlayer:GetAttribute("FishingRod")
local skinName = LocalPlayer:GetAttribute("FishingRodSkin")

if rodName then
    output = output .. "✅ Equipped Rod: " .. rodName .. "\n"
    if skinName then
        output = output .. "🎨 Active Skin: " .. skinName .. "\n"
    else
        output = output .. "🎨 Active Skin: None\n"
    end
else
    output = output .. "❌ No rod equipped (Attribute not set)\n"
end

-- METHOD 2: Replion EquippedItems
output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "📦 METHOD 2: REPLION EQUIPPED ITEMS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

local equippedItems = Data:Get("EquippedItems")
if equippedItems and #equippedItems > 0 then
    output = output .. "✅ Equipped Items Array:\n"
    for i, uuid in ipairs(equippedItems) do
        output = output .. "  [" .. i .. "] UUID: " .. tostring(uuid) .. "\n"
    end
    
    -- Get first equipped item (should be rod)
    local equippedRodUUID = equippedItems[1]
    
    if equippedRodUUID then
        output = output .. "\n🔍 Searching for rod with UUID: " .. equippedRodUUID .. "\n"
        
        -- Find in inventory
        local inventory = Data:Get("Inventory")
        if inventory and inventory.Items then
            local rodItem = inventory.Items[equippedRodUUID]
            
            if rodItem then
                output = output .. "\n✅ FOUND EQUIPPED ROD!\n\n"
                output = output .. "UUID: " .. equippedRodUUID .. "\n"
                output = output .. "ID: " .. tostring(rodItem.Id) .. "\n"
                
                -- Get rod data
                local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(rodItem.Id))
                if itemModule then
                    local ok, data = pcall(require, itemModule)
                    if ok and data.Data then
                        output = output .. "Name: " .. (data.Data.Name or "Unknown") .. "\n"
                        output = output .. "Type: " .. (data.Data.Type or "Unknown") .. "\n"
                    end
                end
                
                output = output .. "\n📊 FULL ROD DATA:\n"
                for key, value in pairs(rodItem) do
                    if type(value) == "table" then
                        output = output .. "  " .. key .. ":\n"
                        for k, v in pairs(value) do
                            if type(v) == "table" then
                                output = output .. "    " .. k .. ":\n"
                                for k2, v2 in pairs(v) do
                                    output = output .. "      " .. k2 .. " = " .. tostring(v2) .. "\n"
                                end
                            else
                                output = output .. "    " .. k .. " = " .. tostring(v) .. "\n"
                            end
                        end
                    else
                        output = output .. "  " .. key .. " = " .. tostring(value) .. "\n"
                    end
                end
            else
                output = output .. "❌ UUID not found in inventory!\n"
            end
        end
    end
else
    output = output .. "❌ No equipped items found\n"
end

-- METHOD 3: All Rods in Inventory
output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "📦 METHOD 3: ALL RODS IN INVENTORY\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local inventory = Data:Get("Inventory")
local rodCount = 0

if inventory and inventory.Items then
    for uuid, item in pairs(inventory.Items) do
        if item.Id then
            local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(item.Id))
            if itemModule then
                local ok, data = pcall(require, itemModule)
                if ok and data.Data and data.Data.Type == "Fishing Rods" then
                    rodCount = rodCount + 1
                    output = output .. "🎣 Rod #" .. rodCount .. ": " .. (data.Data.Name or "Unknown") .. "\n"
                    output = output .. "   UUID: " .. uuid .. "\n"
                    
                    if item.Metadata then
                        output = output .. "   Metadata: {table}\n"
                    end
                    
                    output = output .. "\n"
                end
            end
        end
    end
    
    if rodCount == 0 then
        output = output .. "❌ No rods found in inventory\n"
    else
        output = output .. "📊 Total: " .. rodCount .. " rod(s)\n"
    end
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "✅ ANALYSIS COMPLETE\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

print(output)

-- Send to Discord
SendWebhook({
    username = "UQiLL Rod Analyzer",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🎣 Analyzing Your Rods...",
        description = "Using game's actual architecture",
        color = 0x30ff6a
    }}
})

task.wait(1)

-- Split and send
local chunks = {}
local current = ""
for line in output:gmatch("[^\n]+") do
    if #current + #line > 1800 then
        table.insert(chunks, current)
        current = line .. "\n"
    else
        current = current .. line .. "\n"
    end
end
if #current > 0 then
    table.insert(chunks, current)
end

for _, chunk in ipairs(chunks) do
    SendMessage(chunk)
    task.wait(1)
end

SendWebhook({
    username = "UQiLL Rod Analyzer",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "✅ Analysis Complete!",
        description = "Check messages above for full rod data",
        color = 0x30ff6a
    }}
})

print("\n✅ Results sent to Discord!")