local setView = require "utils.setView"
local function readCD(manager, root)
    root:addLabel()
        :setText("Reading CD...")
        :setPosition(1, 2)

    local loadProgress = root:addProgressBar()
        :setPosition(1, 10)
        :setSize(term.getSize(), 2)
        :setBackground(colors.black)
        :setForeground(colors.white)

    loadProgress.showPercentage = true
    loadProgress.progressColor = colors.green

    for i = 1, 100 do
        loadProgress:setProgress(i)
        os.sleep(0.01)
    end

    _G.loadedDisc = {
        label = "Jazz",
        files = {
            {name = "file1.txt", size = 1234},
            {name = "file2.txt", size = 5678},
            {name = "image.png", size = 23456},
        }
    }

    setView(manager, root, require("wizard.Inspect_CD.2_displayContents"))


end

return readCD