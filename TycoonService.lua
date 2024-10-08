local TycoonService = {}
local BuyableService = require(script.Parent.BuyableService)
local Zone = require(game.ReplicatedStorage:WaitForChild("Zone"))

function TycoonService.ResetTycoon(Tycoon)
	local Buyables = Tycoon.Buyables
	
	for i,v in pairs(Buyables:GetChildren()) do
		for u,b in pairs(v:GetChildren()) do
			BuyableService.InitBuyable(b, v.Name)
		end
	end
	
	local ClaimButton = Tycoon.Claim
	
	for i,v in pairs(ClaimButton:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 0
		elseif (v:IsA("BillboardGui")) then
			v.Enabled = true
		end
	end
	
	local zone = Zone.new(ClaimButton)
	
	zone.playerEntered:Connect(function(player)
		print(("%s entered the zone!"):format(player.Name))
	
		TycoonService.ClaimTycoon(Tycoon, player)
	end)
end

function TycoonService.ClaimTycoon(Tycoon, Owner)
	if not (Tycoon:GetAttribute("Owned")) then
		Tycoon:SetAttribute("Owned", true)
		Tycoon:SetAttribute("OwnerId", Owner.UserId)
		
		for i,v in pairs(Tycoon.Claim:GetChildren()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			elseif (v:IsA("BillboardGui")) then
				v.Enabled = false
			end
		end
	end
end

function TycoonService.UnClaimTycoon(Tycoon)
	if (Tycoon:GetAttribute("Owned")) then
		Tycoon:SetAttribute("Owned", false)
		Tycoon:SetAttribute("OwnerId", nil)
		
		TycoonService.ResetTycoon(Tycoon)
	end
end

return TycoonService
