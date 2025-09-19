local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local ShopService = Knit.CreateService({
    Name = "ShopService",
    Client = {
        PurchaseAbility = "PurchaseAbility"
    }
})

local AbilityEnums = require(ReplicatedStorage.Shared.Data.AbilityEnums)
local DataService

function ShopService:GenerateShopItems()
    local shopItems = {}
    local maxItems = 3
    
    local availableAbilities = {}
    for abilityName, abilityData in pairs(AbilityEnums) do
        table.insert(availableAbilities, {
            name = abilityName,
            data = abilityData
        })
    end
    
    local maxAttempts = 100
    local attempts = 0
    
    while #shopItems < maxItems and attempts < maxAttempts do
        attempts = attempts + 1
        
        for _, ability in pairs(availableAbilities) do
            if #shopItems >= maxItems then
                break
            end
            
            local alreadySelected = false
            for _, selectedItem in pairs(shopItems) do
                if selectedItem.name == ability.name then
                    alreadySelected = true
                    break
                end
            end
            
            if not alreadySelected then
                local randomNumber = math.random(1, 100)
                if randomNumber <= ability.data.Chance then
                    table.insert(shopItems, ability)
                end
            end
        end
    end
    
    if #shopItems < maxItems then
        local remainingSlots = maxItems - #shopItems
        local unselectedAbilities = {}
        
        for _, ability in pairs(availableAbilities) do
            local alreadySelected = false
            for _, selectedItem in pairs(shopItems) do
                if selectedItem.name == ability.name then
                    alreadySelected = true
                    break
                end
            end
            if not alreadySelected then
                table.insert(unselectedAbilities, ability)
            end
        end
        
        for i = 1, math.min(remainingSlots, #unselectedAbilities) do
            table.insert(shopItems, unselectedAbilities[i])
        end
    end
    
    return shopItems
end

function ShopService.Client:PurchaseAbility(player, abilityName)
    local session = DataService.getSession(player)
    if not session or not session.Data then
        return false, "No player data found"
    end
    
    local abilityData = AbilityEnums[abilityName]
    if not abilityData then
        return false, "Ability not found"
    end
    
    local currentStock = session.Data.Shop[abilityName]
    if not currentStock or currentStock <= 0 then
        return false, "Out of stock or not available"
    end
    
    if session.Data.Cash < abilityData.Price then
        return false, "Not enough cash"
    end
    
    local availableSlot = nil
    -- First, check if we already have this ability equipped somewhere
    for _, slot in pairs({"Slot1", "Slot2", "Slot3"}) do
        if session.Data.Abilities[slot].Name == abilityName then
            availableSlot = slot
            break
        end
    end
    
    -- If we don't have it equipped, find an empty slot
    if not availableSlot then
        if session.Data.Abilities.Slot1.Name == "" then
            availableSlot = "Slot1"
        elseif session.Data.Abilities.Slot2.Name == "" then
            availableSlot = "Slot2"
        elseif session.Data.Abilities.Slot3.Name == "" then
            availableSlot = "Slot3"
        end
    end
    
    if not availableSlot then
        return false, "No available ability slots"
    end
    
    session.Data.Cash = session.Data.Cash - abilityData.Price
    session.Data.Shop[abilityName] = currentStock - 1
    
    if session.Data.Abilities[availableSlot].Name == abilityName then
        session.Data.Abilities[availableSlot].Quantity = session.Data.Abilities[availableSlot].Quantity + 1
    else
        session.Data.Abilities[availableSlot].Name = abilityName
        session.Data.Abilities[availableSlot].Quantity = 1
    end
    
    DataService:Replicate(player, {"Cash", "Abilities", "Shop"})
    
    return true, "Purchase successful"
end

function ShopService:UpdatePlayerShops(shopItems)
    for _, player in pairs(Players:GetPlayers()) do
        local session = DataService.getSession(player)
        
        if session then
            if session.Data then                
                -- Check if shop is in old array format and force reset
                local needsReset = false
                if session.Data.Shop then
                    -- Check if it's an array (old format) instead of a dictionary (new format)
                    if #session.Data.Shop > 0 then
                        needsReset = true
                    elseif next(session.Data.Shop) == nil then
                        needsReset = true
                    end
                else
                    needsReset = true
                end
                
                if needsReset then
                    session.Data.Shop = {}
                    session.Data.RestockTimer = 15 * 60
                    for _, item in pairs(shopItems) do
                        session.Data.Shop[item.name] = item.data.Stock
                    end
                    DataService:Replicate(player, {"Shop", "RestockTimer"})
                end
            end
        else
            -- Retry after a delay for players without sessions
            task.spawn(function()
                task.wait(2) -- Wait 2 seconds for session to load
                local retrySession = DataService.getSession(player)
                if retrySession and retrySession.Data then
                    if not retrySession.Data.Shop or next(retrySession.Data.Shop) == nil then
                        retrySession.Data.Shop = {}
                        retrySession.Data.RestockTimer = 15 * 60
                        for _, item in pairs(shopItems) do
                            retrySession.Data.Shop[item.name] = item.data.Stock
                        end
                        DataService:Replicate(player, {"Shop", "RestockTimer"})
                    end
                end
            end)
        end
    end
end

function ShopService:StartRestockTimer()
    game:GetService("RunService").Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            local session = DataService.getSession(player)
            if session and session.Data and session.Data.RestockTimer then
                if session.Data.RestockTimer > 0 then
                    session.Data.RestockTimer = session.Data.RestockTimer - (1/60)
                    if session.Data.RestockTimer <= 0 then
                        self:RegeneratePlayerShop(player)
                    end
                    DataService:Replicate(player, "RestockTimer")
                end
            end
        end
    end)
end

function ShopService:RegeneratePlayerShop(player)
    local session = DataService.getSession(player)
    if not session or not session.Data then
        return
    end
    
    local shopItems = self:GenerateShopItems()
    
    session.Data.Shop = {}
    session.Data.RestockTimer = 15 * 60
    
    for _, item in pairs(shopItems) do
        session.Data.Shop[item.name] = item.data.Stock
    end
    
    DataService:Replicate(player, {"Shop", "RestockTimer"})
end

function ShopService:KnitStart()
    local shopItems = self:GenerateShopItems()
    task.wait(3)
    self:UpdatePlayerShops(shopItems)
    self:StartRestockTimer()
end

function ShopService:KnitInit() 
    DataService = Knit.GetService("DataService")
end

return ShopService
