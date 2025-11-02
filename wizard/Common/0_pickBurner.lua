local function pickBurner(manager, root)
    root:clear()

    root:addLabel()
        :setText("This computer has multiple attached CD burners.")
        :setPosition(1, 2)

    root:addLabel()
        :setText("Please select the burner you wish to use:")
        :setPosition(1, 3)

    for i, burner in ipairs(_G.burners) do
        root:addLabel()
            :setText("[" .. i .. "] " .. tostring(burner))
            :setPosition(1, i + 3)
    end

end

return pickBurner