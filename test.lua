-- Gift System Direct Test
-- Try calling methods directly with product IDs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🎁 GIFT DIRECT TEST")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local GiftingController = require(ReplicatedStorage.Controllers.GiftingController)

-- Test Product IDs from earlier analysis
local testProducts = {
    3274772526, -- Luck II Potion (from earlier data)
    3274773921, -- Luck II Potion x10
    2678950020, -- Mutation I Potion
    2678950936  -- Mutation I Potion x10
}

print("\n🧪 TESTING DIRECT GIFT METHODS:\n")

for i, productId in ipairs(testProducts) do
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Test #" .. i .. " - ProductId: " .. productId)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- Test 1: Open gift UI
    local openOk, openErr = pcall(function()
        GiftingController:Open(productId)
    end)
    print("Open(): " .. (openOk and "✅ Success" or "❌ " .. tostring(openErr)))
    
    task.wait(0.5)
    
    -- Test 2: Set self as target
    local targetOk, targetErr = pcall(function()
        GiftingController:SetTarget(LocalPlayer)
    end)
    print("SetTarget(self): " .. (targetOk and "✅ Success" or "❌ " .. tostring(targetErr)))
    
    task.wait(0.5)
    
    -- Test 3: Try with UserId
    local userIdOk, userIdErr = pcall(function()
        GiftingController:SetTarget(LocalPlayer.UserId)
    end)
    print("SetTarget(UserId): " .. (userIdOk and "✅ Success" or "❌ " .. tostring(userIdErr)))
    
    task.wait(0.5)
    
    -- Test 4: Close
    pcall(function()
        GiftingController:Close()
    end)
    
    print()
    task.wait(1)
end

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("💡 ALTERNATIVE TEST: Open WITHOUT ProductId")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local noArgOk, noArgErr = pcall(function()
    GiftingController:Open()
end)
print("Open(): " .. (noArgOk and "✅ Success - UI opened!" or "❌ " .. tostring(noArgErr)))

if noArgOk then
    print("\n✅ Gift UI opened without product!")
    print("Check your screen - can you select items?")
    print("\n🎯 Try manually:")
    print("  1. Select a player (yourself)")
    print("  2. Select an item")
    print("  3. See if it allows self-gifting")
else
    print("\n❌ Gift system requires product parameter")
end

print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ DIRECT TEST COMPLETE")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")