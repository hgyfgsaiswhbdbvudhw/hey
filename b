]]

-- written by Emper
-- anyone who has the method can receive this code

-- whoever originally wrote it was trying to optimize it
-- so ill be doing that here
-- although you dont really need to optimize stuff thats
-- not done in loops
-- but ill be doing it anyway since thats what they were trying to do

do
	-- Settings:
	
	local DefaultAnimations = false -- doesnt work in velocity because it doesnt allow u to run localscripts
	local DisableCharacterCollisions = true
	local InstantRespawn = true
	local ParentCharacterToRig = false
	local RigTransparency = 1
	
	--
	
	local CFrameidentity = CFrame.identity
	local Inverse = CFrameidentity.Inverse
	local ToAxisAngle = CFrameidentity.ToAxisAngle
	local ToEulerAnglesXYZ = CFrameidentity.ToEulerAnglesXYZ
	local ToObjectSpace = CFrameidentity.ToObjectSpace
	
	local Connections = {}
	
	local Disconnect = nil
	
	local game = game
	local FindFirstChild = game.FindFirstChild
	local FindFirstChildOfClass = game.FindFirstChildOfClass
	local Players = FindFirstChildOfClass(game, "Players")
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local CharacterAdded = LocalPlayer.CharacterAdded
	local Connect = CharacterAdded.Connect
	local Wait = CharacterAdded.Wait
	local Rig = Players:CreateHumanoidModelFromDescription(Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId), Enum.HumanoidRigType.R6)
	local RigAnimate = Rig.Animate
	local RigHumanoid = Rig.Humanoid -- no need to do waitforchild here, its a safe index
	local RigRootPart = RigHumanoid.RootPart
	local RunService = FindFirstChildOfClass(game, "RunService")
	local Workspace = FindFirstChildOfClass(game, "Workspace")
	local GetDescendants = game.GetDescendants
	local IsA = game.IsA
	local WaitForChild = game.WaitForChild
	
	local BreakJoints = Instance.new("Model").BreakJoints
	
	local mathsin = math.sin

  local next = next
  
	local osclock = os.clock
	
	local replicatesignal = replicatesignal
	
	local RootPartCFrame = nil
	
	local Motor6Ds = {}
	
	local select = select
	
	local sethiddenproperty = sethiddenproperty
	
	local tableinsert = table.insert
	
	local Vector3 = Vector3
	local Vector3new = Vector3.new
	local Vector3zero = Vector3.zero
	
	RigAnimate.Enabled = false	
	
	Rig.Name = LocalPlayer.Name
	RigHumanoid.DisplayName = LocalPlayer.DisplayName -- if theres no display it will be just name so this is fine
	
	if Character then
		if replicatesignal then
			if InstantRespawn then
				replicatesignal(LocalPlayer.ConnectDiedSignalBackend)
				task.wait(Players.RespawnTime - 0.1)
				
				local RootPart = FindFirstChild(Character, "HumanoidRootPart")

				if RootPart then
					RootPartCFrame = RootPart.CFrame
				end
				
				replicatesignal(LocalPlayer.Kill)
			end
		else
			BreakJoints(Character)
		end
	end
	
	Character = Wait(CharacterAdded)
	
	local Animate = WaitForChild(Character, "Animate")
	Animate.Enabled = false

	local RootPart = WaitForChild(Character, "HumanoidRootPart")
	RigRootPart.CFrame = RootPartCFrame or RootPart.CFrame
	
	Disconnect = Connect(RigHumanoid.Died, function()
		for Index, Connection in Connections do
			Disconnect(Connection)
		end
		
		if ParentCharacterToRig then
			Character.Parent = Rig.Parent
		end
		
		BreakJoints(Character)
		Rig:Destroy()
		Mobile:Destroy()
		EmoteGui:Destroy()
		Controls:Destroy()
		Destroyed = true
	end).Disconnect
	
	for Index, Descendant in next, GetDescendants(Character) do
		if IsA(Descendant, "Motor6D") then
			Motor6Ds[Descendant] = {
				Part0 = Rig[Descendant.Part0.Name],
				Part1 = Rig[Descendant.Part1.Name]
			}
		end
	end
	
	for Index, Descendant in next, GetDescendants(Rig) do
		if IsA(Descendant, "BasePart") then
			Descendant.Transparency = RigTransparency
		end
	end
	
	Rig.Parent = Workspace
	
	if ParentCharacterToRig then
		Character.Parent = Rig
	end
	
	task.defer(function()
		local CurrentCamera = Workspace.CurrentCamera
		local CameraCFrame = CurrentCamera.CFrame
		
		LocalPlayer.Character = Rig
		CurrentCamera.CameraSubject = RigHumanoid
		
		Wait(RunService.PreRender)
		Workspace.CurrentCamera.CFrame = CameraCFrame
	end)
	
	tableinsert(Connections, Connect(RunService.PostSimulation, function()
		for Motor6D, Table in next, Motor6Ds do
			local Part0 = Table.Part0
			local Part1CFrame = Table.Part1.CFrame
			
			Motor6D.DesiredAngle = select(3, ToEulerAnglesXYZ(Part1CFrame, Part0.CFrame))
			
			local Delta = Inverse(Motor6D.C0) * ( Inverse(Part0.CFrame) *  Part1CFrame ) * Motor6D.C1
			local Axis, Angle = ToAxisAngle(Delta)
			
			sethiddenproperty(Motor6D, "ReplicateCurrentAngle6D", Axis * Angle)
			sethiddenproperty(Motor6D, "ReplicateCurrentOffset6D", Delta.Position)
		end
		
		RootPart.AssemblyAngularVelocity = Vector3zero
		RootPart.AssemblyLinearVelocity = Vector3zero
		RootPart.CFrame = RigRootPart.CFrame + Vector3new(0, mathsin(osclock() * 15) * 0.004, 0)
	end))
	
	tableinsert(Connections, Connect(RunService.PreSimulation, function()
		for Index, BasePart in next, GetDescendants(Rig) do
			if IsA(BasePart, "BasePart") then
				BasePart.CanCollide = false
			end
		end
		
		if DisableCharacterCollisions and not ParentCharacterToRig then
			for Index, BasePart in next, GetDescendants(Character) do
				if IsA(BasePart, "BasePart") then
					BasePart.CanCollide = false
				end
			end
		end
	end))
end
