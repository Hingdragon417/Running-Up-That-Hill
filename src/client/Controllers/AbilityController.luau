local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Knit = require(Packages.Knit)
local AbilityEnums = require(Shared.Data.AbilityEnums)

local DataController

local AbilityController = Knit.CreateController({
    Name = "AbilityController",
})

local player = Players.LocalPlayer

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
    
    print("Using ability:", abilitySlot.Name, "from", slotName)
    
    -- Here you would implement the actual ability logic
    -- For now, just print the ability being used
end

function AbilityController:KnitStart()
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
end

return AbilityController