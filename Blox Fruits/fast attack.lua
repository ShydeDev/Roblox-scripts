-- VARIABLES --
local heartbeat = game:GetService("RunService").Heartbeat
local cameraShaker = require(game:GetService("ReplicatedStorage").Util.CameraShaker)
local combatFrameworkRequire = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local combatFrameworkActiveController = debug.getupvalue(combatFrameworkRequire, 2).activeController
local attackConnection

-- FUNCTIONS --
local function updateController()
    combatFrameworkActiveController.timeToNextAttack = -1
    combatFrameworkActiveController.hitboxMagnitude = 350
    combatFrameworkActiveController.attacking = false
    combatFrameworkActiveController.blocking = false
end

local function fastAttack(enable: boolean)
    if enable then
        cameraShaker:Stop()
        attackConnection = heartbeat:Connect(updateController)
    elseif attackConnection and attackConnection.Connected then
        cameraShaker:Stop()
        attackConnection:Disconnect()
    end
end

-- PLEASE EQUIP A WEAPON BEFORE USE --
fastAttack(true)
