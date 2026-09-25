print("Zot is still awake.")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local env=getgenv and getgenv() or _G
local AFKEvent=ReplicatedStorage:WaitForChild("AFKEvent")

local targetParent=playerGui

pcall(function()
	if gethui then
		targetParent=gethui()
	end
end)

if env.UntitledDriftAFKCleanup then
	pcall(env.UntitledDriftAFKCleanup)
end

for _,parent in ipairs({targetParent,playerGui}) do
	local old=parent:FindFirstChild("UntitledDriftAFKUI")
	if old then
		old:Destroy()
	end
end

local WINDOW=Color3.fromRGB(0,0,0)
local WINDOW_STROKE=Color3.fromRGB(45,45,50)
local PANEL=Color3.fromRGB(18,18,22)
local PANEL_STROKE=Color3.fromRGB(32,32,36)
local TEXT=Color3.fromRGB(240,240,245)
local MUTED=Color3.fromRGB(120,120,130)

local FULL_WIDTH=360
local FULL_HEIGHT=112
local COLLAPSED_HEIGHT=38

local connections={}
local destroyed=false
local collapsed=false
local enabled=true
local sizeTween=nil

env.UntitledDriftAFKEvent=AFKEvent
env.UntitledDriftAFKSession=(env.UntitledDriftAFKSession or 0)+1

local session=env.UntitledDriftAFKSession

if not env.UntitledDriftAFKHooked then
	local oldNamecall

	oldNamecall=hookmetamethod(
		game,
		"__namecall",
		newcclosure(function(self,...)
			local args={...}
			local method=getnamecallmethod()

			if env.StayAFK
				and method=="FireServer"
				and self==env.UntitledDriftAFKEvent
				and args[1]==false then

				return
			end

			return oldNamecall(self,...)
		end)
	)

	env.UntitledDriftAFKHooked=true
end

local function connect(signal,callback)
	local connection=signal:Connect(callback)
	table.insert(connections,connection)
	return connection
end

local function corner(object,radius)
	local c=Instance.new("UICorner",object)
	c.CornerRadius=UDim.new(0,radius)
	return c
end

local function stroke(object,color,thickness)
	local s=Instance.new("UIStroke",object)
	s.Color=color
	s.Thickness=thickness
	s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	return s
end

local gui=Instance.new("ScreenGui")
gui.Name="UntitledDriftAFKUI"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=targetParent

local function setAFK(state)
	enabled=state
	env.StayAFK=state

	pcall(function()
		AFKEvent:FireServer(state,0)
	end)
end

local function cleanup()
	if destroyed then
		return
	end

	destroyed=true
	setAFK(false)

	env.UntitledDriftAFKSession=
		(env.UntitledDriftAFKSession or session)+1

	if sizeTween then
		pcall(function()
			sizeTween:Cancel()
		end)
	end

	for _,connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(connections)

	pcall(function()
		gui:Destroy()
	end)

	if env.UntitledDriftAFKCleanup==cleanup then
		env.UntitledDriftAFKCleanup=nil
	end
end

env.UntitledDriftAFKCleanup=cleanup

local function makeDraggable(dragHandle,targetFrame)
	targetFrame=targetFrame or dragHandle

	local dragging=false
	local dragStart
	local startPos

	connect(dragHandle.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1
			or input.UserInputType==Enum.UserInputType.Touch then

			dragging=true
			dragStart=input.Position

			startPos=Vector2.new(
				targetFrame.Position.X.Offset,
				targetFrame.Position.Y.Offset
			)
		end
	end)

	connect(UIS.InputChanged,function(input)
		if not dragging then
			return
		end

		if input.UserInputType~=Enum.UserInputType.MouseMovement
			and input.UserInputType~=Enum.UserInputType.Touch then
			return
		end

		local camera=Workspace.CurrentCamera
		if not camera then
			return
		end

		local delta=input.Position-dragStart
		local size=targetFrame.AbsoluteSize
		local viewport=camera.ViewportSize
		local topOffset=-57
		local bottomOffset=57

		local x=math.clamp(
			startPos.X+delta.X,
			0,
			math.max(
				0,
				viewport.X-size.X
			)
		)

		local y=math.clamp(
			startPos.Y+delta.Y,
			topOffset,
			math.max(
				topOffset,
				viewport.Y-size.Y-bottomOffset
			)
		)

		targetFrame.Position=UDim2.fromOffset(x,y)
	end)

	connect(UIS.InputEnded,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1
			or input.UserInputType==Enum.UserInputType.Touch then

			dragging=false
		end
	end)
end

local main=Instance.new("Frame",gui)
main.Name="SlateWindow_UntitledDriftAFK"
main.Size=UDim2.fromOffset(FULL_WIDTH,FULL_HEIGHT)
main.BackgroundColor3=WINDOW
main.BorderSizePixel=0
main.ClipsDescendants=true
main.Active=true

corner(main,10)
stroke(main,WINDOW_STROKE,1.2)

local camera=Workspace.CurrentCamera

if camera then
	local viewport=camera.ViewportSize

	main.Position=UDim2.fromOffset(
		math.floor((viewport.X-FULL_WIDTH)/2),
		math.floor((viewport.Y-FULL_HEIGHT)/2)
	)
else
	main.Position=UDim2.new(.5,-180,.5,-56)
end

local header=Instance.new("Frame",main)
header.Name="HeaderBar"
header.Size=UDim2.new(1,0,0,38)
header.BackgroundTransparency=1
header.BorderSizePixel=0
header.Active=true

local title=Instance.new("TextLabel",header)
title.Text="Drift AFK"
title.TextSize=20
title.TextColor3=TEXT
title.FontFace=Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
title.Position=UDim2.fromOffset(12,0)
title.Size=UDim2.new(0,140,1,0)
title.BackgroundTransparency=1
title.TextXAlignment=Enum.TextXAlignment.Left

local switchHolder=Instance.new("TextButton",header)
switchHolder.Size=UDim2.fromOffset(95,24)
switchHolder.Position=UDim2.new(1,-173,0,7)
switchHolder.BackgroundTransparency=1
switchHolder.BorderSizePixel=0
switchHolder.Text=""
switchHolder.AutoButtonColor=false

local switchLabel=Instance.new("TextLabel",switchHolder)
switchLabel.Size=UDim2.fromOffset(50,24)
switchLabel.BackgroundTransparency=1
switchLabel.Text="Active"
switchLabel.TextSize=11
switchLabel.TextColor3=TEXT
switchLabel.FontFace=Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
switchLabel.TextXAlignment=Enum.TextXAlignment.Right

local switchTrack=Instance.new("Frame",switchHolder)
switchTrack.Size=UDim2.fromOffset(30,16)
switchTrack.Position=UDim2.new(1,-34,.5,-8)
switchTrack.BackgroundColor3=Color3.fromRGB(255,255,255)
switchTrack.BorderSizePixel=0

corner(switchTrack,8)

local switchStroke=stroke(
	switchTrack,
	Color3.fromRGB(220,220,225),
	1
)

local switchThumb=Instance.new("Frame",switchTrack)
switchThumb.Size=UDim2.fromOffset(12,12)
switchThumb.Position=UDim2.new(1,-14,.5,-6)
switchThumb.BackgroundColor3=Color3.fromRGB(18,18,22)
switchThumb.BorderSizePixel=0

corner(switchThumb,6)

local minimizeBtn=Instance.new("TextButton",header)
minimizeBtn.Size=UDim2.fromOffset(20,20)
minimizeBtn.Position=UDim2.new(1,-52,0,9)
minimizeBtn.BackgroundTransparency=1
minimizeBtn.BorderSizePixel=0
minimizeBtn.AutoButtonColor=false
minimizeBtn.Text="—"
minimizeBtn.TextSize=16
minimizeBtn.TextColor3=Color3.fromRGB(150,150,160)
minimizeBtn.Font=Enum.Font.GothamBold
minimizeBtn.ZIndex=20

local closeBtn=Instance.new("TextButton",header)
closeBtn.Size=UDim2.fromOffset(20,20)
closeBtn.Position=UDim2.new(1,-28,0,9)
closeBtn.BackgroundTransparency=1
closeBtn.BorderSizePixel=0
closeBtn.AutoButtonColor=false
closeBtn.Text="X"
closeBtn.TextSize=14
closeBtn.TextColor3=Color3.fromRGB(150,150,160)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.ZIndex=20

local function headerHover(button)
	connect(button.MouseEnter,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=TEXT}
		):Play()
	end)

	connect(button.MouseLeave,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=Color3.fromRGB(150,150,160)}
		):Play()
	end)
end

headerHover(minimizeBtn)
headerHover(closeBtn)

makeDraggable(header,main)

local function animateToggle(state)
	if state then
		TweenService:Create(
			switchTrack,
			TweenInfo.new(
				.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				BackgroundColor3=Color3.fromRGB(255,255,255)
			}
		):Play()

		TweenService:Create(
			switchStroke,
			TweenInfo.new(.2),
			{
				Color=Color3.fromRGB(220,220,225)
			}
		):Play()

		TweenService:Create(
			switchThumb,
			TweenInfo.new(
				.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Position=UDim2.new(1,-14,.5,-6),
				BackgroundColor3=Color3.fromRGB(18,18,22)
			}
		):Play()

		switchLabel.Text="Active"
		switchLabel.TextColor3=TEXT
	else
		TweenService:Create(
			switchTrack,
			TweenInfo.new(.2),
			{
				BackgroundColor3=Color3.fromRGB(32,32,38)
			}
		):Play()

		TweenService:Create(
			switchStroke,
			TweenInfo.new(.2),
			{
				Color=Color3.fromRGB(50,50,58)
			}
		):Play()

		TweenService:Create(
			switchThumb,
			TweenInfo.new(
				.2,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Position=UDim2.new(0,2,.5,-6),
				BackgroundColor3=Color3.fromRGB(130,130,140)
			}
		):Play()

		switchLabel.Text="Disabled"
		switchLabel.TextColor3=MUTED
	end
end

connect(switchHolder.MouseButton1Click,function()
	setAFK(not enabled)
	animateToggle(enabled)
end)

local content=Instance.new("Frame",main)
content.Name="Content"
content.Position=UDim2.new(0,10,0,42)
content.Size=UDim2.new(1,-20,1,-50)
content.BackgroundTransparency=1

local panel=Instance.new("Frame",content)
panel.Size=UDim2.new(1,0,1,0)
panel.BackgroundColor3=PANEL
panel.BorderSizePixel=0

corner(panel,9)
stroke(panel,PANEL_STROKE,1)

local description=Instance.new("TextLabel",panel)
description.Position=UDim2.fromOffset(10,0)
description.Size=UDim2.new(1,-20,1,0)
description.BackgroundTransparency=1
description.Text="Keeps Untitled Drift Game's AFK state enabled."
description.TextColor3=MUTED
description.TextSize=11
description.Font=Enum.Font.GothamMedium
description.TextXAlignment=Enum.TextXAlignment.Left

local function clampMain(height)
	local currentCamera=Workspace.CurrentCamera
	if not currentCamera then
		return
	end

	local viewport=currentCamera.ViewportSize
	local topOffset=-57
	local bottomOffset=57

	local x=math.clamp(
		main.Position.X.Offset,
		0,
		math.max(
			0,
			viewport.X-FULL_WIDTH
		)
	)

	local y=math.clamp(
		main.Position.Y.Offset,
		topOffset,
		math.max(
			topOffset,
			viewport.Y-height-bottomOffset
		)
	)

	main.Position=UDim2.fromOffset(x,y)
end

local function setCollapsed(state)
	if collapsed==state then
		return
	end

	collapsed=state

	if sizeTween then
		sizeTween:Cancel()
		sizeTween=nil
	end

	if collapsed then
		content.Visible=false

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(
				.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size=UDim2.fromOffset(
					FULL_WIDTH,
					COLLAPSED_HEIGHT
				)
			}
		)

		sizeTween:Play()
	else
		clampMain(FULL_HEIGHT)

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(
				.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size=UDim2.fromOffset(
					FULL_WIDTH,
					FULL_HEIGHT
				)
			}
		)

		local thisTween=sizeTween

		connect(thisTween.Completed,function()
			if destroyed then
				return
			end

			if not collapsed
				and sizeTween==thisTween
				and main.Parent then

				content.Visible=true
			end
		end)

		thisTween:Play()
	end
end

connect(minimizeBtn.MouseButton1Click,function()
	setCollapsed(not collapsed)
end)

connect(closeBtn.MouseButton1Click,cleanup)

setAFK(true)

task.spawn(function()
	while not destroyed
		and env.StayAFK
		and env.UntitledDriftAFKSession==session do

		pcall(function()
			AFKEvent:FireServer(true,0)
		end)

		task.wait(5)
	end
end)

print("AFK Mode ON")
