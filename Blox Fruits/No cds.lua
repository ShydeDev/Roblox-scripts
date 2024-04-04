local HOOK_DASH = false
local HOOK_SORU = false

local DASH_COOLDOWN = 0.4 -- DEFAULT
local DASH_DISTANCE = 93.5 -- DEFAULT

-- HANDLES --
local dashHandleAction
local soruHandleAction

-- Getting soru & dash function
for _, obj in getgc(false) do
    if typeof(obj) == "function" then
        local name, source = debug.info(obj, "ns")
        if name == "handleAction" then
            if string.find(source, "Dodge") then
                dashHandleAction = obj
            elseif string.find(source, "Soru") then
                soruHandleAction = obj
            end
        end
    end

    -- Stops loop after found everything
    if dashHandleAction and soruHandleAction then
        break
    end
end

assert(dashHandleAction, "Failed to get dash function :(")
assert(soruHandleAction, "Failed to get soru function :(")

-- Hooking dash function to change upvalues before call
if HOOK_DASH then
    local dashHook
    dashHook = hookfunction(dashHandleAction, function(...)
        debug.setupvalue(dashHook, 6, DASH_COOLDOWN)
        debug.setupvalue(dashHook, 10, DASH_DISTANCE)
        return dashHook(...)
    end)
end

-- Hooking soru function to change upvalues before call
if HOOK_SORU then
    local soruHook
    soruHook = hookfunction(soruHandleAction, function(...)
	    debug.getupvalue(soruHook, 9).LastUse = 0
	    return soruHook(...)
    end)
end
