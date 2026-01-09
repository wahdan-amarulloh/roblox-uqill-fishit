local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local cmdr = player:WaitForChild("PlayerGui"):WaitForChild("Cmdr")

cmdr.DisplayOrder = 999999

-- Grab references based on your real path
local mainFrame = cmdr:WaitForChild("Frame")
local autoFrame = cmdr:FindFirstChild("Autocomplete") -- optional
local entry = mainFrame:WaitForChild("Entry") -- this is the key

--========================
-- Movement Block (backup)
--========================
local function sink()
    return Enum.ContextActionResult.Sink
end

local function enableBlock()
    CAS:BindAction("CmdrBlockW", sink, false, Enum.KeyCode.W)
    CAS:BindAction("CmdrBlockA", sink, false, Enum.KeyCode.A)
    CAS:BindAction("CmdrBlockS", sink, false, Enum.KeyCode.S)
    CAS:BindAction("CmdrBlockD", sink, false, Enum.KeyCode.D)
    CAS:BindAction("CmdrBlockSpace", sink, false, Enum.KeyCode.Space)
end

local function disableBlock()
    CAS:UnbindAction("CmdrBlockW")
    CAS:UnbindAction("CmdrBlockA")
    CAS:UnbindAction("CmdrBlockS")
    CAS:UnbindAction("CmdrBlockD")
    CAS:UnbindAction("CmdrBlockSpace")
end

--========================
-- Toggle logic
--========================
local isOpen = false

local function openCmdr()
    cmdr.Enabled = true
    mainFrame.Visible = true
    if autoFrame then autoFrame.Visible = true end

    -- make Entry capture keyboard
    entry.Visible = true
    entry.Active = true
    entry.TextEditable = true
    entry.ClearTextOnFocus = false
    entry.Modal = true  -- IMPORTANT: steal input from game

    enableBlock()

    task.wait(0.05)
    pcall(function()
        entry:CaptureFocus()
    end)

    isOpen = true
    print("[Cmdr] OPEN")
end

local function closeCmdr()
    -- release input
    entry.Modal = false
    pcall(function()
        entry:ReleaseFocus()
    end)

    cmdr.Enabled = false
    disableBlock()

    isOpen = false
    print("[Cmdr] CLOSE")
end

local function toggleCmdr()
    if isOpen then
        closeCmdr()
    else
        openCmdr()
    end
end

--========================
-- Hotkeys
--========================
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        toggleCmdr()
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        -- emergency unfreeze
        entry.Modal = false
        disableBlock()
        isOpen = false
        print("[Cmdr] EMERGENCY UNFREEZE")
    end
end)

print("[Cmdr] Loaded. Press ';' to toggle. RightShift = emergency unfreeze.")
