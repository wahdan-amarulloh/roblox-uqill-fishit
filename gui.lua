--// WindUI Loader
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================
-- Helpers
--========================
local function getPlayerGuiEntries()
    local list = {}
    for _, obj in ipairs(playerGui:GetChildren()) do
        if obj:IsA("ScreenGui") then
            table.insert(list, obj.Name)
        end
    end
    table.sort(list)
    return list
end

local function getGuiByName(name)
    return playerGui:FindFirstChild(name)
end

local function getStatusText(gui)
    if not gui then return "N/A" end
    if gui:IsA("ScreenGui") then
        return gui.Enabled and "Enabled ✅" or "Disabled ❌"
    end
    return "Not ScreenGui"
end

--========================
-- UI
--========================
local Window = WindUI:CreateWindow({
    Title = "PlayerGui Explorer",
    Icon = "layout-dashboard",
    Author = "Wahdan Tools",
    Folder = "GuiExplorer",
    Size = UDim2.fromOffset(520, 420),
})

local Tab = Window:Tab({ Title = "Explorer", Icon = "search" })
local Section = Tab:Section({ Title = "PlayerGui ScreenGuis" })

local guiList = getPlayerGuiEntries()
local selectedGuiName = guiList[1] or ""
local statusLabel

-- Dropdown to select GUI
local dropdown = Section:Dropdown({
    Title = "Select ScreenGui",
    Values = guiList,
    Value = selectedGuiName,
    Callback = function(v)
        selectedGuiName = v
        local gui = getGuiByName(selectedGuiName)
        if statusLabel then
            statusLabel:Set("Status: " .. getStatusText(gui))
        end
    end
})

-- Status label
statusLabel = Section:Label({
    Title = "Status: " .. getStatusText(getGuiByName(selectedGuiName))
})

-- Toggle button
Section:Button({
    Title = "Toggle Enabled (Show/Hide)",
    Callback = function()
        local gui = getGuiByName(selectedGuiName)
        if not gui then
            WindUI:Notify({Title="PlayerGui Explorer", Content="GUI not found: "..tostring(selectedGuiName)})
            return
        end

        if gui:IsA("ScreenGui") then
            gui.Enabled = not gui.Enabled
            if statusLabel then
                statusLabel:Set("Status: " .. getStatusText(gui))
            end
            WindUI:Notify({Title="PlayerGui Explorer", Content=("Toggled '%s' => %s"):format(gui.Name, gui.Enabled and "Enabled" or "Disabled")})
        else
            WindUI:Notify({Title="PlayerGui Explorer", Content=("'%s' is not a ScreenGui"):format(gui.Name)})
        end
    end
})

-- Force enable button (helpful if scripts keep disabling)
Section:Button({
    Title = "Force Enable",
    Callback = function()
        local gui = getGuiByName(selectedGuiName)
        if gui and gui:IsA("ScreenGui") then
            gui.Enabled = true
            statusLabel:Set("Status: " .. getStatusText(gui))
            WindUI:Notify({Title="PlayerGui Explorer", Content=("Force Enabled '%s'"):format(gui.Name)})
        end
    end
})

-- Force disable button
Section:Button({
    Title = "Force Disable",
    Callback = function()
        local gui = getGuiByName(selectedGuiName)
        if gui and gui:IsA("ScreenGui") then
            gui.Enabled = false
            statusLabel:Set("Status: " .. getStatusText(gui))
            WindUI:Notify({Title="PlayerGui Explorer", Content=("Force Disabled '%s'"):format(gui.Name)})
        end
    end
})

Section:Divider()

-- Refresh list button
Section:Button({
    Title = "Refresh List",
    Callback = function()
        guiList = getPlayerGuiEntries()

        -- update dropdown values
        dropdown:SetValues(guiList)

        -- keep selected if still exists
        if not table.find(guiList, selectedGuiName) then
            selectedGuiName = guiList[1] or ""
            dropdown:Set(selectedGuiName)
        end

        local gui = getGuiByName(selectedGuiName)
        statusLabel:Set("Status: " .. getStatusText(gui))

        WindUI:Notify({Title="PlayerGui Explorer", Content="Refreshed ScreenGui list ("..#guiList..")"})
    end
})

WindUI:Notify({Title="PlayerGui Explorer", Content="Loaded. Select any ScreenGui and toggle it."})
