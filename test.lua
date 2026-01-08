-- Working Rod Finder with Correct Type Detection
-- Type = "Fishing Rods" (not "Rod"!)

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
print("🎣 WORKING ROD FINDER")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local Replion = require(ReplicatedStorage.Packages.Replion)
local Data = Replion.Client:WaitReplion("Data")
local inventory = Data:Get("Inventory")

if not inventory or not inventory.Items then
    print("❌ No inventory")
    return
end

print("✅ Inventory: " .. #inventory.Items .. " items")

local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎣 YOUR FISHING RODS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local rodCount = 0

for uuid, item in pairs(inventory.Items) do
    -- Check if item.Id exists in Items database
    if item.Id then
        local itemModule = ReplicatedStorage.Items:FindFirstChild(tostring(item.Id))
        
        if itemModule then
            local ok, data = pcall(require, itemModule)
            
            -- FIXED: Check for "Fishing Rods" type!
            if ok and data.Data and data.Data.Type == "Fishing Rods" then
                rodCount = rodCount + 1
                
                output = output .. "🎣 ROD #" .. rodCount .. "\n"
                output = output .. "Name: " .. (data.Data.Name or "Unknown") .. "\n"
                output = output .. "UUID: " .. tostring(uuid) .. "\n"
                output = output .. "ID: " .. tostring(item.Id) .. "\n"
                
                -- Check for Metadata (likely contains enchants!)
                if item.Metadata then
                    output = output .. "\n📋 METADATA:\n"
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
                
                -- Check for other properties
                output = output .. "\n📊 PROPERTIES:\n"
                for key, value in pairs(item) do
                    if key ~= "Metadata" and key ~= "UUID" and key ~= "Id" then
                        output = output .. "  " .. key .. " = " .. tostring(value) .. "\n"
                    end
                end
                
                output = output .. "\n" .. string.rep("─", 40) .. "\n\n"
            end
        end
    end
end

output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "✅ TOTAL RODS FOUND: " .. rodCount .. "\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

if rodCount == 0 then
    output = output .. "\n⚠️ You don't own any fishing rods yet!\n"
    output = output .. "💡 Get a rod from the shop first.\n"
end

print(output)

-- Send to Discord
SendWebhook({
    username = "UQiLL Rod Analyzer",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🎣 Analyzing Your Rods...",
        description = "Found " .. #inventory.Items .. " items in inventory",
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
        title = "✅ Scan Complete!",
        fields = {
            { name = "Total Rods", value = tostring(rodCount), inline = true },
            { name = "Status", value = rodCount > 0 and "✅ Ready" or "⚠️ No rods", inline = true }
        },
        color = rodCount > 0 and 0x30ff6a or 0xff6a30
    }}
})

print("\n✅ Results sent to Discord!")