local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

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
    
    local dashDistance = 25
    local dashDuration = 0.3
    
    local lookDirection = rootPart.CFrame.LookVector
    local startPosition = rootPart.Position
    
    -- Cast a ray downward from the target position to find the ground
    local targetPosition = startPosition + (lookDirection * dashDistance)
    local downwardRay = RaycastParams.new()
    downwardRay.FilterType = Enum.RaycastFilterType.Blacklist
    downwardRay.FilterDescendantsInstances = {character}
    
    -- Cast ray from high above the target position downward
    local highPoint = targetPosition + Vector3.new(0, 50, 0)
    local groundResult = workspace:Raycast(highPoint, Vector3.new(0, -100, 0), downwardRay)
    
    local finalPosition
    if groundResult then
        -- Position slightly above the ground
        finalPosition = groundResult.Position + Vector3.new(0, 3, 0)
    else
        -- If no ground found, use original target position
        finalPosition = targetPosition
    end
    
    local finalCFrame = CFrame.new(finalPosition, finalPosition + lookDirection)
    
    local tweenInfo = TweenInfo.new(
        dashDuration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = finalCFrame})
    tween:Play()
    
    return true
end

return Dash