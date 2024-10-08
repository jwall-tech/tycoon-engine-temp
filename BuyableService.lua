local BuyableService = {}
local Zone = require(game.ReplicatedStorage:WaitForChild("Zone"))
local PaymentService = require(script.Parent.PaymentService)

-- Helper function to process all parts recursively within a model
local function processPartsRecursively(model, action)
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("Model") then
			-- If the child is a model, recursively process its children
			processPartsRecursively(child, action)
		elseif child:IsA("BasePart") then
			-- Apply the action to BasePart
			child.Anchored = true
			action(child)
		end
	end
end

-- Make the Buyable model invisible
function BuyableService.InvisBuyable(Buyable)
	local Model = Buyable.Model
	Model:SetAttribute("Invis", true)

	if Buyable:FindFirstChild("BillboardGui") then
		Buyable.BillboardGui.Enabled = false
	end

	-- Process parts recursively
	processPartsRecursively(Model, function(Part)
		Part:SetAttribute("OldTransparency", Part.Transparency)
		Part.Anchored = true
		Part.CanCollide = false
		Part.Transparency = 1
	end)
end

-- Undo the invisibility of the Buyable model
function BuyableService.UndoInvis(Buyable)
	local Model = Buyable.Model

	if Buyable:FindFirstChild("BillboardGui") then
		Buyable.BillboardGui.Enabled = true
	end

	-- Process parts recursively
	processPartsRecursively(Model, function(Part)
		local t = Part:GetAttribute("OldTransparency")
		if t then
			Part.CanCollide = false
			Part.Transparency = t
			Part:SetAttribute("OldTransparency", nil)
		end
	end)
end

-- Make the Buyable button invisible
function BuyableService.InvisButton(Buyable)
	local Model = Buyable.Button
	Model:SetAttribute("Invis", true)

	-- Process parts recursively
	processPartsRecursively(Model, function(Part)
		Part:SetAttribute("OldTransparency", Part.Transparency)
		Part.CanCollide = false
		Part.Transparency = 1
		
		if (Part:FindFirstChild("BillboardGui")) then
			Part.BillboardGui.Enabled = false
		end
		
		if (Part:FindFirstChild("ParticleEmitter")) then
			Part.ParticleEmitter.Enabled = false
		end
	end)
end

-- Undo the invisibility of the Buyable button
function BuyableService.UndoInvisButton(Buyable)
	local Model = Buyable.Button

	-- Process parts recursively
	processPartsRecursively(Model, function(Part)
		local t = Part:GetAttribute("OldTransparency")
		if t then
			Part.CanCollide = false
			Part.Transparency = t
			Part:SetAttribute("OldTransparency", nil)
			
			if (Part:FindFirstChild("BillboardGui")) then
				Part.BillboardGui.Enabled = true
			end
			
			if (Part:FindFirstChild("ParticleEmitter")) then
				Part.ParticleEmitter.Enabled = true
			end
		end
	end)
end


function BuyableService.InitButton(Buyable)
	local Button = Buyable.Button
	
	local zone = Zone.new(Button) 
	zone.playerEntered:Connect(function(player)
		print(("%s entered the zone!"):format(player.Name))
		
		
		-- buy GUI
		
		local success = PaymentService.AttemptMoneyCharge(player, Buyable:GetAttribute("BuyPrice"))
		
		if (success) then
			BuyableService.InvisButton(Buyable)
			BuyableService.UndoInvis(Buyable)
			Buyable:SetAttribute("Bought", true)
		end
	end)
	
	zone.playerExited:Connect(function(player)
		print(("%s exited the zone!"):format(player.Name))
		
		-- turn buy gui off
	end)
end

function BuyableService.SetUpButtonProgressionListener(Buyable)
	local ProgressionType = Buyable:GetAttribute("ProgressionType")
	
	if (ProgressionType == "Unlock") then
		local Goal = Buyable.UnlockRequired.Value
		
		Goal:GetAttributeChangedSignal("Bought"):Connect(function()
			if (Goal:GetAttribute("Bought") == true) then
				BuyableService.UndoInvisButton(Buyable)
			end
		end)
	elseif (ProgressionType == "Rebirth") then
	end
end

function BuyableService.SetUpOwnershipClaimListener(Buyable)
	Buyable.Parent.Parent.Parent:GetAttributeChangedSignal("Owned"):Connect(function()
		if (Buyable.Parent.Parent.Parent:GetAttribute("Owned")) then
			BuyableService.UndoInvisButton(Buyable)
		end
	end)
end

function BuyableService.InitBuyable(Buyable, Type)
	local Button,Model = Buyable.Button,Buyable.Model

	if (not Button or not Model) then return end

	BuyableService.InvisBuyable(Buyable)
	BuyableService.InvisButton(Buyable)
	
	if (Buyable:GetAttribute("RequiresProgression")) then
		BuyableService.SetUpButtonProgressionListener(Buyable)
	else
		if (Buyable.Parent.Parent.Parent:GetAttribute("Owned")) then
			BuyableService.UndoInvisButton(Buyable)
		end
		
		BuyableService.SetUpOwnershipClaimListener(Buyable)
	end
	
	BuyableService.InitButton(Buyable)
	
	--Buyable:SetAttribute("Reset", true)
	
	if (Type == "Droppers") then
		require(script.Dropper)(Buyable)
	elseif (Type == "Upgraders") then
		require(script.Upgrader)(Buyable)
	end
end

return BuyableService
