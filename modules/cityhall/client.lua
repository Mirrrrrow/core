local function requestIdentityCard(cityhall)
    if Client.cooldown.lastInteracted then
        return lib.notify({
            description = locale('interaction_cooldown'),
            type = 'error'
        })
    end

    local hasIdentityCard = lib.callback.await('sav:cityhall:server:hasIdentityCard', false)
    if hasIdentityCard then
        return lib.notify({
            description = locale('cityhall_identity_card_already_requested'),
            type = 'error'
        })
    end

    TriggerServerEvent('sav:cityhall:server:requestIdentityCard', cityhall)
    Client.cooldown.lastInteracted = 1000
end

for _, cityhall in pairs(lib.load('data.cityhalls')) do
    local ped = Client.spawnPed(cityhall.model, cityhall.pos, cityhall.scenario)
    local _ = Client.createBlip(cityhall.sprite, .69, cityhall.colour, cityhall.name, cityhall.pos)

    exports.ox_target:addLocalEntity(ped --[[@as number]], {
        label = locale('cityhall_request_identity_card'),
        icon = 'fas fa-id-card-alt',
        onSelect = function ()
            requestIdentityCard(cityhall)
        end
    })
end