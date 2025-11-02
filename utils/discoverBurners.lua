local function discoverBurners()
    local devices = peripheral.getNames()
    local burners = {}

    for _, name in ipairs(devices) do
        if peripheral.getType(name) == "cd_player" then
            table.insert(burners, peripheral.wrap(name))
        end
    end

    return burners
end

return discoverBurners