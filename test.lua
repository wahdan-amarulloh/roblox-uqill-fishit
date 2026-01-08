--// WindUI Loader
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Anims = require(RS.Modules.Animations)

-- VFX modules (exist in your game)
local RodThrowVFXData = require(RS.Shared.RodThrowVFXData)
local VFXController = require(RS.Controllers.VFXController)

--// Helper: Get Animator
local function getAnimator()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    return hum:WaitForChild("Animator")
end

local function getHRP()
    local char = player.Character
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
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

--========================================================
-- VFX HOOK SECTION (for override only)
--========================================================
local vfxEnabled = true       -- toggle from GUI
local hookOverrideVFX = true  -- only active after override applied
local vfxHookRunning = false

-- Markers that MAY be used by different rod throws
local KNOWN_MARKERS = {
    "Throw",
    "THROW_SCYTHE",
    "FLEX_THROW_LINE",
    "HARP_THROW_LINE",
    "THROW_LINE",
    "ADD_ARROW",
    "HIDE_ARROW",

    -- direct VFX keys (sometimes markerName itself is VFX key)
    "EternalFlowerThrow",
    "BlackholeThrow",
    "GingerbreadKatanaThrow",
    "ChristmasParasolThrow",
    "EclipseKatanaThrow",
    "PrincessParasolThrow",
    "CorruptionEdgeThrow",
    "BanHammerThrow",
    "BinaryEdgeThrow",
    "TheVanquisherThrow",
    "FrozenKrampusScytheThrow",
}

-- Optional: alias marker -> VFXData key
-- Kamu bisa tambah di sini kalau kamu menemukan marker yg beda
local MARKER_ALIAS = {
    -- contoh (kalau dibutuhkan):
    -- ["THROW_SCYTHE"] = "SoulScytheThrow",
    -- ["Throw"] = "BinaryEdgeThrow",
}

local hookedTracks = {} -- track => true
local heartbeatConn

local function safeHandleVFX(markerName)
    if not vfxEnabled then return end
    if not hookOverrideVFX then return end

    local key = MARKER_ALIAS[markerName] or markerName
    local data = RodThrowVFXData[key]
    if not data then return end

    local hrp = getHRP()
    if not hrp then return end

    -- If offset exists, spawn based on HRP * offset
    if data.Offset then
        local cf = hrp.CFrame * data.Offset
        pcall(function()
            VFXController.Handle(key, cf)
        end)
        return
    end

    -- If attachment-based, just call handle with HRP CFrame (controller will resolve)
    if data.PlayAttachment then
        pcall(function()
            VFXController.Handle(key, hrp.CFrame)
        end)
    end
end

local function hookTrack(track)
    if hookedTracks[track] then return end
    hookedTracks[track] = true

    for _, marker in ipairs(KNOWN_MARKERS) do
        pcall(function()
            track:GetMarkerReachedSignal(marker):Connect(function()
                safeHandleVFX(marker)
            end)
        end)
    end

    track.Destroying:Once(function()
        hookedTracks[track] = nil
    end)
end

local function startVFXHook()
    if vfxHookRunning then return end
    vfxHookRunning = true

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if not hookOverrideVFX then return end
        local animator = getAnimator()
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            hookTrack(track)
        end
    end)

    WindUI:Notify({Title="Animation Explorer", Content="VFX Hook Active (for override)."})
end

local function stopVFXHook()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    table.clear(hookedTracks)
    vfxHookRunning = false
    WindUI:Notify({Title="Animation Explorer", Content="VFX Hook Stopped."})
end

--========================================================
-- Override Logic
--========================================================
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

    -- activate VFX hook AFTER override
    hookOverrideVFX = true
    startVFXHook()

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

    -- disable override VFX hook (optional)
    hookOverrideVFX = false
    stopVFXHook()

    WindUI:Notify({Title="Animation Explorer", Content="Reset to original defaults ("..restored.." restored)."})
end

--========================================================
-- UI + Hotkey
--========================================================
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
local guiVisible = true
local toggleKey = Enum.KeyCode.RightShift -- safe default

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

Section:Toggle({
    Title = "Enable VFX On Override",
    Value = vfxEnabled,
    Callback = function(v)
        vfxEnabled = v
        WindUI:Notify({Title="Animation Explorer", Content="VFX On Override: "..tostring(v)})
    end
})

Section:Button({
    Title = "Override Default Actions With Selected Rod (VFX Enabled)",
    Callback = function()
        overrideDefaultWithRodPreset(selectedRod)
    end
})

Section:Button({
    Title = "Reset Overrides (Stop VFX Hook)",
    Callback = function()
        resetOverrides()
    end
})

Section:Divider()

Section:Button({
    Title = "Hotkey Toggle GUI = RightShift (Click to Change to Insert)",
    Callback = function()
        toggleKey = (toggleKey == Enum.KeyCode.RightShift) and Enum.KeyCode.Insert or Enum.KeyCode.RightShift
        WindUI:Notify({Title="Animation Explorer", Content="GUI Toggle Key: "..tostring(toggleKey)})
    end
})

-- Hotkey: toggle window visibility
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == toggleKey then
        guiVisible = not guiVisible

        -- WindUI has different internal window classes depending versions.
        -- Most WindUI windows support :Toggle() OR setting .Visible on main frame.
        -- We'll try both safely.
        pcall(function()
            if Window.Toggle then
                Window:Toggle(guiVisible)
            elseif Window.SetVisible then
                Window:SetVisible(guiVisible)
            elseif Window.Visible ~= nil then
                Window.Visible = guiVisible
            end
        end)

        WindUI:Notify({Title="Animation Explorer", Content="GUI Visible: "..tostring(guiVisible)})
    end
end)

WindUI:Notify({
    Title="Animation Explorer",
    Content="Loaded. Preview first. Override is client-only. VFX will trigger during override gameplay."
})
