local ox_inventory = exports.ox_inventory
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

    metadata.description = ('Besitzer: %s  \nKartennummer: %s  \nAusstellungsdatum: %s  \n**PIN: %s**'):format(
        metadata.cardName, metadata.cardNumber, metadata.dateOfIssue, metadata.cardPin
    )

    if not ox_inventory:CanCarryItem(playerId, bankCard.itemName, 1, metadata) then
        return false, locale('inventory_full')
    end

    xPlayer.removeMoney(bankCard.price)
    ox_inventory:AddItem(playerId, bankCard.itemName, 1, metadata)

    MySQL.insert.await('INSERT INTO bank_cards (id, owner, pin) VALUES (?, ?, ?);', {
        metadata.cardNumber, metadata.cardOwner, metadata.cardPin
    })
    return true, locale('statebank_bank_card_successfully_purchased')
end)

lib.callback.register('sav:statebanks:server:getPlayerBankCards', function (source)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local playerCards = MySQL.query.await('SELECT * FROM bank_cards WHERE owner = ?;', {xPlayer.getIdentifier()})
    return playerCards
end)

lib.callback.register('sav:statebanks:server:changeCardPin', function (source, pin)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false, 'error' end

    MySQL.update.await('UPDATE bank_cards SET pin = ? WHERE owner = ?;', {pin, xPlayer.getIdentifier()})
    return true, locale('statebank_card_pin_changed')
end)

RegisterServerEvent('sav:statebanks:server:removePIN', function (slot)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local item = ox_inventory:GetSlot(playerId, slot)
    if not item then return end
    
    if item.metadata.cardPinRemoved then
        return lib.notify(playerId, {
            description = locale('statebank_pin_already_removed'),
            type = 'error'
        })
    end

    item.metadata.cardPinRemoved = true
    item.metadata.description = ('Besitzer: %s  \nKartennummer: %s  \nAusstellungsdatum: %s'):format(
        item.metadata.cardName, item.metadata.cardNumber, item.metadata.dateOfIssue
    )

    ox_inventory:SetMetadata(playerId, slot, item.metadata)

    return lib.notify(playerId, {description = locale('statebank_pin_removed'), type = 'success'})
end)