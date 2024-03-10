for _, elevatorData in pairs(lib.load('data.elevators')) do
    exports.ox_target:addBoxZone({
        coords = elevatorData.originalPosition,
        size = vec3(1, 1, 3),
        rotation = 0.0,
        options = {
            {
                label = elevatorData.opt.label,
                icon = elevatorData.opt.icon,
                groups = elevatorData.groups,
                onSelect = function ()
                    local goal = elevatorData.endPosition
                    RequestCollisionAtCoord(goal.x, goal.y, goal.z)
                    StartPlayerTeleport(PlayerId(), goal.x, goal.y, goal.z, goal.w, true, true, true)
                end
            }
        },
    })
end