local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local RampService = Knit.CreateService({
    Name = "RampService",
    Client = {
        GetTotalHeight = "GetTotalHeight"
    }
})

local RampModel : Model = workspace:WaitForChild("RampModel")
local RampFolder : Folder = workspace:WaitForChild("Ramps")

local MAX_STAIRS = 15
local calculatedTotalHeight = 0

function RampService:CreateRamp()
    local rootPart : Part = RampModel.PrimaryPart

    local startX = rootPart.Position.X
    local startY = rootPart.Position.Y
    local startZ = rootPart.Position.Z

    local xSize = rootPart.Size.X
    local ySize = rootPart.Size.Y
    local zSize = rootPart.Size.Z

    RampModel.Parent = RampFolder

    local originalCFrame = RampModel:GetPivot()
    
    local DESIRED_OVERLAP_STUDS = 4.5
    
    local Y_OVERLAP_PERCENTAGE = DESIRED_OVERLAP_STUDS / ySize
    local Z_OVERLAP_PERCENTAGE = DESIRED_OVERLAP_STUDS / zSize
    local VERTICAL_STEP_RATIO = 0.5
    local VERTICAL_ADJUSTMENT = -0.1
    local highestY = 0 
    
    for i = 1, MAX_STAIRS do
        local ySpacingReduction = ySize * Y_OVERLAP_PERCENTAGE
        local zSpacingReduction = zSize * Z_OVERLAP_PERCENTAGE
        local offsetVector = Vector3.new(0, -(ySize - ySpacingReduction) * i, -(zSize - zSpacingReduction) * i)
        local worldOffset = originalCFrame:VectorToWorldSpace(offsetVector)

        local verticalStepHeight = ySize * VERTICAL_STEP_RATIO
        local nextPos = Vector3.new(startX, startY + (verticalStepHeight * i) + (VERTICAL_ADJUSTMENT * i), startZ) + worldOffset
        
        if i == 1 then
            highestY = nextPos.Y
        else
            highestY = math.max(highestY, nextPos.Y)
        end
        
        print("Ramp", i, "Y position:", nextPos.Y)
        
        local newRamp = RampModel:Clone()
        newRamp.Parent = RampFolder
        
        local newCFrame = CFrame.new(nextPos) * (originalCFrame - originalCFrame.Position)
        newRamp:PivotTo(newCFrame)
    end

    calculatedTotalHeight = highestY + (ySize * 2.8) 
    print("Actual highest ramp Y:", highestY)
    print("Total ramp structure height from ground:", calculatedTotalHeight, "studs")
end

function RampService.Client:GetTotalHeight(player)

    while calculatedTotalHeight <= 0 do
        task.wait(0.1)
    end
    return calculatedTotalHeight
end

function RampService:KnitStart()
    self:CreateRamp()
end

function RampService:KnitInit() 
end

return RampService
