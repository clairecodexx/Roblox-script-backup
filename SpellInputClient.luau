local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local SpellRegistry = require(ReplicatedStorage:WaitForChild("SpellRegistry"))
local CastSpell     = ReplicatedStorage:WaitForChild("CastSpell")
local Player        = Players.LocalPlayer

-- ------------------------------------------
--  DETECTION PLATEFORME
-- ------------------------------------------
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ------------------------------------------
--  CONFIG (adapté selon la plateforme)
-- ------------------------------------------
local PANEL_SIZE   = isMobile and 380  or 800
local RING_RADIUS  = isMobile and 160  or 350
local SNAP_DIST    = isMobile and 45   or 32
local DOT_RADIUS   = isMobile and 16   or 20
local NUM_RING     = 8
local NUM_POINTS   = NUM_RING + 1
local CENTER_IDX   = NUM_POINTS
local IDLE_TIMEOUT = 1.2
local CX           = PANEL_SIZE / 2
local CY           = PANEL_SIZE / 2

-- ------------------------------------------
--  POSITIONS DES POINTS
-- ------------------------------------------
local POINT_POSITIONS = {}
for i = 1, NUM_RING do
	local angle = ((i - 1) / NUM_RING) * math.pi * 2 - math.pi / 2
	POINT_POSITIONS[i] = Vector2.new(
		CX + math.cos(angle) * RING_RADIUS,
		CY + math.sin(angle) * RING_RADIUS
	)
end
POINT_POSITIONS[CENTER_IDX] = Vector2.new(CX, CY)

-- ------------------------------------------
--  BUILD UI
-- ------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "SpellWheel"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = Player:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Name                   = "Panel"
Panel.AnchorPoint            = Vector2.new(0.5, 0.5)
Panel.Position               = UDim2.new(0.5, 0, 0.5, 0)
Panel.Size                   = UDim2.new(0, PANEL_SIZE, 0, PANEL_SIZE)
Panel.BackgroundColor3       = Color3.fromRGB(10, 10, 18)
Panel.BackgroundTransparency = 0.18
Panel.BorderSizePixel        = 0
Panel.Visible                = false
Panel.ClipsDescendants       = false
Panel.Parent                 = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(1, 0)
PanelCorner.Parent       = Panel

local PanelScale = Instance.new("UIScale")
PanelScale.Scale  = 0
PanelScale.Parent = Panel

local SpellLabel = Instance.new("TextLabel")
SpellLabel.Name                   = "SpellLabel"
SpellLabel.Size                   = UDim2.new(1, 0, 0, 30)
SpellLabel.Position               = UDim2.new(0, 0, 1, 12)
SpellLabel.BackgroundTransparency = 1
SpellLabel.TextColor3             = Color3.fromRGB(200, 200, 200)
SpellLabel.Font                   = Enum.Font.GothamBold
SpellLabel.TextSize               = isMobile and 18 or 15
SpellLabel.Text                   = ""
SpellLabel.TextTransparency       = 1
SpellLabel.Parent                 = Panel

-- Dossier lignes
local LinesFolder = Instance.new("Folder")
LinesFolder.Name   = "Lines"
LinesFolder.Parent = Panel

-- Ligne live
local LiveLine = Instance.new("Frame")
LiveLine.Name                   = "LiveLine"
LiveLine.BackgroundColor3       = Color3.fromRGB(186, 117, 23)
LiveLine.BackgroundTransparency = 0.65
LiveLine.BorderSizePixel        = 0
LiveLine.AnchorPoint            = Vector2.new(0.5, 0.5)
LiveLine.Size                   = UDim2.new(0, 0, 0, DOT_RADIUS * 2 * 0.5)
LiveLine.Visible                = false
LiveLine.ZIndex                 = 2
LiveLine.Parent                 = Panel

local LiveLineCorner = Instance.new("UICorner")
LiveLineCorner.CornerRadius = UDim.new(1, 0)
LiveLineCorner.Parent       = LiveLine

-- Dots
local DotFrames = {}
for i = 1, NUM_POINTS do
	local pos      = POINT_POSITIONS[i]
	local isCenter = (i == CENTER_IDX)
	local dotSize  = DOT_RADIUS * 2

	local dot = Instance.new("Frame")
	dot.Name              = "Dot_" .. i
	dot.Size              = UDim2.new(0, dotSize, 0, dotSize)
	dot.AnchorPoint       = Vector2.new(0.5, 0.5)
	dot.Position          = UDim2.new(0, pos.X, 0, pos.Y)
	dot.BackgroundColor3  = isCenter
		and Color3.fromRGB(120, 90, 30)
		or  Color3.fromRGB(60, 60, 75)
	dot.BorderSizePixel   = 0
	dot.ZIndex            = 5
	dot.Parent            = Panel

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(1, 0)
	dc.Parent       = dot

	local orderLabel = Instance.new("TextLabel")
	orderLabel.Name                   = "Order"
	orderLabel.Size                   = UDim2.new(1, 0, 1, 0)
	orderLabel.BackgroundTransparency = 1
	orderLabel.TextColor3             = Color3.fromRGB(10, 8, 0)
	orderLabel.Font                   = Enum.Font.GothamBold
	orderLabel.TextScaled             = true
	orderLabel.Text                   = ""
	orderLabel.Visible                = false
	orderLabel.ZIndex                 = 6
	orderLabel.Parent                 = dot

	local halo = Instance.new("Frame")
	halo.Name                   = "Halo"
	halo.Size                   = UDim2.new(0, dotSize + 20, 0, dotSize + 20)
	halo.AnchorPoint            = Vector2.new(0.5, 0.5)
	halo.Position               = UDim2.new(0.5, 0, 0.5, 0)
	halo.BackgroundTransparency = 1
	halo.BorderSizePixel        = 2
	halo.BorderColor3           = Color3.fromRGB(186, 117, 23)
	halo.ZIndex                 = 4
	halo.Visible                = false
	halo.Parent                 = dot

	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(1, 0)
	hc.Parent       = halo

	DotFrames[i] = dot
end

-- ------------------------------------------
--  BOUTON MOBILE
--  Positionné en bas à droite, au-dessus du bouton saut
--  (le bouton saut Roblox est à environ 90px du bas)
-- ------------------------------------------
local MobileButton = Instance.new("TextButton")
MobileButton.Name                   = "MobileButton"
MobileButton.Size                   = UDim2.new(0, 90, 0, 90)
MobileButton.AnchorPoint            = Vector2.new(1, 1)
MobileButton.Position               = UDim2.new(1, -20, 1, -110)  -- au-dessus du saut
MobileButton.BackgroundColor3       = Color3.fromRGB(186, 117, 23)
MobileButton.BackgroundTransparency = 0.25
MobileButton.BorderSizePixel        = 0
MobileButton.Text                   = "O"
MobileButton.TextColor3             = Color3.fromRGB(255, 255, 255)
MobileButton.Font                   = Enum.Font.GothamBold
MobileButton.TextSize               = 32
MobileButton.Visible                = isMobile
MobileButton.ZIndex                 = 10
MobileButton.Parent                 = ScreenGui

local MBC = Instance.new("UICorner")
MBC.CornerRadius = UDim.new(1, 0)
MBC.Parent       = MobileButton

local MBStroke = Instance.new("UIStroke")
MBStroke.Color     = Color3.fromRGB(239, 159, 39)
MBStroke.Thickness = 2
MBStroke.Parent    = MobileButton

-- ------------------------------------------
--  ANIMATIONS
-- ------------------------------------------
local TWEEN_IN  = TweenInfo.new(0.22, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TWEEN_OUT = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.In)

local function animateIn()
	Panel.Visible                = true
	Panel.BackgroundTransparency = 1
	PanelScale.Scale             = 0
	SpellLabel.TextTransparency  = 1

	TweenService:Create(PanelScale, TWEEN_IN, { Scale = 1 }):Play()
	TweenService:Create(Panel,      TWEEN_IN, { BackgroundTransparency = 0.18 }):Play()

	for _, dot in ipairs(DotFrames) do
		dot.BackgroundTransparency = 1
		TweenService:Create(dot, TWEEN_IN, { BackgroundTransparency = 0 }):Play()
	end

	if isMobile then
		TweenService:Create(MobileButton, TWEEN_IN, {
			BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		}):Play()
	end
end

local function animateOut(callback)
	TweenService:Create(PanelScale, TWEEN_OUT, { Scale = 0.85 }):Play()
	TweenService:Create(Panel,      TWEEN_OUT, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(SpellLabel, TWEEN_OUT, { TextTransparency = 1 }):Play()

	for _, dot in ipairs(DotFrames) do
		TweenService:Create(dot, TWEEN_OUT, { BackgroundTransparency = 1 }):Play()
	end

	if isMobile then
		TweenService:Create(MobileButton, TWEEN_OUT, {
			BackgroundColor3 = Color3.fromRGB(186, 117, 23)
		}):Play()
	end

	local fadeTween = TweenService:Create(Panel, TWEEN_OUT, { BackgroundTransparency = 1 })
	fadeTween.Completed:Connect(function()
		Panel.Visible    = false
		PanelScale.Scale = 0
		if callback then callback() end
	end)
	fadeTween:Play()
end

-- ------------------------------------------
--  HELPERS LIGNES
-- ------------------------------------------
local function createSegment(a, b)
	local delta  = b - a
	local length = delta.Magnitude
	local angle  = math.deg(math.atan2(delta.Y, delta.X))
	local midX   = (a.X + b.X) / 2
	local midY   = (a.Y + b.Y) / 2

	local line = Instance.new("Frame")
	line.Size                   = UDim2.new(0, length, 0, DOT_RADIUS * 2)
	line.AnchorPoint            = Vector2.new(0.5, 0.5)
	line.Position               = UDim2.new(0, midX, 0, midY)
	line.BackgroundColor3       = Color3.fromRGB(186, 117, 23)
	line.BackgroundTransparency = 0
	line.BorderSizePixel        = 0
	line.Rotation               = angle
	line.ZIndex                 = 2
	line.Parent                 = Panel

	local lc = Instance.new("UICorner")
	lc.CornerRadius = UDim.new(1, 0)
	lc.Parent       = line

	return line
end

local function updateLiveLine(from, to)
	local delta  = to - from
	local length = delta.Magnitude
	local angle  = math.deg(math.atan2(delta.Y, delta.X))
	local midX   = (from.X + to.X) / 2
	local midY   = (from.Y + to.Y) / 2

	LiveLine.Size        = UDim2.new(0, length, 0, DOT_RADIUS)
	LiveLine.AnchorPoint = Vector2.new(0.5, 0.5)
	LiveLine.Position    = UDim2.new(0, midX, 0, midY)
	LiveLine.Rotation    = angle
	LiveLine.Visible     = length > 4
end

-- ------------------------------------------
--  STATE
-- ------------------------------------------
local isOpen       = false
local sequence     = {}
local visitedSet   = {}
local drawnLines   = {}
local lastSnapped  = -1
local lastMoveTime = 0
local idleThread   = nil
local touchActive  = false

-- ------------------------------------------
--  RESET
-- ------------------------------------------
local function clearVisuals()
	for _, line in ipairs(drawnLines) do line:Destroy() end
	drawnLines       = {}
	LiveLine.Visible = false
	SpellLabel.Text  = ""

	for i, dot in ipairs(DotFrames) do
		local isCenter = (i == CENTER_IDX)
		dot.BackgroundColor3       = isCenter
			and Color3.fromRGB(120, 90, 30)
			or  Color3.fromRGB(60, 60, 75)
		dot.BackgroundTransparency = 0
		dot.Size = UDim2.new(0, DOT_RADIUS * 2, 0, DOT_RADIUS * 2)

		local order = dot:FindFirstChild("Order")
		if order then order.Visible = false; order.Text = "" end

		local halo = dot:FindFirstChild("Halo")
		if halo then halo.Visible = false end
	end
end

local function fullReset()
	sequence    = {}
	visitedSet  = {}
	lastSnapped = -1
	touchActive = false
	if idleThread then task.cancel(idleThread); idleThread = nil end
	clearVisuals()
end

-- ------------------------------------------
--  HINTS
-- ------------------------------------------
local function updateHints()
	local hints = SpellRegistry.GetNextHints(sequence)
	for i, dot in ipairs(DotFrames) do
		if visitedSet[i] then continue end
		local hint = hints[i]
		local halo = dot:FindFirstChild("Halo")
		if hint then
			dot.BackgroundColor3       = hint.color
			dot.BackgroundTransparency = 0
			if halo then halo.Visible = true; halo.BorderColor3 = hint.color end
		else
			dot.BackgroundColor3       = Color3.fromRGB(35, 35, 45)
			dot.BackgroundTransparency = 0.4
			if halo then halo.Visible = false end
		end
	end
end

-- ------------------------------------------
--  SNAP
-- ------------------------------------------
local function snapPoint(idx)
	if #sequence >= 1 then
		local seg = createSegment(
			POINT_POSITIONS[sequence[#sequence]],
			POINT_POSITIONS[idx]
		)
		table.insert(drawnLines, seg)
	end

	table.insert(sequence, idx)
	visitedSet[idx] = true
	lastSnapped     = idx

	local dot   = DotFrames[idx]
	local order = dot:FindFirstChild("Order")
	local halo  = dot:FindFirstChild("Halo")

	dot.BackgroundColor3 = Color3.fromRGB(239, 159, 39)
	dot.Size             = UDim2.new(0, DOT_RADIUS * 2 + 8, 0, DOT_RADIUS * 2 + 8)
	if order then order.Text = tostring(#sequence); order.Visible = true end
	if halo  then halo.Visible = false end
end

local function trySnap(mouseLocal)
	local hints = SpellRegistry.GetNextHints(sequence)
	for i = 1, NUM_POINTS do
		if visitedSet[i] then continue end
		if hints[i] == nil then continue end
		if (POINT_POSITIONS[i] - mouseLocal).Magnitude < SNAP_DIST and lastSnapped ~= i then
			snapPoint(i)
			updateHints()
			updateSpellLabel()
			return
		end
	end
end

-- ------------------------------------------
--  LABEL + AUTO-LAUNCH
-- ------------------------------------------
function updateSpellLabel()
	local spell = SpellRegistry.Match(sequence)
	if spell then
		SpellLabel.Text             = "? " .. spell.name
		SpellLabel.TextColor3       = Color3.fromRGB(50, 220, 140)
		SpellLabel.TextTransparency = 0
		if not _G.autoLaunched then
			_G.autoLaunched = true
			task.delay(0.15, function()
				if isOpen then validate() end
			end)
		end
	elseif SpellRegistry.AnyPartial(sequence) then
		SpellLabel.Text             = "..."
		SpellLabel.TextColor3       = Color3.fromRGB(200, 200, 200)
		SpellLabel.TextTransparency = 0
	elseif #sequence > 1 then
		SpellLabel.Text             = "? Inconnue"
		SpellLabel.TextColor3       = Color3.fromRGB(220, 60, 60)
		SpellLabel.TextTransparency = 0
	end
end

-- ------------------------------------------
--  IDLE TIMER
-- ------------------------------------------
local function resetIdleTimer()
	if idleThread then task.cancel(idleThread); idleThread = nil end
	if not isOpen or #sequence <= 1 then return end
	idleThread = task.delay(IDLE_TIMEOUT, function()
		if isOpen then validate() end
	end)
end

-- ------------------------------------------
--  OPEN
-- ------------------------------------------
local function openPanel()
	if isOpen then return end
	isOpen          = true
	_G.autoLaunched = false

	if not isMobile then
		UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = false
	end

	fullReset()
	animateIn()
	snapPoint(CENTER_IDX)
	updateHints()
	updateSpellLabel()
	lastMoveTime = tick()
end

-- ------------------------------------------
--  VALIDATE
-- ------------------------------------------
function validate()
	if not isOpen then return end
	isOpen      = false
	touchActive = false

	if idleThread then task.cancel(idleThread); idleThread = nil end

	if not isMobile then
		UserInputService.MouseBehavior    = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end

	LiveLine.Visible = false
	local spell = SpellRegistry.Match(sequence)

	if spell then
		SpellLabel.Text             = "? " .. spell.name .. "!"
		SpellLabel.TextColor3       = Color3.fromRGB(255, 230, 80)
		SpellLabel.TextTransparency = 0
		CastSpell:FireServer(spell.name)
		task.delay(0.4, function()
			animateOut(function() fullReset() end)
		end)
	else
		SpellLabel.Text             = #sequence > 1 and "? Rune inconnue" or ""
		SpellLabel.TextTransparency = 0
		SpellLabel.TextColor3       = Color3.fromRGB(220, 60, 60)
		task.delay(0.2, function()
			animateOut(function() fullReset() end)
		end)
	end
end

-- ------------------------------------------
--  INPUT PC
-- ------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode ~= Enum.KeyCode.E then return end
	if not isOpen then openPanel() else validate() end
end)

-- ------------------------------------------
--  INPUT MOBILE
-- ------------------------------------------
MobileButton.MouseButton1Click:Connect(function()
	if not isOpen then openPanel() else validate() end
end)

UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
	if gameProcessed then return end
	if not isOpen then return end
	if touchActive then return end
	touchActive = true
end)

UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
	if not isOpen or not touchActive then return end

	local panelCenter = Panel.AbsolutePosition + Panel.AbsoluteSize * 0.5
	local scale       = PanelScale.Scale
	if scale <= 0 then return end

	local relX = (touch.Position.X - panelCenter.X) / scale
	local relY = (touch.Position.Y - panelCenter.Y) / scale

	local mouseLocal = Vector2.new(
		math.clamp(CX + relX, 0, PANEL_SIZE),
		math.clamp(CY + relY, 0, PANEL_SIZE)
	)

	trySnap(mouseLocal)

	if #sequence >= 1 then
		updateLiveLine(POINT_POSITIONS[sequence[#sequence]], mouseLocal)
		local now = tick()
		if now - lastMoveTime > 0.05 then
			lastMoveTime = now
			resetIdleTimer()
		end
	end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
	if not isOpen or not touchActive then return end
	touchActive = false
	validate()
end)

-- ------------------------------------------
--  RENDER LOOP PC
-- ------------------------------------------
RunService.RenderStepped:Connect(function()
	if not isOpen or isMobile then return end

	local mouse       = Player:GetMouse()
	local panelCenter = Panel.AbsolutePosition + Panel.AbsoluteSize * 0.5
	local scale       = PanelScale.Scale
	if scale <= 0 then return end

	local relX = (mouse.X - panelCenter.X) / scale
	local relY = (mouse.Y - panelCenter.Y) / scale

	local mouseLocal = Vector2.new(
		math.clamp(CX + relX, 0, PANEL_SIZE),
		math.clamp(CY + relY, 0, PANEL_SIZE)
	)

	trySnap(mouseLocal)

	if #sequence >= 1 then
		updateLiveLine(POINT_POSITIONS[sequence[#sequence]], mouseLocal)
		local now = tick()
		if now - lastMoveTime > 0.05 then
			lastMoveTime = now
			resetIdleTimer()
		end
	end
end)