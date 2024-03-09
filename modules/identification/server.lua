lib.callback.register('sav:identification:server:hasIdentificationCard', function (source, ownCard)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false, nil end

    local identifier = xPlayer.getIdentifier()
    local items = exports.ox_inventory:Search(playerId, 'slots', 'identity_card')
    if items == nil then return false, nil end

    if #items == 1 then
        local item = items[1]
        if not ownCard then return true, item.metadata end

        return item.metadata.playerIdentifier == identifier, item.metadata
    end

    for _, item in ipairs(items) do
        if item.metadata.playerIdentifier == identifier or not ownCard then
            return true, item.metadata
        end
    end

    return false, nil
end)