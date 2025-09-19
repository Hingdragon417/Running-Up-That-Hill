local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local dashAnimId = "rbxassetid://115260988089288"
local dashAnim = Instance.new("Animation")
dashAnim.AnimationId = dashAnimId

local Dash = {}

function Dash.Execute()
    local character = player.Character
    if not character then
        return false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        return false
    end

    local animTrack = humanoid:LoadAnimation(dashAnim)
    animTrack:Play()
    
    local dashDistance = 25  -- Reduced from 50 to about half
    local dashDuration = 0.15 -- Reduced from 0.25 to about half
    
    local lookDirection = rootPart.CFrame.LookVector
    local startPosition = rootPart.Position
    
    -- Calculate a much higher velocity for more noticeable movement
    local dashVelocity = (dashDistance / dashDuration) * 1.5  -- Added 1.5x multiplier
    local velocityVector = lookDirection * dashVelocity
    
    -- Store original velocity to restore later
    local originalVelocity = rootPart.AssemblyLinearVelocity
    
    -- Apply the dash velocity with a slight upward boost to help with obstacles
    rootPart.AssemblyLinearVelocity = Vector3.new(
        velocityVector.X, 
        math.max(originalVelocity.Y, 10), -- Ensure minimum upward velocity
        velocityVector.Z
    )
    
    -- Create a connection to stop the dash after the duration
    local connection
    connection = task.delay(dashDuration, function()
        if rootPart and rootPart.Parent then
            -- Restore a more natural velocity (reduced but not completely stopped)
            rootPart.AssemblyLinearVelocity = Vector3.new(
                originalVelocity.X * 0.1, 
                rootPart.AssemblyLinearVelocity.Y, 
                originalVelocity.Z * 0.1
            )
        end
    end)
    
    return true
end

return Dash