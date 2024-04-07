-- GLOBAL SCRIPT SETTINGS --
_G.autoFarm = true
_G.rejoinTime = 15 -- minutes
_G.enableTimeLabel = true
_G.selectedWeaponName = "Electric Claw"

-- GLOBAL FAST ATTACK SETTINGS --
local manualAttack = false -- perfoms clicks by pressing left mouse
_G.fastAttackOptions = { -- perfoms attack by executing a decompiled script
    ["Slow"] = false,
    ["Normal"] = true,
    ["Fast"] = false,
}

-- SCRIPT SETTINGS --
local noClip = false
local fastAttack = false
local rejoinClock = os.clock()

-- VARIABLES --
local client = game:GetService("Players").LocalPlayer

-- TWEEN VARIABLES --
local currentTween, tweenDiedConn

-- SERVICES --
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local virtualUser = game:GetService("VirtualUser")

-- AUTOFARM VARIABLES --
local questUi = client:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("Quest")
local questTitle = questUi:WaitForChild("Container"):WaitForChild("QuestTitle"):WaitForChild("Title")
local enemyFolder = workspace:WaitForChild("Enemies")
local enemySpawnsFolder = workspace:WaitForChild("_WorldOrigin"):WaitForChild("EnemySpawns")

-- FAST ATTACK VARIABLES --
local cameraShaker = require(replicatedStorage.Util.CameraShaker)
local combatFrameworkRequire = require(client.PlayerScripts.CombatFramework)
local combatFramework = debug.getupvalue(combatFrameworkRequire, 2)

-- SEA VARIALBES --
local seas = {
    [2753915549] = "sea1Quests.json",
    [4442272183] = "sea2Quests.json",
    [7449423635] = "sea3Quests.json"
}

-- QUEST --
local quests = httpService:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/ShydeDev/Roblox-scripts/main/Blox%20Fruits/autoFarm/"..seas[game.PlaceId]))
-- RETURNS: minLevel, maxLevel, monsterName, monsterSpawnName, questLevel, questName, questCFrame (numbers only)

-- FUNCTIONS
-- tween
local TWEEN_SPEED = 250
local function tweenTo(cframe)
    local character = client.Character or client.CharacterAdded:Wait()
    local rootPart = character and character:WaitForChild("HumanoidRootPart")
    if rootPart then
        rootPart.Velocity = Vector3.new(0,0,0)

        local distance = (cframe.Position - rootPart.Position).Magnitude
        local tweenInfo = TweenInfo.new(distance / TWEEN_SPEED, Enum.EasingStyle.Linear)

        currentTween = tweenService:Create(rootPart, tweenInfo, { CFrame = cframe })
        currentTween:Play()

        tweenDiedConn = character.Humanoid.Died:Connect(function()
            currentTween:Cancel()
            client.CharacterAdded:Wait()
            tweenTo(cframe)
        end)
    end
end

local function isTweening()
    return currentTween and currentTween.PlaybackState == "Playing"
end

local function stopTween()
    currentTween:Cancel()
    tweenDiedConn:Disconnect()
end

-- quests
local function determineCurrentQuest(clientLevel)
    for _, quest in quests do
        if clientLevel >= quest.minLevel and clientLevel <= quest.maxLevel then
            return quest
        end
    end
end

local function startQuest(quest)
    tweenTo(CFrame.new(unpack(quest.questCFrame)))

    currentTween.Completed:Once(function()
        replicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.questName, quest.questLevel)
    end)
end

-- equips
local function equipWeapon()
    if client.Backpack:FindFirstChild(_G.selectedWeaponName) then
        local character = client.Character or client.CharacterAdded:Wait()
        character.Humanoid:EquipTool(client.Backpack[_G.selectedWeaponName])
    end
end

local function equipHaki()
    local character = client.Character or client.CharacterAdded:Wait()
    if not character:FindFirstChild("HasBuso") then
        replicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

-- enemy
local function findNearestEnemy(questController)
    if not _G.autoFarm then return end
    local nearestEnemy = nil

    for _, enemy in enemyFolder:GetChildren() do
        if enemy.Name == questController.monsterName then
            local enemyHead = enemy:FindFirstChild("Head")
            local enemyHumanoid = enemy:FindFirstChild("Humanoid")

            if enemyHead or enemyHumanoid then
                if enemyHead.Transparency ~= 1 or enemyHumanoid.Health ~= 0  then
                    local character = client.Character or client.CharacterAdded:Wait()
                    local dist = (character.PrimaryPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist < math.huge then
                        nearestEnemy = enemy
                    end
                end
            end
        end
    end
    return nearestEnemy
end

-- https://scriptblox.com/script/Blox-Fruits-Script-auto-farm-level-auto-update-open-source-8701
local function CurrentWeapon()
	local ac = combatFramework.activeController
	local ret = ac.blades[1]
    local character = client.Character or client.CharacterAdded:Wait()
	if not ret then return character:FindFirstChildOfClass("Tool").Name end

	pcall(function()
		while ret.Parent ~= character do
            ret=ret.Parent
        end
	end)

	if not ret then
        return character:FindFirstChildOfClass("Tool").Name
    end

	return ret
end



local function getAllBladeHits(Sizes)
	local Hits = {}
    local enemies = enemyFolder:GetChildren()

	for i = 1, #enemies do
        local v = enemies[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if Human and Human.RootPart and Human.Health > 0 and client:DistanceFromCharacter(Human.RootPart.Position) < Sizes + 5 then
			table.insert(Hits,Human.RootPart)
		end
	end

	return Hits
end

local function AttackFunction()
	local ac = combatFramework.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getAllBladeHits(60)
			if #bladehit > 0 then

				local AcAttack8 = debug.getupvalue(ac.attack, 5)
				local AcAttack9 = debug.getupvalue(ac.attack, 6)
				local AcAttack7 = debug.getupvalue(ac.attack, 4)
				local AcAttack10 = debug.getupvalue(ac.attack, 7)
				local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
				local NumberAc13 = AcAttack7 * 798405

				(function()
					NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
					AcAttack8 = math.floor(NumberAc12 / AcAttack9)
					AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
				end)()

				AcAttack10 = AcAttack10 + 1

				debug.setupvalue(ac.attack, 5, AcAttack8)
				debug.setupvalue(ac.attack, 6, AcAttack9)
				debug.setupvalue(ac.attack, 4, AcAttack7)
				debug.setupvalue(ac.attack, 7, AcAttack10)

				for _, v in ac.animator.anims.basic do
					v:Play(0.01,0.01,0.01)
				end  

                local character = client.Character or client.CharacterAdded:Wait()
				if character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
					replicatedStorage.RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
					replicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					replicatedStorage.RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end

-- server
local function hopLowest()
    local servers = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"

    local function ListServers(cursor)
       local Raw = game:HttpGet(servers .. ((cursor and "&cursor="..cursor) or ""))
       return httpService:JSONDecode(Raw)
    end

    local Server, Next
    while not Server do
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor

        task.wait()
    end
    
    teleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, client)
end

-- CONNECTIONS --
runService.Stepped:Connect(function()
    local state = not (noClip or isTweening())
    local character = client.Character or client.CharacterAdded:Wait()
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end)

runService.Heartbeat:Connect(function()
    local character = client.Character or client.CharacterAdded:Wait()

    if not _G.autoFarm then
        if character.PrimaryPart:FindFirstChild("BodyClip") then
            character.PrimaryPart:FindFirstChild("BodyClip"):Destroy()
        end
        fastAttack = false
        noClip = false
        return
    end

    local clientHumanoid = character.Humanoid
    if clientHumanoid.Sit then clientHumanoid.Sit = false end

    local questController = determineCurrentQuest(client.Data.Level.Value)
    local questInProgress = string.find(questTitle.Text, questController.monsterName) and questUi.Visible

    if not questInProgress then
        startQuest(questController)
        questInProgress = true
    end
    
    noClip = true
    equipHaki()
    equipWeapon()
    cameraShaker:Stop()

    local nearestEnemy = findNearestEnemy(questController)
    if nearestEnemy then
        tweenTo(nearestEnemy.PrimaryPart.CFrame + Vector3.yAxis * 25)
        if (nearestEnemy.PrimaryPart.Position - character.PrimaryPart.Position).Magnitude <= 55 then

            if manualAttack then
                local ac = combatFramework.activeController
                ac.timeToNextAttack = -1
                ac.hitboxMagnitude = 55
                virtualUser:Button1Down(Vector2.new(1280, 672))
            end

            fastAttack = true
        end
    else
        tweenTo(CFrame.new(unpack(questController.questCFrame)) - Vector3.yAxis * 10)

        for _, spawn in enemySpawnsFolder:GetChildren() do
            if spawn.Name == determineCurrentQuest(client.Data.Level.Value).monsterSpawnName then
                tweenTo(spawn.CFrame + Vector3.yAxis * 50)
            end
        end
    end
end)

-- LOOPS --
task.spawn(function()
    while true do
        local elapsedTime = os.clock() - rejoinClock
        local remainingTime = _G.rejoinTime * 60 - elapsedTime
        if remainingTime <= 0 then
            hopLowest()
        end

        if _G.enableTimeLabel then
            local gui = Instance.new("ScreenGui")
            gui.Parent = client:WaitForChild("PlayerGui")
        
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(0, 340, 0, 70)
            textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)
            textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
            textLabel.TextScaled = true 
            textLabel.Parent = gui

            local minutes = math.floor(remainingTime / 60)
            local seconds = math.floor(remainingTime % 60)
            textLabel.Text = "Remaining time until rejoin: ".. minutes.." minutes, ".. seconds.. " seconds"
        end
        
        task.wait(1)
    end
end)

while true do
    local ac = combatFramework.activeController
    
    if ac and ac.equipped then
        if fastAttack then
            local cooldown = if _G.fastAttackOptions["Slow"] then 0.7 elseif _G.fastAttackOptions["Normal"] then 0.1 else 0.01
            AttackFunction()
            task.wait(cooldown)
        end
    end

    task.wait()
end
