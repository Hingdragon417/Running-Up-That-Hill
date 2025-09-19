local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Knit = require(Packages.Knit)

local AbilityEnums = require(Shared.Data.AbilityEnums)

local DataController
local ShopService

local ShopController = Knit.CreateController({
    Name = "ShopController",
})

local isUpdating = false

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("Main")
local framesFolder = mainGui:WaitForChild("Frames")
local shopFrame = framesFolder:WaitForChild("Shop")
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local timerLabel = shopFrame:WaitForChild("Timer")

local shopTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UIAssets"):WaitForChild("ShopTemplate")

function ShopController:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function ShopController:UpdateTimerDisplay()
    local playerData = DataController.getData()
    
    if playerData and playerData.RestockTimer then
        local timeLeft = playerData.RestockTimer
        if timeLeft > 0 then
            timerLabel.Text = "Next Restock: " .. self:FormatTime(timeLeft)
        elseif timeLeft <= 0 then
            timerLabel.Text = "Shop Restocked!"
        end
    else
        timerLabel.Text = "Timer Loading..."
    end
end

function ShopController:UpdateShopUI()
    if isUpdating then
        return
    end
    
    isUpdating = true
    
    local playerData = DataController.getData()
    
    if playerData and playerData.Shop then
        
        -- Count items in shop
        local itemCount = 0
        for abilityName, stockAmount in pairs(playerData.Shop) do
            itemCount = itemCount + 1
        end
        
        for _, child in pairs(scrollingFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
                child:Destroy()
            end
        end
        
        local itemIndex = 1
        for abilityName, stockAmount in pairs(playerData.Shop) do
            local abilityData = AbilityEnums[abilityName]
            
            if abilityData then
                local newItem = shopTemplate:Clone()
                newItem.Name = "ShopItem" .. itemIndex
                newItem.Visible = true
                newItem.Parent = scrollingFrame
                
                local nameLabel = newItem:FindFirstChild("Name")
                if nameLabel then
                    nameLabel.Text = abilityData.Name
                end
                
                local stockLabel = newItem:FindFirstChild("Stock")
                if stockLabel then
                    stockLabel.Text = "Stock: " .. stockAmount
                end
                
                local purchaseButton = newItem:FindFirstChild("Purchase")
                if purchaseButton then
                    if stockAmount > 0 then
                        purchaseButton.Text = "$" .. abilityData.Price
                        purchaseButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
                    else
                        purchaseButton.Text = "Out of Stock"
                        purchaseButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
                    end
                    
                    purchaseButton.MouseButton1Click:Connect(function()
                        if stockAmount > 0 then
                            ShopService:PurchaseAbility(abilityName):andThen(function(success, message)
                                if success then
                                    -- Purchase successful
                                else
                                    -- Purchase failed
                                end
                            end):catch(function(err)
                                -- Purchase error
                            end)
                        end
                    end)
                end
                
                local imageLabel = newItem:FindFirstChild("ImageLabel")
                if imageLabel then
                    imageLabel.Image = "rbxassetid://" .. abilityData.Image
                end
                
                local descriptionLabel = newItem:FindFirstChild("DescriptionLabel")
                if descriptionLabel then
                    descriptionLabel.Text = abilityData.Description
                end
                
                itemIndex = itemIndex + 1
            end
        end
    end
    
    -- Update the timer display
    self:UpdateTimerDisplay()
    
    isUpdating = false
end

function ShopController:KnitStart() 
    DataController.onReplicated("Shop"):Connect(function()
        self:UpdateShopUI()
    end)
    
    DataController.onReplicated("RestockTimer"):Connect(function()
        self:UpdateTimerDisplay()
    end)
    
    task.wait(1)
    self:UpdateShopUI()
end

function ShopController:KnitInit()
    DataController = Knit.GetController("DataController")
    ShopService = Knit.GetService("ShopService")
end

return ShopController