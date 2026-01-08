-- Advanced Rod Finder (uqill.lua compatible)
-- Uses existing SendWebhook function from uqill

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ⚙️ Use existing webhook from uqill.lua
local HttpRequest = syn and syn.request or http_request or request or 
                    (fluxus and fluxus.request) or (krnl and krnl.request)

-- Webhook URL (change this to yours)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1455588039152767159/eFMjdTcF7MA_Yi3wE4UggQa6nFQMtBpCdY4Qo0A5OP_EAR8Yhkc4cNV4_kQLYStiyirP"

-- SendWebhook function (from uqill.lua style)
local function SendWebhook(payload)
    if not HttpRequest then
        warn("HTTP not available")
        return
    end
    
    pcall(function()
        HttpRequest({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

local function SendLongMessage(text)
    -- Split into chunks untuk Discord 2000 char limit
    local maxLen = 1900
    local chunks = {}
    local current = "```lua\n"
    
    for line in text:gmatch("[^\n]+") do
        if #current + #line + 5 > maxLen then
            current = current .. "```"
            table.insert(chunks, current)
            current = "```lua\n" .. line .. "\n"
        else
            current = current .. line .. "\n"
        end
    end
    
    if #current > 8 then
        current = current .. "```"
        table.insert(chunks, current)
    end
    
    -- Send each chunk with uqill-style embed
    for i, chunk in ipairs(chunks) do
        SendWebhook({
            username = "UQiLL Rod Analyzer",
            avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
            embeds = {{
                description = chunk,
                color = 0x30ff6a,
                footer = { text = "Part " .. i .. "/" .. #chunks }
            }}
        })
        if i < #chunks then task.wait(1) end
    end
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔍 ADVANCED ROD FINDER")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local output = ""
local function log(text)
    print(text)
    output = output .. text .. "\n"
end

-- Deep property scanner
local function DumpProperties(obj, indent)
    indent = indent or ""
    local result = ""
    
    for _, child in pairs(obj:GetChildren()) do
        result = result .. indent .. "├─ " .. child.Name .. " (" .. child.ClassName .. ")"
        
        if child:IsA("ValueBase") then
            local ok, val = pcall(function() return child.Value end)
            if ok then result = result .. " = " .. tostring(val) end
        end
        
        local attrs = child:GetAttributes()
        if next(attrs) then
            result = result .. "\n" .. indent .. "│  Attributes:"
            for k, v in pairs(attrs) do
                result = result .. "\n" .. indent .. "│    " .. k .. " = " .. tostring(v)
            end
        end
        
        result = result .. "\n"
        
        if #child:GetChildren() > 0 and #indent < 12 then
            result = result .. DumpProperties(child, indent .. "│  ")
        end
    end
    
    return result
end

SendWebhook({
    username = "UQiLL Rod Analyzer",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🎣 Rod Analysis Starting...",
        description = "Player: `" .. LocalPlayer.Name .. "`",
        color = 0x30ff6a
    }}
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- METHOD 1: REPLION INVENTORY (Primary Source)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
log("📦 METHOD 1: REPLION INVENTORY")
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local replionSuccess = false
local replionRods = 0

pcall(function()
    local Replion = require(ReplicatedStorage.Packages.Replion)
    local Data = Replion.Client:WaitReplion("Data")
    local inventory = Data:Get("Inventory")
    
    if inventory and inventory.Items then
        replionSuccess = true
        log("✅ Inventory accessible!")
        log("Total items: " .. tostring(#inventory.Items or "unknown"))
        
        for uuid, item in pairs(inventory.Items) do
            local isRod = item.Type == "Rod"
            
            if not isRod and item.Id then
                local ok, data = pcall(function()
                    return require(ReplicatedStorage.Items[tostring(item.Id)])
                end)
                if ok and data.Data and data.Data.Type == "Rod" then
                    isRod = true
                end
            end
            
            if isRod then
                replionRods = replionRods + 1
                log("\n🎣 ROD #" .. replionRods)
                log("UUID: " .. uuid)
                log("ID: " .. tostring(item.Id))
                
                -- Dump ALL properties
                for key, value in pairs(item) do
                    if type(value) == "table" then
                        log("  " .. key .. ":")
                        for k, v in pairs(value) do
                            if type(v) == "table" then
                                log("    " .. k .. ":")
                                for k2, v2 in pairs(v) do
                                    log("      " .. k2 .. " = " .. tostring(v2))
                                end
                            else
                                log("    " .. k .. " = " .. tostring(v))
                            end
                        end
                    else
                        log("  " .. key .. " = " .. tostring(value))
                    end
                end
            end
        end
    end
end)

log("\n📊 Replion Rods Found: " .. replionRods)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- METHOD 2: PHYSICAL TOOLS (Backpack + Character)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
log("🎒 METHOD 2: PHYSICAL TOOLS")
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local physicalRods = 0

local function ScanTools(container, name)
    log("\nScanning " .. name .. "...")
    local found = 0
    
    for _, tool in pairs(container:GetChildren()) do
        if tool:IsA("Tool") then
            local isRod = tool.Name:lower():find("rod") or 
                         tool.Name:lower():find("pole") or
                         tool.Name:lower():find("fishing")
            
            if isRod then
                found = found + 1
                log("\n🎣 Physical Rod #" .. found)
                log("Name: " .. tool.Name)
                log("Path: " .. tool:GetFullName())
                
                local attrs = tool:GetAttributes()
                if next(attrs) then
                    log("Attributes:")
                    for k, v in pairs(attrs) do
                        log("  " .. k .. " = " .. tostring(v))
                    end
                end
                
                log("\nStructure:")
                log(DumpProperties(tool, "  "))
            end
        end
    end
    
    return found
end

physicalRods = physicalRods + ScanTools(LocalPlayer.Backpack, "Backpack")
if LocalPlayer.Character then
    physicalRods = physicalRods + ScanTools(LocalPlayer.Character, "Character")
end

log("\n📊 Physical Rods Found: " .. physicalRods)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- METHOD 3: ALL TOOLS (Fallback - list everything)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if physicalRods == 0 then
    log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    log("📋 METHOD 3: ALL TOOLS (Debug)")
    log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    log("\nBackpack tools:")
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            log("  • " .. tool.Name)
        end
    end
    
    if LocalPlayer.Character then
        log("\nCharacter tools:")
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                log("  • " .. tool.Name .. " (EQUIPPED)")
            end
        end
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SUMMARY
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
log("✅ SCAN COMPLETE")
log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
log("📊 Summary:")
log("  • Replion Rods: " .. replionRods)
log("  • Physical Rods: " .. physicalRods)
log("  • Total: " .. (replionRods + physicalRods))

if replionRods + physicalRods == 0 then
    log("\n⚠️ NO RODS DETECTED!")
    log("\n💡 Troubleshooting:")
    log("  1. Make sure you own a fishing rod")
    log("  2. Try equipping the rod")
    log("  3. Check 'ALL TOOLS' list above")
    log("  4. Rod might use different naming")
end

-- Send to webhook
task.wait(1)
SendLongMessage(output)
task.wait(1)
SendWebhook({
    username = "UQiLL Rod Analyzer",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "✅ Scan Complete!",
        fields = {
            { name = "Replion Rods", value = tostring(replionRods), inline = true },
            { name = "Physical Rods", value = tostring(physicalRods), inline = true },
            { name = "Total", value = tostring(replionRods + physicalRods), inline = true }
        },
        color = 0x30ff6a
    }}
})

print("\n✅ Results sent to Discord!")