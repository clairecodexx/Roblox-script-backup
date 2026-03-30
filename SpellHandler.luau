local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local CastSpell     = ReplicatedStorage:WaitForChild("CastSpell")
local COOLDOWNS     = {}
local COOLDOWN_TIME = 1.5

local function getCharacter(player)
	return player.Character
end

local SpellEffects = {}

SpellEffects["Fireball"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local ball = Instance.new("Part")
	ball.Shape        = Enum.PartType.Ball
	ball.Size         = Vector3.new(2, 2, 2)
	ball.BrickColor   = BrickColor.new("Bright orange")
	ball.Material     = Enum.Material.Neon
	ball.CFrame       = root.CFrame * CFrame.new(0, 0, -4)
	ball.Parent       = workspace
	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = root.CFrame.LookVector * 60
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent    = ball
	game:GetService("Debris"):AddItem(ball, 3)
	ball.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and hit.Parent ~= char then
			humanoid:TakeDamage(30)
			ball:Destroy()
		end
	end)
end

SpellEffects["Shield"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local shield = Instance.new("Part")
	shield.Shape        = Enum.PartType.Ball
	shield.Size         = Vector3.new(7, 7, 7)
	shield.Transparency = 0.7
	shield.BrickColor   = BrickColor.new("Cyan")
	shield.Material     = Enum.Material.Neon
	shield.CanCollide   = false
	shield.CFrame       = root.CFrame
	shield.Parent       = workspace
	local weld = Instance.new("WeldConstraint")
	weld.Part0  = root
	weld.Part1  = shield
	weld.Parent = shield
	game:GetService("Debris"):AddItem(shield, 5)
end

SpellEffects["Blink"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	root.CFrame = root.CFrame * CFrame.new(0, 0, -20)
end

SpellEffects["Heal"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	humanoid.Health = math.min(humanoid.Health + 40, humanoid.MaxHealth)
end

SpellEffects["Nova"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local pos = root.Position
	for _, obj in ipairs(workspace:GetChildren()) do
		local otherRoot = obj:FindFirstChild("HumanoidRootPart")
		local humanoid  = obj:FindFirstChildOfClass("Humanoid")
		if otherRoot and humanoid and obj ~= char then
			if (otherRoot.Position - pos).Magnitude <= 15 then
				humanoid:TakeDamage(50)
			end
		end
	end
	local blast = Instance.new("Part")
	blast.Shape        = Enum.PartType.Ball
	blast.Size         = Vector3.new(1, 1, 1)
	blast.Transparency = 0.5
	blast.BrickColor   = BrickColor.new("Bright violet")
	blast.Material     = Enum.Material.Neon
	blast.Anchored     = true
	blast.CanCollide   = false
	blast.CFrame       = root.CFrame
	blast.Parent       = workspace
	for i = 1, 10 do
		task.wait(0.03)
		blast.Size        = Vector3.new(i * 3, i * 3, i * 3)
		blast.Transparency = 0.5 + (i * 0.05)
	end
	blast:Destroy()
end

SpellEffects["Ice Spear"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local spear = Instance.new("Part")
	spear.Size      = Vector3.new(0.5, 0.5, 6)
	spear.BrickColor = BrickColor.new("Cyan")
	spear.Material   = Enum.Material.Neon
	spear.CFrame     = root.CFrame * CFrame.new(0, 0, -5)
	spear.Parent     = workspace
	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = root.CFrame.LookVector * 80
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent    = spear
	game:GetService("Debris"):AddItem(spear, 3)
	spear.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and hit.Parent ~= char then
			humanoid:TakeDamage(45)
			spear:Destroy()
		end
	end)
end

SpellEffects["Thunder"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, obj in ipairs(workspace:GetChildren()) do
		local otherRoot = obj:FindFirstChild("HumanoidRootPart")
		local humanoid  = obj:FindFirstChildOfClass("Humanoid")
		if otherRoot and humanoid and obj ~= char then
			if (otherRoot.Position - root.Position).Magnitude <= 20 then
				humanoid:TakeDamage(40)
				local bolt = Instance.new("Part")
				bolt.Size        = Vector3.new(0.3, (root.Position - otherRoot.Position).Magnitude, 0.3)
				bolt.BrickColor  = BrickColor.new("Bright yellow")
				bolt.Material    = Enum.Material.Neon
				bolt.Anchored    = true
				bolt.CanCollide  = false
				bolt.CFrame      = CFrame.new(root.Position, otherRoot.Position) * CFrame.new(0, 0, -bolt.Size.Y/2)
				bolt.Parent      = workspace
				game:GetService("Debris"):AddItem(bolt, 0.2)
			end
		end
	end
end

SpellEffects["Dark Void"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local void = Instance.new("Part")
	void.Shape        = Enum.PartType.Ball
	void.Size         = Vector3.new(3, 3, 3)
	void.BrickColor   = BrickColor.new("Really black")
	void.Material     = Enum.Material.Neon
	void.Anchored     = true
	void.CanCollide   = false
	void.CFrame       = root.CFrame * CFrame.new(0, 0, -10)
	void.Parent       = workspace
	for i = 1, 15 do
		task.wait(0.05)
		local pos = void.Position
		for _, obj in ipairs(workspace:GetChildren()) do
			local otherRoot = obj:FindFirstChild("HumanoidRootPart")
			local humanoid  = obj:FindFirstChildOfClass("Humanoid")
			if otherRoot and humanoid and obj ~= char then
				if (otherRoot.Position - pos).Magnitude <= 12 then
					local pull = (pos - otherRoot.Position).Unit * 5
					otherRoot.Velocity = pull
					humanoid:TakeDamage(5)
				end
			end
		end
	end
	void:Destroy()
end

SpellEffects["Barrier"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local barrier = Instance.new("Part")
	barrier.Shape        = Enum.PartType.Ball
	barrier.Size         = Vector3.new(10, 10, 10)
	barrier.Transparency = 0.5
	barrier.BrickColor   = BrickColor.new("Teal")
	barrier.Material     = Enum.Material.Neon
	barrier.CanCollide   = true
	barrier.CFrame       = root.CFrame
	barrier.Parent       = workspace
	local weld = Instance.new("WeldConstraint")
	weld.Part0  = root
	weld.Part1  = barrier
	weld.Parent = barrier
	game:GetService("Debris"):AddItem(barrier, 6)
end

SpellEffects["Summon"] = function(player)
	local char = getCharacter(player)
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for i = 1, 3 do
		local summon = Instance.new("Part")
		summon.Size      = Vector3.new(2, 4, 2)
		summon.BrickColor = BrickColor.new("Black")
		summon.Material   = Enum.Material.SmoothPlastic
		local angle = (i / 3) * math.pi * 2
		summon.CFrame = root.CFrame * CFrame.new(
			math.cos(angle) * 5, 0, math.sin(angle) * 5
		)
		summon.Parent = workspace
		game:GetService("Debris"):AddItem(summon, 8)
	end
end

CastSpell.OnServerEvent:Connect(function(player, spellName)
	local now  = tick()
	local last = COOLDOWNS[player.UserId] or 0
	if now - last < COOLDOWN_TIME then return end
	COOLDOWNS[player.UserId] = now
	local effect = SpellEffects[spellName]
	if not effect then
		warn("Sort inconnu reçu :", spellName, "- possible exploit")
		return
	end
	effect(player)
end)

Players.PlayerRemoving:Connect(function(player)
	COOLDOWNS[player.UserId] = nil
end)