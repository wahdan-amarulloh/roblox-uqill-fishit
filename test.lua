-- Check if you have ANY Fishing Rods items
-- Shows what those IDs actually are

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

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

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 CHECKING YOUR INVENTORY ITEMS")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")
local inventory = Data:Get("Inventory")

local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "📋 YOUR INVENTORY BREAKDOWN\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

-- Count by type
local typeCount = {}

for uuid, item in pairs(inventory.Items) do
    if item.Id then
        local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(item.Id))
        
        if itemModule then
            local ok, data = pcall(require, itemModule)
            
            if ok and data.Data then
                local itemType = data.Data.Type or "Unknown"
                typeCount[itemType] = (typeCount[itemType] or 0) + 1
            end
        end
    end
end

output = output .. "📊 ITEMS BY TYPE:\n\n"
for itemType, count in pairs(typeCount) do
    output = output .. itemType .. ": " .. count .. " items\n"
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎣 ROD STATUS:\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

if typeCount["Fishing Rods"] then
    output = output .. "✅ You have " .. typeCount["Fishing Rods"] .. " fishing rod(s)!\n"
    output = output .. "⚠️ But previous script couldn't find them.\n"
    output = output .. "💡 This might be a script bug.\n"
else
    output = output .. "❌ You DON'T own any fishing rods!\n\n"
    output = output .. "💡 How to get a rod:\n"
    output = output .. "  1. Visit the shop\n"
    output = output .. "  2. Buy 'Starter Rod' or any rod\n"
    output = output .. "  3. Run this script again\n"
end

-- Also check equipped rod
output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎒 RAW BACKPACK DUMP (ALL ITEMS):\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local LocalPlayer = Players.LocalPlayer
local backpackCount = 0

-- List EVERYTHING in backpack
for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
    backpackCount = backpackCount + 1
    output = output .. backpackCount .. ". " .. item.Name .. " (" .. item.ClassName .. ")\n"
    
    -- Show some properties
    if item:IsA("Tool") then
        output = output .. "   → This is a Tool\n"
    end
    
    -- Check for attributes
    local attrs = item:GetAttributes()
    if next(attrs) then
        output = output .. "   Attributes:\n"
        for k, v in pairs(attrs) do
            output = output .. "     " .. k .. " = " .. tostring(v) .. "\n"
        end
    end
end

if backpackCount == 0 then
    output = output .. "❌ Backpack is EMPTY!\n"
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "👤 RAW CHARACTER DUMP (ALL ITEMS):\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local charCount = 0

if LocalPlayer.Character then
    for _, item in pairs(LocalPlayer.Character:GetChildren()) do
        -- Only show relevant items (not body parts)
        if item:IsA("Tool") or item:IsA("Accessory") or 
           item.Name:lower():find("rod") or item.Name:lower():find("gear") then
            charCount = charCount + 1
            output = output .. charCount .. ". " .. item.Name .. " (" .. item.ClassName .. ")\n"
            
            if item:IsA("Tool") then
                output = output .. "   → EQUIPPED TOOL ⭐\n"
            end
            
            local attrs = item:GetAttributes()
            if next(attrs) then
                output = output .. "   Attributes:\n"
                for k, v in pairs(attrs) do
                    output = output .. "     " .. k .. " = " .. tostring(v) .. "\n"
                end
            end
        end
    end
    
    if charCount == 0 then
        output = output .. "❌ No relevant items equipped\n"
    end
else
    output = output .. "❌ Character not loaded\n"
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "💡 CONCLUSION:\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

if typeCount["Fishing Rods"] then
    output = output .. "You HAVE rods in inventory data.\n"
    output = output .. "But they're not showing up in scans.\n"
    output = output .. "Possible issue with script logic.\n"
elseif hasRod then
    output = output .. "You have a PHYSICAL rod equipped.\n"
    output = output .. "But no rods in Replion inventory.\n"
    output = output .. "This is a game design choice.\n"
else
    output = output .. "You genuinely don't have any rods.\n"
    output = output .. "Go buy one from the shop first!\n"
end

print(output)

-- Send to Discord
SendWebhook({
    username = "UQiLL Inventory Checker",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        description = "```lua\n" .. output .. "```",
        color = 0x30ff6a
    }}
})

print("\n✅ Check Discord for full breakdown!")