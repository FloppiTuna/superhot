local setView = require "utils.setView"

local function prepare(manager, root)
    root:addLabel()
        :setText("superh0t is preparing to burn a CD...")
        :setPosition(1, 2)

    -- clear out burn blueprint
    _G.discBlueprint = {
        label = "",
        files = {}
    }

    -- if there's just one burner we can skip selection, otherwise send to picker
    if #_G.burners == 1 then
        _G.selectedBurner = _G.burners[1]
        setView(manager, root, require("wizard.Burn_CD.1_setMetadata"))
        return
    else
        setView(manager, root, require("wizard.Common.0_pickBurner"))
    end
end

return prepare