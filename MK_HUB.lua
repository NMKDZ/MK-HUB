--========================================================--
--              MK HUB v2.0 - AIMLOCK PRO                --
--        FOV + SMOOTH LOCK + TARGET PRIORITY            --
--========================================================--

--========================================================--
-- AIM SETTINGS
--========================================================--

local AimSettings = {

	Enabled = false,

	-- FOV
	FOV = 120,
	FOVVisible = true,
	FOVFilled = false,

	-- Smoothness
	Smoothness = 0.18,

	-- Target
	TargetPart = "Head",

	-- Priority:
	-- "Crosshair" = gần tâm màn hình nhất
	-- "Distance" = gần player nhất
	-- "Health" = máu thấp nhất
	Priority = "Crosshair",

	-- Team
	TeamCheck = true,

	-- Visibility
	VisibleCheck = true,

	-- Hold mode
	HoldMode = false,
	HoldKey = Enum.KeyCode.Q,

	-- Prediction
	Prediction = false,
	PredictionAmount = 0.12,

	-- Maximum target distance
	MaxDistance = 2000
}

local AimTarget = nil
local AimConnection = nil
local AimInputConnection = nil

--========================================================--
-- AIM FOV CIRCLE
--========================================================--

local AimFOVCircle = Instance.new("Frame")

AimFOVCircle.Name = "MK_AIM_FOV"

AimFOVCircle.AnchorPoint =
	Vector2.new(0.5,0.5)

AimFOVCircle.Size =
	UDim2.fromOffset(
		AimSettings.FOV * 2,
		AimSettings.FOV * 2
	)

AimFOVCircle.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

AimFOVCircle.BackgroundTransparency = 1

AimFOVCircle.BorderSizePixel = 0

AimFOVCircle.Visible =
	AimSettings.FOVVisible

AimFOVCircle.ZIndex = 500

AimFOVCircle.Parent = Gui

local AimFOVCorner =
	Instance.new("UICorner")

AimFOVCorner.CornerRadius =
	UDim.new(1,0)

AimFOVCorner.Parent =
	AimFOVCircle

local AimFOVStroke =
	Instance.new("UIStroke")

AimFOVStroke.Color =
	C.Purple

AimFOVStroke.Thickness = 1.5

AimFOVStroke.Transparency = 0.1

AimFOVStroke.Parent =
	AimFOVCircle

--========================================================--
-- FOV CENTER
--========================================================--

local AimCenter =
	Instance.new("Frame")

AimCenter.Name =
	"MK_AIM_CENTER"

AimCenter.AnchorPoint =
	Vector2.new(0.5,0.5)

AimCenter.Size =
	UDim2.fromOffset(4,4)

AimCenter.Position =
	UDim2.fromScale(0.5,0.5)

AimCenter.BackgroundColor3 =
	C.Purple

AimCenter.BorderSizePixel = 0

AimCenter.Visible =
	AimSettings.FOVVisible

AimCenter.ZIndex = 501

AimCenter.Parent = Gui

Corner(AimCenter,4)

--========================================================--
-- UPDATE FOV
--========================================================--

local function UpdateAimFOV()

	if not AimFOVCircle then
		return
	end

	AimFOVCircle.Size =
		UDim2.fromOffset(
			AimSettings.FOV * 2,
			AimSettings.FOV * 2
		)

	AimFOVCircle.Visible =
		AimSettings.FOVVisible

	AimCenter.Visible =
		AimSettings.FOVVisible

end

--========================================================--
-- TEAM CHECK
--========================================================--

local function IsEnemy(PlayerObject)

	if PlayerObject == Player then
		return false
	end

	if not PlayerObject.Character then
		return false
	end

	if AimSettings.TeamCheck then

		if PlayerObject.Team ~= nil
			and Player.Team ~= nil
			and PlayerObject.Team == Player.Team then

			return false

		end

	end

	return true

end

--========================================================--
-- TARGET PART
--========================================================--

local function GetTargetPart(CharacterObject)

	if not CharacterObject then
		return nil
	end

	local Preferred =
		CharacterObject:FindFirstChild(
			AimSettings.TargetPart
		)

	if Preferred then
		return Preferred
	end

	local Head =
		CharacterObject:FindFirstChild("Head")

	if Head then
		return Head
	end

	return CharacterObject:FindFirstChild(
		"HumanoidRootPart"
	)

end

--========================================================--
-- CHARACTER ALIVE
--========================================================--

local function IsAlive(CharacterObject)

	if not CharacterObject then
		return false
	end

	local HumanoidObject =
		CharacterObject:FindFirstChildOfClass(
			"Humanoid"
		)

	if not HumanoidObject then
		return false
	end

	return HumanoidObject.Health > 0

end

--========================================================--
-- VISIBILITY CHECK
--========================================================--

local function IsVisible(TargetPart)

	if not AimSettings.VisibleCheck then
		return true
	end

	if not TargetPart then
		return false
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
		return false
	end

	local Origin =
		Camera.CFrame.Position

	local Direction =
		TargetPart.Position - Origin

	if Direction.Magnitude <= 0 then
		return true
	end

	local Parameters =
		RaycastParams.new()

	Parameters.FilterType =
		Enum.RaycastFilterType.Exclude

	Parameters.FilterDescendantsInstances = {
		Character
	}

	Parameters.IgnoreWater = true

	local Result =
		Workspace:Raycast(
			Origin,
			Direction,
			Parameters
		)

	if not Result then
		return true
	end

	return Result.Instance:IsDescendantOf(
		TargetPart.Parent
	)

end

--========================================================--
-- SCREEN DISTANCE
--========================================================--

local function GetScreenDistance(
	Camera,
	Position
)

	local ScreenPosition,
	Visible =
		Camera:WorldToViewportPoint(
			Position
		)

	if not Visible then
		return math.huge
	end

	local Viewport =
		Camera.ViewportSize

	local Center =
		Vector2.new(
			Viewport.X / 2,
			Viewport.Y / 2
		)

	local Screen =
		Vector2.new(
			ScreenPosition.X,
			ScreenPosition.Y
		)

	return (
		Screen - Center
	).Magnitude

end

--========================================================--
-- TARGET DATA
--========================================================--

local function GetTargetData(PlayerObject)

	if not IsEnemy(PlayerObject) then
		return nil
	end

	local CharacterObject =
		PlayerObject.Character

	if not IsAlive(CharacterObject) then
		return nil
	end

	local TargetPart =
		GetTargetPart(CharacterObject)

	if not TargetPart then
		return nil
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local Distance =
		(
			Camera.CFrame.Position -
			TargetPart.Position
		).Magnitude

	if Distance >
		AimSettings.MaxDistance then

		return nil

	end

	local ScreenDistance =
		GetScreenDistance(
			Camera,
			TargetPart.Position
		)

	if ScreenDistance >
		AimSettings.FOV then

		return nil

	end

	if not IsVisible(TargetPart) then
		return nil
	end

	local HumanoidObject =
		CharacterObject:FindFirstChildOfClass(
			"Humanoid"
		)

	local Health =
		HumanoidObject
		and HumanoidObject.Health
		or math.huge

	return {

		Player = PlayerObject,

		Character = CharacterObject,

		Part = TargetPart,

		Distance = Distance,

		ScreenDistance = ScreenDistance,

		Health = Health

	}

end

--========================================================--
-- TARGET PRIORITY
--========================================================--

local function CompareTargets(A,B)

	if not A then
		return B
	end

	if not B then
		return A
	end

	--====================================================--
	-- CROSSHAIR
	--====================================================--

	if AimSettings.Priority ==
		"Crosshair" then

		if B.ScreenDistance <
			A.ScreenDistance then

			return B

		end

		return A

	end

	--====================================================--
	-- DISTANCE
	--====================================================--

	if AimSettings.Priority ==
		"Distance" then

		if B.Distance <
			A.Distance then

			return B

		end

		return A

	end

	--====================================================--
	-- HEALTH
	--====================================================--

	if AimSettings.Priority ==
		"Health" then

		if B.Health <
			A.Health then

			return B

		end

		return A

	end

	return A

end

--========================================================--
-- FIND BEST TARGET
--========================================================--

local function FindBestTarget()

	local BestTarget = nil

	for _, OtherPlayer in ipairs(
		Players:GetPlayers()
	) do

		if OtherPlayer ~= Player then

			local Data =
				GetTargetData(
					OtherPlayer
				)

			if Data then

				BestTarget =
					CompareTargets(
						BestTarget,
						Data
					)

			end

		end

	end

	return BestTarget

end

--========================================================--
-- TARGET VALIDATION
--========================================================--

local function ValidateTarget()

	if not AimTarget then
		return false
	end

	if not AimTarget.Player then
		return false
	end

	if not AimTarget.Player.Parent then
		return false
	end

	local NewData =
		GetTargetData(
			AimTarget.Player
		)

	if not NewData then
		return false
	end

	AimTarget =
		NewData

	return true

end

--========================================================--
-- PREDICTION
--========================================================--

local function GetAimPosition(TargetData)

	if not TargetData
		or not TargetData.Part then

		return nil

	end

	local Position =
		TargetData.Part.Position

	if not AimSettings.Prediction then
		return Position
	end

	local TargetCharacter =
		TargetData.Character

	local TargetRoot =
		TargetCharacter
		and TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not TargetRoot then
		return Position
	end

	local Velocity =
		TargetRoot.AssemblyLinearVelocity

	Position +=
		Velocity *
		AimSettings.PredictionAmount

	return Position

end

--========================================================--
-- SMOOTH CAMERA LOCK
--========================================================--

local function AimAtTarget(
	TargetData,
	DeltaTime
)

	if not TargetData then
		return
	end

	local Camera =
		Workspace.CurrentCamera

	if not Camera then
		return
	end

	local AimPosition =
		GetAimPosition(
			TargetData
		)

	if not AimPosition then
		return
	end

	local CameraPosition =
		Camera.CFrame.Position

	local Desired =
		CFrame.lookAt(
			CameraPosition,
			AimPosition
		)

	--====================================================--
	-- FRAME RATE INDEPENDENT SMOOTHING
	--====================================================--

	local Smooth =
		math.clamp(
			AimSettings.Smoothness,
			0.01,
			1
		)

	local Alpha =
		1 -
		math.pow(
			1 - Smooth,
			DeltaTime * 60
		)

	Camera.CFrame =
		Camera.CFrame:Lerp(
			Desired,
			Alpha
		)

end

--========================================================--
-- AIMLOCK UPDATE
--========================================================--

local function AimUpdate(DeltaTime)

	if not AimSettings.Enabled then
		return
	end

	if AimSettings.HoldMode then

		if not UIS:IsKeyDown(
			AimSettings.HoldKey
		) then

			AimTarget = nil

			return

		end

	end

	if not ValidateTarget() then

		AimTarget =
			FindBestTarget()

	end

	if AimTarget then

		AimAtTarget(
			AimTarget,
			DeltaTime
		)

	end

end

--========================================================--
-- START AIMLOCK
--========================================================--

local function StartAimlock()

	if AimSettings.Enabled then
		return
	end

	AimSettings.Enabled = true

	AimTarget = nil

	if AimConnection then
		AimConnection:Disconnect()
		AimConnection = nil
	end

	AimConnection =
		RunService.RenderStepped:Connect(
			AimUpdate
		)

end

--========================================================--
-- STOP AIMLOCK
--========================================================--

local function StopAimlock()

	AimSettings.Enabled = false

	AimTarget = nil

	if AimConnection then

		AimConnection:Disconnect()

		AimConnection = nil

	end

end

--========================================================--
-- AIMLOCK BUTTON
--========================================================--

local AimButton =
	FeatureButton(
		"AIMLOCK  :  OFF",
		15,
		348,
		MainPage
	)

AimButton.MouseButton1Click:Connect(function()

	if AimSettings.Enabled then

		StopAimlock()

		AimButton.Text =
			"AIMLOCK  :  OFF"

	else

		StartAimlock()

		AimButton.Text =
			"AIMLOCK  :  ON"

	end

end)

--========================================================--
-- AIM FOV SLIDER
--========================================================--

local AimFOVSlider =
	MakeSlider(
		"AIM FOV",
		410,
		20,
		500,
		AimSettings.FOV,

		function(Value)

			AimSettings.FOV =
				Value

			UpdateAimFOV()

		end
	)

--========================================================--
-- AIM SMOOTH SLIDER
--========================================================--

local AimSmoothLabel =
	Instance.new("TextLabel")

AimSmoothLabel.Size =
	UDim2.fromOffset(200,22)

AimSmoothLabel.Position =
	UDim2.fromOffset(15,470)

AimSmoothLabel.BackgroundTransparency = 1

AimSmoothLabel.Text =
	"AIM SMOOTH"

AimSmoothLabel.TextColor3 =
	C.Gray

AimSmoothLabel.TextSize = 10

AimSmoothLabel.Font =
	Enum.Font.GothamBold

AimSmoothLabel.TextXAlignment =
	Enum.TextXAlignment.Left

AimSmoothLabel.Parent =
	MainPage

local AimSmoothTrack =
	Instance.new("Frame")

AimSmoothTrack.Size =
	UDim2.fromOffset(260,7)

AimSmoothTrack.Position =
	UDim2.fromOffset(15,497)

AimSmoothTrack.BackgroundColor3 =
	Color3.fromRGB(39,40,50)

AimSmoothTrack.BorderSizePixel = 0

AimSmoothTrack.Parent =
	MainPage

Corner(
	AimSmoothTrack,
	10
)

local AimSmoothFill =
	Instance.new("Frame")

AimSmoothFill.Size =
	UDim2.new(
		AimSettings.Smoothness,
		0,
		1,
		0
	)

AimSmoothFill.BackgroundColor3 =
	C.Purple

AimSmoothFill.BorderSizePixel = 0

AimSmoothFill.Parent =
	AimSmoothTrack

Corner(
	AimSmoothFill,
	10
)

--========================================================--
-- SMOOTH INPUT
--========================================================--

local AimSmoothInput =
	Instance.new("TextBox")

AimSmoothInput.Size =
	UDim2.fromOffset(75,31)

AimSmoothInput.Position =
	UDim2.fromOffset(300,465)

AimSmoothInput.BackgroundColor3 =
	C.Button

AimSmoothInput.BorderSizePixel = 0

AimSmoothInput.Text =
	string.format(
		"%.2f",
		AimSettings.Smoothness
	)

AimSmoothInput.TextColor3 =
	C.White

AimSmoothInput.TextSize = 11

AimSmoothInput.Font =
	Enum.Font.GothamBold

AimSmoothInput.ClearTextOnFocus = false

AimSmoothInput.Parent =
	MainPage

Corner(
	AimSmoothInput,
	8
)

AddStroke(
	AimSmoothInput,
	C.Stroke,
	1,
	0.35
)

local function SetAimSmooth(Value)

	Value =
		tonumber(Value)
		or AimSettings.Smoothness

	Value =
		math.clamp(
			Value,
			0.01,
			1
		)

	AimSettings.Smoothness =
		Value

	AimSmoothFill.Size =
		UDim2.new(
			Value,
			0,
			1,
			0
		)

	AimSmoothInput.Text =
		string.format(
			"%.2f",
			Value
		)

end

AimSmoothInput.FocusLost:Connect(function()

	SetAimSmooth(
		AimSmoothInput.Text
	)

end)

AimSmoothTrack.InputBegan:Connect(function(InputObject)

	if InputObject.UserInputType ~=
		Enum.UserInputType.MouseButton1 then

		return

	end

	local Connection

	Connection =
		UIS.InputChanged:Connect(
			function(Move)

				if Move.UserInputType ~=
					Enum.UserInputType.MouseMovement then

					return

				end

				local Left =
					AimSmoothTrack.AbsolutePosition.X

				local Width =
					AimSmoothTrack.AbsoluteSize.X

				local Percent =
					math.clamp(
						(
							Move.Position.X -
							Left
						) / Width,
						0,
						1
					)

				SetAimSmooth(
					Percent
				)

			end
		)

	local EndConnection

	EndConnection =
		UIS.InputEnded:Connect(
			function(Ended)

				if Ended.UserInputType ==
					Enum.UserInputType.MouseButton1 then

					if Connection then
						Connection:Disconnect()
					end

					if EndConnection then
						EndConnection:Disconnect()
					end

				end

			end
		)

end)

--========================================================--
-- FOV TOGGLE
--========================================================--

local FOVButton =
	FeatureButton(
		"FOV CIRCLE  :  ON",
		205,
		348,
		MainPage
	)

FOVButton.MouseButton1Click:Connect(function()

	AimSettings.FOVVisible =
		not AimSettings.FOVVisible

	AimFOVCircle.Visible =
		AimSettings.FOVVisible

	AimCenter.Visible =
		AimSettings.FOVVisible

	if AimSettings.FOVVisible then

		FOVButton.Text =
			"FOV CIRCLE  :  ON"

	else

		FOVButton.Text =
			"FOV CIRCLE  :  OFF"

	end

end)

--========================================================--
-- TARGET PRIORITY
--========================================================--

local PriorityButton =
	FeatureButton(
		"PRIORITY : CROSSHAIR",
		15,
		535,
		MainPage
	)

local Priorities = {
	"Crosshair",
	"Distance",
	"Health"
}

local PriorityIndex = 1

PriorityButton.MouseButton1Click:Connect(function()

	PriorityIndex += 1

	if PriorityIndex >
		#Priorities then

		PriorityIndex = 1

	end

	AimSettings.Priority =
		Priorities[PriorityIndex]

	PriorityButton.Text =
		"PRIORITY : "
		.. string.upper(
			AimSettings.Priority
		)

	AimTarget = nil

end)

--========================================================--
-- TARGET PART
--========================================================--

local TargetPartButton =
	FeatureButton(
		"TARGET : HEAD",
		205,
		535,
		MainPage
	)

local TargetParts = {
	"Head",
	"HumanoidRootPart",
	"UpperTorso"
}

local TargetPartIndex = 1

TargetPartButton.MouseButton1Click:Connect(function()

	TargetPartIndex += 1

	if TargetPartIndex >
		#TargetParts then

		TargetPartIndex = 1

	end

	AimSettings.TargetPart =
		TargetParts[TargetPartIndex]

	TargetPartButton.Text =
		"TARGET : "
		.. string.upper(
			AimSettings.TargetPart
		)

	AimTarget = nil

end)

--========================================================--
-- PREDICTION
--========================================================--

local PredictionButton =
	FeatureButton(
		"PREDICTION : OFF",
		15,
		583,
		MainPage
	)

PredictionButton.MouseButton1Click:Connect(function()

	AimSettings.Prediction =
		not AimSettings.Prediction

	PredictionButton.Text =
		"PREDICTION : "
		.. (
			AimSettings.Prediction
			and "ON"
			or "OFF"
		)

end)

--========================================================--
-- HOLD MODE
--========================================================--

local HoldButton =
	FeatureButton(
		"HOLD AIM : OFF",
		205,
		583,
		MainPage
	)

HoldButton.MouseButton1Click:Connect(function()

	AimSettings.HoldMode =
		not AimSettings.HoldMode

	HoldButton.Text =
		"HOLD AIM : "
		.. (
			AimSettings.HoldMode
			and "ON"
			or "OFF"
		)

	AimTarget = nil

end)

--========================================================--
-- AIM TARGET STATUS
--========================================================--

local AimStatus =
	Instance.new("TextLabel")

AimStatus.Size =
	UDim2.new(
		1,
		-30,
		0,
		30
	)

AimStatus.Position =
	UDim2.fromOffset(
		15,
		635
	)

AimStatus.BackgroundTransparency = 1

AimStatus.Text =
	"TARGET : NONE"

AimStatus.TextColor3 =
	C.Gray

AimStatus.TextSize = 10

AimStatus.Font =
	Enum.Font.GothamBold

AimStatus.TextXAlignment =
	Enum.TextXAlignment.Left

AimStatus.Parent =
	MainPage

--========================================================--
-- STATUS UPDATE
--========================================================--

task.spawn(function()

	while Gui.Parent do

		if AimSettings.Enabled
			and AimTarget
			and AimTarget.Player then

			AimStatus.Text =
				"TARGET : "
				.. AimTarget.Player.DisplayName
				.. "  |  "
				.. math.floor(
					AimTarget.Distance
				)
				.. " studs"

		else

			AimStatus.Text =
				"TARGET : NONE"

		end

		task.wait(0.08)

	end

end)

--========================================================--
-- RESET AIM
--========================================================--

local function ResetAim()

	StopAimlock()

	AimSettings.FOV =
		DEFAULT.AimFOV

	AimSettings.Smoothness =
		0.18

	AimSettings.Priority =
		"Crosshair"

	AimSettings.TargetPart =
		"Head"

	AimSettings.FOVVisible =
		true

	AimSettings.Prediction =
		false

	AimSettings.HoldMode =
		false

	PriorityIndex = 1
	TargetPartIndex = 1

	AimButton.Text =
		"AIMLOCK  :  OFF"

	FOVButton.Text =
		"FOV CIRCLE  :  ON"

	PriorityButton.Text =
		"PRIORITY : CROSSHAIR"

	TargetPartButton.Text =
		"TARGET : HEAD"

	PredictionButton.Text =
		"PREDICTION : OFF"

	HoldButton.Text =
		"HOLD AIM : OFF"

	AimFOVSlider.Set(
		DEFAULT.AimFOV
	)

	SetAimSmooth(
		0.18
	)

	UpdateAimFOV()

end

--========================================================--
-- EXTEND EXISTING RESET
--========================================================--

local OriginalResetEverything =
	ResetEverything

ResetEverything =
	function()

		OriginalResetEverything()

		ResetAim()

	end

--========================================================--
-- PLAYER CLEANUP
--========================================================--

Players.PlayerRemoving:Connect(function(
	LeavingPlayer
)

	if AimTarget
		and AimTarget.Player ==
			LeavingPlayer then

		AimTarget = nil

	end

end)

--========================================================--
-- CHARACTER CLEANUP
--========================================================--

Player.CharacterAdded:Connect(function()

	AimTarget = nil

end)

--========================================================--
-- INITIALIZE
--========================================================--

UpdateAimFOV()

SetAimSmooth(
	AimSettings.Smoothness
)

print(
	"MK HUB v2.0 - AIMLOCK PRO READY"
)

--========================================================--
-- END AIMLOCK PRO
--========================================================--
