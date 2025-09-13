local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local LightService = Knit.CreateService({
    Name = "LightService",
    Client = {},
})

local function ManagePointLight(part : Part)
    local pointLight = part:FindFirstChildWhichIsA("PointLight")
    print("Managing point light for part:", part.Name)
    
    if not pointLight then
        print("No existing point light found, creating one.")
        local newPointLight = Instance.new("PointLight")
        newPointLight.Brightness = 2
        newPointLight.Color = Color3.new(1, 1, 0) -- Yellow light
        newPointLight.Range = 10
        newPointLight.Parent = part
        print("Point light created")
    else
        pointLight:Destroy()
        print("Point light destroyed")
    end
end

function LightService.Client:ToggleLight(player : Player)
    local character = player.Character
    if character then
        local HRP = character:FindFirstChild("HumanoidRootPart")
        if HRP then
            ManagePointLight(HRP)
        else
            print("HumanoidRootPart not found for player:", player.Name)
        end
    else
        print("Character not found for player:", player.Name)
    end
end

function LightService:KnitStart()
    print("LightService started")
end

function LightService:KnitInit()
    print("LightService initialized")
end

return LightService
