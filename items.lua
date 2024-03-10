return {
    ['bank_card'] = {
		label = 'Bankkarte',
        weight = 3,
		buttons = {
			{
				label = 'PIN entfernen',
				action = function(slot)
					TriggerServerEvent('sav:statebanks:server:removePIN', slot)
				end
			}
		},
		stack = false
	},

	['identity_card'] = {
		label = 'Personalausweis',
		stack = false,
		weight = 2,
	},
}