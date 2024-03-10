lib.locale()

local cooldowns = {}

CreateThread(function ()
    while true do
        Wait(0)
        for key, endTime in pairs(cooldowns) do
            if endTime < GetGameTimer() then
                cooldowns[key] = nil
            end
        end
    end
end)

Client.cooldown = setmetatable({
    getRemainingTime = function (key)
        if not cooldowns[key] then return 0 end
        return cooldowns[key] and (cooldowns[key] - GetGameTimer()) or 0
    end
}, {
    __index = function (self, key)
        return cooldowns[key] ~= nil
    end,
    __newindex = function (self, key, value)
        if type(value) ~= "number" then print("value must be a number") end
        if cooldowns[key] then lib.print.warn(("cooldown '%s' already exists, overwriting it."):format(key)) end

        cooldowns[key] = GetGameTimer() + value
    end
})

function Client.createBlip(sprite, scale, colour, name, coords)
    local createdBlip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(createdBlip, sprite)
    SetBlipScale(createdBlip, scale)
    SetBlipColour(createdBlip, colour)
    SetBlipAsShortRange(createdBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(createdBlip)

    return createdBlip
end

function Client.spawnPed(hash, coords, scenario)
    local model = lib.requestModel(hash)
    if not model then return end

    local entity = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false ,true)
    if scenario then TaskStartScenarioInPlace(entity, scenario, 0, true) end

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    return entity
end

require 'modules.cityhall.client'
require 'modules.statebanks.client'
require 'modules.elevator.client'
require 'modules.DEVELOPER.client'