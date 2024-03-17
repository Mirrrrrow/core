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

local function changeCardPin(card)
    local input = lib.inputDialog(locale('statebank_manage_card_input_header', card.id), {
        {
            label = locale('statebank_card_pin_input_label'),
            description = locale('statebank_card_pin_input_description'),
            icon = 'fas fa-list-ol',
            type = 'number',
            min = 1000,
            max = 9999
        }
    })

    if not input then return end

    local pin = input[1]
    if not pin then return end

    local success, message = lib.callback.await('sav:statebanks:server:changeCardPin', false, card.id, pin)
    lib.notify({
        description = message,
        type = success and 'success' or 'error'
    })
end

local function manageCard(card)
    local contextId = 'statebank_manage_card_' ..card.id
    lib.registerContext({
        id = contextId,
        title = locale('statebank_manage_card', card.id),
        options = {
            {
                title = locale('menu_back'),
                icon = 'fas fa-arrow-left',
                event = 'sav:statebank:client:manageCards',
            },
            {
                title = locale('statebank_card_change_pin'),
                description = locale('statebank_card_change_pin_description'),
                icon = 'fas fa-key',
                onSelect = function ()
                    changeCardPin(card)
                end
            },
            {
                title = locale('statebank_card_lock_card'),
                description = locale('statebank_card_lock_card_description'),
                icon = 'fas fa-lock',
                onSelect = function ()
                    -- TODO: Lock card
                end
            }
        }
    })
    lib.showContext(contextId)
end

local function manageCards()
    local cards = lib.callback.await('sav:statebanks:server:getPlayerBankCards', false)
    local options, n = {}, 0
    for _, card in pairs(cards) do
        n += 1

        ---@type ContextMenuItem
        local option = {
            title = tostring(card.id),
            icon = 'fas fa-credit-card',
            disabled = card.disabled,
            onSelect = function ()
                manageCard(card)
            end
        }

        options[n] = option
    end

    lib.registerContext({
        id = 'statebank_manage_cards',
        title = locale('statebank_manage_cards'),
        options = options
    })
    lib.showContext('statebank_manage_cards')
end

CreateThread(function ()
    for _, statebank in pairs(lib.load('data.statebanks')) do
        local ped = Client.spawnPed(statebank.model, statebank.pos, statebank.scenario)
        local _ = Client.createBlip(statebank.sprite, .69, statebank.colour, statebank.name, statebank.pos)
    
        exports.ox_target:addLocalEntity(ped --[[@as number]], {
            {
                label = locale('statebank_request_bank_card'),
                icon = 'fas fa-credit-card',
                onSelect = function ()
                    requestBankCard(statebank)
                end
            },
            {
                label = locale('statebank_manage_cards'),
                icon = 'fas fa-credit-card',
                onSelect = function ()
                    manageCards()
                end
            }
        })
    end
end)

AddEventHandler('sav:statebank:client:manageCards', function ()
    manageCards()
end)