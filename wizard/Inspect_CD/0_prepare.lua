local setView = require "utils.setView"

local function prepare(manager, root)
    root:addLabel()
        :setText("superh0t is preparing to read the CD...")
        :setPosition(1, 2)

    -- if there's just one burner we can skip selection, otherwise send to picker
    if #_G.burners == 1 then
        _G.selectedBurner = _G.burners[1]
        setView(manager, root, require("wizard.Inspect_CD.1_readCD"))
        return
    else
        setView(manager, root, require("wizard.Common.0_pickBurner"))
    end
end

return prepare