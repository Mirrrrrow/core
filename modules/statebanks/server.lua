lib.callback.register('sav:statebanks:server:requestBankCard', function (source, identificationData, bankCard)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local money = xPlayer.getMoney()
    if money < bankCard.price then
        return false, locale('not_enough_money', locale('money'), bankCard.price - money)
    end

    local metadata = {
        cardName = identificationData.playerName,
        cardOwner = identificationData.playerIdentifier,
        dateOfIssue = os.date('%d/%m/%Y'),
        cardPin = math.random(1000, 9999),
        cardPinRemoved = false,
        cardNumber = math.random(10000000000000, 99999999999999)
    }

    metadata.description = ('Besitzer: %s  \nKartennummer: %s  \n Ausstellungsdatum: %s  \n**PIN: %s**'):format(
        metadata.cardName, metadata.cardNumber, metadata.dateOfIssue, metadata.cardPin
    )

    if not exports.ox_inventory:CanCarryItem(playerId, bankCard.itemName, 1, metadata) then
        return false, locale('inventory_full')
    end

    xPlayer.removeMoney(bankCard.price)
    exports.ox_inventory:AddItem(playerId, bankCard.itemName, 1, metadata)

    -- TODO: SQL
    return true, locale('state_bank_bank_card_successfully_purchased')
end)

RegisterServerEvent('sav:statebanks:server:removePIN', function (slot)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local item = exports.ox_inventory:GetSlot(playerId, slot)
    if not item then return end
    
    if item.metadata.cardPinRemoved then
        return lib.notify(playerId, {
            description = locale('state_bank_pin_already_removed'),
            type = 'error'
        })
    end

    item.metadata.cardPinRemoved = true
    item.metadata.description = ('Besitzer: %s  \nKartennummer: %s  \n Ausstellungsdatum: %s'):format(
        item.metadata.cardName, item.metadata.cardNumber, item.metadata.dateOfIssue
    )

    exports.ox_inventory:SetMetadata(playerId, slot, item.metadata)

    return lib.notify(playerId, {description = locale('state_bank_pin_removed'), type = 'success'})
end)