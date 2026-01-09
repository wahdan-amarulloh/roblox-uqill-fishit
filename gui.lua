local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================
-- Helpers
--========================
local function getScreenGuiNames()
    local names = {}
    for _, obj in ipairs(playerGui:GetChildren()) do
        if obj:IsA("ScreenGui") then
            table.insert(names, obj.Name)
        end
    end
    table.sort(names)
    return names
end

local function getGui(name)
    return playerGui:FindFirstChild(name)
end

--========================
-- UI
--========================
local Window = WindUI:CreateWindow({
    Title = "PlayerGui Explorer",
    Icon = "layout-dashboard",
    Author = "Wahdan Tools",
    Folder = "GuiExplorer",
    Size = UDim2.fromOffset(560, 420),
})

local Tab = Window:Tab({ Title = "Explorer", Icon = "search" })
local Section = Tab:Section({ Title = "PlayerGui ScreenGuis" })

local guiNames = getScreenGuiNames()
local selectedName = guiNames[1] or ""

Section:Dropdown({
    Title = "Select ScreenGui",
    Values = guiNames,
    Value = selectedName,
    Callback = function(v)
        selectedName = v
        local gui = getGui(selectedName)
        WindUI:Notify({
            Title = "Selected",
            Content = selectedName .. " | Enabled = " .. tostring(gui and gui.Enabled)
        })
    end
})

Section:Button({
    Title = "Toggle Enabled (On/Off)",
    Callback = function()
        local gui = getGui(selectedName)
        if not gui then
            WindUI:Notify({Title="Error", Content="GUI not found: "..tostring(selectedName)})
            return
        end
        if not gui:IsA("ScreenGui") then
            WindUI:Notify({Title="Error", Content=selectedName.." is not a ScreenGui"})
            return
        end
        gui.Enabled = not gui.Enabled
        WindUI:Notify({Title="Toggled", Content=selectedName.." => "..tostring(gui.Enabled)})
    end
})

Section:Button({
    Title = "Force Enable",
    Callback = function()
        local gui = getGui(selectedName)
        if gui and gui:IsA("ScreenGui") then
            gui.Enabled = true
            WindUI:Notify({Title="Force Enable", Content=selectedName.." => true"})
        else
            WindUI:Notify({Title="Error", Content="Not a ScreenGui"})
        end
    end
})

Section:Button({
    Title = "Force Disable",
    Callback = function()
        local gui = getGui(selectedName)
        if gui and gui:IsA("ScreenGui") then
            gui.Enabled = false
            WindUI:Notify({Title="Force Disable", Content=selectedName.." => false"})
        else
            WindUI:Notify({Title="Error", Content="Not a ScreenGui"})
        end
    end
})

Section:Button({
    Title = "Refresh (Print List)",
    Callback = function()
        local newList = getScreenGuiNames()
        print("=== PlayerGui ScreenGuis ===")
        for _, name in ipairs(newList) do
            local gui = getGui(name)
            print(name, "Enabled=", gui and gui.Enabled)
        end
        WindUI:Notify({Title="Refresh", Content="Printed "..#newList.." ScreenGuis in console"})
    end
})

WindUI:Notify({Title="PlayerGui Explorer", Content="Loaded. Select GUI then use Toggle/Force buttons."})
