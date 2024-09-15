local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Tycoons = workspace.Tycoons

local TycoonService = require(script.Services.TycoonService)
local DataService = require(script.Services.DataService)

for i,v in pairs(Tycoons:GetChildren()) do
	TycoonService.ResetTycoon(v)
end

Players.PlayerAdded:Connect(function(Player)
	DataService.LoadPlayerData(Player)	
end)

Players.PlayerRemoving:Connect(function(Player)
	DataService.SavePlayerData(Player)
end)

game:BindToClose(function()
	for i,v in pairs(Players:GetPlayers()) do
		DataService.SavePlayerData(v)
	end
end)
