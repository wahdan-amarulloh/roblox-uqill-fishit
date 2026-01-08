-- Check EquippedItems Storage
-- Maybe equipped items stored separately?

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
        username = "UQiLL Equipped Items Debugger",
        avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
        embeds = {{
            description = "```lua\n" .. text .. "```",
            color = 0x30ff6a
        }}
    })
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 EQUIPPED ITEMS DEEP SCAN")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")

local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🔍 EQUIPPED ITEMS ANALYSIS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

-- Get equipped items
local equippedItems = Data:Get("EquippedItems")

if not equippedItems or #equippedItems == 0 then
    output = output .. "❌ No equipped items\n"
else
    output = output .. "✅ Found " .. #equippedItems .. " equipped items\n\n"
    
    for i, uuid in ipairs(equippedItems) do
        output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        output = output .. "ITEM #" .. i .. "\n"
        output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        output = output .. "UUID: " .. tostring(uuid) .. "\n\n"
        
        -- Try to find in inventory
        local inventory = Data:Get("Inventory")
        local found = false
        
        if inventory and inventory.Items then
            -- Direct UUID lookup
            local item = inventory.Items[uuid]
            
            if item then
                found = true
                output = output .. "✅ Found in Inventory.Items[UUID]\n\n"
                
                -- Get item data
                if item.Id then
                    local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(item.Id))
                    if itemModule then
                        local ok, data = pcall(require, itemModule)
                        if ok and data.Data then
                            output = output .. "Name: " .. (data.Data.Name or "Unknown") .. "\n"
                            output = output .. "Type: " .. (data.Data.Type or "Unknown") .. "\n"
                        end
                    end
                end
                
                output = output .. "\n📊 Item Properties:\n"
                for key, value in pairs(item) do
                    if key ~= "Metadata" then
                        output = output .. "  " .. key .. " = " .. tostring(value) .. "\n"
                    end
                end
                
                -- ENCHANT DATA CHECK
                if item.Metadata then
                    output = output .. "\n🔮 METADATA (ENCHANTS?):\n"
                    for key, value in pairs(item.Metadata) do
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
                end
            end
        end
        
        if not found then
            output = output .. "❌ NOT found in Inventory.Items\n"
            output = output .. "💡 Maybe stored elsewhere?\n"
        end
        
        output = output .. "\n"
    end
end

-- Check all Data keys
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "📋 ALL DATA KEYS (Looking for equipped storage):\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

-- List all keys in Data replion
local allKeys = Data:GetAll()
for key, value in pairs(allKeys) do
    local valueType = type(value)
    local valueInfo = valueType
    
    if valueType == "table" then
        local count = 0
        for _ in pairs(value) do count = count + 1 end
        valueInfo = "table (" .. count .. " items)"
    elseif valueType == "string" and #value > 50 then
        valueInfo = "string (long)"
    end
    
    output = output .. key .. " = " .. valueInfo .. "\n"
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "✅ SCAN COMPLETE\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

print(output)

-- Send to Discord
SendWebhook({
    username = "UQiLL Equipped Items Debugger",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🔍 Deep Scanning Equipped Items...",
        description = "Checking where equipped items are stored",
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
    username = "UQiLL Equipped Items Debugger",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "✅ Scan Complete!",
        description = "Check above for equipped items data",
        color = 0x30ff6a
    }}
})

print("\n✅ Results sent to Discord!")