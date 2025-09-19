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
    
    -- Call server to use the ability and reduce quantity
    DataService:UseAbility(slotName):andThen(function(success, message)
        if success then
            -- Ability used successfully, perform client-side effects
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
    
    -- Clear existing ability UI elements
    for _, child in pairs(centerFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Name:find("AbilitySlot") then
            child:Destroy()
        end
    end
    
    -- Create UI for each ability slot that has an ability with quantity > 0
    for slotName, abilitySlot in pairs(playerData.Abilities) do
        if abilitySlot.Name ~= "" and abilitySlot.Quantity > 0 then
            local abilityData = AbilityEnums[abilitySlot.Name]
            if abilityData then
                local newTemplate = abilityTemplate:Clone()
                newTemplate.Name = "AbilitySlot" .. slotName
                newTemplate.Visible = true
                newTemplate.Parent = centerFrame
                
                -- Update the image
                local imageLabel = newTemplate:FindFirstChild("ImageLabel")
                if imageLabel then
                    imageLabel.Image = "rbxassetid://" .. abilityData.Image
                end
                
                -- Update the keybind text
                local keybindLabel = newTemplate:FindFirstChild("KeybindLabel")
                if keybindLabel then
                    -- Find the keybind for this slot from the keyBindings table
                    for keyCode, slot in pairs(keyBindings) do
                        if slot == slotName then
                            keybindLabel.Text = keyCode.Name
                            break
                        end
                    end
                end
                
                -- Update the quantity text
                local quantityLabel = newTemplate:FindFirstChild("QuantityLabel")
                if quantityLabel then
                    quantityLabel.Text = "x" .. abilitySlot.Quantity
                end
            end
        end
    end
end

function AbilityController:PerformAbilityEffect(abilityName, abilityData)
    -- Here you would implement the actual ability logic
    -- For now, just print the ability being used
    print("Using ability:", abilityName)
    
    -- TODO: Add specific ability effects based on abilityName
    -- Examples:
    -- if abilityName == "Double Jump" then
    --     -- Enable double jump for player
    -- elseif abilityName == "Speed Boost" then
    --     -- Apply speed boost to player
    -- end
end

function AbilityController:KnitStart()
    -- Connect to ability data changes
    DataController.onReplicated("Abilities"):Connect(function()
        self:UpdateAbilityUI()
    end)
    
    -- Initial UI update
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