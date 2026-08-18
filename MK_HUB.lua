--========================================================--
--                    MK HUB v2.0                         --
--                 FOX ANIME EDITION                      --
--========================================================--
-- GIỮ NGUYÊN TOÀN BỘ CODE CŨ CỦA BOSS MAN
-- CHỈ THAY PHẦN "FARM TAB / ESP" BẰNG PHẦN DƯỚI ĐÂY
--========================================================--

--========================================================--
-- AIMLOCK SETTINGS
--========================================================--

local AimlockEnabled = false
local AimlockFOV = 150
local AimlockTarget = nil

local AimlockConnection
local AimlockFOVCircle

local AIMLOCK_DEFAULT_FOV = 150
local AIMLOCK_MIN_FOV = 25
local AIMLOCK_MAX_FOV = 600

--========================================================--
-- AIMLOCK FOV CIRCLE
--========================================================--

local function CreateAimlockFOV()

	if AimlockFOVCircle then
		AimlockFOVCircle:Remove()
		AimlockFOVCircle = nil
	end

	local Circle = Drawing.new("Circle")

	Circle.Visible = false
	Circle.Radius = AimlockFOV
	Circle.Thickness = 1.5
	Circle.Filled = false
	Circle.Transparency = 0.9
	Circle.Color = Color3.fromRGB(
		178,
		105,
		255
	)

	AimlockFOVCircle = Circle

	return Circle
end

CreateAimlockFOV()

--========================================================--
-- GET CLOSEST TARGET
--========================================================--

local function GetClosestAimlockTarget()

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return nil
	end

	local MousePosition =
		UIS:GetMouseLocation()

	local ClosestPlayer = nil
	local ClosestDistance = math.huge

	for _, OtherPlayer in ipairs(
		Players:GetPlayers()
	) do

		if OtherPlayer ~= Player then

			local CharacterObject =
				OtherPlayer.Character

			if CharacterObject then

				local HumanoidObject =
					CharacterObject:FindFirstChildOfClass(
						"Humanoid"
					)

				local Head =
					CharacterObject:FindFirstChild(
						"Head"
					)

				if
					HumanoidObject
					and HumanoidObject.Health > 0
					and Head
				then

					local ScreenPosition,
						OnScreen =
						Camera:WorldToViewportPoint(
							Head.Position
						)

					if OnScreen then

						local Distance =
							(
								Vector2.new(
									ScreenPosition.X,
									ScreenPosition.Y
								)
								-
								MousePosition
							).Magnitude

						if
							Distance <= AimlockFOV
							and Distance < ClosestDistance
						then

							ClosestDistance =
								Distance

							ClosestPlayer =
								OtherPlayer

						end

					end

				end

			end

		end

	end

	return ClosestPlayer

end

--========================================================--
-- UPDATE FOV CIRCLE
--========================================================--

local function UpdateAimlockFOV()

	if not AimlockFOVCircle then
		return
	end

	local Camera =
		workspace.CurrentCamera

	if not Camera then
		return
	end

	local MousePosition =
		UIS:GetMouseLocation()

	AimlockFOVCircle.Position =
		Vector2.new(
			MousePosition.X,
			MousePosition.Y
		)

	AimlockFOVCircle.Radius =
		AimlockFOV

	AimlockFOVCircle.Visible =
		AimlockEnabled

end

--========================================================--
-- STOP AIMLOCK
--========================================================--

local function StopAimlock()

	AimlockEnabled = false
	AimlockTarget = nil

	if AimlockConnection then

		AimlockConnection:Disconnect()
		AimlockConnection = nil

	end

	if AimlockFOVCircle then

		AimlockFOVCircle.Visible = false

	end

end

--========================================================--
-- START AIMLOCK
--========================================================--

local function StartAimlock()

	if AimlockEnabled then
		return
	end

	AimlockEnabled = true

	AimlockConnection =
		RunService.RenderStepped:Connect(
			function()

				if not AimlockEnabled then
					return
				end

				local Camera =
					workspace.CurrentCamera

				if not Camera then
					return
				end

				UpdateAimlockFOV()

				-- Giữ mục tiêu hiện tại nếu còn hợp lệ
				if AimlockTarget then

					local CharacterObject =
						AimlockTarget.Character

					local HumanoidObject =
						CharacterObject
						and CharacterObject:FindFirstChildOfClass(
							"Humanoid"
						)

					local Head =
						CharacterObject
						and CharacterObject:FindFirstChild(
							"Head"
						)

					if
						not CharacterObject
						or not HumanoidObject
						or HumanoidObject.Health <= 0
						or not Head
					then

						AimlockTarget = nil

					end

				end

				-- Tìm mục tiêu mới
				if not AimlockTarget then

					AimlockTarget =
						GetClosestAimlockTarget()

				end

				-- Aim vào Head
				if AimlockTarget then

					local CharacterObject =
						AimlockTarget.Character

					local Head =
						CharacterObject
						and CharacterObject:FindFirstChild(
							"Head"
						)

					if Head then

						Camera.CFrame =
							CFrame.lookAt(
								Camera.CFrame.Position,
								Head.Position
							)

					end

				end

			end
		)

end

--========================================================--
-- TAB 2 CONTENT
--========================================================--

local FarmTitle =
	Instance.new("TextLabel")

FarmTitle.Size =
	UDim2.new(
		1,
		-30,
		0,
		35
	)

FarmTitle.Position =
	UDim2.fromOffset(
		15,
		8
	)

FarmTitle.BackgroundTransparency = 1

FarmTitle.Text =
	"AIMLOCK"

FarmTitle.TextColor3 =
	C.White

FarmTitle.TextSize = 18

FarmTitle.Font =
	Enum.Font.GothamBlack

FarmTitle.TextXAlignment =
	Enum.TextXAlignment.Left

FarmTitle.Parent =
	FarmPage

--========================================================--
-- SEPARATOR
--========================================================--

local FarmLine =
	Instance.new("Frame")

FarmLine.Size =
	UDim2.new(
		1,
		-30,
		0,
		1
	)

FarmLine.Position =
	UDim2.fromOffset(
		15,
		45
	)

FarmLine.BackgroundColor3 =
	C.Stroke

FarmLine.BackgroundTransparency =
	0.35

FarmLine.BorderSizePixel = 0

FarmLine.Parent =
	FarmPage

--========================================================--
-- AIMLOCK BUTTON
--========================================================--

local AimlockButton =
	FeatureButton(
		"AIMLOCK  :  OFF",
		15,
		65,
		FarmPage
	)

AimlockButton.MouseButton1Click:Connect(
	function()

		if AimlockEnabled then

			StopAimlock()

			AimlockButton.Text =
				"AIMLOCK  :  OFF"

		else

			StartAimlock()

			AimlockButton.Text =
				"AIMLOCK  :  ON"

		end

	end
)

--========================================================--
-- FOV LABEL
--========================================================--

local AimlockFOVLabel =
	Instance.new("TextLabel")

AimlockFOVLabel.Size =
	UDim2.fromOffset(
		260,
		25
	)

AimlockFOVLabel.Position =
	UDim2.fromOffset(
		15,
		120
	)

AimlockFOVLabel.BackgroundTransparency = 1

AimlockFOVLabel.Text =
	"FOV"

AimlockFOVLabel.TextColor3 =
	C.Gray

AimlockFOVLabel.TextSize = 11

AimlockFOVLabel.Font =
	Enum.Font.GothamBold

AimlockFOVLabel.TextXAlignment =
	Enum.TextXAlignment.Left

AimlockFOVLabel.Parent =
	FarmPage

--========================================================--
-- FOV TRACK
--========================================================--

local AimlockFOVTrack =
	Instance.new("Frame")

AimlockFOVTrack.Size =
	UDim2.fromOffset(
		260,
		7
	)

AimlockFOVTrack.Position =
	UDim2.fromOffset(
		15,
		150
	)

AimlockFOVTrack.BackgroundColor3 =
	Color3.fromRGB(
		39,
		40,
		50
	)

AimlockFOVTrack.BorderSizePixel = 0

AimlockFOVTrack.Parent =
	FarmPage

Corner(
	AimlockFOVTrack,
	10
)

--========================================================--
-- FOV FILL
--========================================================--

local AimlockFOVFill =
	Instance.new("Frame")

AimlockFOVFill.Size =
	UDim2.new(
		0,
		0,
		1,
		0
	)

AimlockFOVFill.BackgroundColor3 =
	C.Purple

AimlockFOVFill.BorderSizePixel = 0

AimlockFOVFill.Parent =
	AimlockFOVTrack

Corner(
	AimlockFOVFill,
	10
)

local AimlockFOVGradient =
	Instance.new("UIGradient")

AimlockFOVGradient.Color =
	ColorSequence.new({

		ColorSequenceKeypoint.new(
			0,
			C.Blue
		),

		ColorSequenceKeypoint.new(
			1,
			C.Purple
		)

	})

AimlockFOVGradient.Parent =
	AimlockFOVFill

--========================================================--
-- FOV KNOB
--========================================================--

local AimlockFOVKnob =
	Instance.new("TextButton")

AimlockFOVKnob.Size =
	UDim2.fromOffset(
		18,
		18
	)

AimlockFOVKnob.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

AimlockFOVKnob.BackgroundColor3 =
	Color3.fromRGB(
		250,
		250,
		255
	)

AimlockFOVKnob.BorderSizePixel = 0

AimlockFOVKnob.Text = ""

AimlockFOVKnob.Parent =
	AimlockFOVTrack

Corner(
	AimlockFOVKnob,
	20
)

AddStroke(
	AimlockFOVKnob,
	C.Purple,
	1,
	0.15
)

--========================================================--
-- FOV INPUT
--========================================================--

local AimlockFOVInput =
	Instance.new("TextBox")

AimlockFOVInput.Size =
	UDim2.fromOffset(
		75,
		31
	)

AimlockFOVInput.Position =
	UDim2.fromOffset(
		300,
		135
	)

AimlockFOVInput.BackgroundColor3 =
	C.Button

AimlockFOVInput.BorderSizePixel = 0

AimlockFOVInput.Text =
	tostring(AimlockFOV)

AimlockFOVInput.TextColor3 =
	C.White

AimlockFOVInput.TextSize = 11

AimlockFOVInput.Font =
	Enum.Font.GothamBold

AimlockFOVInput.ClearTextOnFocus = false

AimlockFOVInput.Parent =
	FarmPage

Corner(
	AimlockFOVInput,
	8
)

AddStroke(
	AimlockFOVInput,
	C.Stroke,
	1,
	0.35
)

--========================================================--
-- SET FOV
--========================================================--

local function SetAimlockFOV(Value)

	Value =
		tonumber(Value)
		or AimlockFOV

	Value =
		math.clamp(
			math.floor(
				Value + 0.5
			),
			AIMLOCK_MIN_FOV,
			AIMLOCK_MAX_FOV
		)

	AimlockFOV =
		Value

	AimlockFOVInput.Text =
		tostring(Value)

	local Percent =
		(
			Value -
			AIMLOCK_MIN_FOV
		)
		/
		(
			AIMLOCK_MAX_FOV -
			AIMLOCK_MIN_FOV
		)

	AimlockFOVFill.Size =
		UDim2.new(
			Percent,
			0,
			1,
			0
		)

	AimlockFOVKnob.Position =
		UDim2.new(
			Percent,
			0,
			0.5,
			0
		)

end

--========================================================--
-- FOV MOUSE CONTROL
--========================================================--

local function SetFOVFromMouse(X)

	local Left =
		AimlockFOVTrack.AbsolutePosition.X

	local Width =
		AimlockFOVTrack.AbsoluteSize.X

	if Width <= 0 then
		return
	end

	local Percent =
		math.clamp(
			(
				X -
				Left
			)
			/
			Width,
			0,
			1
		)

	local Value =
		AIMLOCK_MIN_FOV
		+
		(
			AIMLOCK_MAX_FOV -
			AIMLOCK_MIN_FOV
		)
		*
		Percent

	SetAimlockFOV(
		Value
	)

end

--========================================================--
-- TRACK CLICK
--========================================================--

AimlockFOVTrack.InputBegan:Connect(
	function(InputObject)

		if InputObject.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			SetFOVFromMouse(
				InputObject.Position.X
			)

		end

	end
)

--========================================================--
-- KNOB DRAG
--========================================================--

AimlockFOVKnob.InputBegan:Connect(
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

						SetFOVFromMouse(
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

						if Moving then
							Moving:Disconnect()
						end

						if Released then
							Released:Disconnect()
						end

					end

				end
			)

	end
)

--========================================================--
-- FOV TEXT INPUT
--========================================================--

AimlockFOVInput.FocusLost:Connect(
	function()

		local Value =
			tonumber(
				AimlockFOVInput.Text
			)

		if Value then

			SetAimlockFOV(
				Value
			)

		else

			AimlockFOVInput.Text =
				tostring(
					AimlockFOV
				)

		end

	end
)

--========================================================--
-- INITIAL FOV
--========================================================--

SetAimlockFOV(
	AIMLOCK_DEFAULT_FOV
)

--========================================================--
-- RESET ALL - AIMLOCK ADDITION
--========================================================--

-- Trong ResetEverything() hiện tại của boss man,
-- thêm đoạn này TRƯỚC "end":

StopAimlock()

AimlockButton.Text =
	"AIMLOCK  :  OFF"

SetAimlockFOV(
	AIMLOCK_DEFAULT_FOV
)

--========================================================--
-- CHARACTER RESPAWN SAFETY
--========================================================--

Player.CharacterAdded:Connect(
	function()

		-- Không tự bật lại Aimlock.
		-- Nếu đang bật thì target cũ bị xóa
		-- để hệ thống tìm target mới.

		AimlockTarget = nil

	end
)

--========================================================--
-- PLAYER REMOVING SAFETY
--========================================================--

Players.PlayerRemoving:Connect(
	function(RemovingPlayer)

		if AimlockTarget ==
			RemovingPlayer then

			AimlockTarget = nil

		end

	end
)

--========================================================--
-- FINAL
--========================================================--

print(
	"MK HUB v2.0 | AIMLOCK + FOV READY"
)
