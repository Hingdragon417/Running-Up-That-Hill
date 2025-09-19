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
    print("=== UseAbility Called ===")
    print("SlotName:", slotName)
    
    local playerData = DataController.getData()
    print("PlayerData exists:", playerData ~= nil)
    
    if not playerData or not playerData.Abilities then
        print("ERROR: No player data or abilities found")
        return
    end
    
    print("Abilities data:", playerData.Abilities)
    
    local abilitySlot = playerData.Abilities[slotName]
    print("AbilitySlot for", slotName, ":", abilitySlot)
    
    if not abilitySlot or abilitySlot.Name == "" or abilitySlot.Quantity <= 0 then
        print("ERROR: Invalid ability slot - Name:", abilitySlot and abilitySlot.Name or "nil", "Quantity:", abilitySlot and abilitySlot.Quantity or "nil")
        return
    end
    
    local abilityData = AbilityEnums[abilitySlot.Name]
    print("AbilityData for", abilitySlot.Name, "exists:", abilityData ~= nil)
    
    if not abilityData then
        print("ERROR: No ability data found for:", abilitySlot.Name)
        return
    end
    
    print("Calling DataService:UseAbility...")
    DataService:UseAbility(slotName):andThen(function(success, message)
        print("DataService response - Success:", success, "Message:", message)
        if success then
            print("Performing ability effect for:", abilitySlot.Name)
            self:PerformAbilityEffect(abilitySlot.Name, abilityData)
        else
            print("Ability use failed:", message)
        end
    end):catch(function(err)
        print("ERROR: Failed to use ability:", err)
    end)
end

function AbilityController:UpdateAbilityUI()
    local playerData = DataController.getData()
    if not playerData or not playerData.Abilities then
        return
    end
    
    -- Attempt to update UI - fail silently if UI not available
    pcall(function()
        -- Cleanup existing UI elements
        for _, child in pairs(centerFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name:find("AbilitySlot") then
                child:Destroy()
            end
        end
        
        -- Create new UI elements
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
    end)
end

function AbilityController:PerformAbilityEffect(abilityName, abilityData)
    print("=== PerformAbilityEffect Called ===")
    print("AbilityName:", abilityName)
    print("AbilityData:", abilityData)
    
    local modulePath = script.Parent.Parent.Modules.Abilities[abilityName]
    print("Module path exists:", modulePath ~= nil)
    
    local success, abilityModule = pcall(function()
        return require(modulePath)
    end)
    
    print("Module require success:", success)
    if success then
        print("AbilityModule loaded:", abilityModule ~= nil)
        print("Execute function exists:", abilityModule and abilityModule.Execute ~= nil)
    else
        print("ERROR: Failed to require module:", abilityModule)
    end
    
    if success and abilityModule and abilityModule.Execute then
        print("Executing ability:", abilityName)
        if abilityName == "Invisibility" then
            task.spawn(function()
                abilityModule.Execute()
            end)
        else
            abilityModule.Execute()
        end
        print("Ability execution completed")
    else
        print("ERROR: Ability module not found or invalid:", abilityName)
    end
end

function AbilityController:KnitStart()
    print("=== AbilityController:KnitStart ===")
    
    -- Key bindings - completely independent of UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        
        local slotName = keyBindings[input.KeyCode]
        if slotName then
            print("Key pressed:", input.KeyCode.Name, "-> Slot:", slotName)
            self:UseAbility(slotName)
        end
    end)
    print("Key bindings connected")
    
    -- UI updates only when data changes
    DataController.onReplicated("Abilities"):Connect(function()
        print("Abilities data replicated, updating UI")
        self:UpdateAbilityUI()
    end)
    print("Data replication connected")
    
    task.wait(1)
    -- Initial UI update
    print("Performing initial UI update")
    self:UpdateAbilityUI()
    print("AbilityController initialization complete")
end

function AbilityController:KnitInit()
    DataController = Knit.GetController("DataController")
    DataService = Knit.GetService("DataService")
end

return AbilityController