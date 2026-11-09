--========================================================--
--                    MK HUB v2.0                         --
--                 FOX ANIME EDITION                      --
--           MAIN / TOOL — UPDATED BUILD                  --
--========================================================--
-- Changes:
--   • Player ESP: auto re-attach on respawn (CharacterAdded)
--   • Mob ESP:    highlights all NPC Humanoids, auto re-attach
--                 on death via Died → wait → re-scan
--   • Fly:        BodyVelocity → LinearVelocity (R15/newer)
--                 fallback BodyVelocity kept for old servers
--   • Speed:      set via RenderStepped loop, not direct assign
--                 — bypasses most per-frame server checks
--   • HighJump:   same loop approach
--   • NoClip:     unchanged (Stepped loop already solid)
--========================================================--

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local TweenService= game:GetService("TweenService")
local Lighting    = game:GetService("Lighting")
local Workspace   = workspace

local Player = Players.LocalPlayer

--========================================================--
-- SETTINGS
--========================================================--

local DEFAULT = {
	Speed    = 60,
	Jump     = 100,
	FlySpeed = 80,
	AimFOV   = 120,
}

local Settings = {
	Speed    = DEFAULT.Speed,
	Jump     = DEFAULT.Jump,
	FlySpeed = DEFAULT.FlySpeed,
	AimFOV   = DEFAULT.AimFOV,
}

--========================================================--
-- CHARACTER
--========================================================--

local Character, Humanoid, Root

local function LoadCharacter(Char)
	Character = Char
	Humanoid  = Char:WaitForChild("Humanoid")
	Root      = Char:WaitForChild("HumanoidRootPart")
	Humanoid.UseJumpPower = true
end

if Player.Character then
	LoadCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(Char)
	LoadCharacter(Char)
	task.wait(0.2)
	if Humanoid then
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
	end
end)

--========================================================--
-- STATES
--========================================================--

local SpeedEnabled   = false
local JumpEnabled    = false
local FlyEnabled     = false
local NoClipEnabled  = false
local ESPEnabled     = false
local MobESPEnabled  = false
local FastModeEnabled= false

local FlyBody, FlyConnection
local NoClipConnection
local ESPConnection
local MobESPConnection
local SpeedConnection
local JumpConnection

--========================================================--
-- COLORS
--========================================================--

local C = {
	Background  = Color3.fromRGB(7,8,13),
	Panel       = Color3.fromRGB(14,15,22),
	Panel2      = Color3.fromRGB(21,22,31),
	Button      = Color3.fromRGB(27,28,38),
	ButtonHover = Color3.fromRGB(43,43,58),
	White       = Color3.fromRGB(245,245,255),
	Gray        = Color3.fromRGB(150,152,170),
	Purple      = Color3.fromRGB(178,105,255),
	Blue        = Color3.fromRGB(100,160,255),
	Pink        = Color3.fromRGB(255,125,205),
	Green       = Color3.fromRGB(100,255,160),
	Orange      = Color3.fromRGB(255,180,80),
	Stroke      = Color3.fromRGB(70,70,92),
}

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")
Gui.Name           = "MK_HUB_v2"
Gui.ResetOnSpawn   = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder   = 999
Gui.Parent         = Player:WaitForChild("PlayerGui")

--========================================================--
-- UTILITY
--========================================================--

local function Corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
	return c
end

local function AddStroke(o, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color        = col   or C.Stroke
	s.Thickness    = thick or 1
	s.Transparency = trans or 0
	s.Parent = o
	return s
end

local function MakeTween(o, t, props, style)
	return TweenService:Create(
		o,
		TweenInfo.new(t, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		props
	)
end

--========================================================--
-- DRAG
--========================================================--

local function MakeDraggable(Object, Handle)
	local Dragging, DragStart, StartPos
	Handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging  = true
			DragStart = i.Position
			StartPos  = Object.Position
		end
	end)
	Handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not Dragging then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = i.Position - DragStart
		Object.Position = UDim2.new(
			StartPos.X.Scale, StartPos.X.Offset + d.X,
			StartPos.Y.Scale, StartPos.Y.Offset + d.Y
		)
	end)
end

--========================================================--
-- FOX HELPER
--========================================================--

local function CreateFox(Parent, Position, Size, ZIndex)
	local f = Instance.new("TextLabel")
	f.Size                = UDim2.fromOffset(Size, Size)
	f.Position            = Position
	f.BackgroundTransparency = 1
	f.Text                = "🦊"
	f.TextSize            = math.floor(Size * 0.72)
	f.Font                = Enum.Font.GothamBlack
	f.TextColor3          = Color3.fromRGB(255,255,255)
	f.ZIndex              = ZIndex or 10
	f.Parent              = Parent
	return f
end

--========================================================--
-- LOADING SCREEN  (unchanged from original)
--========================================================--

local Loading = Instance.new("Frame")
Loading.Size                 = UDim2.fromScale(1,1)
Loading.BackgroundColor3     = C.Background
Loading.BorderSizePixel      = 0
Loading.ZIndex               = 1000
Loading.Parent               = Gui

local LoadingGradient        = Instance.new("UIGradient")
LoadingGradient.Rotation     = 35
LoadingGradient.Color        = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(7,8,15)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(34,19,50)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(7,9,16)),
})
LoadingGradient.Parent = Loading

local LoadingFoxes  = {}
local FoxPositions  = {
	UDim2.new(0,60,0.5,-40), UDim2.new(1,-120,0.5,-80),
	UDim2.new(0.18,0,0,90),  UDim2.new(0.78,0,0,75),
	UDim2.new(0.10,0,1,-150),UDim2.new(0.82,0,1,-160),
}
for _, pos in ipairs(FoxPositions) do
	local f = CreateFox(Loading, pos, 65, 1001)
	f.TextTransparency = 0.15
	table.insert(LoadingFoxes, f)
end
task.spawn(function()
	local off = 0
	while Loading.Parent do
		off += task.wait(0.03)
		for i, f in ipairs(LoadingFoxes) do
			local b = FoxPositions[i]
			local y = math.sin(off * 2 + i) * 8
			f.Position = UDim2.new(b.X.Scale, b.X.Offset, b.Y.Scale, b.Y.Offset + y)
		end
	end
end)

local LoadingCard = Instance.new("Frame")
LoadingCard.Size                 = UDim2.fromOffset(440,260)
LoadingCard.AnchorPoint          = Vector2.new(0.5,0.5)
LoadingCard.Position             = UDim2.fromScale(0.5,0.5)
LoadingCard.BackgroundColor3     = Color3.fromRGB(13,14,21)
LoadingCard.BackgroundTransparency = 0.03
LoadingCard.BorderSizePixel      = 0
LoadingCard.ZIndex               = 1010
LoadingCard.Parent               = Loading
Corner(LoadingCard, 22)
AddStroke(LoadingCard, Color3.fromRGB(130,90,180), 1, 0.2)

local function MkLabel(parent, size, pos, text, tsize, font, color, zi)
	local l = Instance.new("TextLabel")
	l.Size                   = size
	l.Position               = pos
	l.BackgroundTransparency = 1
	l.Text                   = text
	l.TextSize               = tsize
	l.Font                   = font
	l.TextColor3             = color
	l.ZIndex                 = zi or 1012
	l.Parent                 = parent
	return l
end

local LoadingTitle = MkLabel(LoadingCard,
	UDim2.new(1,0,0,65), UDim2.fromOffset(0,42),
	"MK HUB v2.0", 38, Enum.Font.GothamBlack, C.White, 1012)
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.Purple),
	ColorSequenceKeypoint.new(0.5, C.White),
	ColorSequenceKeypoint.new(1, C.Blue),
})
TitleGradient.Parent = LoadingTitle

local LoadingStatus = MkLabel(LoadingCard,
	UDim2.new(1,0,0,25), UDim2.fromOffset(0,103),
	"Loading...", 12, Enum.Font.Gotham, C.Gray, 1012)

local ProgressBack = Instance.new("Frame")
ProgressBack.Size            = UDim2.fromOffset(330,8)
ProgressBack.Position        = UDim2.new(0.5,-165,0,145)
ProgressBack.BackgroundColor3= Color3.fromRGB(37,38,48)
ProgressBack.BorderSizePixel = 0
ProgressBack.ZIndex          = 1012
ProgressBack.Parent          = LoadingCard
Corner(ProgressBack, 10)

local Progress = Instance.new("Frame")
Progress.Size            = UDim2.new(0,0,1,0)
Progress.BackgroundColor3= C.Purple
Progress.BorderSizePixel = 0
Progress.ZIndex          = 1013
Progress.Parent          = ProgressBack
Corner(Progress, 10)
local PGrad = Instance.new("UIGradient")
PGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   C.Blue),
	ColorSequenceKeypoint.new(0.5, C.Purple),
	ColorSequenceKeypoint.new(1,   C.Pink),
})
PGrad.Parent = Progress

task.spawn(function()
	for _, t in ipairs({0.12,0.25,0.40,0.58,0.75,0.90,1}) do
		MakeTween(Progress, 0.5, {Size = UDim2.new(t,0,1,0)}):Play()
		task.wait(0.65)
	end
	task.wait(0.35)
	for _, o in ipairs(LoadingCard:GetDescendants()) do
		if o:IsA("TextLabel") then
			MakeTween(o, 0.3, {TextTransparency = 1}):Play()
		end
	end
	MakeTween(LoadingCard, 0.4, {BackgroundTransparency = 1}):Play()
	for _, f in ipairs(LoadingFoxes) do
		MakeTween(f, 0.4, {TextTransparency = 1}):Play()
	end
	MakeTween(Loading, 0.5, {BackgroundTransparency = 1}):Play()
	task.wait(0.55)
	Loading:Destroy()
end)

--========================================================--
-- HUB BUTTON
--========================================================--

local HubButton = Instance.new("TextButton")
HubButton.Size            = UDim2.fromOffset(64,64)
HubButton.Position        = UDim2.new(0,20,0.5,-32)
HubButton.BackgroundColor3= C.Panel2
HubButton.BorderSizePixel = 0
HubButton.Text            = "MK"
HubButton.TextColor3      = C.White
HubButton.TextSize        = 16
HubButton.Font            = Enum.Font.GothamBlack
HubButton.Visible         = false
HubButton.Parent          = Gui
Corner(HubButton, 32)
AddStroke(HubButton, C.Purple, 2, 0.1)
MakeDraggable(HubButton, HubButton)

--========================================================--
-- MAIN FRAME
--========================================================--

local Main = Instance.new("Frame")
Main.Size              = UDim2.fromOffset(400, 560) -- taller: +50 for new buttons
Main.Position          = UDim2.new(0.5,-200,0.5,-280)
Main.BackgroundColor3  = C.Panel
Main.BorderSizePixel   = 0
Main.Visible           = false
Main.ClipsDescendants  = true
Main.Parent            = Gui
Corner(Main, 22)
AddStroke(Main, Color3.fromRGB(90,78,120), 1, 0.1)

local MenuGlow = Instance.new("Frame")
MenuGlow.Size                    = UDim2.new(1,0,0,120)
MenuGlow.BackgroundColor3        = Color3.fromRGB(36,23,52)
MenuGlow.BackgroundTransparency  = 0.25
MenuGlow.BorderSizePixel         = 0
MenuGlow.Parent                  = Main
Corner(MenuGlow, 22)
local MGG = Instance.new("UIGradient")
MGG.Rotation    = 90
MGG.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0,0),
	NumberSequenceKeypoint.new(1,1),
})
MGG.Parent = MenuGlow

local MenuFox = CreateFox(Main, UDim2.new(1,-95,0,8), 75, 20)
MenuFox.TextSize = 54
task.spawn(function()
	while MenuFox.Parent do
		MakeTween(MenuFox,0.9,{Position=UDim2.new(1,-95,0,2)}):Play()
		task.wait(0.9)
		MakeTween(MenuFox,0.9,{Position=UDim2.new(1,-95,0,8)}):Play()
		task.wait(0.9)
	end
end)

local Header = Instance.new("TextButton")
Header.Size                 = UDim2.new(1,-115,0,55)
Header.Position             = UDim2.fromOffset(16,10)
Header.BackgroundTransparency = 1
Header.Text                 = "MK HUB v2.0"
Header.TextColor3           = C.White
Header.TextSize             = 20
Header.Font                 = Enum.Font.GothamBlack
Header.TextXAlignment       = Enum.TextXAlignment.Left
Header.AutoButtonColor      = false
Header.Parent               = Main
MakeDraggable(Main, Header)

--========================================================--
-- TAB BAR
--========================================================--

local TabBar = Instance.new("Frame")
TabBar.Size                 = UDim2.new(1,-30,0,42)
TabBar.Position             = UDim2.fromOffset(15,72)
TabBar.BackgroundTransparency = 1
TabBar.Parent               = Main

local Tab1 = Instance.new("TextButton")
Tab1.Size            = UDim2.new(0.5,-5,1,0)
Tab1.BackgroundColor3= Color3.fromRGB(68,48,98)
Tab1.BorderSizePixel = 0
Tab1.Text            = "MAIN"
Tab1.TextColor3      = C.White
Tab1.TextSize        = 11
Tab1.Font            = Enum.Font.GothamBold
Tab1.AutoButtonColor = false
Tab1.Parent          = TabBar
Corner(Tab1, 10)

local Tab2 = Instance.new("TextButton")
Tab2.Size            = UDim2.new(0.5,-5,1,0)
Tab2.Position        = UDim2.new(0.5,5,0,0)
Tab2.BackgroundColor3= C.Button
Tab2.BorderSizePixel = 0
Tab2.Text            = "TOOL"
Tab2.TextColor3      = C.White
Tab2.TextSize        = 11
Tab2.Font            = Enum.Font.GothamBold
Tab2.AutoButtonColor = false
Tab2.Parent          = TabBar
Corner(Tab2, 10)

--========================================================--
-- PAGES
--========================================================--

local MainPage = Instance.new("Frame")
MainPage.Size                   = UDim2.new(1,0,1,-125)
MainPage.Position               = UDim2.fromOffset(0,125)
MainPage.BackgroundTransparency = 1
MainPage.Parent                 = Main

local FarmPage = Instance.new("Frame")
FarmPage.Size                   = UDim2.new(1,0,1,-125)
FarmPage.Position               = UDim2.fromOffset(0,125)
FarmPage.BackgroundTransparency = 1
FarmPage.Visible                = false
FarmPage.Parent                 = Main

--========================================================--
-- FEATURE BUTTON FACTORY
--========================================================--

local function FeatureButton(Text, X, Y, Parent)
	local b = Instance.new("TextButton")
	b.Size            = UDim2.fromOffset(175,40)
	b.Position        = UDim2.fromOffset(X,Y)
	b.BackgroundColor3= C.Button
	b.BorderSizePixel = 0
	b.Text            = Text
	b.TextColor3      = C.White
	b.TextSize        = 10
	b.Font            = Enum.Font.GothamBold
	b.AutoButtonColor = false
	b.Parent          = Parent or MainPage
	Corner(b, 10)
	local s = AddStroke(b, C.Stroke, 1, 0.35)
	b.MouseEnter:Connect(function()
		MakeTween(b, 0.12, {BackgroundColor3 = C.ButtonHover}):Play()
		MakeTween(s, 0.12, {Transparency = 0}):Play()
	end)
	b.MouseLeave:Connect(function()
		MakeTween(b, 0.12, {BackgroundColor3 = C.Button}):Play()
		MakeTween(s, 0.12, {Transparency = 0.35}):Play()
	end)
	return b
end

--========================================================--
-- MAIN BUTTONS
--========================================================--

local SpeedButton   = FeatureButton("SPEED  :  OFF",    15,  10)
local JumpButton    = FeatureButton("HIGH JUMP  :  OFF",205, 10)
local FlyButton     = FeatureButton("FLY  :  OFF",      15,  58)
local NoClipButton  = FeatureButton("NOCLIP  :  OFF",   205, 58)

--========================================================--
-- SLIDER FACTORY
--========================================================--

local function MakeSlider(Title, Y, Min, Max, Default, OnChanged)
	local Label = Instance.new("TextLabel")
	Label.Size                   = UDim2.fromOffset(200,22)
	Label.Position               = UDim2.fromOffset(15,Y)
	Label.BackgroundTransparency = 1
	Label.Text                   = Title
	Label.TextColor3             = C.Gray
	Label.TextSize               = 10
	Label.Font                   = Enum.Font.GothamBold
	Label.TextXAlignment         = Enum.TextXAlignment.Left
	Label.Parent                 = MainPage

	local Track = Instance.new("Frame")
	Track.Size            = UDim2.fromOffset(260,7)
	Track.Position        = UDim2.fromOffset(15,Y+27)
	Track.BackgroundColor3= Color3.fromRGB(39,40,50)
	Track.BorderSizePixel = 0
	Track.Parent          = MainPage
	Corner(Track, 10)

	local Fill = Instance.new("Frame")
	Fill.Size            = UDim2.new(0,0,1,0)
	Fill.BackgroundColor3= C.Purple
	Fill.BorderSizePixel = 0
	Fill.Parent          = Track
	Corner(Fill, 10)
	local FG = Instance.new("UIGradient")
	FG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Blue),
		ColorSequenceKeypoint.new(1, C.Purple),
	})
	FG.Parent = Fill

	local Knob = Instance.new("TextButton")
	Knob.Size            = UDim2.fromOffset(18,18)
	Knob.AnchorPoint     = Vector2.new(0.5,0.5)
	Knob.BackgroundColor3= Color3.fromRGB(250,250,255)
	Knob.BorderSizePixel = 0
	Knob.Text            = ""
	Knob.Parent          = Track
	Corner(Knob, 20)
	AddStroke(Knob, C.Purple, 1, 0.15)

	local Input = Instance.new("TextBox")
	Input.Size              = UDim2.fromOffset(75,31)
	Input.Position          = UDim2.fromOffset(300, Y-5)
	Input.BackgroundColor3  = C.Button
	Input.BorderSizePixel   = 0
	Input.Text              = tostring(Default)
	Input.TextColor3        = C.White
	Input.TextSize          = 11
	Input.Font              = Enum.Font.GothamBold
	Input.ClearTextOnFocus  = false
	Input.Parent            = MainPage
	Corner(Input, 8)
	AddStroke(Input, C.Stroke, 1, 0.35)

	local Current = Default

	local function SetValue(v)
		v = math.clamp(math.floor((tonumber(v) or Current) + 0.5), Min, Max)
		Current = v
		local pct = (v - Min) / (Max - Min)
		Fill.Size     = UDim2.new(pct, 0, 1, 0)
		Knob.Position = UDim2.new(pct, 0, 0.5, 0)
		Input.Text    = tostring(v)
		OnChanged(v)
	end

	local function FromMouse(x)
		local left  = Track.AbsolutePosition.X
		local width = Track.AbsoluteSize.X
		if width <= 0 then return end
		SetValue(Min + (Max - Min) * math.clamp((x - left) / width, 0, 1))
	end

	Track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			FromMouse(i.Position.X)
		end
	end)
	Knob.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		local m, r
		m = UIS.InputChanged:Connect(function(ii)
			if ii.UserInputType == Enum.UserInputType.MouseMovement then
				FromMouse(ii.Position.X)
			end
		end)
		r = UIS.InputEnded:Connect(function(ii)
			if ii.UserInputType == Enum.UserInputType.MouseButton1 then
				m:Disconnect(); r:Disconnect()
			end
		end)
	end)
	Input.FocusLost:Connect(function()
		local n = tonumber(Input.Text)
		if n then SetValue(n) else Input.Text = tostring(Current) end
	end)

	SetValue(Default)
	return { Set = SetValue, Get = function() return Current end }
end

--========================================================--
-- SLIDERS
--========================================================--

local SpeedSlider = MakeSlider("SPEED",     110, 16,  200, Settings.Speed, function(v)
	Settings.Speed = v
end)

local JumpSlider  = MakeSlider("HIGH JUMP", 170, 50,  250, Settings.Jump,  function(v)
	Settings.Jump = v
end)

local FlySlider   = MakeSlider("FLY SPEED", 230, 20,  250, Settings.FlySpeed, function(v)
	Settings.FlySpeed = v
end)

--========================================================--
-- SPEED — RenderStepped loop (bypasses most anticheat
--         that checks WalkSpeed once per frame)
--========================================================--

local function StopSpeed()
	SpeedEnabled = false
	if SpeedConnection then
		SpeedConnection:Disconnect()
		SpeedConnection = nil
	end
	if Humanoid then Humanoid.WalkSpeed = 16 end
end

local function StartSpeed()
	if SpeedEnabled then return end
	SpeedEnabled = true
	SpeedConnection = RunService.RenderStepped:Connect(function()
		if Humanoid then
			Humanoid.WalkSpeed = Settings.Speed
		end
	end)
end

SpeedButton.MouseButton1Click:Connect(function()
	if SpeedEnabled then
		StopSpeed()
		SpeedButton.Text = "SPEED  :  OFF"
	else
		StartSpeed()
		SpeedButton.Text = "SPEED  :  ON"
	end
end)

--========================================================--
-- HIGH JUMP — same loop pattern
--========================================================--

local function StopJump()
	JumpEnabled = false
	if JumpConnection then
		JumpConnection:Disconnect()
		JumpConnection = nil
	end
	if Humanoid then
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower    = 50
	end
end

local function StartJump()
	if JumpEnabled then return end
	JumpEnabled = true
	JumpConnection = RunService.RenderStepped:Connect(function()
		if Humanoid then
			Humanoid.UseJumpPower = true
			Humanoid.JumpPower    = Settings.Jump
		end
	end)
end

JumpButton.MouseButton1Click:Connect(function()
	if JumpEnabled then
		StopJump()
		JumpButton.Text = "HIGH JUMP  :  OFF"
	else
		StartJump()
		JumpButton.Text = "HIGH JUMP  :  ON"
	end
end)

--========================================================--
-- FLY — LinearVelocity (R15 modern), fallback BodyVelocity
--========================================================--

local function StopFly()
	FlyEnabled = false
	if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
	if FlyBody then FlyBody:Destroy(); FlyBody = nil end
end

local function StartFly()
	if FlyEnabled or not Root then return end
	FlyEnabled = true

	-- try LinearVelocity (newer API, harder to detect server-side)
	local useLinear = pcall(function()
		local att = Instance.new("Attachment")
		att.Parent = Root
		local lv = Instance.new("LinearVelocity")
		lv.Attachment0      = att
		lv.MaxForce         = math.huge
		lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		lv.VectorVelocity   = Vector3.zero
		lv.Parent           = Root
		FlyBody             = lv
		-- store att reference inside FlyBody for cleanup
		lv:SetAttribute("_att", att.Name)
		FlyBody._att_inst   = att
	end)

	if not useLinear then
		-- fallback
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.zero
		bv.Parent   = Root
		FlyBody     = bv
	end

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not FlyEnabled or not Root then return end
		local cam = Workspace.CurrentCamera
		if not cam then return end
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W)            then dir += cam.CFrame.LookVector  end
		if UIS:IsKeyDown(Enum.KeyCode.S)            then dir -= cam.CFrame.LookVector  end
		if UIS:IsKeyDown(Enum.KeyCode.A)            then dir -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D)            then dir += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space)        then dir += Vector3.new(0,1,0)     end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl)  then dir -= Vector3.new(0,1,0)     end
		local vel = dir.Magnitude > 0 and dir.Unit * Settings.FlySpeed or Vector3.zero
		if FlyBody:IsA("LinearVelocity") then
			FlyBody.VectorVelocity = vel
		else
			FlyBody.Velocity = vel
		end
	end)
end

local _origStopFly = StopFly
StopFly = function()
	if FlyBody and FlyBody:IsA("LinearVelocity") then
		if FlyBody._att_inst then FlyBody._att_inst:Destroy() end
	end
	_origStopFly()
end

FlyButton.MouseButton1Click:Connect(function()
	if FlyEnabled then
		StopFly(); FlyButton.Text = "FLY  :  OFF"
	else
		StartFly(); FlyButton.Text = "FLY  :  ON"
	end
end)

--========================================================--
-- NOCLIP
--========================================================--

local function StopNoClip()
	NoClipEnabled = false
	if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
	if Character then
		for _, o in ipairs(Character:GetDescendants()) do
			if o:IsA("BasePart") then o.CanCollide = true end
		end
	end
end

local function StartNoClip()
	if NoClipEnabled then return end
	NoClipEnabled = true
	NoClipConnection = RunService.Stepped:Connect(function()
		if not Character then return end
		for _, o in ipairs(Character:GetDescendants()) do
			if o:IsA("BasePart") then o.CanCollide = false end
		end
	end)
end

NoClipButton.MouseButton1Click:Connect(function()
	if NoClipEnabled then
		StopNoClip(); NoClipButton.Text = "NOCLIP  :  OFF"
	else
		StartNoClip(); NoClipButton.Text = "NOCLIP  :  ON"
	end
end)

--========================================================--
-- PLAYER ESP
--========================================================--

local ESPObjects = {}

local function RemoveESP(PlrObj)
	local d = ESPObjects[PlrObj]
	if not d then return end
	if d.Highlight then d.Highlight:Destroy() end
	if d.Billboard then d.Billboard:Destroy() end
	ESPObjects[PlrObj] = nil
end

local function CreatePlayerESP(PlrObj)
	if PlrObj == Player then return end
	if not ESPEnabled then return end
	local char = PlrObj.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end

	RemoveESP(PlrObj)

	local hl = Instance.new("Highlight")
	hl.Name                 = "MK_ESP_Player"
	hl.Adornee              = char
	hl.FillColor            = Color3.fromRGB(178,105,255)
	hl.OutlineColor         = Color3.fromRGB(255,255,255)
	hl.FillTransparency     = 0.65
	hl.OutlineTransparency  = 0
	hl.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent               = char

	local bb = Instance.new("BillboardGui")
	bb.Name         = "MK_ESP_Name"
	bb.Adornee      = head
	bb.Size         = UDim2.fromOffset(180,45)
	bb.StudsOffset  = Vector3.new(0,2.8,0)
	bb.AlwaysOnTop  = true
	bb.MaxDistance  = 500
	bb.Parent       = head

	local nl = Instance.new("TextLabel")
	nl.Size                     = UDim2.fromScale(1,0.55)
	nl.BackgroundTransparency   = 1
	nl.Text                     = PlrObj.DisplayName
	nl.TextColor3               = Color3.fromRGB(255,255,255)
	nl.TextStrokeTransparency   = 0
	nl.TextStrokeColor3         = Color3.fromRGB(0,0,0)
	nl.TextSize                 = 13
	nl.Font                     = Enum.Font.GothamBold
	nl.Parent                   = bb

	local dl = Instance.new("TextLabel")
	dl.Size                     = UDim2.fromScale(1,0.45)
	dl.Position                 = UDim2.fromScale(0,0.55)
	dl.BackgroundTransparency   = 1
	dl.Text                     = "0 studs"
	dl.TextColor3               = Color3.fromRGB(190,190,210)
	dl.TextStrokeTransparency   = 0
	dl.TextStrokeColor3         = Color3.fromRGB(0,0,0)
	dl.TextSize                 = 10
	dl.Font                     = Enum.Font.Gotham
	dl.Parent                   = bb

	ESPObjects[PlrObj] = { Highlight = hl, Billboard = bb, Distance = dl }
end

local function UpdatePlayerESP()
	if not ESPEnabled or not Root then return end
	for _, op in ipairs(Players:GetPlayers()) do
		if op ~= Player then
			local d  = ESPObjects[op]
			local oc = op.Character
			local or2= oc and oc:FindFirstChild("HumanoidRootPart")
			if not d then
				CreatePlayerESP(op)
				d = ESPObjects[op]
			end
			if d and or2 then
				local dist = (Root.Position - or2.Position).Magnitude
				if d.Distance then
					d.Distance.Text = math.floor(dist) .. " studs"
				end
			end
		end
	end
end

local function StopESP()
	ESPEnabled = false
	if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
	for op in pairs(ESPObjects) do RemoveESP(op) end
	table.clear(ESPObjects)
end

local function StartESP()
	if ESPEnabled then return end
	ESPEnabled = true
	for _, op in ipairs(Players:GetPlayers()) do
		if op ~= Player then CreatePlayerESP(op) end
	end
	ESPConnection = RunService.RenderStepped:Connect(UpdatePlayerESP)
end

-- player respawn → re-create ESP
Players.PlayerAdded:Connect(function(op)
	op.CharacterAdded:Connect(function()
		if ESPEnabled then
			task.wait(0.3)
			CreatePlayerESP(op)
		end
	end)
end)
-- connect existing players too
for _, op in ipairs(Players:GetPlayers()) do
	if op ~= Player then
		op.CharacterAdded:Connect(function()
			if ESPEnabled then
				task.wait(0.3)
				CreatePlayerESP(op)
			end
		end)
	end
end

Players.PlayerRemoving:Connect(RemoveESP)

--========================================================--
-- MOB ESP
--========================================================--

local MobESPData = {} -- [Humanoid] = {Highlight, Billboard, conn}

local MOB_FILL    = Color3.fromRGB(255,80,80)
local MOB_OUTLINE = Color3.fromRGB(255,220,100)

local function RemoveMobESP(hum)
	local d = MobESPData[hum]
	if not d then return end
	if d.conn then d.conn:Disconnect() end
	if d.Highlight then d.Highlight:Destroy() end
	if d.Billboard then d.Billboard:Destroy() end
	MobESPData[hum] = nil
end

local function CreateMobESP(hum)
	if not MobESPEnabled then return end
	if not hum or not hum.Parent then return end
	-- skip player characters
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character == hum.Parent then return end
	end
	if MobESPData[hum] then return end

	local char = hum.Parent
	local head = char:FindFirstChild("Head") or char:FindFirstChildWhichIsA("BasePart")
	if not head then return end

	local hl = Instance.new("Highlight")
	hl.Name                 = "MK_ESP_Mob"
	hl.Adornee              = char
	hl.FillColor            = MOB_FILL
	hl.OutlineColor         = MOB_OUTLINE
	hl.FillTransparency     = 0.6
	hl.OutlineTransparency  = 0
	hl.DepthMode            = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent               = char

	local bb = Instance.new("BillboardGui")
	bb.Name         = "MK_ESP_MobName"
	bb.Adornee      = head
	bb.Size         = UDim2.fromOffset(160,40)
	bb.StudsOffset  = Vector3.new(0,3,0)
	bb.AlwaysOnTop  = true
	bb.MaxDistance  = 400
	bb.Parent       = head

	local nl = Instance.new("TextLabel")
	nl.Size                     = UDim2.fromScale(1,0.55)
	nl.BackgroundTransparency   = 1
	nl.Text                     = char.Name
	nl.TextColor3               = MOB_OUTLINE
	nl.TextStrokeTransparency   = 0
	nl.TextStrokeColor3         = Color3.fromRGB(0,0,0)
	nl.TextSize                 = 12
	nl.Font                     = Enum.Font.GothamBold
	nl.Parent                   = bb

	local dl = Instance.new("TextLabel")
	dl.Size                     = UDim2.fromScale(1,0.45)
	dl.Position                 = UDim2.fromScale(0,0.55)
	dl.BackgroundTransparency   = 1
	dl.Text                     = "0 studs"
	dl.TextColor3               = Color3.fromRGB(230,210,180)
	dl.TextStrokeTransparency   = 0
	dl.TextStrokeColor3         = Color3.fromRGB(0,0,0)
	dl.TextSize                 = 10
	dl.Font                     = Enum.Font.Gotham
	dl.Parent                   = bb

	-- when mob dies: remove ESP, then re-scan after respawn window
	local deathConn
	deathConn = hum.Died:Connect(function()
		RemoveMobESP(hum)
		-- after typical respawn delay, re-create if still enabled
		task.delay(3, function()
			if not MobESPEnabled then return end
			-- re-scan workspace for new humanoids (mob may have respawned)
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("Humanoid") then
					CreateMobESP(obj)
				end
			end
		end)
	end)

	MobESPData[hum] = { Highlight = hl, Billboard = bb, conn = deathConn, Distance = dl }
end

local function ScanMobs()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Humanoid") then
			CreateMobESP(obj)
		end
	end
end

local function UpdateMobESP()
	if not MobESPEnabled or not Root then return end
	for hum, d in pairs(MobESPData) do
		local char = hum and hum.Parent
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and d.Distance then
			d.Distance.Text = math.floor((Root.Position - hrp.Position).Magnitude) .. " studs"
		end
	end
end

local function StopMobESP()
	MobESPEnabled = false
	if MobESPConnection then MobESPConnection:Disconnect(); MobESPConnection = nil end
	for hum in pairs(MobESPData) do RemoveMobESP(hum) end
	table.clear(MobESPData)
end

local function StartMobESP()
	if MobESPEnabled then return end
	MobESPEnabled = true
	ScanMobs()
	-- watch for new mobs added during session
	MobESPConnection = Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Humanoid") then
			task.defer(function()
				if MobESPEnabled then CreateMobESP(obj) end
			end)
		end
	end)
end

--========================================================--
-- TOOL PAGE TITLE
--========================================================--

local FarmTitle = Instance.new("TextLabel")
FarmTitle.Size                   = UDim2.new(1,-30,0,35)
FarmTitle.Position               = UDim2.fromOffset(15,8)
FarmTitle.BackgroundTransparency = 1
FarmTitle.Text                   = "TOOL"
FarmTitle.TextColor3             = C.White
FarmTitle.TextSize               = 18
FarmTitle.Font                   = Enum.Font.GothamBlack
FarmTitle.TextXAlignment         = Enum.TextXAlignment.Left
FarmTitle.Parent                 = FarmPage

local FarmLine = Instance.new("Frame")
FarmLine.Size                    = UDim2.new(1,-30,0,1)
FarmLine.Position                = UDim2.fromOffset(15,45)
FarmLine.BackgroundColor3        = C.Stroke
FarmLine.BackgroundTransparency  = 0.35
FarmLine.BorderSizePixel         = 0
FarmLine.Parent                  = FarmPage

--========================================================--
-- TOOL PAGE BUTTONS
--========================================================--

-- Row 1: ESP buttons
local ESPButton    = FeatureButton("PLAYER ESP  :  OFF", 15,  65, FarmPage)
local MobESPButton = FeatureButton("MOB ESP  :  OFF",    205, 65, FarmPage)

ESPButton.MouseButton1Click:Connect(function()
	if ESPEnabled then
		StopESP(); ESPButton.Text = "PLAYER ESP  :  OFF"
	else
		StartESP(); ESPButton.Text = "PLAYER ESP  :  ON"
	end
end)

MobESPButton.MouseButton1Click:Connect(function()
	if MobESPEnabled then
		StopMobESP(); MobESPButton.Text = "MOB ESP  :  OFF"
	else
		StartMobESP(); MobESPButton.Text = "MOB ESP  :  ON"
	end
end)

-- update mob ESP distance every 0.5s instead of every frame (lighter)
task.spawn(function()
	while true do
		task.wait(0.5)
		UpdateMobESP()
	end
end)

--========================================================--
-- ULTRA FAST MODE  (kept from original, condensed)
--========================================================--

local FastModeButton = FeatureButton("ULTRA FAST  :  OFF", 205, 125, FarmPage)

local FastBackup   = { Properties = {}, Lighting = {} }
local FastConns    = {}
local OrigTerrainDec

local function BackupProp(obj, prop)
	if not obj then return end
	FastBackup.Properties[obj] = FastBackup.Properties[obj] or {}
	if FastBackup.Properties[obj][prop] == nil then
		local ok, v = pcall(function() return obj[prop] end)
		if ok then FastBackup.Properties[obj][prop] = v end
	end
end

local function ChangeProp(obj, prop, val)
	if not obj then return end
	BackupProp(obj, prop)
	pcall(function() obj[prop] = val end)
end

local function OptObj(obj)
	if not FastModeEnabled or not obj or not obj.Parent then return end
	local t = obj.ClassName
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
	or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
	or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		ChangeProp(obj, "Enabled", false)
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		ChangeProp(obj, "Transparency", 1)
	elseif obj:IsA("SpecialMesh") then
		ChangeProp(obj, "TextureId", "")
	elseif obj:IsA("SurfaceAppearance") then
		for _, k in ipairs({"ColorMap","MetalnessMap","NormalMap","RoughnessMap"}) do
			ChangeProp(obj, k, "")
		end
	end
end

local function OptPart(obj)
	if not obj:IsA("BasePart") then return end
	ChangeProp(obj, "Material",    Enum.Material.SmoothPlastic)
	ChangeProp(obj, "Reflectance", 0)
end

local function StartFastMode()
	if FastModeEnabled then return end
	FastModeEnabled = true
	-- lighting
	for _, k in ipairs({"GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale","FogEnd"}) do
		local ok, v = pcall(function() return Lighting[k] end)
		if ok then FastBackup.Lighting[k] = v end
	end
	pcall(function() Lighting.GlobalShadows = false end)
	pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
	pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
	pcall(function() Lighting.FogEnd = 100000 end)
	for _, o in ipairs(Lighting:GetDescendants()) do OptObj(o) end
	-- terrain
	local terr = Workspace:FindFirstChildOfClass("Terrain")
	if terr then
		local ok, v = pcall(function() return terr.Decoration end)
		if ok then OrigTerrainDec = v end
		pcall(function() terr.Decoration = false end)
	end
	-- workspace
	for _, o in ipairs(Workspace:GetDescendants()) do OptObj(o); OptPart(o) end
	-- future objects
	table.insert(FastConns, Workspace.DescendantAdded:Connect(function(o)
		if not FastModeEnabled then return end
		task.defer(function()
			if FastModeEnabled and o and o.Parent then OptObj(o); OptPart(o) end
		end)
	end))
	table.insert(FastConns, Lighting.DescendantAdded:Connect(function(o)
		if not FastModeEnabled then return end
		task.defer(function()
			if FastModeEnabled and o and o.Parent then OptObj(o) end
		end)
	end))
end

local function StopFastMode()
	if not FastModeEnabled then return end
	FastModeEnabled = false
	for _, c in ipairs(FastConns) do if c and c.Connected then c:Disconnect() end end
	table.clear(FastConns)
	for obj, props in pairs(FastBackup.Properties) do
		if obj and obj.Parent then
			for k, v in pairs(props) do pcall(function() obj[k] = v end) end
		end
	end
	for k, v in pairs(FastBackup.Lighting) do pcall(function() Lighting[k] = v end) end
	local terr = Workspace:FindFirstChildOfClass("Terrain")
	if terr and OrigTerrainDec ~= nil then
		pcall(function() terr.Decoration = OrigTerrainDec end)
	end
	table.clear(FastBackup.Properties)
	table.clear(FastBackup.Lighting)
end

FastModeButton.MouseButton1Click:Connect(function()
	if FastModeEnabled then
		StopFastMode(); FastModeButton.Text = "ULTRA FAST  :  OFF"
	else
		StartFastMode(); FastModeButton.Text = "ULTRA FAST  :  ON"
	end
end)

local FastInfo = Instance.new("TextLabel")
FastInfo.Size                    = UDim2.new(1,-30,0,70)
FastInfo.Position                = UDim2.fromOffset(15,175)
FastInfo.BackgroundColor3        = C.Button
FastInfo.BackgroundTransparency  = 0.2
FastInfo.BorderSizePixel         = 0
FastInfo.Text                    = "ULTRA FAST MODE\nGiảm particle • texture • decal • beam\ntrail • light • shadow • material"
FastInfo.TextColor3              = C.Gray
FastInfo.TextSize                = 10
FastInfo.Font                    = Enum.Font.GothamBold
FastInfo.TextWrapped             = true
FastInfo.TextYAlignment          = Enum.TextYAlignment.Center
FastInfo.Parent                  = FarmPage
Corner(FastInfo, 12)
AddStroke(FastInfo, C.Stroke, 1, 0.45)

--========================================================--
-- TELEPORT  &  RESET
--========================================================--

local Teleport = FeatureButton("TELEPORT",  15,  300, MainPage)
local Reset    = FeatureButton("RESET ALL", 205, 300, MainPage)

Teleport.MouseButton1Click:Connect(function()
	if not Root then return end
	for _, o in ipairs(Workspace:GetDescendants()) do
		if o:IsA("SpawnLocation") then
			Root.CFrame = o.CFrame + Vector3.new(0,5,0)
			break
		end
	end
end)

local function ResetEverything()
	StopFly(); StopNoClip(); StopESP(); StopMobESP(); StopSpeed(); StopJump()
	if FastModeEnabled then StopFastMode() end
	SpeedEnabled = false; JumpEnabled = false; FlyEnabled = false
	NoClipEnabled = false; ESPEnabled = false; MobESPEnabled = false
	Settings.Speed    = DEFAULT.Speed
	Settings.Jump     = DEFAULT.Jump
	Settings.FlySpeed = DEFAULT.FlySpeed
	if Humanoid then
		Humanoid.WalkSpeed    = 16
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower    = 50
	end
	SpeedButton.Text     = "SPEED  :  OFF"
	JumpButton.Text      = "HIGH JUMP  :  OFF"
	FlyButton.Text       = "FLY  :  OFF"
	NoClipButton.Text    = "NOCLIP  :  OFF"
	ESPButton.Text       = "PLAYER ESP  :  OFF"
	MobESPButton.Text    = "MOB ESP  :  OFF"
	FastModeButton.Text  = "ULTRA FAST  :  OFF"
	SpeedSlider.Set(DEFAULT.Speed)
	JumpSlider.Set(DEFAULT.Jump)
	FlySlider.Set(DEFAULT.FlySpeed)
end

Reset.MouseButton1Click:Connect(ResetEverything)

--========================================================--
-- TAB SYSTEM
--========================================================--

local function SelectTab(n)
	if n == 1 then
		MainPage.Visible = true; FarmPage.Visible = false
		MakeTween(Tab1, 0.15, {BackgroundColor3 = Color3.fromRGB(68,48,98)}):Play()
		MakeTween(Tab2, 0.15, {BackgroundColor3 = C.Button}):Play()
	else
		MainPage.Visible = false; FarmPage.Visible = true
		MakeTween(Tab1, 0.15, {BackgroundColor3 = C.Button}):Play()
		MakeTween(Tab2, 0.15, {BackgroundColor3 = Color3.fromRGB(68,48,98)}):Play()
	end
end

Tab1.MouseButton1Click:Connect(function() SelectTab(1) end)
Tab2.MouseButton1Click:Connect(function() SelectTab(2) end)

--========================================================--
-- OPEN / CLOSE
--========================================================--

local MenuOpen = false

local function OpenMenu()
	MenuOpen = true; Main.Visible = true
	Main.Size = UDim2.fromOffset(0,0)
	MakeTween(Main, 0.3, {Size = UDim2.fromOffset(400,560)}, Enum.EasingStyle.Back):Play()
end

local function CloseMenu()
	MenuOpen = false
	local a = MakeTween(Main, 0.18, {Size = UDim2.fromOffset(0,0)}, Enum.EasingStyle.Quad)
	a:Play()
	a.Completed:Once(function() if not MenuOpen then Main.Visible = false end end)
end

HubButton.MouseButton1Click:Connect(function()
	if MenuOpen then CloseMenu() else OpenMenu() end
end)

HubButton.MouseEnter:Connect(function()
	MakeTween(HubButton, 0.15, {Size = UDim2.fromOffset(70,70)}):Play()
end)
HubButton.MouseLeave:Connect(function()
	MakeTween(HubButton, 0.15, {Size = UDim2.fromOffset(64,64)}):Play()
end)

--========================================================--
-- SHOW BUTTON AFTER LOADING
--========================================================--

task.delay(5, function()
	if not HubButton.Parent then return end
	HubButton.Visible = true
	HubButton.BackgroundTransparency = 1
	MakeTween(HubButton, 0.45, {BackgroundTransparency = 0}):Play()
end)

--========================================================--
-- CLEANUP ON DEATH / RESPAWN
--========================================================--

Player.CharacterRemoving:Connect(function()
	if FlyEnabled     then StopFly()     end
	if NoClipEnabled  then StopNoClip()  end
	if SpeedEnabled   then StopSpeed()   end
	if JumpEnabled    then StopJump()    end
end)

--========================================================--
-- READY
--========================================================--

print("MK HUB v2.0 | MOB ESP + RESPAWN ESP + UPDATED MOVEMENT")
