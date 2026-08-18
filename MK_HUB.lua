--========================================================--
--                    MK HUB v2.0                         --
--                 FOX ANIME EDITION                      --
--              TOOL / ULTRA FAST MODE                    --
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local Workspace = workspace

local Player = Players.LocalPlayer

--========================================================--
-- SETTINGS
--========================================================--

local DEFAULT = {
	Speed = 60,
	Jump = 100,
	FlySpeed = 80,
	AimFOV = 120
}

local Settings = {
	Speed = DEFAULT.Speed,
	Jump = DEFAULT.Jump,
	FlySpeed = DEFAULT.FlySpeed,
	AimFOV = DEFAULT.AimFOV
}

--========================================================--
-- CHARACTER
--========================================================--

local Character
local Humanoid
local Root

local function LoadCharacter(Char)
	Character = Char
	Humanoid = Char:WaitForChild("Humanoid")
	Root = Char:WaitForChild("HumanoidRootPart")

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

local SpeedEnabled = false
local JumpEnabled = false
local FlyEnabled = false
local NoClipEnabled = false
local ESPEnabled = false
local AimlockEnabled = false
local FastModeEnabled = false

local FlyVelocity
local FlyConnection
local NoClipConnection
local ESPConnection
local AimConnection

--========================================================--
-- COLORS
--========================================================--

local C = {
	Background = Color3.fromRGB(7, 8, 13),
	Panel = Color3.fromRGB(14, 15, 22),
	Panel2 = Color3.fromRGB(21, 22, 31),
	Button = Color3.fromRGB(27, 28, 38),
	ButtonHover = Color3.fromRGB(43, 43, 58),

	White = Color3.fromRGB(245, 245, 255),
	Gray = Color3.fromRGB(150, 152, 170),

	Purple = Color3.fromRGB(178, 105, 255),
	Blue = Color3.fromRGB(100, 160, 255),
	Pink = Color3.fromRGB(255, 125, 205),

	Stroke = Color3.fromRGB(70, 70, 92)
}

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")

Gui.Name = "MK_HUB_v2"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999

Gui.Parent = Player:WaitForChild("PlayerGui")

--========================================================--
-- UTILITY
--========================================================--

local function Corner(Object, Radius)
	local CornerObject = Instance.new("UICorner")

	CornerObject.CornerRadius = UDim.new(0, Radius)
	CornerObject.Parent = Object

	return CornerObject
end

local function AddStroke(Object, Color, Thickness, Transparency)
	local S = Instance.new("UIStroke")

	S.Color = Color or C.Stroke
	S.Thickness = Thickness or 1
	S.Transparency = Transparency or 0

	S.Parent = Object

	return S
end

local function MakeTween(Object, Time, Properties, Style)
	return TweenService:Create(
		Object,
		TweenInfo.new(
			Time,
			Style or Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		Properties
	)
end

--========================================================--
-- DRAG
--========================================================--

local function MakeDraggable(Object, Handle)

	local Dragging = false
	local DragStart
	local StartPosition

	Handle.InputBegan:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Object.Position

		end

	end)

	Handle.InputEnded:Connect(function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			Dragging = false

		end

	end)

	UIS.InputChanged:Connect(function(Input)

		if not Dragging then
			return
		end

		if Input.UserInputType ~=
			Enum.UserInputType.MouseMovement then

			return
		end

		local Delta =
			Input.Position - DragStart

		Object.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)

	end)

end

--========================================================--
-- FOX
--========================================================--

local function CreateFox(Parent, Position, Size, ZIndex)

	local Fox = Instance.new("TextLabel")

	Fox.Size =
		UDim2.fromOffset(Size, Size)

	Fox.Position = Position

	Fox.BackgroundTransparency = 1
	Fox.Text = "🦊"

	Fox.TextSize =
		math.floor(Size * 0.72)

	Fox.Font = Enum.Font.GothamBlack
	Fox.TextColor3 = Color3.fromRGB(255,255,255)

	Fox.ZIndex = ZIndex or 10
	Fox.Parent = Parent

	return Fox
end

--========================================================--
-- LOADING
--========================================================--

local Loading = Instance.new("Frame")

Loading.Size = UDim2.fromScale(1,1)
Loading.BackgroundColor3 = C.Background
Loading.BorderSizePixel = 0
Loading.ZIndex = 1000
Loading.Parent = Gui

local LoadingGradient = Instance.new("UIGradient")

LoadingGradient.Rotation = 35

LoadingGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(7,8,15)
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.fromRGB(34,19,50)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(7,9,16)
		)
	})

LoadingGradient.Parent = Loading

local LoadingFoxes = {}

local FoxPositions = {
	UDim2.new(0,60,0.5,-40),
	UDim2.new(1,-120,0.5,-80),
	UDim2.new(0.18,0,0,90),
	UDim2.new(0.78,0,0,75),
	UDim2.new(0.10,0,1,-150),
	UDim2.new(0.82,0,1,-160)
}

for _, Position in ipairs(FoxPositions) do

	local Fox =
		CreateFox(
			Loading,
			Position,
			65,
			1001
		)

	Fox.TextTransparency = 0.15

	table.insert(
		LoadingFoxes,
		Fox
	)

end

task.spawn(function()

	local Offset = 0

	while Loading.Parent do

		Offset += task.wait(0.03)

		for Index, Fox in ipairs(LoadingFoxes) do

			local Base = FoxPositions[Index]

			local Y =
				math.sin(
					Offset * 2 + Index
				) * 8

			Fox.Position =
				UDim2.new(
					Base.X.Scale,
					Base.X.Offset,
					Base.Y.Scale,
					Base.Y.Offset + Y
				)

		end

	end

end)

--========================================================--
-- LOADING CARD
--========================================================--

local LoadingCard = Instance.new("Frame")

LoadingCard.Size =
	UDim2.fromOffset(440,260)

LoadingCard.AnchorPoint =
	Vector2.new(0.5,0.5)

LoadingCard.Position =
	UDim2.fromScale(0.5,0.5)

LoadingCard.BackgroundColor3 =
	Color3.fromRGB(13,14,21)

LoadingCard.BackgroundTransparency = 0.03
LoadingCard.BorderSizePixel = 0
LoadingCard.ZIndex = 1010
LoadingCard.Parent = Loading

Corner(LoadingCard,22)

AddStroke(
	LoadingCard,
	Color3.fromRGB(130,90,180),
	1,
	0.2
)

local LoadingTitle = Instance.new("TextLabel")

LoadingTitle.Size =
	UDim2.new(1,0,0,65)

LoadingTitle.Position =
	UDim2.fromOffset(0,42)

LoadingTitle.BackgroundTransparency = 1

LoadingTitle.Text =
	"MK HUB v2.0"

LoadingTitle.TextColor3 = C.White
LoadingTitle.TextSize = 38
LoadingTitle.Font = Enum.Font.GothamBlack
LoadingTitle.ZIndex = 1012
LoadingTitle.Parent = LoadingCard

local TitleGradient = Instance.new("UIGradient")

TitleGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(0,C.Purple),
		ColorSequenceKeypoint.new(0.5,C.White),
		ColorSequenceKeypoint.new(1,C.Blue)
	})

TitleGradient.Parent = LoadingTitle

local LoadingStatus = Instance.new("TextLabel")

LoadingStatus.Size =
	UDim2.new(1,0,0,25)

LoadingStatus.Position =
	UDim2.fromOffset(0,103)

LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "Loading..."
LoadingStatus.TextColor3 = C.Gray
LoadingStatus.TextSize = 12
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.ZIndex = 1012
LoadingStatus.Parent = LoadingCard

local ProgressBack = Instance.new("Frame")

ProgressBack.Size =
	UDim2.fromOffset(330,8)

ProgressBack.Position =
	UDim2.new(0.5,-165,0,145)

ProgressBack.BackgroundColor3 =
	Color3.fromRGB(37,38,48)

ProgressBack.BorderSizePixel = 0
ProgressBack.ZIndex = 1012
ProgressBack.Parent = LoadingCard

Corner(ProgressBack,10)

local Progress = Instance.new("Frame")

Progress.Size =
	UDim2.new(0,0,1,0)

Progress.BackgroundColor3 = C.Purple
Progress.BorderSizePixel = 0
Progress.ZIndex = 1013
Progress.Parent = ProgressBack

Corner(Progress,10)

local ProgressGradient = Instance.new("UIGradient")

ProgressGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(0,C.Blue),
		ColorSequenceKeypoint.new(0.5,C.Purple),
		ColorSequenceKeypoint.new(1,C.Pink)
	})

ProgressGradient.Parent = Progress

--========================================================--
-- LOADING 5 SEC
--========================================================--

task.spawn(function()

	local Steps = {
		0.12,
		0.25,
		0.40,
		0.58,
		0.75,
		0.90,
		1
	}

	for _, Target in ipairs(Steps) do

		LoadingStatus.Text = "Loading..."

		MakeTween(
			Progress,
			0.5,
			{
				Size =
					UDim2.new(
						Target,
						0,
						1,
						0
					)
			}
		):Play()

		task.wait(0.65)

	end

	task.wait(0.35)

	for _, Object in ipairs(
		LoadingCard:GetDescendants()
	) do

		if Object:IsA("TextLabel") then

			MakeTween(
				Object,
				0.3,
				{
					TextTransparency = 1
				}
			):Play()

		end

	end

	MakeTween(
		LoadingCard,
		0.4,
		{
			BackgroundTransparency = 1
		}
	):Play()

	for _, Fox in ipairs(LoadingFoxes) do

		MakeTween(
			Fox,
			0.4,
			{
				TextTransparency = 1
			}
		):Play()

	end

	MakeTween(
		Loading,
		0.5,
		{
			BackgroundTransparency = 1
		}
	):Play()

	task.wait(0.55)

	Loading:Destroy()

end)

--========================================================--
-- HUB BUTTON
--========================================================--

local HubButton = Instance.new("TextButton")

HubButton.Size =
	UDim2.fromOffset(64,64)

HubButton.Position =
	UDim2.new(0,20,0.5,-32)

HubButton.BackgroundColor3 = C.Panel2
HubButton.BorderSizePixel = 0
HubButton.Text = "MK"
HubButton.TextColor3 = C.White
HubButton.TextSize = 16
HubButton.Font = Enum.Font.GothamBlack
HubButton.Visible = false

HubButton.Parent = Gui

Corner(HubButton,32)

AddStroke(
	HubButton,
	C.Purple,
	2,
	0.1
)

MakeDraggable(
	HubButton,
	HubButton
)

--========================================================--
-- MAIN MENU
--========================================================--

local Main = Instance.new("Frame")

Main.Size =
	UDim2.fromOffset(400,510)

Main.Position =
	UDim2.new(
		0.5,
		-200,
		0.5,
		-255
	)

Main.BackgroundColor3 = C.Panel
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui

Corner(Main,22)

AddStroke(
	Main,
	Color3.fromRGB(90,78,120),
	1,
	0.1
)

--========================================================--
-- TOP GLOW
--========================================================--

local MenuGlow = Instance.new("Frame")

MenuGlow.Size =
	UDim2.new(1,0,0,120)

MenuGlow.BackgroundColor3 =
	Color3.fromRGB(36,23,52)

MenuGlow.BackgroundTransparency = 0.25
MenuGlow.BorderSizePixel = 0
MenuGlow.Parent = Main

Corner(MenuGlow,22)

local MenuGlowGradient = Instance.new("UIGradient")

MenuGlowGradient.Rotation = 90

MenuGlowGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0,0),
		NumberSequenceKeypoint.new(1,1)
	})

MenuGlowGradient.Parent = MenuGlow

--========================================================--
-- FOX
--========================================================--

local MenuFox =
	CreateFox(
		Main,
		UDim2.new(1,-95,0,8),
		75,
		20
	)

MenuFox.TextSize = 54

task.spawn(function()

	while MenuFox.Parent do

		MakeTween(
			MenuFox,
			0.9,
			{
				Position =
					UDim2.new(
						1,-95,
						0,2
					)
			}
		):Play()

		task.wait(0.9)

		MakeTween(
			MenuFox,
			0.9,
			{
				Position =
					UDim2.new(
						1,-95,
						0,8
					)
			}
		):Play()

		task.wait(0.9)

	end

end)

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("TextButton")

Header.Size =
	UDim2.new(1,-115,0,55)

Header.Position =
	UDim2.fromOffset(16,10)

Header.BackgroundTransparency = 1

Header.Text =
	"MK HUB v2.0"

Header.TextColor3 = C.White
Header.TextSize = 20
Header.Font = Enum.Font.GothamBlack

Header.TextXAlignment =
	Enum.TextXAlignment.Left

Header.AutoButtonColor = false
Header.Parent = Main

MakeDraggable(Main,Header)

--========================================================--
-- TAB BAR
--========================================================--

local TabBar = Instance.new("Frame")

TabBar.Size =
	UDim2.new(1,-30,0,42)

TabBar.Position =
	UDim2.fromOffset(15,72)

TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local Tab1 = Instance.new("TextButton")

Tab1.Size =
	UDim2.new(0.5,-5,1,0)

Tab1.BackgroundColor3 =
	Color3.fromRGB(68,48,98)

Tab1.BorderSizePixel = 0
Tab1.Text = "MAIN"
Tab1.TextColor3 = C.White
Tab1.TextSize = 11
Tab1.Font = Enum.Font.GothamBold
Tab1.AutoButtonColor = false
Tab1.Parent = TabBar

Corner(Tab1,10)

local Tab2 = Instance.new("TextButton")

Tab2.Size =
	UDim2.new(0.5,-5,1,0)

Tab2.Position =
	UDim2.new(0.5,5,0,0)

Tab2.BackgroundColor3 = C.Button
Tab2.BorderSizePixel = 0

-- ĐỔI FARM -> TOOL
Tab2.Text = "TOOL"

Tab2.TextColor3 = C.White
Tab2.TextSize = 11
Tab2.Font = Enum.Font.GothamBold
Tab2.AutoButtonColor = false
Tab2.Parent = TabBar

Corner(Tab2,10)

--========================================================--
-- PAGES
--========================================================--

local MainPage = Instance.new("Frame")

MainPage.Size =
	UDim2.new(1,0,1,-125)

MainPage.Position =
	UDim2.fromOffset(0,125)

MainPage.BackgroundTransparency = 1
MainPage.Parent = Main

local FarmPage = Instance.new("Frame")

FarmPage.Size =
	UDim2.new(1,0,1,-125)

FarmPage.Position =
	UDim2.fromOffset(0,125)

FarmPage.BackgroundTransparency = 1
FarmPage.Visible = false
FarmPage.Parent = Main

--========================================================--
-- FEATURE BUTTON
--========================================================--

local function FeatureButton(Text,X,Y,Parent)

	local Button = Instance.new("TextButton")

	Button.Size =
		UDim2.fromOffset(175,40)

	Button.Position =
		UDim2.fromOffset(X,Y)

	Button.BackgroundColor3 = C.Button
	Button.BorderSizePixel = 0

	Button.Text = Text
	Button.TextColor3 = C.White
	Button.TextSize = 10
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false

	Button.Parent =
		Parent or MainPage

	Corner(Button,10)

	local S =
		AddStroke(
			Button,
			C.Stroke,
			1,
			0.35
		)

	Button.MouseEnter:Connect(function()

		MakeTween(
			Button,
			0.12,
			{
				BackgroundColor3 =
					C.ButtonHover
			}
		):Play()

		MakeTween(
			S,
			0.12,
			{
				Transparency = 0
			}
		):Play()

	end)

	Button.MouseLeave:Connect(function()

		MakeTween(
			Button,
			0.12,
			{
				BackgroundColor3 =
					C.Button
			}
		):Play()

		MakeTween(
			S,
			0.12,
			{
				Transparency = 0.35
			}
		):Play()

	end)

	return Button
end

--========================================================--
-- MAIN BUTTONS
--========================================================--

local SpeedButton =
	FeatureButton(
		"SPEED  :  OFF",
		15,
		10
	)

local JumpButton =
	FeatureButton(
		"HIGH JUMP  :  OFF",
		205,
		10
	)

local FlyButton =
	FeatureButton(
		"FLY  :  OFF",
		15,
		58
	)

local NoClipButton =
	FeatureButton(
		"NOCLIP  :  OFF",
		205,
		58
	)

--========================================================--
-- SLIDER
--========================================================--

local function MakeSlider(
	Title,
	Y,
	Min,
	Max,
	DefaultValue,
	Changed
)

	local Label = Instance.new("TextLabel")

	Label.Size =
		UDim2.fromOffset(200,22)

	Label.Position =
		UDim2.fromOffset(15,Y)

	Label.BackgroundTransparency = 1
	Label.Text = Title
	Label.TextColor3 = C.Gray
	Label.TextSize = 10
	Label.Font = Enum.Font.GothamBold

	Label.TextXAlignment =
		Enum.TextXAlignment.Left

	Label.Parent = MainPage

	local Track = Instance.new("Frame")

	Track.Size =
		UDim2.fromOffset(260,7)

	Track.Position =
		UDim2.fromOffset(15,Y+27)

	Track.BackgroundColor3 =
		Color3.fromRGB(39,40,50)

	Track.BorderSizePixel = 0
	Track.Parent = MainPage

	Corner(Track,10)

	local Fill = Instance.new("Frame")

	Fill.Size =
		UDim2.new(0,0,1,0)

	Fill.BackgroundColor3 = C.Purple
	Fill.BorderSizePixel = 0
	Fill.Parent = Track

	Corner(Fill,10)

	local FillGradient = Instance.new("UIGradient")

	FillGradient.Color =
		ColorSequence.new({
			ColorSequenceKeypoint.new(0,C.Blue),
			ColorSequenceKeypoint.new(1,C.Purple)
		})

	FillGradient.Parent = Fill

	local Knob = Instance.new("TextButton")

	Knob.Size =
		UDim2.fromOffset(18,18)

	Knob.AnchorPoint =
		Vector2.new(0.5,0.5)

	Knob.BackgroundColor3 =
		Color3.fromRGB(250,250,255)

	Knob.BorderSizePixel = 0
	Knob.Text = ""
	Knob.Parent = Track

	Corner(Knob,20)

	AddStroke(
		Knob,
		C.Purple,
		1,
		0.15
	)

	local Input = Instance.new("TextBox")

	Input.Size =
		UDim2.fromOffset(75,31)

	Input.Position =
		UDim2.fromOffset(300,Y-5)

	Input.BackgroundColor3 = C.Button
	Input.BorderSizePixel = 0

	Input.Text =
		tostring(DefaultValue)

	Input.TextColor3 = C.White
	Input.TextSize = 11
	Input.Font = Enum.Font.GothamBold

	Input.ClearTextOnFocus = false
	Input.Parent = MainPage

	Corner(Input,8)

	AddStroke(
		Input,
		C.Stroke,
		1,
		0.35
	)

	local Current =
		DefaultValue

	local function SetValue(Value)

		Value =
			tonumber(Value) or Current

		Value =
			math.clamp(
				math.floor(Value+0.5),
				Min,
				Max
			)

		Current = Value

		local Percent =
			(Value-Min)/(Max-Min)

		Fill.Size =
			UDim2.new(
				Percent,
				0,
				1,
				0
			)

		Knob.Position =
			UDim2.new(
				Percent,
				0,
				0.5,
				0
			)

		Input.Text =
			tostring(Value)

		Changed(Value)

	end

	local function SetFromMouse(X)

		local Left =
			Track.AbsolutePosition.X

		local Width =
			Track.AbsoluteSize.X

		if Width <= 0 then
			return
		end

		local Percent =
			math.clamp(
				(X-Left)/Width,
				0,
				1
			)

		SetValue(
			Min+(Max-Min)*Percent
		)

	end

	Track.InputBegan:Connect(function(InputObject)

		if InputObject.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			SetFromMouse(
				InputObject.Position.X
			)

		end

	end)

	Knob.InputBegan:Connect(function(InputObject)

		if InputObject.UserInputType ~=
			Enum.UserInputType.MouseButton1 then

			return
		end

		local Moving
		local Released

		Moving =
			UIS.InputChanged:Connect(function(Move)

				if Move.UserInputType ==
					Enum.UserInputType.MouseMovement then

					SetFromMouse(
						Move.Position.X
					)

				end

			end)

		Released =
			UIS.InputEnded:Connect(function(Ended)

				if Ended.UserInputType ==
					Enum.UserInputType.MouseButton1 then

					Moving:Disconnect()
					Released:Disconnect()

				end

			end)

	end)

	Input.FocusLost:Connect(function()

		local Number =
			tonumber(Input.Text)

		if Number then
			SetValue(Number)
		else
			Input.Text =
				tostring(Current)
		end

	end)

	SetValue(DefaultValue)

	return {
		Set = SetValue,

		Get = function()
			return Current
		end
	}
end

--========================================================--
-- SLIDERS
--========================================================--

local SpeedSlider =
	MakeSlider(
		"SPEED",
		110,
		16,
		200,
		Settings.Speed,

		function(Value)

			Settings.Speed = Value

			if SpeedEnabled and Humanoid then
				Humanoid.WalkSpeed = Value
			end

		end
	)

local JumpSlider =
	MakeSlider(
		"HIGH JUMP",
		170,
		50,
		250,
		Settings.Jump,

		function(Value)

			Settings.Jump = Value

			if JumpEnabled and Humanoid then
				Humanoid.JumpPower = Value
			end

		end
	)

local FlySlider =
	MakeSlider(
		"FLY SPEED",
		230,
		20,
		250,
		Settings.FlySpeed,

		function(Value)

			Settings.FlySpeed = Value

		end
	)

--========================================================--
-- SPEED
--========================================================--

SpeedButton.MouseButton1Click:Connect(function()

	SpeedEnabled =
		not SpeedEnabled

	if not Humanoid then
		return
	end

	if SpeedEnabled then

		Humanoid.WalkSpeed =
			Settings.Speed

		SpeedButton.Text =
			"SPEED  :  ON"

	else

		Humanoid.WalkSpeed = 16

		SpeedButton.Text =
			"SPEED  :  OFF"

	end

end)

--========================================================--
-- HIGH JUMP
--========================================================--

JumpButton.MouseButton1Click:Connect(function()

	JumpEnabled =
		not JumpEnabled

	if not Humanoid then
		return
	end

	Humanoid.UseJumpPower = true

	if JumpEnabled then

		Humanoid.JumpPower =
			Settings.Jump

		JumpButton.Text =
			"HIGH JUMP  :  ON"

	else

		Humanoid.JumpPower = 50

		JumpButton.Text =
			"HIGH JUMP  :  OFF"

	end

end)

--========================================================--
-- FLY
--========================================================--

local function StopFly()

	FlyEnabled = false

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

end

local function StartFly()

	if FlyEnabled or not Root then
		return
	end

	FlyEnabled = true

	FlyVelocity =
		Instance.new("BodyVelocity")

	FlyVelocity.MaxForce =
		Vector3.new(
			math.huge,
			math.huge,
			math.huge
		)

	FlyVelocity.Velocity =
		Vector3.zero

	FlyVelocity.Parent =
		Root

	FlyConnection =
		RunService.RenderStepped:Connect(
			function()

				if not FlyEnabled
					or not Root then

					return
				end

				local Camera =
					Workspace.CurrentCamera

				if not Camera then
					return
				end

				local Direction =
					Vector3.zero

				if UIS:IsKeyDown(
					Enum.KeyCode.W
				) then

					Direction +=
						Camera.CFrame.LookVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.S
				) then

					Direction -=
						Camera.CFrame.LookVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.A
				) then

					Direction -=
						Camera.CFrame.RightVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.D
				) then

					Direction +=
						Camera.CFrame.RightVector

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.Space
				) then

					Direction +=
						Vector3.new(0,1,0)

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.LeftControl
				) then

					Direction -=
						Vector3.new(0,1,0)

				end

				if Direction.Magnitude > 0 then

					FlyVelocity.Velocity =
						Direction.Unit *
						Settings.FlySpeed

				else

					FlyVelocity.Velocity =
						Vector3.zero

				end

			end
		)

end

FlyButton.MouseButton1Click:Connect(function()

	if FlyEnabled then

		StopFly()

		FlyButton.Text =
			"FLY  :  OFF"

	else

		StartFly()

		FlyButton.Text =
			"FLY  :  ON"

	end

end)

--========================================================--
-- NOCLIP
--========================================================--

local function StopNoClip()

	NoClipEnabled = false

	if NoClipConnection then

		NoClipConnection:Disconnect()
		NoClipConnection = nil

	end

	if Character then

		for _, Object in ipairs(
			Character:GetDescendants()
		) do

			if Object:IsA("BasePart") then
				Object.CanCollide = true
			end

		end

	end

end

local function StartNoClip()

	if NoClipEnabled then
		return
	end

	NoClipEnabled = true

	NoClipConnection =
		RunService.Stepped:Connect(function()

			if not Character then
				return
			end

			for _, Object in ipairs(
				Character:GetDescendants()
			) do

				if Object:IsA("BasePart") then
					Object.CanCollide = false
				end

			end

		end)

end

NoClipButton.MouseButton1Click:Connect(function()

	if NoClipEnabled then

		StopNoClip()

		NoClipButton.Text =
			"NOCLIP  :  OFF"

	else

		StartNoClip()

		NoClipButton.Text =
			"NOCLIP  :  ON"

	end

end)

--========================================================--
-- ESP
--========================================================--

local ESPObjects = {}

local function RemoveESP(PlayerObject)

	local Data =
		ESPObjects[PlayerObject]

	if not Data then
		return
	end

	if Data.Highlight then
		Data.Highlight:Destroy()
	end

	if Data.Billboard then
		Data.Billboard:Destroy()
	end

	ESPObjects[PlayerObject] = nil
end

local function CreateESP(PlayerObject)

	if PlayerObject == Player then
		return
	end

	if not ESPEnabled then
		return
	end

	local CharacterObject =
		PlayerObject.Character

	if not CharacterObject then
		return
	end

	local Head =
		CharacterObject:FindFirstChild("Head")

	if not Head then
		return
	end

	RemoveESP(PlayerObject)

	local Highlight =
		Instance.new("Highlight")

	Highlight.Name =
		"MK_ESP_Highlight"

	Highlight.Adornee =
		CharacterObject

	Highlight.FillColor =
		Color3.fromRGB(
			178,105,255
		)

	Highlight.OutlineColor =
		Color3.fromRGB(
			255,255,255
		)

	Highlight.FillTransparency =
		0.65

	Highlight.OutlineTransparency =
		0

	Highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	Highlight.Parent =
		CharacterObject

	local Billboard =
		Instance.new("BillboardGui")

	Billboard.Name =
		"MK_ESP_Name"

	Billboard.Adornee =
		Head

	Billboard.Size =
		UDim2.fromOffset(180,45)

	Billboard.StudsOffset =
		Vector3.new(0,2.8,0)

	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = 500
	Billboard.Parent = Head

	local NameLabel =
		Instance.new("TextLabel")

	NameLabel.Size =
		UDim2.fromScale(1,0.55)

	NameLabel.BackgroundTransparency = 1

	NameLabel.Text =
		PlayerObject.DisplayName

	NameLabel.TextColor3 =
		Color3.fromRGB(
			255,255,255
		)

	NameLabel.TextStrokeTransparency = 0

	NameLabel.TextStrokeColor3 =
		Color3.fromRGB(0,0,0)

	NameLabel.TextSize = 13
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Parent = Billboard

	local DistanceLabel =
		Instance.new("TextLabel")

	DistanceLabel.Size =
		UDim2.fromScale(1,0.45)

	DistanceLabel.Position =
		UDim2.fromScale(0,0.55)

	DistanceLabel.BackgroundTransparency = 1

	DistanceLabel.Text =
		"0 studs"

	DistanceLabel.TextColor3 =
		Color3.fromRGB(
			190,190,210
		)

	DistanceLabel.TextStrokeTransparency = 0

	DistanceLabel.TextStrokeColor3 =
		Color3.fromRGB(0,0,0)

	DistanceLabel.TextSize = 10
	DistanceLabel.Font = Enum.Font.Gotham
	DistanceLabel.Parent = Billboard

	ESPObjects[PlayerObject] = {
		Highlight = Highlight,
		Billboard = Billboard,
		Distance = DistanceLabel
	}

end

local function UpdateESP()

	if not ESPEnabled or not Root then
		return
	end

	for _, OtherPlayer in ipairs(
		Players:GetPlayers()
	) do

		if OtherPlayer ~= Player then

			local Data =
				ESPObjects[OtherPlayer]

			local OtherCharacter =
				OtherPlayer.Character

			local OtherRoot =
				OtherCharacter
				and OtherCharacter:FindFirstChild(
					"HumanoidRootPart"
				)

			if not Data then

				CreateESP(
					OtherPlayer
				)

				Data =
					ESPObjects[OtherPlayer]

			end

			if Data and OtherRoot then

				local Distance =
					(
						Root.Position -
						OtherRoot.Position
					).Magnitude

				if Data.Distance then

					Data.Distance.Text =
						math.floor(Distance)
						.. " studs"

				end

			end

		end

	end

end

local function StopESP()

	ESPEnabled = false

	if ESPConnection then

		ESPConnection:Disconnect()
		ESPConnection = nil

	end

	for OtherPlayer in pairs(
		ESPObjects
	) do

		RemoveESP(
			OtherPlayer
		)

	end

	table.clear(ESPObjects)

end

local function StartESP()

	if ESPEnabled then
		return
	end

	ESPEnabled = true

	for _, OtherPlayer in ipairs(
		Players:GetPlayers()
	) do

		if OtherPlayer ~= Player then
			CreateESP(OtherPlayer)
		end

	end

	ESPConnection =
		RunService.RenderStepped:Connect(
			UpdateESP
		)

end

Players.PlayerAdded:Connect(function(OtherPlayer)

	OtherPlayer.CharacterAdded:Connect(function()

		if ESPEnabled then

			task.wait(0.3)

			CreateESP(
				OtherPlayer
			)

		end

	end)

end)

Players.PlayerRemoving:Connect(function(OtherPlayer)

	RemoveESP(
		OtherPlayer
	)

end)

--========================================================--
-- TOOL TITLE
--========================================================--

local FarmTitle =
	Instance.new("TextLabel")

FarmTitle.Size =
	UDim2.new(1,-30,0,35)

FarmTitle.Position =
	UDim2.fromOffset(15,8)

FarmTitle.BackgroundTransparency = 1

FarmTitle.Text = "TOOL"

FarmTitle.TextColor3 = C.White
FarmTitle.TextSize = 18
FarmTitle.Font = Enum.Font.GothamBlack

FarmTitle.TextXAlignment =
	Enum.TextXAlignment.Left

FarmTitle.Parent = FarmPage

local FarmLine =
	Instance.new("Frame")

FarmLine.Size =
	UDim2.new(1,-30,0,1)

FarmLine.Position =
	UDim2.fromOffset(15,45)

FarmLine.BackgroundColor3 = C.Stroke
FarmLine.BackgroundTransparency = 0.35
FarmLine.BorderSizePixel = 0
FarmLine.Parent = FarmPage

--========================================================--
-- ESP BUTTON
--========================================================--

local ESPButton =
	FeatureButton(
		"ESP  :  OFF",
		15,
		65,
		FarmPage
	)

ESPButton.MouseButton1Click:Connect(function()

	if ESPEnabled then

		StopESP()

		ESPButton.Text =
			"ESP  :  OFF"

	else

		StartESP()

		ESPButton.Text =
			"ESP  :  ON"

	end

end)

--========================================================--
-- ULTRA FAST MODE
--========================================================--

local FastModeButton =
	FeatureButton(
		"ULTRA FAST  :  OFF",
		205,
		65,
		FarmPage
	)

--========================================================--
-- FAST MODE STORAGE
--========================================================--

local FastBackup = {
	Properties = {},
	Lighting = {},
	Terrain = {},
	Processed = {}
}

local FastConnections = {}

local function BackupProperty(
	Object,
	Property
)

	if not Object then
		return
	end

	if not FastBackup.Properties[Object] then

		FastBackup.Properties[Object] = {}

	end

	if FastBackup.Properties[Object][Property]
		== nil then

		local Success, Value =
			pcall(function()

				return Object[Property]

			end)

		if Success then

			FastBackup.Properties[Object][Property] =
				Value

		end

	end

end

local function ChangeProperty(
	Object,
	Property,
	Value
)

	if not Object then
		return
	end

	BackupProperty(
		Object,
		Property
	)

	pcall(function()

		Object[Property] = Value

	end)

end

--========================================================--
-- FAST OBJECT OPTIMIZER
--========================================================--

local function OptimizeFastObject(Object)

	if not FastModeEnabled then
		return
	end

	if not Object
		or not Object.Parent then

		return
	end

	--====================================================--
	-- PARTICLES
	--====================================================--

	if Object:IsA("ParticleEmitter") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- TRAIL
	--====================================================--

	if Object:IsA("Trail") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- BEAM
	--====================================================--

	if Object:IsA("Beam") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- FIRE
	--====================================================--

	if Object:IsA("Fire") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- SMOKE
	--====================================================--

	if Object:IsA("Smoke") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- SPARKLES
	--====================================================--

	if Object:IsA("Sparkles") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- LIGHTS
	--====================================================--

	if Object:IsA("PointLight")
		or Object:IsA("SpotLight")
		or Object:IsA("SurfaceLight") then

		ChangeProperty(
			Object,
			"Enabled",
			false
		)

		return
	end

	--====================================================--
	-- DECALS
	--====================================================--

	if Object:IsA("Decal") then

		ChangeProperty(
			Object,
			"Transparency",
			1
		)

		return
	end

	--====================================================--
	-- TEXTURES
	--====================================================--

	if Object:IsA("Texture") then

		ChangeProperty(
			Object,
			"Transparency",
			1
		)

		return
	end

	--====================================================--
	-- SPECIAL MESH
	--====================================================--

	if Object:IsA("SpecialMesh") then

		ChangeProperty(
			Object,
			"TextureId",
			""
		)

		return
	end

	--====================================================--
	-- SURFACE APPEARANCE
	--====================================================--

	if Object:IsA("SurfaceAppearance") then

		ChangeProperty(
			Object,
			"AlphaMode",
			Enum.AlphaMode.Overlay
		)

		ChangeProperty(
			Object,
			"ColorMap",
			""
		)

		ChangeProperty(
			Object,
			"MetalnessMap",
			""
		)

		ChangeProperty(
			Object,
			"NormalMap",
			""
		)

		ChangeProperty(
			Object,
			"RoughnessMap",
			""
		)

		return
	end

end

--========================================================--
-- MATERIAL OPTIMIZER
--========================================================--

local function OptimizePart(Object)

	if not Object:IsA("BasePart") then
		return
	end

	-- Không đụng collision.
	-- Chỉ đơn giản hóa phần hiển thị.

	ChangeProperty(
		Object,
		"Material",
		Enum.Material.SmoothPlastic
	)

	ChangeProperty(
		Object,
		"Reflectance",
		0
	)

end

--========================================================--
-- LIGHTING
--========================================================--

local function OptimizeLighting()

	local Properties = {
		"GlobalShadows",
		"EnvironmentDiffuseScale",
		"EnvironmentSpecularScale",
		"FogEnd"
	}

	for _, Property in ipairs(Properties) do

		local Success, Value =
			pcall(function()

				return Lighting[Property]

			end)

		if Success then

			FastBackup.Lighting[Property] =
				Value

		end

	end

	pcall(function()
		Lighting.GlobalShadows = false
	end)

	pcall(function()
		Lighting.EnvironmentDiffuseScale = 0
	end)

	pcall(function()
		Lighting.EnvironmentSpecularScale = 0
	end)

	pcall(function()
		Lighting.FogEnd = 100000
	end)

	--====================================================--
	-- POST PROCESSING
	--====================================================--

	for _, Object in ipairs(
		Lighting:GetDescendants()
	) do

		if Object:IsA("BloomEffect")
			or Object:IsA("BlurEffect")
			or Object:IsA("ColorCorrectionEffect")
			or Object:IsA("DepthOfFieldEffect")
			or Object:IsA("SunRaysEffect") then

			OptimizeFastObject(
				Object
			)

		end

	end

end

--========================================================--
-- TERRAIN
--========================================================--

local OriginalTerrainDecoration

local function OptimizeTerrain()

	local Terrain =
		Workspace:FindFirstChildOfClass(
			"Terrain"
		)

	if not Terrain then
		return
	end

	local Success, Value =
		pcall(function()

			return Terrain.Decoration

		end)

	if Success then

		OriginalTerrainDecoration =
			Value

	end

	pcall(function()

		Terrain.Decoration = false

	end)

end

local function RestoreTerrain()

	local Terrain =
		Workspace:FindFirstChildOfClass(
			"Terrain"
		)

	if not Terrain then
		return
	end

	if OriginalTerrainDecoration ~= nil then

		pcall(function()

			Terrain.Decoration =
				OriginalTerrainDecoration

		end)

	end

end

--========================================================--
-- ULTRA FAST START
--========================================================--

local function StartFastMode()

	if FastModeEnabled then
		return
	end

	FastModeEnabled = true

	-- Lighting
	OptimizeLighting()

	-- Terrain
	OptimizeTerrain()

	-- Workspace
	for _, Object in ipairs(
		Workspace:GetDescendants()
	) do

		OptimizeFastObject(
			Object
		)

		if Object:IsA("BasePart") then

			OptimizePart(
				Object
			)

		end

	end

	-- Lighting
	for _, Object in ipairs(
		Lighting:GetDescendants()
	) do

		OptimizeFastObject(
			Object
		)

	end

	--====================================================--
	-- FUTURE OBJECTS
	--====================================================--

	table.insert(
		FastConnections,

		Workspace.DescendantAdded:Connect(
			function(Object)

				if not FastModeEnabled then
					return
				end

				task.defer(function()

					if not FastModeEnabled then
						return
					end

					if not Object
						or not Object.Parent then

						return

					end

					OptimizeFastObject(
						Object
					)

					if Object:IsA("BasePart") then

						OptimizePart(
							Object
						)

					end

				end)

			end
		)
	)

	table.insert(
		FastConnections,

		Lighting.DescendantAdded:Connect(
			function(Object)

				if not FastModeEnabled then
					return
				end

				task.defer(function()

					if FastModeEnabled
						and Object
						and Object.Parent then

						OptimizeFastObject(
							Object
						)

					end

				end)

			end
		)
	)

end

--========================================================--
-- ULTRA FAST RESTORE
--========================================================--

local function StopFastMode()

	if not FastModeEnabled then
		return
	end

	FastModeEnabled = false

	for _, Connection in ipairs(
		FastConnections
	) do

		if Connection
			and Connection.Connected then

			Connection:Disconnect()

		end

	end

	table.clear(
		FastConnections
	)

	--====================================================--
	-- RESTORE OBJECTS
	--====================================================--

	for Object, Properties in pairs(
		FastBackup.Properties
	) do

		if Object
			and Object.Parent then

			for Property, Value in pairs(
				Properties
			) do

				pcall(function()

					Object[Property] =
						Value

				end)

			end

		end

	end

	--====================================================--
	-- RESTORE LIGHTING
	--====================================================--

	for Property, Value in pairs(
		FastBackup.Lighting
	) do

		pcall(function()

			Lighting[Property] =
				Value

		end)

	end

	--====================================================--
	-- RESTORE TERRAIN
	--====================================================--

	RestoreTerrain()

	table.clear(
		FastBackup.Properties
	)

	table.clear(
		FastBackup.Lighting
	)

end

--========================================================--
-- FAST MODE BUTTON
--========================================================--

FastModeButton.MouseButton1Click:Connect(function()

	if FastModeEnabled then

		StopFastMode()

		FastModeButton.Text =
			"ULTRA FAST  :  OFF"

	else

		StartFastMode()

		FastModeButton.Text =
			"ULTRA FAST  :  ON"

	end

end)

--========================================================--
-- FAST MODE INFO
--========================================================--

local FastInfo =
	Instance.new("TextLabel")

FastInfo.Size =
	UDim2.new(1,-30,0,90)

FastInfo.Position =
	UDim2.fromOffset(15,175)

FastInfo.BackgroundColor3 =
	C.Button

FastInfo.BackgroundTransparency = 0.2
FastInfo.BorderSizePixel = 0

FastInfo.Text =
	"ULTRA FAST MODE\n\n" ..
	"Giảm particle • texture • decal • beam\n" ..
	"trail • light • shadow • hậu kỳ • material"

FastInfo.TextColor3 = C.Gray
FastInfo.TextSize = 10
FastInfo.Font = Enum.Font.GothamBold
FastInfo.TextWrapped = true

FastInfo.TextYAlignment =
	Enum.TextYAlignment.Center

FastInfo.Parent = FarmPage

Corner(
	FastInfo,
	12
)

AddStroke(
	FastInfo,
	C.Stroke,
	1,
	0.45
)

--========================================================--
-- TELEPORT
--========================================================--

local Teleport =
	FeatureButton(
		"TELEPORT",
		15,
		300
	)

Teleport.MouseButton1Click:Connect(function()

	if not Root then
		return
	end

	local Spawn

	for _, Object in ipairs(
		Workspace:GetDescendants()
	) do

		if Object:IsA("SpawnLocation") then

			Spawn = Object
			break

		end

	end

	if Spawn then

		Root.CFrame =
			Spawn.CFrame +
			Vector3.new(0,5,0)

	end

end)

--========================================================--
-- RESET
--========================================================--

local Reset =
	FeatureButton(
		"RESET ALL",
		205,
		300
	)

local function ResetEverything()

	StopFly()
	StopNoClip()
	StopESP()

	if FastModeEnabled then
		StopFastMode()
	end

	SpeedEnabled = false
	JumpEnabled = false
	FlyEnabled = false
	NoClipEnabled = false
	ESPEnabled = false
	AimlockEnabled = false

	Settings.Speed =
		DEFAULT.Speed

	Settings.Jump =
		DEFAULT.Jump

	Settings.FlySpeed =
		DEFAULT.FlySpeed

	Settings.AimFOV =
		DEFAULT.AimFOV

	if Humanoid then

		Humanoid.WalkSpeed = 16
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = 50

	end

	SpeedButton.Text =
		"SPEED  :  OFF"

	JumpButton.Text =
		"HIGH JUMP  :  OFF"

	FlyButton.Text =
		"FLY  :  OFF"

	NoClipButton.Text =
		"NOCLIP  :  OFF"

	ESPButton.Text =
		"ESP  :  OFF"

	FastModeButton.Text =
		"ULTRA FAST  :  OFF"

	SpeedSlider.Set(
		DEFAULT.Speed
	)

	JumpSlider.Set(
		DEFAULT.Jump
	)

	FlySlider.Set(
		DEFAULT.FlySpeed
	)

end

Reset.MouseButton1Click:Connect(
	ResetEverything
)

--========================================================--
-- TAB SYSTEM
--========================================================--

local function SelectTab(Number)

	if Number == 1 then

		MainPage.Visible = true
		FarmPage.Visible = false

		MakeTween(
			Tab1,
			0.15,
			{
				BackgroundColor3 =
					Color3.fromRGB(
						68,48,98
					)
			}
		):Play()

		MakeTween(
			Tab2,
			0.15,
			{
				BackgroundColor3 =
					C.Button
			}
		):Play()

	else

		MainPage.Visible = false
		FarmPage.Visible = true

		MakeTween(
			Tab1,
			0.15,
			{
				BackgroundColor3 =
					C.Button
			}
		):Play()

		MakeTween(
			Tab2,
			0.15,
			{
				BackgroundColor3 =
					Color3.fromRGB(
						68,48,98
					)
			}
		):Play()

	end

end

Tab1.MouseButton1Click:Connect(function()
	SelectTab(1)
end)

Tab2.MouseButton1Click:Connect(function()
	SelectTab(2)
end)

--========================================================--
-- OPEN / CLOSE
--========================================================--

local MenuOpen = false

local function OpenMenu()

	MenuOpen = true

	Main.Visible = true

	Main.Size =
		UDim2.fromOffset(0,0)

	MakeTween(
		Main,
		0.3,
		{
			Size =
				UDim2.fromOffset(
					400,
					510
				)
		},
		Enum.EasingStyle.Back
	):Play()

end

local function CloseMenu()

	MenuOpen = false

	local Animation =
		MakeTween(
			Main,
			0.18,
			{
				Size =
					UDim2.fromOffset(
						0,
						0
					)
			},
			Enum.EasingStyle.Quad
		)

	Animation:Play()

	Animation.Completed:Once(
		function()

			if not MenuOpen then

				Main.Visible = false

			end

		end
	)

end

HubButton.MouseButton1Click:Connect(function()

	if MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end

end)

--========================================================--
-- HUB BUTTON ANIMATION
--========================================================--

HubButton.MouseEnter:Connect(function()

	MakeTween(
		HubButton,
		0.15,
		{
			Size =
				UDim2.fromOffset(
					70,
					70
				)
		}
	):Play()

end)

HubButton.MouseLeave:Connect(function()

	MakeTween(
		HubButton,
		0.15,
		{
			Size =
				UDim2.fromOffset(
					64,
					64
				)
		}
	):Play()

end)

--========================================================--
-- SHOW BUTTON AFTER LOADING
--========================================================--

task.delay(
	5,
	function()

		if not HubButton.Parent then
			return
		end

		HubButton.Visible = true

		HubButton.BackgroundTransparency = 1

		MakeTween(
			HubButton,
			0.45,
			{
				BackgroundTransparency = 0
			}
		):Play()

	end
)

--========================================================--
-- CLEANUP
--========================================================--

Player.CharacterRemoving:Connect(function()

	if FlyEnabled then
		StopFly()
	end

	if NoClipEnabled then
		StopNoClip()
	end

end)

--========================================================--
-- READY
--========================================================--

print(
	"MK HUB v2.0 READY"
)
