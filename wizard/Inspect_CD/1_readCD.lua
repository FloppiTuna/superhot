local setView = require "utils.setView"
local function readCD(manager, root)
    local statusLabel = root:addLabel()
        :setText("Reading CD...")
        :setPosition(1, 2)

    local loadProgress = root:addProgressBar()
        :setPosition(1, 10)
        :setSize(term.getSize(), 2)
        :setBackground(colors.black)
        :setForeground(colors.white)

    loadProgress.showPercentage = true
    loadProgress.progressColor = colors.green

    -- read the cd
    local cd = _G.selectedBurner

    local function read_str(offset, len)
        return cd.read(offset, len)
    end

    local function read_u32(offset)
        local data = cd.read(offset, 4)
        return string.unpack("<I4", data)
    end

    local function read_u16(offset)
        local data = cd.read(offset, 2)
        return string.unpack("<I2", data)
    end

    local function read_byte(offset)
        return string.byte(cd.read(offset, 1))
    end

    statusLabel:setText("Checking disc header...")
    local magic = read_str(0, 8)

    if magic ~= "DMCDFS1\00" then
        return setView(manager, root, require("wizard.Common.1_crapError"))
    end

    statusLabel:setText("Reading track table...")
    local version = read_byte(8)
    local track_count = read_byte(9)
    local name_len = read_u16(10)
    local name = read_str(12, name_len)
    local offset = 12 + name_len

    local files = {}
    for i = 1, track_count do
        statusLabel:setText("Reading track " .. i .. " of " .. track_count .. "...")
        local entry_offset = offset + (i - 1) * 64
        local rawname = cd.read(entry_offset, 32):gsub("\0+$", "")
        local start, length, rate, channels =
        string.unpack("<I4I4I4I4", cd.read(entry_offset + 0x20, 16))
        -- print(("Track %02d: %s | %d bytes @ %d | %d Hz, %s")
        -- :format(i, rawname, length, start, rate, channels == 2 and "stereo" or "mono"))
        table.insert(files, {
            position = i,
            name = rawname,
            size = length,
            offset = start,
        })
        loadProgress:setProgress(math.floor((i / track_count) * 100))
    end



    _G.loadedDisc = {
        label = name,
        files = files
    }

    setView(manager, root, require("wizard.Inspect_CD.2_displayContents"))
end

return readCD