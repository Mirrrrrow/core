local function hasGotIdentityCard(identifier)
    return MySQL.scalar.await('SELECT has_identity_card FROM users WHERE identifier = ?', {identifier})
end

local function generateMetadata(xPlayer, state)
    local result = MySQL.query.await("SELECT dateofbirth, sex FROM users WHERE identifier = ? LIMIT 1;", { xPlayer.getIdentifier() })
    result = result[1] or {}

    local metadata = {
        playerName = xPlayer.getName(),
        playerSex = result.sex == 'm' and 'Männlich' or 'Weiblich',
        playerDOB = result.dateofbirth,
        playerIdentifier = xPlayer.getIdentifier(),
        playerNationality = state.. ', San Andreas',
        dateOfIssue = os.date('%d/%m/%Y')
    }

    metadata.description = ('Name: %s  \n Geschlecht: %s  \nGeburtsdatum: %s  \nAngehörigkeit: %s  \nAusstellungsdatum: %s'):format(
        metadata.playerName, metadata.playerSex, metadata.playerDOB, metadata.playerNationality, metadata.dateOfIssue
    )

    return metadata
end

lib.callback.register('sav:cityhall:server:hasIdentityCard', function (source)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    return hasGotIdentityCard(xPlayer.getIdentifier())
end)

local ox_inv = exports.ox_inventory
RegisterServerEvent('sav:cityhall:server:requestIdentityCard', function (cityhall)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local identifier = xPlayer.getIdentifier()
    if hasGotIdentityCard(identifier) then return end

    local metadata = generateMetadata(xPlayer, cityhall.state)
    if not ox_inv:CanCarryItem(playerId, cityhall.itemName, 1, metadata) then
        return lib.notify(playerId, {
            description = locale('inventory_full'),
            type = 'error'
        })
    end

    ox_inv:AddItem(playerId, cityhall.itemName, 1, metadata)
    lib.notify(playerId, {
        description = locale('cityhall_identity_card_received'),
        type = 'success'
    })

    MySQL.update.await('UPDATE users SET has_identity_card = true WHERE identifier = ?', {identifier})
end)