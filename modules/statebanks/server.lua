lib.callback.register('sav:statebanks:server:requestBankCard', function (source, identificationData, bankCard)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local money = xPlayer.getMoney()
    if money < bankCard.price then
        return lib.notify(playerId, {
            description = locale('not_enough_money', locale('money'), bankCard.price - money),
            type = 'error'
        })
    end

    -- TODO: SQL
end)