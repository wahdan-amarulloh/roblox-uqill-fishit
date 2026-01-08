--// WindUI Loader
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Anims = require(RS.Modules.Animations)

--// Helper: Get Animator
local function getAnimator()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    return hum:WaitForChild("Animator")
end

--// Track preview instance
local currentTrack

local function stopPreview()
    if currentTrack then
        pcall(function()
            currentTrack:Stop()
            currentTrack:Destroy()
        end)
        currentTrack = nil
    end
end

local function previewAnimation(animKey)
    local data = Anims[animKey]
    if not data or data.Disabled then
        WindUI:Notify({Title="Animation Explorer", Content="Anim not found/disabled: "..tostring(animKey)})
        return
    end

    local animator = getAnimator()

    stopPreview()

    local anim = Instance.new("Animation")
    anim.AnimationId = data.AnimationId

    local track = animator:LoadAnimation(anim)
    track.Priority = data.AnimationPriority or Enum.AnimationPriority.Action
    track.Looped = data.Looped or false
    track:Play(nil, nil, data.PlaybackSpeed or 1)

    currentTrack = track
    WindUI:Notify({Title="Animation Explorer", Content="Preview: "..animKey})
end

--// Collect Rod Presets dynamically from Anim keys
local RodPresets = { "Default" }
do
    local seen = {}
    for k,_ in pairs(Anims) do
        local rod = k:match("^(.-) %- ")
        if rod and not seen[rod] then
            seen[rod] = true
            table.insert(RodPresets, rod)
        end
    end
end
table.sort(RodPresets)

--// Actions we care about
local Actions = {"RodThrow","ReelingIdle","ReelStart","ReelIntermission","EquipIdle","FishCaught","StartRodCharge","LoopedRodCharge"}

--// Backup original IDs for reset
local originalIds = {}
for _, action in ipairs(Actions) do
    if Anims[action] and Anims[action].AnimationId then
        originalIds[action] = Anims[action].AnimationId
    end
end

--// Override default action animations with preset rod variants
local function overrideDefaultWithRodPreset(rodPreset)
    if rodPreset == "Default" then
        WindUI:Notify({Title="Animation Explorer", Content="Default preset selected. Use Reset instead."})
        return
    end

    local applied = 0
    for _, action in ipairs(Actions) do
        local fromKey = string.format("%s - %s", rodPreset, action)
        local fromData = Anims[fromKey]
        local baseData = Anims[action]

        if baseData and baseData.AnimationId and fromData and not fromData.Disabled and fromData.AnimationId then
            baseData.AnimationId = fromData.AnimationId
            applied += 1
        end
    end

    WindUI:Notify({
        Title="Animation Explorer",
        Content=("Override applied from '%s' (%d/%d actions). Respawn recommended if no change."):format(rodPreset, applied, #Actions)
    })
end

local function resetOverrides()
    local restored = 0
    for action, id in pairs(originalIds) do
        if Anims[action] and Anims[action].AnimationId then
            Anims[action].AnimationId = id
            restored += 1
        end
    end
    stopPreview()
    WindUI:Notify({Title="Animation Explorer", Content="Reset to original defaults ("..restored.." restored)."})
end

--// UI
local Window = WindUI:CreateWindow({
    Title = "Animation Explorer",
    Icon = "sparkles",
    Author = "Wahdan Tools",
    Folder = "AnimExplorer",
    Size = UDim2.fromOffset(560, 460),
})

local Tab = Window:Tab({ Title = "Explorer", Icon = "search" })
local Section = Tab:Section({ Title = "Preview & Override" })

local selectedRod = "Default"
local selectedAction = "RodThrow"

Section:Dropdown({
    Title = "Rod Preset",
    Values = RodPresets,
    Value = selectedRod,
    Callback = function(v) selectedRod = v end
})

Section:Dropdown({
    Title = "Action",
    Values = Actions,
    Value = selectedAction,
    Callback = function(v) selectedAction = v end
})

Section:Button({
    Title = "Preview Selected",
    Callback = function()
        local key = (selectedRod == "Default") and selectedAction or (selectedRod .. " - " .. selectedAction)
        previewAnimation(key)
    end
})

Section:Button({
    Title = "Stop Preview",
    Callback = function()
        stopPreview()
        WindUI:Notify({Title="Animation Explorer", Content="Preview stopped."})
    end
})

Section:Divider()

Section:Button({
    Title = "Override Default Actions With Selected Rod",
    Callback = function()
        overrideDefaultWithRodPreset(selectedRod)
    end
})

Section:Button({
    Title = "Reset Overrides",
    Callback = function()
        resetOverrides()
    end
})

WindUI:Notify({Title="Animation Explorer", Content="Loaded. Use Preview first. Override is client-only (visual)."})
