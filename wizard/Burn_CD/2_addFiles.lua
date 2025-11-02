local setView = require "utils.setView"
local function addFiles(manager, root)
    root:addLabel()
        :setText("Add music to be burned onto this CD. " .. #_G.discBlueprint.files .. " files added.")
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

    -- resync the track list from the blueprint
    for i, file in ipairs(_G.discBlueprint.files or {}) do
        print("Adding file to table: " .. file.name)
        trackTable:addRow(
            tostring(i),
            file.name,
            tostring(file.size)
        )
    end

    root:addLabel()
        :setText("(A)dd File  (R)emove File  (N)ext")
        :setPosition(1, 18)


    while true do
        local event, key = os.pullEvent("key")
        if key == keys.a then
            -- Add file logic
            setView(manager, root, require("wizard.Burn_CD.2~1_pickFile"))
        elseif key == keys.r then
            -- Remove file logic
            local selectedRow = trackTable:getSelectedRow()
            if selectedRow then
                local fileIndex = tonumber(selectedRow[1])
                table.remove(_G.discBlueprint.files, fileIndex)
                setView(manager, root, require("wizard.Burn_CD.2_addFiles"))
            end
        elseif key == keys.n then
            setView(manager, root, require("wizard.Burn_CD.3_reviewBlueprint"))
            break
        end
    end
    
end
return addFiles