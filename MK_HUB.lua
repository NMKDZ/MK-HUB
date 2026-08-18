--========================================================--
--                    MK HUB v2.0                         --
--                 FOX ANIME EDITION                      --
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================--
-- SETTINGS
--========================================================--

local DEFAULT = {
	Speed = 60,
	Jump = 100,
	FlySpeed = 80
}

local Settings = {
	Speed = DEFAULT.Speed,
	Jump = DEFAULT.Jump,
	FlySpeed = DEFAULT.FlySpeed
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

local FlyVelocity
local FlyConnection
local NoClipConnection

--========================================================--
-- ESP
--========================================================--

local ESPObjects = {}
local ESPConnection

local function RemoveESP(PlayerObject)
	local Data = ESPObjects[PlayerObject]

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

	local CharacterObject = PlayerObject.Character

	if not CharacterObject then
		return
	end

	local Head = CharacterObject:FindFirstChild("Head")

	if not Head then
		return
	end

	RemoveESP(PlayerObject)

	local Highlight = Instance.new("Highlight")

	Highlight.Name = "MK_ESP_Highlight"
	Highlight.Adornee = CharacterObject
	Highlight.FillColor = Color3.fromRGB(178, 105, 255)
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	Highlight.FillTransparency = 0.65
	Highlight.OutlineTransparency = 0
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Parent = CharacterObject

	local Billboard = Instance.new("BillboardGui")

	Billboard.Name = "MK_ESP_Name"
	Billboard.Adornee = Head
	Billboard.Size = UDim2.fromOffset(180, 45)
	Billboard.StudsOffset = Vector3.new(0, 2.8, 0)
	Billboard.AlwaysOnTop = true
	Billboard.MaxDistance = 500
	Billboard.Parent = Head

	local NameLabel = Instance.new("TextLabel")

	NameLabel.Size = UDim2.fromScale(1, 0.55)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = PlayerObject.DisplayName
	NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NameLabel.TextStrokeTransparency = 0
	NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	NameLabel.TextSize = 13
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Parent = Billboard

	local DistanceLabel = Instance.new("TextLabel")

	DistanceLabel.Size = UDim2.fromScale(1, 0.45)
	DistanceLabel.Position = UDim2.fromScale(0, 0.55)
	DistanceLabel.BackgroundTransparency = 1
	DistanceLabel.Text = "0 studs"
	DistanceLabel.TextColor3 = Color3.fromRGB(190, 190, 210)
	DistanceLabel.TextStrokeTransparency = 0
	DistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
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

	for _, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player then

			local Data = ESPObjects[OtherPlayer]
			local OtherCharacter = OtherPlayer.Character

			local OtherRoot =
				OtherCharacter and
				OtherCharacter:FindFirstChild("HumanoidRootPart")

			if not Data or not Data.Billboard then
				CreateESP(OtherPlayer)
				Data = ESPObjects[OtherPlayer]
			end

			if Data and OtherRoot then
				local Distance =
					(Root.Position - OtherRoot.Position).Magnitude

				if Data.Distance then
					Data.Distance.Text =
						math.floor(Distance) .. " studs"
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

	for OtherPlayer in pairs(ESPObjects) do
		RemoveESP(OtherPlayer)
	end

	table.clear(ESPObjects)
end

local function StartESP()
	if ESPEnabled then
		return
	end

	ESPEnabled = true

	for _, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player then
			CreateESP(OtherPlayer)
		end
	end

	ESPConnection =
		RunService.RenderStepped:Connect(UpdateESP)
end

Players.PlayerAdded:Connect(function(OtherPlayer)
	OtherPlayer.CharacterAdded:Connect(function()
		if ESPEnabled then
			task.wait(0.3)
			CreateESP(OtherPlayer)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(OtherPlayer)
	RemoveESP(OtherPlayer)
end)

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
	Fox.TextSize = math.floor(Size * 0.72)
	Fox.Font = Enum.Font.GothamBlack
	Fox.TextColor3 = Color3.fromRGB(255, 255, 255)
	Fox.ZIndex = ZIndex or 10
	Fox.Parent = Parent

	return Fox
end

--========================================================--
-- LOADING
--========================================================--

local Loading = Instance.new("Frame")

Loading.Size = UDim2.fromScale(1, 1)
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
			Color3.fromRGB(7, 8, 15)
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.fromRGB(34, 19, 50)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(7, 9, 16)
		)
	})

LoadingGradient.Parent = Loading

--========================================================--
-- LOADING FOXES
--========================================================--

local LoadingFoxes = {}

local FoxPositions = {
	UDim2.new(0, 60, 0.5, -40),
	UDim2.new(1, -120, 0.5, -80),
	UDim2.new(0.18, 0, 0, 90),
	UDim2.new(0.78, 0, 0, 75),
	UDim2.new(0.10, 0, 1, -150),
	UDim2.new(0.82, 0, 1, -160)
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

			local Base =
				FoxPositions[Index]

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

LoadingCard.Size = UDim2.fromOffset(440, 260)
LoadingCard.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingCard.Position = UDim2.fromScale(0.5, 0.5)
LoadingCard.BackgroundColor3 = Color3.fromRGB(13, 14, 21)
LoadingCard.BackgroundTransparency = 0.03
LoadingCard.BorderSizePixel = 0
LoadingCard.ZIndex = 1010
LoadingCard.Parent = Loading

Corner(LoadingCard, 22)

AddStroke(
	LoadingCard,
	Color3.fromRGB(130, 90, 180),
	1,
	0.2
)

local LoadingTitle = Instance.new("TextLabel")

LoadingTitle.Size = UDim2.new(1, 0, 0, 65)
LoadingTitle.Position = UDim2.fromOffset(0, 42)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "MK HUB v2.0"
LoadingTitle.TextColor3 = C.White
LoadingTitle.TextSize = 38
LoadingTitle.Font = Enum.Font.GothamBlack
LoadingTitle.ZIndex = 1012
LoadingTitle.Parent = LoadingCard

local TitleGradient = Instance.new("UIGradient")

TitleGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Purple),
		ColorSequenceKeypoint.new(0.5, C.White),
		ColorSequenceKeypoint.new(1, C.Blue)
	})

TitleGradient.Parent = LoadingTitle

local LoadingStatus = Instance.new("TextLabel")

LoadingStatus.Size = UDim2.new(1, 0, 0, 25)
LoadingStatus.Position = UDim2.fromOffset(0, 103)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "Loading..."
LoadingStatus.TextColor3 = C.Gray
LoadingStatus.TextSize = 12
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.ZIndex = 1012
LoadingStatus.Parent = LoadingCard

local ProgressBack = Instance.new("Frame")

ProgressBack.Size = UDim2.fromOffset(330, 8)
ProgressBack.Position = UDim2.new(0.5, -165, 0, 145)
ProgressBack.BackgroundColor3 = Color3.fromRGB(37, 38, 48)
ProgressBack.BorderSizePixel = 0
ProgressBack.ZIndex = 1012
ProgressBack.Parent = LoadingCard

Corner(ProgressBack, 10)

local Progress = Instance.new("Frame")

Progress.Size = UDim2.new(0, 0, 1, 0)
Progress.BackgroundColor3 = C.Purple
Progress.BorderSizePixel = 0
Progress.ZIndex = 1013
Progress.Parent = ProgressBack

Corner(Progress, 10)

local ProgressGradient = Instance.new("UIGradient")

ProgressGradient.Color =
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Blue),
		ColorSequenceKeypoint.new(0.5, C.Purple),
		ColorSequenceKeypoint.new(1, C.Pink)
	})

ProgressGradient.Parent = Progress

--========================================================--
-- HUB BUTTON
--========================================================--

local HubButton = Instance.new("TextButton")

HubButton.Size = UDim2.fromOffset(64, 64)
HubButton.Position = UDim2.new(0, 20, 0.5, -32)
HubButton.BackgroundColor3 = C.Panel2
HubButton.BorderSizePixel = 0
HubButton.Text = "MK"
HubButton.TextColor3 = C.White
HubButton.TextSize = 16
HubButton.Font = Enum.Font.GothamBlack
HubButton.Visible = false
HubButton.Parent = Gui

Corner(HubButton, 32)

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

Main.Size = UDim2.fromOffset(400, 510)

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

Corner(Main, 22)

AddStroke(
	Main,
	Color3.fromRGB(90, 78, 120),
	1,
	0.1
)

local MenuGlow = Instance.new("Frame")

MenuGlow.Size =
	UDim2.new(1, 0, 0, 120)

MenuGlow.BackgroundColor3 =
	Color3.fromRGB(36, 23, 52)

MenuGlow.BackgroundTransparency = 0.25
MenuGlow.BorderSizePixel = 0
MenuGlow.Parent = Main

Corner(MenuGlow, 22)

local MenuGlowGradient = Instance.new("UIGradient")

MenuGlowGradient.Rotation = 90

MenuGlowGradient.Transparency =
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

MenuGlowGradient.Parent = MenuGlow

local MenuFox =
	CreateFox(
		Main,
		UDim2.new(1, -95, 0, 8),
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
						1,
						-95,
						0,
						2
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
						1,
						-95,
						0,
						8
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

Header.Size = UDim2.new(1, -115, 0, 55)
Header.Position = UDim2.fromOffset(16, 10)
Header.BackgroundTransparency = 1
Header.Text = "MK HUB v2.0"
Header.TextColor3 = C.White
Header.TextSize = 20
Header.Font = Enum.Font.GothamBlack
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.AutoButtonColor = false
Header.Parent = Main

MakeDraggable(Main, Header)

--========================================================--
-- TAB BAR
--========================================================--

local TabBar = Instance.new("Frame")

TabBar.Size = UDim2.new(1, -30, 0, 42)
TabBar.Position = UDim2.fromOffset(15, 72)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local Tab1 = Instance.new("TextButton")

Tab1.Size = UDim2.new(0.5, -5, 1, 0)
Tab1.BackgroundColor3 = Color3.fromRGB(68, 48, 98)
Tab1.BorderSizePixel = 0
Tab1.Text = "MAIN"
Tab1.TextColor3 = C.White
Tab1.TextSize = 11
Tab1.Font = Enum.Font.GothamBold
Tab1.AutoButtonColor = false
Tab1.Parent = TabBar

Corner(Tab1, 10)

local Tab2 = Instance.new("TextButton")

Tab2.Size = UDim2.new(0.5, -5, 1, 0)
Tab2.Position = UDim2.new(0.5, 5, 0, 0)
Tab2.BackgroundColor3 = C.Button
Tab2.BorderSizePixel = 0

-- ĐỔI FARM -> TOOL
Tab2.Text = "TOOL"

Tab2.TextColor3 = C.White
Tab2.TextSize = 11
Tab2.Font = Enum.Font.GothamBold
Tab2.AutoButtonColor = false
Tab2.Parent = TabBar

Corner(Tab2, 10)

--========================================================--
-- PAGES
--========================================================--

local MainPage = Instance.new("Frame")

MainPage.Size = UDim2.new(1, 0, 1, -125)
MainPage.Position = UDim2.fromOffset(0, 125)
MainPage.BackgroundTransparency = 1
MainPage.Parent = Main

local ToolPage = Instance.new("Frame")

ToolPage.Size = UDim2.new(1, 0, 1, -125)
ToolPage.Position = UDim2.fromOffset(0, 125)
ToolPage.BackgroundTransparency = 1
ToolPage.Visible = false
ToolPage.Parent = Main

--========================================================--
-- FEATURE BUTTON
--========================================================--

local function FeatureButton(Text, X, Y, Parent)

	local Button = Instance.new("TextButton")

	Button.Size =
		UDim2.fromOffset(175, 40)

	Button.Position =
		UDim2.fromOffset(X, Y)

	Button.BackgroundColor3 =
		C.Button

	Button.BorderSizePixel = 0
	Button.Text = Text
	Button.TextColor3 = C.White
	Button.TextSize = 10
	Button.Font = Enum.Font.GothamBold
	Button.AutoButtonColor = false
	Button.Parent = Parent or MainPage

	Corner(Button, 10)

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

	local Label =
		Instance.new("TextLabel")

	Label.Size =
		UDim2.fromOffset(200, 22)

	Label.Position =
		UDim2.fromOffset(15, Y)

	Label.BackgroundTransparency = 1
	Label.Text = Title
	Label.TextColor3 = C.Gray
	Label.TextSize = 10
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = MainPage

	local Track =
		Instance.new("Frame")

	Track.Size =
		UDim2.fromOffset(260, 7)

	Track.Position =
		UDim2.fromOffset(15, Y + 27)

	Track.BackgroundColor3 =
		Color3.fromRGB(39, 40, 50)

	Track.BorderSizePixel = 0
	Track.Parent = MainPage

	Corner(Track, 10)

	local Fill =
		Instance.new("Frame")

	Fill.Size =
		UDim2.new(0, 0, 1, 0)

	Fill.BackgroundColor3 =
		C.Purple

	Fill.BorderSizePixel = 0
	Fill.Parent = Track

	Corner(Fill, 10)

	local FillGradient =
		Instance.new("UIGradient")

	FillGradient.Color =
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.Blue),
			ColorSequenceKeypoint.new(1, C.Purple)
		})

	FillGradient.Parent = Fill

	local Knob =
		Instance.new("TextButton")

	Knob.Size =
		UDim2.fromOffset(18, 18)

	Knob.AnchorPoint =
		Vector2.new(0.5, 0.5)

	Knob.BackgroundColor3 =
		Color3.fromRGB(250, 250, 255)

	Knob.BorderSizePixel = 0
	Knob.Text = ""
	Knob.Parent = Track

	Corner(Knob, 20)

	AddStroke(
		Knob,
		C.Purple,
		1,
		0.15
	)

	local Input =
		Instance.new("TextBox")

	Input.Size =
		UDim2.fromOffset(75, 31)

	Input.Position =
		UDim2.fromOffset(300, Y - 5)

	Input.BackgroundColor3 =
		C.Button

	Input.BorderSizePixel = 0
	Input.Text = tostring(DefaultValue)
	Input.TextColor3 = C.White
	Input.TextSize = 11
	Input.Font = Enum.Font.GothamBold
	Input.ClearTextOnFocus = false
	Input.Parent = MainPage

	Corner(Input, 8)

	AddStroke(
		Input,
		C.Stroke,
		1,
		0.35
	)

	local Current = DefaultValue

	local function SetValue(Value)

		Value =
			tonumber(Value) or Current

		Value =
			math.clamp(
				math.floor(Value + 0.5),
				Min,
				Max
			)

		Current = Value

		local Percent =
			(Value - Min) /
			(Max - Min)

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
				(X - Left) / Width,
				0,
				1
			)

		local Value =
			Min +
			(Max - Min) *
			Percent

		SetValue(Value)
	end

	Track.InputBegan:Connect(
		function(InputObject)

			if InputObject.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				SetFromMouse(
					InputObject.Position.X
				)
			end
		end
	)

	Knob.InputBegan:Connect(
		function(InputObject)

			if InputObject.UserInputType ~=
				Enum.UserInputType.MouseButton1 then
				return
			end

			local Moving
			local Released

			Moving =
				UIS.InputChanged:Connect(
					function(Move)

						if Move.UserInputType ==
							Enum.UserInputType.MouseMovement then

							SetFromMouse(
								Move.Position.X
							)
						end
					end
				)

			Released =
				UIS.InputEnded:Connect(
					function(Ended)

						if Ended.UserInputType ==
							Enum.UserInputType.MouseButton1 then

							Moving:Disconnect()
							Released:Disconnect()
						end
					end
				)
		end
	)

	Input.FocusLost:Connect(
		function()

			local Number =
				tonumber(Input.Text)

			if Number then
				SetValue(Number)
			else
				Input.Text =
					tostring(Current)
			end
		end
	)

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

				if not FlyEnabled or not Root then
					return
				end

				local CurrentCamera =
					workspace.CurrentCamera

				if not CurrentCamera then
					return
				end

				local Direction =
					Vector3.zero

				if UIS:IsKeyDown(Enum.KeyCode.W) then
					Direction +=
						CurrentCamera.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.S) then
					Direction -=
						CurrentCamera.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.A) then
					Direction -=
						CurrentCamera.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.D) then
					Direction +=
						CurrentCamera.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					Direction +=
						Vector3.new(0, 1, 0)
				end

				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
					Direction -=
						Vector3.new(0, 1, 0)
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

		for _, Object in
			ipairs(Character:GetDescendants()) do

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
		RunService.Stepped:Connect(
			function()

				if not Character then
					return
				end

				for _, Object in
					ipairs(Character:GetDescendants()) do

					if Object:IsA("BasePart") then
						Object.CanCollide = false
					end
				end
			end
		)
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

	for _, Object in
		ipairs(workspace:GetDescendants()) do

		if Object:IsA("SpawnLocation") then

			Spawn = Object
			break
		end
	end

	if Spawn then

		Root.CFrame =
			Spawn.CFrame +
			Vector3.new(0, 5, 0)
	end
end)

--========================================================--
-- AIMLOCK CONFIG
--========================================================--

local AimLockEnabled = false
local AimTarget = nil

local AimConfig = {
	FOV = 150,
	Smoothness = 0.16,
	Prediction = 0.10,
	TeamCheck = true,
	MaxDistance = 2000
}

local AimFOVCircle
local AimConnection

--========================================================--
-- AIM FOV
--========================================================--

local function CreateAimFOV()

	if AimFOVCircle then
		return
	end

	AimFOVCircle =
		Instance.new("Frame")

	AimFOVCircle.Name =
		"MK_Aim_FOV"

	AimFOVCircle.AnchorPoint =
		Vector2.new(0.5, 0.5)

	AimFOVCircle.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)

	AimFOVCircle.Size =
		UDim2.fromOffset(
			AimConfig.FOV * 2,
			AimConfig.FOV * 2
		)

	AimFOVCircle.BackgroundTransparency = 1
	AimFOVCircle.BorderSizePixel = 0
	AimFOVCircle.Visible = false
	AimFOVCircle.ZIndex = 999
	AimFOVCircle.Parent = Gui

	Corner(
		AimFOVCircle,
		AimConfig.FOV
	)

	local Stroke =
		Instance.new("UIStroke")

	Stroke.Color =
		C.Purple

	Stroke.Thickness = 1.5
	Stroke.Transparency = 0.1
	Stroke.Parent = AimFOVCircle
end

CreateAimFOV()

local function UpdateAimFOV()

	if not AimFOVCircle then
		return
	end

	AimFOVCircle.Size =
		UDim2.fromOffset(
			AimConfig.FOV * 2,
			AimConfig.FOV * 2
		)
end

--========================================================--
-- TARGET VALIDATION
--========================================================--

local function IsValidAimTarget(Target)

	if not Target then
		return false
	end

	if Target == Player then
		return false
	end

	local TargetCharacter =
		Target.Character

	if not TargetCharacter then
		return false
	end

	local TargetHumanoid =
		TargetCharacter:FindFirstChildOfClass(
			"Humanoid"
		)

	local TargetRoot =
		TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	local TargetHead =
		TargetCharacter:FindFirstChild(
			"Head"
		)

	if not TargetHumanoid
		or not TargetRoot
		or not TargetHead then

		return false
	end

	if TargetHumanoid.Health <= 0 then
		return false
	end

	if AimConfig.TeamCheck then

		if Player.Team
			and Target.Team
			and Player.Team == Target.Team then

			return false
		end
	end

	if Root then

		local Distance =
			(
				Root.Position -
				TargetRoot.Position
			).Magnitude

		if Distance >
			AimConfig.MaxDistance then

			return false
		end
	end

	return true
end

--========================================================--
-- TARGET SCREEN DISTANCE
--========================================================--

local function GetScreenDistance(TargetPart)

	if not TargetPart then
		return math.huge
	end

	local ScreenPosition,
		OnScreen =
		Camera:WorldToViewportPoint(
			TargetPart.Position
		)

	if not OnScreen then
		return math.huge
	end

	local Viewport =
		Camera.ViewportSize

	local Center =
		Vector2.new(
			Viewport.X / 2,
			Viewport.Y / 2
		)

	local Position =
		Vector2.new(
			ScreenPosition.X,
			ScreenPosition.Y
		)

	return (
		Position -
		Center
	).Magnitude
end

--========================================================--
-- BEST TARGET
--========================================================--

local function GetBestAimTarget()

	local BestTarget
	local BestDistance =
		AimConfig.FOV

	for _, Target in
		ipairs(Players:GetPlayers()) do

		if IsValidAimTarget(Target) then

			local CharacterObject =
				Target.Character

			local Head =
				CharacterObject:FindFirstChild(
					"Head"
				)

			local Distance =
				GetScreenDistance(
					Head
				)

			if Distance <
				BestDistance then

				BestDistance =
					Distance

				BestTarget =
					Target
			end
		end
	end

	return BestTarget
end

--========================================================--
-- PREDICTION
--========================================================--

local function GetAimPosition(Target)

	if not Target then
		return nil
	end

	local TargetCharacter =
		Target.Character

	if not TargetCharacter then
		return nil
	end

	local TargetRoot =
		TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not TargetRoot then
		return nil
	end

	local Velocity =
		TargetRoot.AssemblyLinearVelocity

	return
		TargetRoot.Position +
		(
			Velocity *
			AimConfig.Prediction
		)
end

--========================================================--
-- AIM
--========================================================--

local function AimAtTarget(Target)

	if not IsValidAimTarget(Target) then
		return
	end

	local Position =
		GetAimPosition(Target)

	if not Position then
		return
	end

	local CurrentCamera =
		workspace.CurrentCamera

	if not CurrentCamera then
		return
	end

	local Desired =
		CFrame.lookAt(
			CurrentCamera.CFrame.Position,
			Position
		)

	CurrentCamera.CFrame =
		CurrentCamera.CFrame:Lerp(
			Desired,
			AimConfig.Smoothness
		)
end

--========================================================--
-- AIMLOCK START / STOP
--========================================================--

local function StopAimLock()

	AimLockEnabled = false
	AimTarget = nil

	if AimConnection then

		AimConnection:Disconnect()
		AimConnection = nil
	end

	if AimFOVCircle then
		AimFOVCircle.Visible = false
	end
end

local function StartAimLock()

	if AimLockEnabled then
		return
	end

	AimLockEnabled = true

	if AimFOVCircle then
		AimFOVCircle.Visible = true
	end

	AimConnection =
		RunService.RenderStepped:Connect(
			function()

				if not AimLockEnabled then
					return
				end

				if not IsValidAimTarget(
					AimTarget
				) then

					AimTarget =
						GetBestAimTarget()
				end

				if AimTarget then

					local TargetCharacter =
						AimTarget.Character

					local Head =
						TargetCharacter
						and TargetCharacter:FindFirstChild(
							"Head"
						)

					if Head then

						local Distance =
							GetScreenDistance(
								Head
							)

						if Distance >
							AimConfig.FOV then

							AimTarget =
								GetBestAimTarget()
						end
					end
				end

				if AimTarget then
					AimAtTarget(
						AimTarget
					)
				end
			end
		)
end

--========================================================--
-- TOOL TITLE
--========================================================--

local ToolTitle =
	Instance.new("TextLabel")

ToolTitle.Size =
	UDim2.new(
		1,
		-30,
		0,
		35
	)

ToolTitle.Position =
	UDim2.fromOffset(
		15,
		8
	)

ToolTitle.BackgroundTransparency = 1
ToolTitle.Text = "TOOL"
ToolTitle.TextColor3 = C.White
ToolTitle.TextSize = 18
ToolTitle.Font = Enum.Font.GothamBlack
ToolTitle.TextXAlignment =
	Enum.TextXAlignment.Left
ToolTitle.Parent = ToolPage

local ToolLine =
	Instance.new("Frame")

ToolLine.Size =
	UDim2.new(
		1,
		-30,
		0,
		1
	)

ToolLine.Position =
	UDim2.fromOffset(
		15,
		45
	)

ToolLine.BackgroundColor3 =
	C.Stroke

ToolLine.BackgroundTransparency = 0.35
ToolLine.BorderSizePixel = 0
ToolLine.Parent = ToolPage

--========================================================--
-- AIMLOCK BUTTON
--========================================================--

local AimLockButton =
	FeatureButton(
		"AIMLOCK  :  OFF",
		15,
		65,
		ToolPage
	)

AimLockButton.MouseButton1Click:Connect(function()

	if AimLockEnabled then

		StopAimLock()

		AimLockButton.Text =
			"AIMLOCK  :  OFF"

	else

		StartAimLock()

		AimLockButton.Text =
			"AIMLOCK  :  ON"
	end
end)

--========================================================--
-- AIM FOV SLIDER
--========================================================--

local AimFOVLabel =
	Instance.new("TextLabel")

AimFOVLabel.Size =
	UDim2.fromOffset(
		200,
		22
	)

AimFOVLabel.Position =
	UDim2.fromOffset(
		15,
		120
	)

AimFOVLabel.BackgroundTransparency = 1
AimFOVLabel.Text = "AIM FOV"
AimFOVLabel.TextColor3 = C.Gray
AimFOVLabel.TextSize = 10
AimFOVLabel.Font = Enum.Font.GothamBold
AimFOVLabel.TextXAlignment =
	Enum.TextXAlignment.Left
AimFOVLabel.Parent = ToolPage

local FOVTrack =
	Instance.new("Frame")

FOVTrack.Size =
	UDim2.fromOffset(
		260,
		7
	)

FOVTrack.Position =
	UDim2.fromOffset(
		15,
		147
	)

FOVTrack.BackgroundColor3 =
	Color3.fromRGB(
		39,
		40,
		50
	)

FOVTrack.BorderSizePixel = 0
FOVTrack.Parent = ToolPage

Corner(
	FOVTrack,
	10
)

local FOVFill =
	Instance.new("Frame")

FOVFill.Size =
	UDim2.new(
		0.2857,
		0,
		1,
		0
	)

FOVFill.BackgroundColor3 =
	C.Purple

FOVFill.BorderSizePixel = 0
FOVFill.Parent = FOVTrack

Corner(
	FOVFill,
	10
)

local FOVKnob =
	Instance.new("Frame")

FOVKnob.Size =
	UDim2.fromOffset(
		18,
		18
	)

FOVKnob.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

FOVKnob.Position =
	UDim2.new(
		0.2857,
		0,
		0.5,
		0
	)

FOVKnob.BackgroundColor3 =
	Color3.fromRGB(
		250,
		250,
		255
	)

FOVKnob.BorderSizePixel = 0
FOVKnob.Parent = FOVTrack

Corner(
	FOVKnob,
	20
)

AddStroke(
	FOVKnob,
	C.Purple,
	1,
	0.15
)

local FOVValue =
	Instance.new("TextLabel")

FOVValue.Size =
	UDim2.fromOffset(
		75,
		31
	)

FOVValue.Position =
	UDim2.fromOffset(
		300,
		132
	)

FOVValue.BackgroundColor3 =
	C.Button

FOVValue.BorderSizePixel = 0
FOVValue.Text = "150"
FOVValue.TextColor3 = C.White
FOVValue.TextSize = 11
FOVValue.Font = Enum.Font.GothamBold
FOVValue.Parent = ToolPage

Corner(
	FOVValue,
	8
)

AddStroke(
	FOVValue,
	C.Stroke,
	1,
	0.35
)

local FOVDragging = false

local function SetAimFOV(X)

	local Left =
		FOVTrack.AbsolutePosition.X

	local Width =
		FOVTrack.AbsoluteSize.X

	if Width <= 0 then
		return
	end

	local Percent =
		math.clamp(
			(X - Left) / Width,
			0,
			1
		)

	local Value =
		math.floor(
			50 +
			350 * Percent
		)

	AimConfig.FOV =
		Value

	FOVFill.Size =
		UDim2.new(
			Percent,
			0,
			1,
			0
		)

	FOVKnob.Position =
		UDim2.new(
			Percent,
			0,
			0.5,
			0
		)

	FOVValue.Text =
		tostring(Value)

	UpdateAimFOV()
end

FOVTrack.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		FOVDragging = true

		SetAimFOV(
			Input.Position.X
		)
	end
end)

UIS.InputChanged:Connect(function(Input)

	if not FOVDragging then
		return
	end

	if Input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		SetAimFOV(
			Input.Position.X
		)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		FOVDragging = false
	end
end)

--========================================================--
-- FAST MODE
--========================================================--

local FastModeEnabled = false

local FastModeButton =
	FeatureButton(
		"FAST MODE  :  OFF",
		205,
		65,
		ToolPage
	)

local SavedEffects = {}

local function SetEffectEnabled(Object, Enabled)

	if Object:IsA("ParticleEmitter")
		or Object:IsA("Trail")
		or Object:IsA("Beam")
		or Object:IsA("Smoke")
		or Object:IsA("Fire")
		or Object:IsA("Sparkles") then

		if SavedEffects[Object] == nil then
			SavedEffects[Object] =
				Object.Enabled
		end

		Object.Enabled =
			Enabled
	end
end

local function ApplyFastMode()

	for _, Object in
		ipairs(workspace:GetDescendants()) do

		SetEffectEnabled(
			Object,
			false
		)

		if Object:IsA("BasePart") then

			if Object.Material ==
				Enum.Material.Neon then

				Object.Material =
					Enum.Material.SmoothPlastic
			end
		end
	end

	local Lighting =
		game:GetService("Lighting")

	for _, Object in
		ipairs(Lighting:GetChildren()) do

		if Object:IsA("PostEffect") then

			if SavedEffects[Object] == nil then
				SavedEffects[Object] =
					Object.Enabled
			end

			Object.Enabled = false
		end
	end
end

local function RestoreFastMode()

	for Object, OriginalValue in
		pairs(SavedEffects) do

		if Object and Object.Parent then

			if Object:IsA("ParticleEmitter")
				or Object:IsA("Trail")
				or Object:IsA("Beam")
				or Object:IsA("Smoke")
				or Object:IsA("Fire")
				or Object:IsA("Sparkles")
				or Object:IsA("PostEffect") then

				Object.Enabled =
					OriginalValue
			end
		end
	end

	table.clear(SavedEffects)
end

FastModeButton.MouseButton1Click:Connect(function()

	FastModeEnabled =
		not FastModeEnabled

	if FastModeEnabled then

		ApplyFastMode()

		FastModeButton.Text =
			"FAST MODE  :  ON"

	else

		RestoreFastMode()

		FastModeButton.Text =
			"FAST MODE  :  OFF"
	end
end)

--========================================================--
-- ESP BUTTON
--========================================================--

local ESPButton =
	FeatureButton(
		"ESP  :  OFF",
		15,
		220,
		ToolPage
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
-- ESP INFO
--========================================================--

local ESPInfo =
	Instance.new("TextLabel")

ESPInfo.Size =
	UDim2.new(
		1,
		-30,
		0,
		80
	)

ESPInfo.Position =
	UDim2.fromOffset(
		15,
		270
	)

ESPInfo.BackgroundColor3 =
	C.Button

ESPInfo.BackgroundTransparency = 0.2
ESPInfo.BorderSizePixel = 0

ESPInfo.Text =
	"ESP\n\nHiển thị người chơi + khoảng cách"

ESPInfo.TextColor3 =
	C.Gray

ESPInfo.TextSize = 11
ESPInfo.Font = Enum.Font.GothamBold
ESPInfo.TextWrapped = true
ESPInfo.TextYAlignment =
	Enum.TextYAlignment.Center

ESPInfo.Parent =
	ToolPage

Corner(
	ESPInfo,
	12
)

AddStroke(
	ESPInfo,
	C.Stroke,
	1,
	0.45
)

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
	StopAimLock()

	if FastModeEnabled then
		FastModeEnabled = false
		RestoreFastMode()
	end

	SpeedEnabled = false
	JumpEnabled = false
	FlyEnabled = false
	NoClipEnabled = false
	ESPEnabled = false
	AimLockEnabled = false
	AimTarget = nil

	Settings.Speed =
		DEFAULT.Speed

	Settings.Jump =
		DEFAULT.Jump

	Settings.FlySpeed =
		DEFAULT.FlySpeed

	AimConfig.FOV = 150

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

	AimLockButton.Text =
		"AIMLOCK  :  OFF"

	FastModeButton.Text =
		"FAST MODE  :  OFF"

	ESPButton.Text =
		"ESP  :  OFF"

	SpeedSlider.Set(
		DEFAULT.Speed
	)

	JumpSlider.Set(
		DEFAULT.Jump
	)

	FlySlider.Set(
		DEFAULT.FlySpeed
	)

	FOVFill.Size =
		UDim2.new(
			0.2857,
			0,
			1,
			0
		)

	FOVKnob.Position =
		UDim2.new(
			0.2857,
			0,
			0.5,
			0
		)

	FOVValue.Text = "150"

	UpdateAimFOV()
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
		ToolPage.Visible = false

		MakeTween(
			Tab1,
			0.15,
			{
				BackgroundColor3 =
					Color3.fromRGB(
						68,
						48,
						98
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
		ToolPage.Visible = true

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
						68,
						48,
						98
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
		UDim2.fromOffset(
			0,
			0
		)

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
-- LOADING 5 SECOND
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

		LoadingStatus.Text =
			"Loading..."

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

	for _, Object in
		ipairs(LoadingCard:GetDescendants()) do

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

	for _, Fox in
		ipairs(LoadingFoxes) do

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
-- SHOW BUTTON
--========================================================--

task.delay(
	5.0,
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
-- CHARACTER CLEANUP
--========================================================--

Player.CharacterAdded:Connect(function()
	AimTarget = nil
end)

--========================================================--
-- READY
--========================================================--

print(
	"MK HUB v2.0 READY "
)
