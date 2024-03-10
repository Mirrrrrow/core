for _, elevator in pairs(lib.load('data.elevators')) do
    Client.createBlip(58, 0.5, 5, elevator.opt.label, elevator.originalPosition)
end