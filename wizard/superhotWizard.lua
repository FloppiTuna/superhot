local setView = require "utils.setView"
-- superhotWizard, wizard handler for superh0t.

local function superhotWizard(manager, root)
    root:clear() -- ensure container is empty before we begin.

    root:addLabel()
        :setText("welcome to superh0t!")
        :setPosition(1, 2)
    root:addLabel()
        :setText("Please select one of the options below to begin.")
        :setPosition(1, 3)
        

    local options = {
        [1] = "Burn a new CD",
        [2] = "Inspect a CD",
        [3] = "Exit",
    }

    for i, option in ipairs(options) do
        root:addLabel()
            :setText("[" .. i .. "] " .. option)
            :setPosition(1, i + 4)
    end

    -- Wait for user input
    local choice = nil
    while choice == nil do
        local event, key = os.pullEvent("key")
        if key >= keys.one and key <= keys.four then
            choice = key - keys.zero
        end
    end

    if choice == 1 then
        setView(manager, root, require("wizard.Burn_CD.0_prepare"))
    elseif choice == 2 then
        setView(manager, root, require("wizard.Inspect_CD.0_prepare"))
    end

end

return superhotWizard