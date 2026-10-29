local Library = {
	Font = Enum.Font.RobotoCondensed,
	Rainbow = false,
	Tracers = false,
	Unloaded = false,
	ShowDistance = false,
	MatchColors = true,
	Arrows = false,
	TextTransparency = 0,
	TracerOrigin = "Bottom",
	FillTransparency = 0.75,
	OutlineTransparency = 0,
	TextOutlineTransparency = 0,
	FadeTime = 0,
	RenderLimit = 240,
	TracerSize = 0.5,
	ArrowRadius = 200,
	TextSize = 20,
	DistanceSizeRatio = 1,
	OutlineColor = Color3.fromRGB(255, 255, 255),
	RainbowColor = Color3.fromRGB(255, 255, 255),

	ElementsEnabled = {},
	TransparencyEnabled = {},
	Highlights = {},
	Labels = {},
	Frames = {},
	Lines = {},
	ArrowsTable = {},
	ColorTable = {},
	TextTable = {},
	ConnectionsTable = {},
	Objects = {},
	TotalObjects = {},
}

local RainbowState = {
	HueSetup = 0,
	Hue = 0,
	Step = 0,
	Color = Color3.new(),
}

local CloneReference = cloneref or function(O) return O end
local Players = CloneReference(game:GetService("Players"))
local CoreGui = getgenv and CloneReference(game:GetService("CoreGui")) or Players.LocalPlayer.PlayerGui
local Workspace = CloneReference(workspace)
local RunService = CloneReference(game:GetService("RunService"))
local TweenService = CloneReference(game:GetService("TweenService"))
local UserInputService = CloneReference(game:GetService("UserInputService"))
local Debris = CloneReference(game:GetService("Debris"))
local LocalPlayer = Players.LocalPlayer

local function GetHiddenUI()
	if gethui then return gethui() end
	local Folder = Instance.new("Folder", CoreGui)
	Folder.Name = ("%032x"):format(math.random(0, 2^31))
	return Folder
end

function Library:GenerateRandomString()
	local Chars = {}
	local Pool = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local PoolLen = #Pool
	for I = 1, 24 do
		local Idx = math.random(1, PoolLen)
		Chars[I] = Pool:sub(Idx, Idx)
	end
	return table.concat(Chars)
end

local HiddenUI = GetHiddenUI()
local Camera = Workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = Library:GenerateRandomString()
ScreenGui.Parent = HiddenUI

local HighlightsFolder = Instance.new("Folder")
HighlightsFolder.Name = Library:GenerateRandomString()
HighlightsFolder.Parent = ScreenGui

local BillboardsFolder = Instance.new("Folder")
BillboardsFolder.Name = Library:GenerateRandomString()
BillboardsFolder.Parent = ScreenGui

local TracersFrame = Instance.new("Frame")
TracersFrame.Size = UDim2.new(1, 0, 1, 0)
TracersFrame.BackgroundTransparency = 1
TracersFrame.Visible = false
TracersFrame.Name = Library:GenerateRandomString()
TracersFrame.Parent = ScreenGui

local ArrowsFrame = Instance.new("Frame")
ArrowsFrame.Size = UDim2.new(1, 0, 1, 0)
ArrowsFrame.BackgroundTransparency = 1
ArrowsFrame.Visible = false
ArrowsFrame.Name = Library:GenerateRandomString()
ArrowsFrame.Parent = ScreenGui

local ArrowTemplate = Instance.new("ImageLabel")
ArrowTemplate.Image = "rbxassetid://16368985219"
ArrowTemplate.Size = UDim2.new(0, 50, 0, 50)
ArrowTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
ArrowTemplate.BackgroundTransparency = 1
ArrowTemplate.ImageTransparency = 1
local ArrowConstraint = Instance.new("UIAspectRatioConstraint")
ArrowConstraint.AspectRatio = 1
ArrowConstraint.Name = Library:GenerateRandomString()
ArrowConstraint.Parent = ArrowTemplate

local TweenInfoQuad = TweenInfo.new(0, Enum.EasingStyle.Quad)
local function MakeTween(Instance_, Props)
	local Info = TweenInfo.new(Library.FadeTime, Enum.EasingStyle.Quad)
	return TweenService:Create(Instance_, Info, Props)
end

local function PlayTween(Instance_, Props)
	MakeTween(Instance_, Props):Play()
end

local function DestroyObjectData(Object)
	local Highlight = Library.Highlights[Object]
	if Highlight then
		Highlight:Destroy()
		Library.Highlights[Object] = nil
	end

	local Frame = Library.Frames[Object]
	if Frame then
		Frame:Destroy()
		Library.Frames[Object] = nil
	end

	local LineData = Library.Lines[Object]
	if LineData then
		if LineData[1] then LineData[1]:Destroy() end
		Library.Lines[Object] = nil
	end

	local Arrow = Library.ArrowsTable[Object]
	if Arrow then
		Arrow:Destroy()
		Library.ArrowsTable[Object] = nil
	end

	local Conns = Library.ConnectionsTable[Object]
	if Conns then
		for _, Conn in ipairs(Conns) do
			Conn:Disconnect()
		end
		Library.ConnectionsTable[Object] = nil
	end

	Library.Labels[Object] = nil
	Library.ColorTable[Object] = nil
	Library.TextTable[Object] = nil
	Library.ElementsEnabled[Object] = nil
	Library.TransparencyEnabled[Object] = nil
	Library.Objects[Object] = nil

	for Idx = #Library.TotalObjects, 1, -1 do
		if Library.TotalObjects[Idx] == Object then
			table.remove(Library.TotalObjects, Idx)
			break
		end
	end
end

function Library:AddESP(Parameters)
	local Object = Parameters.Object
	if Library.ElementsEnabled[Object] == true or Library.Unloaded == true then return end
	if not Object:IsA("BasePart") and not Object:IsA("Model") then return end

	Library.ElementsEnabled[Object] = true
	Library.TransparencyEnabled[Object] = false
	Library.ConnectionsTable[Object] = Library.ConnectionsTable[Object] or {}

	if Library.Highlights[Object] then
		Library.Highlights[Object]:Destroy()
		Library.Highlights[Object] = nil
	end

	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.Name = Library:GenerateRandomString()
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Adornee = Object
	Highlight.Parent = HighlightsFolder
	Library.Highlights[Object] = Highlight

	local TextFrame = Instance.new("Frame")
	TextFrame.Visible = false
	TextFrame.Name = Library:GenerateRandomString()
	TextFrame.Size = UDim2.fromScale(1, 1)
	TextFrame.BackgroundTransparency = 1
	TextFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	TextFrame.Parent = BillboardsFolder

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Name = Library:GenerateRandomString()
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = Parameters.Text
	TextLabel.TextTransparency = 1
	TextLabel.TextStrokeTransparency = Library.TextOutlineTransparency
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Font = Library.Font
	TextLabel.TextSize = Library.TextSize
	TextLabel.RichText = true
	TextLabel.TextColor3 = Parameters.Color
	TextLabel.Parent = TextFrame

	Library.Frames[Object] = TextFrame
	Library.Labels[Object] = TextLabel
	Library.ColorTable[Object] = Parameters.Color
	Library.TextTable[Object] = Parameters.Text
	Library.Objects[Object] = Object
	table.insert(Library.TotalObjects, Object)

	PlayTween(Highlight, { FillTransparency = Library.FillTransparency })
	PlayTween(Highlight, { OutlineTransparency = Library.OutlineTransparency })

	local TextFadeIn = MakeTween(TextLabel, { TextTransparency = Library.TextTransparency })
	TextFadeIn.Completed:Once(function()
		Library.TransparencyEnabled[Object] = true
	end)
	TextFadeIn:Play()
	PlayTween(TextLabel, { TextStrokeTransparency = Library.TextOutlineTransparency })

	local LineFrame = Instance.new("Frame")
	LineFrame.Size = UDim2.new(0, 0, 0, 0)
	LineFrame.BackgroundTransparency = 1
	LineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	LineFrame.Name = Library:GenerateRandomString()
	LineFrame.Parent = TracersFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = Library.TracerSize
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Transparency = 1
	Stroke.Name = Library:GenerateRandomString()
	Stroke.Parent = LineFrame

	PlayTween(LineFrame, { BackgroundTransparency = 0 })
	PlayTween(Stroke, { Transparency = 0 })
	Library.Lines[Object] = { LineFrame, Stroke }

	task.spawn(function()
		local Last = 0
		local MinInterval = 1 / Library.RenderLimit

		local function Render()
			if not Object or not Object:IsDescendantOf(game) then
				Library:RemoveESP(Object)
				return
			end

			local ObjectPos = Object:GetPivot().Position
			local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(ObjectPos)

			local Frame = Library.Frames[Object]
			local Label = Library.Labels[Object]
			local CachedHighlight = Library.Highlights[Object]
			local LineData = Library.Lines[Object]

			if LineData and LineData[1] then
				LineData[1].Visible = OnScreen
			end

			if Frame then
				Frame.Visible = OnScreen
				if OnScreen then
					Frame.Position = UDim2.new(0, ScreenPoint.X, 0, ScreenPoint.Y)
				end
			end

			if not OnScreen then
				if CachedHighlight then
					CachedHighlight:Destroy()
					Library.Highlights[Object] = nil
					CachedHighlight = nil
				end
			elseif Library.ElementsEnabled[Object] == true and not CachedHighlight then
				CachedHighlight = Instance.new("Highlight")
				CachedHighlight.FillTransparency = 1
				CachedHighlight.OutlineTransparency = 1
				CachedHighlight.Name = Library:GenerateRandomString()
				CachedHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				CachedHighlight.Adornee = Object
				CachedHighlight.Parent = HighlightsFolder
				Library.Highlights[Object] = CachedHighlight
			end

			local ActiveColor = Library.Rainbow and RainbowState.Color or Library.ColorTable[Object] or Color3.fromRGB(255, 255, 255)

			if Label then
				Label.TextColor3 = ActiveColor
			end

			if CachedHighlight then
				local Distance = math.floor((Camera.CFrame.Position - ObjectPos).Magnitude)
				local DistanceText = Library.ShowDistance
					and ("\n" .. '<font size="' .. math.round(Library.TextSize * Library.DistanceSizeRatio) .. '">[' .. Distance .. ']</font>')
					or ""
				if Label then
					Label.Text = Library.TextTable[Object] .. DistanceText
				end

				CachedHighlight.Enabled = true
				CachedHighlight.FillColor = ActiveColor
				CachedHighlight.OutlineColor = Library.MatchColors and ActiveColor or Library.OutlineColor

				if Library.TransparencyEnabled[Object] == true then
					CachedHighlight.FillTransparency = Library.FillTransparency
					CachedHighlight.OutlineTransparency = Library.OutlineTransparency
					if Label then
						Label.TextTransparency = Library.TextTransparency
						Label.TextStrokeTransparency = Library.TextOutlineTransparency
					end
				end
			end

			if LineData and CachedHighlight and Library.Tracers == true and OnScreen then
				local ScreenSize = Camera.ViewportSize
				local Origin

				if Library.TracerOrigin == "Center" then
					Origin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
				elseif Library.TracerOrigin == "Top" then
					Origin = Vector2.new(ScreenSize.X / 2, 0)
				elseif Library.TracerOrigin == "Mouse" then
					local MouseLoc = UserInputService:GetMouseLocation()
					Origin = Vector2.new(LocalPlayer:GetMouse().X, MouseLoc.Y)
				else
					Origin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y)
				end

				local Destination = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
				local MidPoint = (Origin + Destination) / 2
				local Rotation = math.deg(math.atan2(Destination.Y - Origin.Y, Destination.X - Origin.X))
				local Length = (Origin - Destination).Magnitude
				local LF = LineData[1]
				local SK = LineData[2]

				LF.Position = UDim2.new(0, MidPoint.X, 0, MidPoint.Y)
				LF.Size = UDim2.new(0, Length, 0, 1)
				LF.Rotation = Rotation
				LF.BackgroundColor3 = ActiveColor
				LF.BorderSizePixel = 0
				LF.Visible = true
				SK.Color = ActiveColor
				SK.Thickness = Library.TracerSize
			end

			if Library.Arrows == true then
				local Arrow = Library.ArrowsTable[Object]
				if Arrow == nil and Library.ElementsEnabled[Object] == true then
					Arrow = ArrowTemplate:Clone()
					Arrow.Name = Library:GenerateRandomString()
					Arrow:WaitForChild(ArrowConstraint.Name, 5)
					Arrow.Parent = ArrowsFrame
					Library.ArrowsTable[Object] = Arrow
					PlayTween(Arrow, { ImageTransparency = 0 })
				elseif Arrow and Library.ElementsEnabled[Object] == true then
					if OnScreen and ScreenPoint.Z > 0 then
						Arrow.Visible = false
					else
						local ScreenSize = Camera.ViewportSize
						local ScreenCenter = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
						local ToObj = (ObjectPos - Camera.CFrame.Position).Unit
						local Dir = Vector2.new(ScreenPoint.X, ScreenPoint.Y) - ScreenCenter
						if Camera.CFrame.LookVector:Dot(ToObj) < 0 then
							Dir = -Dir
						end
						local Angle = math.atan2(Dir.Y, Dir.X)
						local Radius = math.min(ScreenSize.X, ScreenSize.Y) / 2 - (400 - Library.ArrowRadius)
						local ArrowPos = ScreenCenter + Dir.Unit * Radius

						Arrow.Position = UDim2.new(0, ArrowPos.X, 0, ArrowPos.Y)
						Arrow.Rotation = math.deg(Angle) - 90
						Arrow.Visible = true
						Arrow.ImageColor3 = Library.Rainbow and Library.RainbowColor or Library.ColorTable[Object]
					end
				end
			end
		end

		local Connection
		Connection = RunService.Heartbeat:Connect(function(Delta)
			Last = Last + Delta
			if Last >= 1 / Library.RenderLimit then
				Last = 0
				if Library.ElementsEnabled[Object] ~= true then
					Connection:Disconnect()
					return
				end
				Render()
			end
		end)
		table.insert(Library.ConnectionsTable[Object], Connection)
	end)
end

function Library:RemoveESP(Object)
	if Library.Unloaded == true or Library.ElementsEnabled[Object] ~= true then return end
	Library.ElementsEnabled[Object] = false
	Library.TransparencyEnabled[Object] = false

	local Label = Library.Labels[Object]
	if Label then
		PlayTween(Label, { TextTransparency = 1 })
	end

	local LineData = Library.Lines[Object]
	if LineData then
		if LineData[1] then PlayTween(LineData[1], { BackgroundTransparency = 1 }) end
		if LineData[2] then PlayTween(LineData[2], { Transparency = 1 }) end
	end

	local Highlight = Library.Highlights[Object]
	if Highlight then
		PlayTween(Highlight, { FillTransparency = 1 })
		PlayTween(Highlight, { OutlineTransparency = 1 })
	end

	local Arrow = Library.ArrowsTable[Object]
	if Arrow then
		PlayTween(Arrow, { ImageTransparency = 1 })
	end

	local FadeTime = Library.FadeTime

	if not Object.Parent then
		task.delay(FadeTime + 0.05, function()
			if Library.ElementsEnabled[Object] == false then
				DestroyObjectData(Object)
			end
		end)
	else
		task.delay(FadeTime + 0.05, function()
			if Library.ElementsEnabled[Object] == false then
				DestroyObjectData(Object)
			else
				local ReHighlight = Library.Highlights[Object]
				if ReHighlight then
					PlayTween(ReHighlight, { FillTransparency = Library.FillTransparency })
					PlayTween(ReHighlight, { OutlineTransparency = Library.OutlineTransparency })
				end
			end
		end)
	end
end

function Library:UpdateObjectText(Object, Text)
	if Library.TextTable[Object] ~= nil then
		Library.TextTable[Object] = Text
	end
end

function Library:UpdateObjectColor(Object, Color)
	Library.ColorTable[Object] = Color
	if Library.Labels[Object] and Library.Rainbow ~= true then
		Library.Labels[Object].TextColor3 = Color
	end
end

function Library:SetColorTable(Name, Color)
	Library.ColorTable[Name] = Color
end

function Library:SetFadeTime(Number)
	Library.FadeTime = Number
end

function Library:SetRenderLimit(Number)
	Library.RenderLimit = Number
end

function Library:SetTextTransparency(Number)
	Library.TextTransparency = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextTransparency = Number
	end
end

function Library:SetFillTransparency(Number)
	Library.FillTransparency = Number
	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.FillTransparency = Number
		end
	end
end

function Library:SetOutlineTransparency(Number)
	Library.OutlineTransparency = Number
	for _, Highlight in pairs(Library.Highlights) do
		if Highlight:IsA("Highlight") then
			Highlight.OutlineTransparency = Number
		end
	end
end

function Library:SetTextSize(Number)
	Library.TextSize = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextSize = Number
	end
end

function Library:SetTextOutlineTransparency(Number)
	Library.TextOutlineTransparency = Number
	for _, Label in pairs(Library.Labels) do
		Label.TextStrokeTransparency = Number
	end
end

function Library:SetFont(Font)
	Library.Font = Font
	for _, Label in pairs(Library.Labels) do
		Label.Font = Font
	end
end

function Library:SetOutlineColor(Color)
	Library.OutlineColor = Color
end

function Library:SetRainbow(Value)
	Library.Rainbow = Value
end

function Library:SetShowDistance(Value)
	Library.ShowDistance = Value
end

function Library:SetMatchColors(Value)
	Library.MatchColors = Value
end

function Library:SetTracers(Value)
	Library.Tracers = Value
	TracersFrame.Visible = Value
end

function Library:SetArrows(Value)
	Library.Arrows = Value
	ArrowsFrame.Visible = Value
end

function Library:SetArrowRadius(Value)
	Library.ArrowRadius = Value
end

function Library:SetTracerOrigin(Value)
	Library.TracerOrigin = Value
end

function Library:SetDistanceSizeRatio(Value)
	Library.DistanceSizeRatio = Value
end

function Library:SetTracerSize(Value)
	Library.TracerSize = 0.5 * Value
end

function Library:Unload()
	if Library.Unloaded then return end
	Library.Unloaded = true
	for _, Object in pairs(Library.Objects) do
		Library:RemoveESP(Object)
	end
	for _, Conns in pairs(Library.ConnectionsTable) do
		for _, Conn in ipairs(Conns) do
			Conn:Disconnect()
		end
	end
	RainbowConnection:Disconnect()
	CameraConnection:Disconnect()
	ScreenGui.Enabled = false
end

RainbowConnection = RunService.RenderStepped:Connect(function(Delta)
	RainbowState.Step = RainbowState.Step + Delta
	if RainbowState.Step >= (1 / 60) then
		RainbowState.Step = 0
		RainbowState.HueSetup = RainbowState.HueSetup + (1 / 400)
		if RainbowState.HueSetup > 1 then RainbowState.HueSetup = 0 end
		RainbowState.Hue = RainbowState.HueSetup
		RainbowState.Color = Color3.fromHSV(RainbowState.Hue, 0.8, 1)
		Library.RainbowColor = RainbowState.Color
	end
end)

CameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = Workspace.CurrentCamera
end)

if getgenv then
	getgenv().ESPLibrary = Library
end

return Library
