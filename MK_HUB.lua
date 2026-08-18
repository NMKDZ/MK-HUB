--========================================================--
--                         MK HUB                         --
--              DRAGGABLE + SLIDER + INPUT               --
--========================================================--

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

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

local function LoadCharacter(char)

	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Root = char:WaitForChild("HumanoidRootPart")

	Humanoid.UseJumpPower = true

end

if Player.Character then
	LoadCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)

	LoadCharacter(char)

	task.wait(0.2)

	Humanoid.WalkSpeed = 16
	Humanoid.JumpPower = 50

end)

--========================================================--
-- STATES
--========================================================--

local SpeedEnabled = false
local JumpEnabled = false
local FlyEnabled = false
local NoClipEnabled = false

local FlyVelocity
local FlyConnection
local NoClipConnection

--========================================================--
-- GUI
--========================================================--

local Gui = Instance.new("ScreenGui")

Gui.Name = "MK_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999

Gui.Parent = Player:WaitForChild("PlayerGui")

--========================================================--
-- DRAG SYSTEM
--========================================================--

local function MakeDraggable(Object, Handle)

	local Dragging = false
	local DragStart
	local StartPosition

	Handle.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			Dragging = true

			DragStart = input.Position
			StartPosition = Object.Position

		end

	end)

	Handle.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			Dragging = false

		end

	end)

	UIS.InputChanged:Connect(function(input)

		if not Dragging then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.MouseMovement then
			return
		end

		local Delta =
			input.Position - DragStart

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
-- LOADING SCREEN
--========================================================--

local Loading = Instance.new("Frame")

Loading.Size =
	UDim2.fromScale(1, 1)

Loading.BackgroundColor3 =
	Color3.fromRGB(7, 8, 12)

Loading.BorderSizePixel = 0

Loading.ZIndex = 1000

Loading.Parent = Gui

local LoadingGradient =
	Instance.new("UIGradient")

LoadingGradient.Rotation = 45

LoadingGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			Color3.fromRGB(7, 9, 16)
		),

		ColorSequenceKeypoint.new(
			0.5,
			Color3.fromRGB(25, 18, 38)
		),

		ColorSequenceKeypoint.new(
			1,
			Color3.fromRGB(6, 8, 13)
		)

	})

LoadingGradient.Parent = Loading

--========================================================--
-- LOADING CONTENT
--========================================================--

local LoadingBox = Instance.new("Frame")

LoadingBox.Size =
	UDim2.fromOffset(430, 280)

LoadingBox.AnchorPoint =
	Vector2.new(0.5, 0.5)

LoadingBox.Position =
	UDim2.fromScale(0.5, 0.5)

LoadingBox.BackgroundTransparency = 1

LoadingBox.ZIndex = 1001

LoadingBox.Parent = Loading

local Logo = Instance.new("TextLabel")

Logo.Size =
	UDim2.new(1, 0, 0, 80)

Logo.Position =
	UDim2.fromOffset(0, 20)

Logo.BackgroundTransparency = 1

Logo.Text = "MK"

Logo.TextColor3 =
	Color3.fromRGB(255, 255, 255)

Logo.TextSize = 60

Logo.Font =
	Enum.Font.GothamBlack

Logo.ZIndex = 1002

Logo.Parent = LoadingBox

local Name = Instance.new("TextLabel")

Name.Size =
	UDim2.new(1, 0, 0, 30)

Name.Position =
	UDim2.fromOffset(0, 95)

Name.BackgroundTransparency = 1

Name.Text = "MK HUB"

Name.TextColor3 =
	Color3.fromRGB(180, 185, 200)

Name.TextSize = 18

Name.Font =
	Enum.Font.GothamBold

Name.ZIndex = 1002

Name.Parent = LoadingBox

local Status = Instance.new("TextLabel")

Status.Size =
	UDim2.new(1, 0, 0, 25)

Status.Position =
	UDim2.fromOffset(0, 135)

Status.BackgroundTransparency = 1

Status.Text = "Loading..."

Status.TextColor3 =
	Color3.fromRGB(130, 135, 150)

Status.TextSize = 12

Status.Font =
	Enum.Font.Gotham

Status.ZIndex = 1002

Status.Parent = LoadingBox

local ProgressBack = Instance.new("Frame")

ProgressBack.Size =
	UDim2.fromOffset(330, 8)

ProgressBack.Position =
	UDim2.new(
		0.5,
		-165,
		0,
		175
	)

ProgressBack.BackgroundColor3 =
	Color3.fromRGB(38, 40, 48)

ProgressBack.BorderSizePixel = 0

ProgressBack.ZIndex = 1002

ProgressBack.Parent = LoadingBox

local ProgressBackCorner =
	Instance.new("UICorner")

ProgressBackCorner.CornerRadius =
	UDim.new(1, 0)

ProgressBackCorner.Parent =
	ProgressBack

local Progress = Instance.new("Frame")

Progress.Size =
	UDim2.new(0, 0, 1, 0)

Progress.BackgroundColor3 =
	Color3.fromRGB(120, 185, 255)

Progress.BorderSizePixel = 0

Progress.ZIndex = 1003

Progress.Parent = ProgressBack

local ProgressCorner =
	Instance.new("UICorner")

ProgressCorner.CornerRadius =
	UDim.new(1, 0)

ProgressCorner.Parent = Progress

local Percent = Instance.new("TextLabel")

Percent.Size =
	UDim2.new(1, 0, 0, 25)

Percent.Position =
	UDim2.fromOffset(0, 195)

Percent.BackgroundTransparency = 1

Percent.Text = "0%"

Percent.TextColor3 =
	Color3.fromRGB(220, 225, 235)

Percent.TextSize = 11

Percent.Font =
	Enum.Font.GothamBold

Percent.ZIndex = 1002

Percent.Parent = LoadingBox

--========================================================--
-- LOADING
--========================================================--

task.spawn(function()

	local Steps = {

		{0.15, "Starting MK HUB..."},
		{0.30, "Loading interface..."},
		{0.50, "Loading controls..."},
		{0.70, "Loading sliders..."},
		{0.88, "Preparing hub..."},
		{1.00, "Ready."}

	}

	local oldPercent = 0

	for _, Step in ipairs(Steps) do

		local Target = Step[1]

		Status.Text = Step[2]

		TweenService:Create(
			Progress,
			TweenInfo.new(
				0.4,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			),
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

		for i = oldPercent,
			math.floor(Target * 100) do

			Percent.Text =
				tostring(i) .. "%"

			task.wait(0.01)

		end

		oldPercent =
			math.floor(Target * 100)

		task.wait(0.12)

	end

	task.wait(0.4)

	for _, Object in ipairs(
		Loading:GetDescendants()
		) do

		if Object:IsA("TextLabel") then

			TweenService:Create(
				Object,
				TweenInfo.new(0.4),
				{
					TextTransparency = 1
				}
			):Play()

		end

	end

	TweenService:Create(
		Loading,
		TweenInfo.new(0.5),
		{
			BackgroundTransparency = 1
		}
	):Play()

	task.wait(0.55)

	Loading:Destroy()

end)

--========================================================--
-- ROUND MK BUTTON
--========================================================--

local HubButton = Instance.new("TextButton")

HubButton.Size =
	UDim2.fromOffset(62, 62)

HubButton.Position =
	UDim2.new(
		0,
		20,
		0.5,
		-31
	)

HubButton.BackgroundColor3 =
	Color3.fromRGB(20, 21, 27)

HubButton.BorderSizePixel = 0

HubButton.Text = "MK"

HubButton.TextColor3 =
	Color3.fromRGB(255, 255, 255)

HubButton.TextSize = 16

HubButton.Font =
	Enum.Font.GothamBlack

HubButton.Visible = false

HubButton.Parent = Gui

local HubCorner =
	Instance.new("UICorner")

HubCorner.CornerRadius =
	UDim.new(1, 0)

HubCorner.Parent = HubButton

local HubStroke =
	Instance.new("UIStroke")

HubStroke.Thickness = 2

HubStroke.Color =
	Color3.fromRGB(100, 150, 220)

HubStroke.Parent = HubButton

-- IMPORTANT:
-- Drag the actual circular button.

MakeDraggable(
	HubButton,
	HubButton
)

--========================================================--
-- MAIN MENU
--========================================================--

local Main = Instance.new("Frame")

Main.Size =
	UDim2.fromOffset(340, 460)

Main.Position =
	UDim2.new(
		0.5,
		-170,
		0.5,
		-230
	)

Main.BackgroundColor3 =
	Color3.fromRGB(14, 15, 20)

Main.BorderSizePixel = 0

Main.Visible = false

Main.Parent = Gui

local MainCorner =
	Instance.new("UICorner")

MainCorner.CornerRadius =
	UDim.new(0, 16)

MainCorner.Parent = Main

local MainStroke =
	Instance.new("UIStroke")

MainStroke.Thickness = 1

MainStroke.Color =
	Color3.fromRGB(65, 70, 82)

MainStroke.Parent = Main

--========================================================--
-- HEADER / DRAG HANDLE
--========================================================--

local Header = Instance.new("TextButton")

Header.Size =
	UDim2.new(1, -20, 0, 50)

Header.Position =
	UDim2.fromOffset(10, 5)

Header.BackgroundTransparency = 1

Header.Text = "MK HUB"

Header.TextColor3 =
	Color3.fromRGB(255, 255, 255)

Header.TextSize = 18

Header.Font =
	Enum.Font.GothamBold

Header.TextXAlignment =
	Enum.TextXAlignment.Left

Header.AutoButtonColor = false

Header.Parent = Main

-- Menu can also be dragged.

MakeDraggable(
	Main,
	Header
)

--========================================================--
-- FEATURE BUTTON
--========================================================--

local function FeatureButton(Text, X, Y)

	local Button = Instance.new("TextButton")

	Button.Size =
		UDim2.fromOffset(150, 38)

	Button.Position =
		UDim2.fromOffset(X, Y)

	Button.BackgroundColor3 =
		Color3.fromRGB(30, 31, 38)

	Button.BorderSizePixel = 0

	Button.Text = Text

	Button.TextColor3 =
		Color3.fromRGB(235, 235, 240)

	Button.TextSize = 11

	Button.Font =
		Enum.Font.GothamBold

	Button.Parent = Main

	local Corner =
		Instance.new("UICorner")

	Corner.CornerRadius =
		UDim.new(0, 9)

	Corner.Parent = Button

	return Button

end

local SpeedButton =
	FeatureButton(
		"SPEED : OFF",
		12,
		65
	)

local JumpButton =
	FeatureButton(
		"JUMP : OFF",
		178,
		65
	)

local FlyButton =
	FeatureButton(
		"FLY : OFF",
		12,
		110
	)

local NoClipButton =
	FeatureButton(
		"NOCLIP : OFF",
		178,
		110
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
		UDim2.fromOffset(130, 24)

	Label.Position =
		UDim2.fromOffset(12, Y)

	Label.BackgroundTransparency = 1

	Label.Text = Title

	Label.TextColor3 =
		Color3.fromRGB(190, 195, 205)

	Label.TextSize = 10

	Label.Font =
		Enum.Font.GothamBold

	Label.TextXAlignment =
		Enum.TextXAlignment.Left

	Label.Parent = Main

	-- TRACK

	local Track =
		Instance.new("Frame")

	Track.Size =
		UDim2.fromOffset(205, 7)

	Track.Position =
		UDim2.fromOffset(12, Y + 27)

	Track.BackgroundColor3 =
		Color3.fromRGB(42, 44, 52)

	Track.BorderSizePixel = 0

	Track.Parent = Main

	local TrackCorner =
		Instance.new("UICorner")

	TrackCorner.CornerRadius =
		UDim.new(1, 0)

	TrackCorner.Parent = Track

	-- FILL

	local Fill =
		Instance.new("Frame")

	Fill.Size =
		UDim2.new(0, 0, 1, 0)

	Fill.BackgroundColor3 =
		Color3.fromRGB(110, 180, 255)

	Fill.BorderSizePixel = 0

	Fill.Parent = Track

	local FillCorner =
		Instance.new("UICorner")

	FillCorner.CornerRadius =
		UDim.new(1, 0)

	FillCorner.Parent = Fill

	-- KNOB

	local Knob =
		Instance.new("TextButton")

	Knob.Size =
		UDim2.fromOffset(17, 17)

	Knob.AnchorPoint =
		Vector2.new(0.5, 0.5)

	Knob.BackgroundColor3 =
		Color3.fromRGB(255, 255, 255)

	Knob.BorderSizePixel = 0

	Knob.Text = ""

	Knob.Parent = Track

	local KnobCorner =
		Instance.new("UICorner")

	KnobCorner.CornerRadius =
		UDim.new(1, 0)

	KnobCorner.Parent = Knob

	-- NUMBER INPUT
	-- nằm ngay bên phải thanh

	local Input =
		Instance.new("TextBox")

	Input.Size =
		UDim2.fromOffset(72, 30)

	Input.Position =
		UDim2.fromOffset(247, Y - 2)

	Input.BackgroundColor3 =
		Color3.fromRGB(31, 32, 40)

	Input.BorderSizePixel = 0

	Input.Text =
		tostring(DefaultValue)

	Input.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	Input.TextSize = 11

	Input.Font =
		Enum.Font.GothamBold

	Input.ClearTextOnFocus = false

	Input.Parent = Main

	local InputCorner =
		Instance.new("UICorner")

	InputCorner.CornerRadius =
		UDim.new(0, 7)

	InputCorner.Parent = Input

	-- VALUE

	local Current =
		DefaultValue

	local function SetValue(Value)

		Value =
			tonumber(Value)
			or Current

		Value =
			math.clamp(
				math.floor(Value + 0.5),
				Min,
				Max
			)

		Current =
			Value

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

	-- CLICK TRACK

	Track.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			SetFromMouse(
				input.Position.X
			)

		end

	end)

	-- DRAG KNOB

	Knob.InputBegan:Connect(function(input)

		if input.UserInputType ~=
			Enum.UserInputType.MouseButton1 then

			return

		end

		local Moving
		local Released

		Moving =
			UIS.InputChanged:Connect(
				function(move)

					if move.UserInputType ==
						Enum.UserInputType.MouseMovement then

						SetFromMouse(
							move.Position.X
						)

					end

				end
			)

		Released =
			UIS.InputEnded:Connect(
				function(endInput)

					if endInput.UserInputType ==
						Enum.UserInputType.MouseButton1 then

						Moving:Disconnect()
						Released:Disconnect()

					end

				end
			)

	end)

	-- DIRECT NUMBER INPUT

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
		165,
		16,
		200,
		Settings.Speed,
		function(Value)

			Settings.Speed = Value

			if SpeedEnabled and Humanoid then

				Humanoid.WalkSpeed =
				Value

			end

		end
	)

local JumpSlider =
	MakeSlider(
		"JUMP",
		225,
		50,
		250,
		Settings.Jump,
		function(Value)

			Settings.Jump = Value

			if JumpEnabled and Humanoid then

				Humanoid.JumpPower =
				Value

			end

		end
	)

local FlySlider =
	MakeSlider(
		"FLY SPEED",
		285,
		20,
		250,
		Settings.FlySpeed,
		function(Value)

			Settings.FlySpeed =
			Value

		end
	)

--========================================================--
-- SPEED
--========================================================--

SpeedButton.MouseButton1Click:Connect(function()

	SpeedEnabled =
		not SpeedEnabled

	if Humanoid then

		if SpeedEnabled then

			Humanoid.WalkSpeed =
				Settings.Speed

			SpeedButton.Text =
				"SPEED : ON"

		else

			Humanoid.WalkSpeed = 16

			SpeedButton.Text =
				"SPEED : OFF"

		end

	end

end)

--========================================================--
-- JUMP
--========================================================--

JumpButton.MouseButton1Click:Connect(function()

	JumpEnabled =
		not JumpEnabled

	if Humanoid then

		Humanoid.UseJumpPower = true

		if JumpEnabled then

			Humanoid.JumpPower =
				Settings.Jump

			JumpButton.Text =
				"JUMP : ON"

		else

			Humanoid.JumpPower = 50

			JumpButton.Text =
				"JUMP : OFF"

		end

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

				local Camera =
				workspace.CurrentCamera

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
					Vector3.new(0, 1, 0)

				end

				if UIS:IsKeyDown(
					Enum.KeyCode.LeftControl
					) then

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
			"FLY : OFF"

	else

		StartFly()

		FlyButton.Text =
			"FLY : ON"

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
		RunService.Stepped:Connect(
			function()

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

			end
		)

end

NoClipButton.MouseButton1Click:Connect(function()

	if NoClipEnabled then

		StopNoClip()

		NoClipButton.Text =
			"NOCLIP : OFF"

	else

		StartNoClip()

		NoClipButton.Text =
			"NOCLIP : ON"

	end

end)

--========================================================--
-- TELEPORT
--========================================================--

local Teleport =
	FeatureButton(
		"TELEPORT",
		12,
		350
	)

Teleport.MouseButton1Click:Connect(function()

	if not Root then
		return
	end

	local Spawn

	for _, Object in ipairs(
		workspace:GetDescendants()
		) do

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
-- RESET
--========================================================--

local Reset =
	FeatureButton(
		"RESET ALL",
		178,
		350
	)

local function ResetEverything()

	-- STOP SYSTEMS

	StopFly()
	StopNoClip()

	-- STATES

	SpeedEnabled = false
	JumpEnabled = false
	FlyEnabled = false
	NoClipEnabled = false

	-- VALUES

	Settings.Speed =
		DEFAULT.Speed

	Settings.Jump =
		DEFAULT.Jump

	Settings.FlySpeed =
		DEFAULT.FlySpeed

	-- CHARACTER

	if Humanoid then

		Humanoid.WalkSpeed = 16
		Humanoid.UseJumpPower = true
		Humanoid.JumpPower = 50

	end

	-- BUTTONS

	SpeedButton.Text =
		"SPEED : OFF"

	JumpButton.Text =
		"JUMP : OFF"

	FlyButton.Text =
		"FLY : OFF"

	NoClipButton.Text =
		"NOCLIP : OFF"

	-- SLIDERS

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
-- OPEN / CLOSE
--========================================================--

local MenuOpen = false

local function OpenMenu()

	MenuOpen = true
	Main.Visible = true

	Main.Size =
		UDim2.fromOffset(0, 0)

	TweenService:Create(
		Main,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.fromOffset(340, 460)
		}
	):Play()

end

local function CloseMenu()

	MenuOpen = false

	local Animation =
		TweenService:Create(
			Main,
			TweenInfo.new(0.18),
			{
				Size =
				UDim2.fromOffset(0, 0)
			}
		)

	Animation:Play()

	Animation.Completed:Once(function()

		if not MenuOpen then

			Main.Visible = false

		end

	end)

end

HubButton.MouseButton1Click:Connect(function()

	if MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end

end)

--========================================================--
-- KEYBINDS
--========================================================--

UIS.InputBegan:Connect(function(
	Input,
	Processed
)

	if Processed then
		return
	end

	if Input.KeyCode ==
		Enum.KeyCode.RightShift then

		if MenuOpen then
			CloseMenu()
		else
			OpenMenu()
		end

	elseif Input.KeyCode ==
		Enum.KeyCode.R then

		ResetEverything()

	elseif Input.KeyCode ==
		Enum.KeyCode.F then

		FlyButton:Activate()

	elseif Input.KeyCode ==
		Enum.KeyCode.N then

		NoClipButton:Activate()

	end

end)

--========================================================--
-- SHOW BUTTON AFTER LOADING
--========================================================--

task.delay(4.2, function()

	HubButton.Visible = true

	HubButton.BackgroundTransparency = 1

	TweenService:Create(
		HubButton,
		TweenInfo.new(0.4),
		{
			BackgroundTransparency = 0
		}
	):Play()

end)

print("MK HUB READY")
