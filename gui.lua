local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local cmdrGui = playerGui:WaitForChild("Cmdr")

cmdrGui.DisplayOrder = 999999

--========================
-- Movement block
--========================
local function sink()
    return Enum.ContextActionResult.Sink
end

local function enableTypingBlock()
    CAS:BindAction("CmdrBlockW", sink, false, Enum.KeyCode.W)
    CAS:BindAction("CmdrBlockA", sink, false, Enum.KeyCode.A)
    CAS:BindAction("CmdrBlockS", sink, false, Enum.KeyCode.S)
    CAS:BindAction("CmdrBlockD", sink, false, Enum.KeyCode.D)
    CAS:BindAction("CmdrBlockSpace", sink, false, Enum.KeyCode.Space)
end

local function disableTypingBlock()
    CAS:UnbindAction("CmdrBlockW")
    CAS:UnbindAction("CmdrBlockA")
    CAS:UnbindAction("CmdrBlockS")
    CAS:UnbindAction("CmdrBlockD")
    CAS:UnbindAction("CmdrBlockSpace")
end

--========================
-- Find input TextBox
--========================
local function findMainTextBox()
    -- prefer TextBox paling panjang (biasanya command bar)
    local best, bestLen = nil, 0
    for _, v in ipairs(cmdrGui:GetDescendants()) do
        if v:IsA("TextBox") then
            local len = (v.AbsoluteSize.X or 0)
            if v.Visible and v.Active and len > bestLen then
                best = v
                bestLen = len
            end
        end
    end
    return best
end

local textBox
local keepFocusConn

local function forceFocus()
    textBox = textBox or findMainTextBox()
    if not textBox then
        warn("[CmdrToggle] TextBox not found")
        return
    end

    textBox.ClearTextOnFocus = false
    textBox.TextEditable = true
    textBox.Active = true

    task.wait(0.05)
    pcall(function()
        textBox:CaptureFocus()
    end)

    -- kalau fokus hilang karena klik luar, ambil lagi biar Cmdr gak auto close
    if not keepFocusConn then
        keepFocusConn = textBox.FocusLost:Connect(function()
            task.wait(0.05)
            if cmdrGui.Enabled then
                pcall(function()
                    textBox:CaptureFocus()
                end)
            end
        end)
    end
end

--========================
-- Open / Close
--========================
local function openCmdr()
    cmdrGui.Enabled = true
    enableTypingBlock()
    forceFocus()
    print("[CmdrToggle] OPEN")
end

local function closeCmdr()
    cmdrGui.Enabled = false
    disableTypingBlock()

    if textBox then
        pcall(function()
            textBox:ReleaseFocus()
        end)
    end

    print("[CmdrToggle] CLOSE")
end

local function toggleCmdr()
    if cmdrGui.Enabled then
        closeCmdr()
    else
        openCmdr()
    end
end

--========================
-- Hotkey ;
--========================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        toggleCmdr()
    end
end)

print("[CmdrToggle] Loaded. Press ';' to toggle Cmdr.")
