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
    
    local dashDistance = 25
    local dashDuration = 0.15
    
    local lookDirection = rootPart.CFrame.LookVector
    local startPosition = rootPart.Position
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}
    
    local forwardRay = workspace:Raycast(startPosition + Vector3.new(0, 2, 0), lookDirection * 15, rayParams)
    
    local dashVelocity = (dashDistance / dashDuration) * 2.5
    local finalVelocity = lookDirection * dashVelocity
    
    if forwardRay then
        local surfaceNormal = forwardRay.Normal
        local rampAngle = math.acos(math.clamp(surfaceNormal:Dot(Vector3.new(0, 1, 0)), -1, 1))
        
        if rampAngle > math.rad(5) and rampAngle < math.rad(75) then
            local rampDirection = (lookDirection - lookDirection:Dot(surfaceNormal) * surfaceNormal).Unit
            local upSlope = Vector3.new(0, 1, 0):Cross(surfaceNormal):Cross(surfaceNormal).Unit
            
            if lookDirection:Dot(upSlope) > 0 then
                finalVelocity = upSlope * dashVelocity * 1.5
                finalVelocity = finalVelocity + Vector3.new(0, 50, 0)
            end
        end
    end
    
    local originalVelocity = rootPart.AssemblyLinearVelocity
    
    rootPart.AssemblyLinearVelocity = Vector3.new(
        finalVelocity.X, 
        math.max(finalVelocity.Y, 30),
        finalVelocity.Z
    )
    
    local connection
    connection = task.delay(dashDuration, function()
        if rootPart and rootPart.Parent then
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