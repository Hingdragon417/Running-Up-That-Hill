local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local HeightController = Knit.CreateController({
    Name = "HeightController"
})

local player = Players.LocalPlayer
local ScreenGui = player:WaitForChild("PlayerGui"):WaitForChild("Main")
local mainFrame = ScreenGui:WaitForChild("PlayerHeightFrame")
local playersFrame = mainFrame:WaitForChild("Players")
local playerTemplate = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UIAssets"):WaitForChild("PlayerTemplate")

local playerLabels = {}

function HeightController:getPlayerHeadshot(userId)
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size100x100
	local content, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	return content
end

function HeightController:createPlayerLabel(player)
	local label = playerTemplate:Clone()
	label.Name = player.Name
	label.Parent = playersFrame
	label.Visible = true

	local success, image = pcall(function()
		return self:getPlayerHeadshot(player.UserId)
	end)

	if success then
		label.Image = image
	end
	playerLabels[player] = label
end

function HeightController:KnitStart()
	local RampService = Knit.GetService("RampService")
	local calculatedHeight = 1000 

	task.wait(1) 

	RampService:GetTotalHeight():andThen(function(height)
		calculatedHeight = height
	end):catch(function(err)
		warn("Failed to get calculated height:", err)
	end)
	
	for _, player in ipairs(Players:GetPlayers()) do
		self:createPlayerLabel(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:createPlayerLabel(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if playerLabels[player] then
			playerLabels[player]:Destroy()
			playerLabels[player] = nil
		end

		local existing = playersFrame:FindFirstChild(player.Name)
		if existing then
			existing:Destroy()
		end
	end)

	RunService.RenderStepped:Connect(function()
		for player, label in pairs(playerLabels) do
			local character = player.Character
			if character then
				local hrp = character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local y = hrp.Position.Y
					local ratio = math.clamp(y / calculatedHeight, 0, 1)
					label.Position = UDim2.new(ratio, 0, 0, 0)
				end
			end
		end
	end)
end

function HeightController:KnitInit()
	
end

return HeightController