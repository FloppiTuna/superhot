local function displayContents(manager, root)
    root:addLabel()
        :setText("Loaded disc \"" .. (_G.loadedDisc.label or "Untitled") .. "\".")
        :setPosition(1, 2)

    local trackTable = root:addTable()
        :setPosition(1, 4)
        :setSize(term.getSize(), 13)
        :setColumns({
            {name = "#", width = 4},
            {name = "File", width = 54},
            {name = "Size", width = 6}
        })
        :setBackground(colors.black)
        :setForeground(colors.white)

    -- populate the track list from the blueprint
    for i, file in ipairs(_G.loadedDisc.files or {}) do
        trackTable:addRow(
            tostring(i),
            file.name,
            tostring(file.size)
        )
    end

    root:addLabel()
        :setText("(P)lay File (E)xit")
        :setPosition(1, 18)


end

return displayContents