local function crapError(manager, root)
    -- beep any attached speakers
    peripheral.find("speaker").playNote("bit", 1, 0)
    sleep(.25)
    peripheral.find("speaker").playNote("bit", 1, 0)
    sleep(.25)
    peripheral.find("speaker").playNote("bit", 1, 0)
    sleep(.25)


    root:setBackground(colors.red)

    root:addLabel()
        :setText("\"Man the lifeboats! Women and children first!\"")
        :setPosition(1, 2)
        :setColor(colors.white)
        :setBackground(colors.red)

    root:addLabel()
        :setText("a critical error has occurred :((")
        :setPosition(1, 4)
        :setColor(colors.white)

    root:addLabel()
        :setText("in file " .. debug.getinfo(1).source .. ", line " .. debug.getinfo(1).currentline .. ":")
        :setPosition(1, 5)
        :setColor(colors.white)

    root:addLabel()
        :setText(debug.traceback())
        :setPosition(1, 7)
        :setColor(colors.white)
end

return crapError