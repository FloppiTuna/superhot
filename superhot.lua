-- SUPERHOT: A CD burning tool for Datamatrix.
local basalt = require("/basalt")
local discoverBurners = require("utils.discoverBurners")

-- Get the main frame (your window)
local main = basalt.getMainFrame()

-- Header
local header = main:addLabel()
    :setText("superh0t")
    :setPosition(1, 1)
    :setSize(term.getSize(), 1)

-- Container for wizard content and crap
local root = main:addContainer()
    :setPosition(1, 2)
    :setSize(term.getSize(), term.getSize() - 1)

parallel.waitForAll(
    function() basalt.run() end,
    function()
        while true do
            os.sleep(1)
            header:setText("superh0t - " .. os.date("%H:%M:%S"))
        end
    end,
    function ()
        _G.burners = discoverBurners()
        require("wizard.superhotWizard")(main, root)
    end,
    function ()
        -- while true do
        --     local event, key = os.pullEvent("key")
        --     if key == keys.p then
        --         main:debugChildren()
        --         root:debugChildren()
        --         main:openConsole()
        --     end
        -- end
    end
)