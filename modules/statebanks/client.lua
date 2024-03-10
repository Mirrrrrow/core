local function requestBankCard(statebank)
    local hasPlayerIdentificationCard, identificationData = lib.callback.await('sav:identification:server:hasIdentificationCard', false, true)
    if not hasPlayerIdentificationCard then
        return lib.notify({
            description = locale('identification_missing'),
            type = 'error'
        })
    end

    local alert = lib.alertDialog({
        header = locale('statebank_request_bank_card_alert_header', statebank.bankCard.price),
        content = locale('statebank_request_bank_card_alert_content', LocalPlayer.state.name, statebank.bankCard.price),
        centered = true,
        cancel = true,
        size = 'xl',
    })

    if alert == 'cancel' then return end

    local success, message = lib.callback.await('sav:statebanks:server:requestBankCard', false, identificationData, statebank.bankCard)
    lib.notify({
        description = message,
        type = success and 'success' or 'error'
    })
end

for _, statebank in pairs(lib.load('data.statebanks')) do
    local ped = Client.spawnPed(statebank.model, statebank.pos, statebank.scenario)
    local _ = Client.createBlip(statebank.sprite, .69, statebank.colour, statebank.name, statebank.pos)

    exports.ox_target:addLocalEntity(ped --[[@as number]], {
        label = locale('statebank_request_bank_card'),
        icon = 'fas fa-credit-card',
        onSelect = function ()
            requestBankCard(statebank)
        end
    })
end