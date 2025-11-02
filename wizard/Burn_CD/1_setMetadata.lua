local setView = require "utils.setView"
local function setMetadata(manager, root)
    root:addLabel()
        :setText("Please enter a label for this CD.")
        :setPosition(1, 2)

    local nameEntry = root:addTextBox()
        :setPosition(1, 4)
        :setSize(30, 1)
        :setBackground(colors.black)
        :setForeground(colors.green)

    local choice = nil
    while choice == nil do
        local event, key = os.pullEvent("key")
        if key == keys.enter then
            choice = nameEntry:getText()
            _G.discBlueprint.label = choice

            setView(manager, root, require("wizard.Burn_CD.2_addFiles"))
        end
    end        

    -- Further steps for setting metadata would go here...
end

return setMetadata