-- VARIABLES --
local heartbeat = game:GetService("RunService").Heartbeat
local cameraShaker = require(game:GetService("ReplicatedStorage").Util.CameraShaker)
local combatFrameworkRequire = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local combatFramework = debug.getupvalue(combatFrameworkRequire, 2)
local attackConnection

-- FUNCTIONS --
local function updateController()
    local combatFrameworkAC = combatFramework.activeController

    if combatFrameworkAC and combatFrameworkAC.equipped then
        combatFrameworkAC.timeToNextAttack = -1
        combatFrameworkAC.hitboxMagnitude = 350
        combatFrameworkAC.attacking = false
        combatFrameworkAC.blocking = false
    end
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
