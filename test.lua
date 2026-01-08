-- Inventory Item Sampler
-- Shows random items to identify rod structure

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
        username = "UQiLL Inventory Debugger",
        avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
        embeds = {{
            description = "```lua\n" .. text .. "```",
            color = 0x30ff6a
        }}
    })
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 INVENTORY ITEM SAMPLER")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")
local inventory = Data:Get("Inventory")

if not inventory or not inventory.Items then
    print("❌ No inventory data")
    return
end

print("✅ Found " .. #inventory.Items .. " items")

-- Sample items to identify structure
local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🔍 INVENTORY ITEM SAMPLES (First 10)\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local count = 0
for uuid, item in pairs(inventory.Items) do
    if count >= 10 then break end
    count = count + 1
    
    output = output .. "ITEM #" .. count .. ":\n"
    output = output .. "UUID: " .. tostring(uuid) .. "\n"
    
    -- Print all top-level keys
    for key, value in pairs(item) do
        local valueStr = tostring(value)
        
        if type(value) == "table" then
            valueStr = "{table}"
        elseif type(value) == "string" and #value > 50 then
            valueStr = value:sub(1, 50) .. "..."
        end
        
        output = output .. "  " .. key .. " = " .. valueStr .. "\n"
    end
    
    output = output .. "\n"
end

-- Look for Item database types
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "📚 ITEM DATABASE TYPES\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local typeCount = {}
for _, module in pairs(ReplicatedStorage.Items:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        if ok and data.Data and data.Data.Type then
            local itemType = data.Data.Type
            typeCount[itemType] = (typeCount[itemType] or 0) + 1
        end
    end
end

for itemType, count in pairs(typeCount) do
    output = output .. itemType .. ": " .. count .. " items\n"
end

-- Look for rod-like items
output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎣 SEARCHING FOR ROD-LIKE ITEMS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local rodLikeCount = 0
for _, module in pairs(ReplicatedStorage.Items:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        if ok and data.Data then
            local name = tostring(data.Data.Name or ""):lower()
            local itemType = tostring(data.Data.Type or ""):lower()
            
            if name:find("rod") or name:find("pole") or name:find("fishing") or
               itemType:find("rod") or itemType:find("fishing") then
                rodLikeCount = rodLikeCount + 1
                output = output .. "Found: " .. (data.Data.Name or "unnamed") .. "\n"
                output = output .. "  ID: " .. module.Name .. "\n"
                output = output .. "  Type: " .. (data.Data.Type or "unknown") .. "\n\n"
            end
        end
    end
end

if rodLikeCount == 0 then
    output = output .. "⚠️ No rod-like items found in database!\n"
    output = output .. "Rod might use different naming or type.\n"
end

print(output)

-- Send to Discord in chunks
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

SendWebhook({
    username = "UQiLL Inventory Debugger",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🔍 Inventory Analysis",
        description = "Analyzing 638 items...",
        color = 0x30ff6a
    }}
})

task.wait(1)

for _, chunk in ipairs(chunks) do
    SendMessage(chunk)
    task.wait(1)
end

SendWebhook({
    username = "UQiLL Inventory Debugger",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "✅ Analysis Complete",
        description = "Check messages above for item structure",
        color = 0x30ff6a
    }}
})

print("\n✅ Results sent to Discord!")