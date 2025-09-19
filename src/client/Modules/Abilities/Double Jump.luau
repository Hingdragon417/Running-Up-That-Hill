local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local DoubleJump = {}
local hasDoubleJumped = false

function DoubleJump.Execute()
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        return false
    end
    
    if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        return false
    end
    
    if hasDoubleJumped then
        return false
    end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, 4000, 0)
    bodyVelocity.Velocity = Vector3.new(0, 50, 0)
    bodyVelocity.Parent = rootPart
    
    hasDoubleJumped = true
    
    game:GetService("Debris"):AddItem(bodyVelocity, 0.2)
    
    local connection
    connection = humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Landed then
            hasDoubleJumped = false
            connection:Disconnect()
        end
    end)
    
    return true
end

return DoubleJump