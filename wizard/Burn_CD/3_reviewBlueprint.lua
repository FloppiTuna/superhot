local setView = require "utils.setView"
local function reviewBlueprint(manager, root)
    root:addLabel()
        :setText("\"" .. _G.discBlueprint.label .. "\" will contain...")
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
    for i, file in ipairs(_G.discBlueprint.files or {}) do
        trackTable:addRow(
            tostring(i),
            file.name,
            tostring(file.size)
        )
    end

    root:addLabel()
        :setText("(B)urn CD  (A)dd More Files  (Q)uit")
        :setPosition(1, 18)

    while true do
        local event, key = os.pullEvent("key")
        if key == keys.b then
            -- Burn CD logic
            setView(manager, root, require("wizard.Burn_CD.4_burnCD"))
            break
        elseif key == keys.a then
            -- Add more files logic
            setView(manager, root, require("wizard.Burn_CD.2_addFiles"))
            break
        elseif key == keys.q then
            -- Quit logic
            shell.exit()
            break
        end
    end
end

return reviewBlueprint