local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Knit = require(Packages.Knit)
local AbilityEnums = require(Shared.Data.AbilityEnums)

local DataController
local DataService

local AbilityController = Knit.CreateController({
    Name = "AbilityController",
})

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local framesFolder = mainGui:WaitForChild("Frames")
local utilityFrame = mainGui:WaitForChild("Utility")
local centerFrame = utilityFrame:WaitForChild("Center")

local abilityTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UIAssets"):WaitForChild("AbilityTemplate")

local keyBindings = {
    [Enum.KeyCode.F] = "Slot1",
    [Enum.KeyCode.Q] = "Slot2", 
    [Enum.KeyCode.E] = "Slot3"
}

function AbilityController:UseAbility(slotName)
    local playerData = DataController.getData()
    if not playerData or not playerData.Abilities then
        return
    end
    
    local abilitySlot = playerData.Abilities[slotName]
    if not abilitySlot or abilitySlot.Name == "" or abilitySlot.Quantity <= 0 then
        return
    end
    
    local abilityData = AbilityEnums[abilitySlot.Name]
    if not abilityData then
        return
    end
    
    DataService:UseAbility(slotName):andThen(function(success, message)
        if success then
            self:PerformAbilityEffect(abilitySlot.Name, abilityData)
        end
    end):catch(function(err)
        warn("Failed to use ability:", err)
    end)
end

function AbilityController:UpdateAbilityUI()
    local playerData = DataController.getData()
    if not playerData or not playerData.Abilities then
        return
    end
    
    for _, child in pairs(centerFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Name:find("AbilitySlot") then
            child:Destroy()
        end
    end
    
    for slotName, abilitySlot in pairs(playerData.Abilities) do
        if abilitySlot.Name ~= "" and abilitySlot.Quantity > 0 then
            local abilityData = AbilityEnums[abilitySlot.Name]
            if abilityData then
                local newTemplate = abilityTemplate:Clone()
                newTemplate.Name = "AbilitySlot" .. slotName
                newTemplate.Visible = true
                newTemplate.Parent = centerFrame
                
                local imageLabel = newTemplate:FindFirstChild("ImageLabel")
                if imageLabel then
                    imageLabel.Image = "rbxassetid://" .. abilityData.Image
                end
                
                local keybindLabel = newTemplate:FindFirstChild("Keybind")
                if keybindLabel then
                    for keyCode, slot in pairs(keyBindings) do
                        if slot == slotName then
                            keybindLabel.Text = keyCode.Name
                            break
                        end
                    end
                end
                
                local quantityLabel = newTemplate:FindFirstChild("Quantity")
                if quantityLabel then
                    quantityLabel.Text = "x" .. abilitySlot.Quantity
                end
            end
        end
    end
end

function AbilityController:PerformAbilityEffect(abilityName, abilityData)
    print("Using ability:", abilityName)
    
    local success, abilityModule = pcall(function()
        return require(script.Parent.Parent.Modules.Abilities[abilityName])
    end)
    
    if success and abilityModule and abilityModule.Execute then
        if abilityName == "Invisibility" then
            task.spawn(function()
                abilityModule.Execute()
            end)
        else
            abilityModule.Execute()
        end
    else
        warn("Ability module not found or invalid:", abilityName)
    end
end

function AbilityController:KnitStart()
    DataController.onReplicated("Abilities"):Connect(function()
        self:UpdateAbilityUI()
    end)
    
    task.wait(1)
    self:UpdateAbilityUI()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        
        local slotName = keyBindings[input.KeyCode]
        if slotName then
            self:UseAbility(slotName)
        end
    end)
end

function AbilityController:KnitInit()
    DataController = Knit.GetController("DataController")
    DataService = Knit.GetService("DataService")
end

return AbilityController