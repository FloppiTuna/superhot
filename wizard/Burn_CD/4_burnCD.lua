local function burnCD(manager, root)
    root:addLabel()
        :setText("Burning " .. _G.discBlueprint.label .. ".")
        :setPosition(1, 2)

    local statusText = root:addLabel()
        :setText("Preparing...")
        :setPosition(1, 3)
        :setColor(colors.red)

    root:addLabel()
        :setText("Song Progress")
        :setPosition(1, 5)

    local songProgress = root:addProgressBar()
        :setPosition(1, 6)
        :setSize(term.getSize(), 2)
        :setBackground(colors.black)
        :setForeground(colors.white)

    root:addLabel()
        :setText("Total Progress")
        :setPosition(1, 9)

    local totalProgress = root:addProgressBar()
        :setPosition(1, 10)
        :setSize(term.getSize(), 2)
        :setBackground(colors.black)
        :setForeground(colors.white)
        
    songProgress.showPercentage = true
    totalProgress.showPercentage = true

    songProgress.progressColor = colors.green
    totalProgress.progressColor = colors.blue

    -- Begin actual burning using the peripheral
    local cd = _G.selectedBurner
    if not cd then
        error("CD peripheral '" .. tostring(_G.selectedBurner) .. "' not found. Check your connections.")
    end

    -- Helper writers
    local function write_u32(offset, value)
      cd.write(offset, string.pack("<I4", value))
      return offset + 4
    end

    local function write_u16(offset, value)
      cd.write(offset, string.pack("<I2", value))
      return offset + 2
    end

    local function write_byte(offset, value)
      cd.write(offset, string.char(value))
      return offset + 1
    end

    local function pad_to(offset, align)
      local pad = align - (offset % align)
      if pad ~= align then
        cd.write(offset, string.rep("\0", pad))
        offset = offset + pad
      end
      return offset
    end

    -- Prepare header and track table
    local files = _G.discBlueprint.files or {}
    local cd_name = _G.discBlueprint.label or "Untitled"
    local offset = 0

    -- Header
    statusText:setText("Writing header...")
    cd.write(offset, "DMCDFS1\0")  offset = offset + 8
    offset = write_byte(offset, 1) -- version
    offset = write_byte(offset, #files)
    offset = write_u16(offset, #cd_name)
    cd.write(offset, cd_name)      offset = offset + #cd_name

    -- Track table placeholder
    local track_table_offset = offset
    local track_entry_size = 64
    for i, file in ipairs(files) do
        -- normalize file entry (support either "path" string or { name = path, size = ... } table)
        statusText:setText("Assembling the track table..." .. "(" .. i .. "/" .. #files .. ")")
        local filePath = (type(file) == "table") and file.name or file
        local name = fs.getName(filePath):gsub("%.dfpwm$", "")
        local entry_offset = track_table_offset + (i - 1) * track_entry_size
        cd.write(entry_offset, name .. string.rep("\0", math.max(0, 32 - #name)))
        offset = math.max(offset, entry_offset + track_entry_size)
    end

    -- Audio data starts after table
    local data_offset = track_table_offset + #files * track_entry_size

    local totalFiles = #files
    for i, file in ipairs(files) do
        statusText:setText("Reading " .. file.name .. " (" .. i .. "/" .. totalFiles .. ").")
        -- normalize file entry
        local filePath = (type(file) == "table") and file.name or file
        local name = fs.getName(filePath):gsub("%.dfpwm$", "")
        -- Determine file length and read chunks
        local h = fs.open(filePath, "rb")
        if not h then error("Cannot open " .. filePath) end
        local file_size = 0
        local chunks = {}
        while true do
            local chunk = h.read(16384)
            if not chunk then break end
            table.insert(chunks, chunk)
            file_size = file_size + #chunk
        end
        h.close()

        local start = data_offset
        local length = file_size
        local rate = 48000
        local channels = 1

        -- Write audio data in chunks and update song progress
        local written = 0
        for _, chunk in ipairs(chunks) do
            statusText:setText("Writing " .. name .. " (" .. i .. "/" .. totalFiles .. "): " .. written .. "/" .. length .. " bytes.")
            cd.write(start + written, chunk)
            written = written + #chunk
            local pct = (length > 0) and math.floor((written / length) * 100) or 100
            songProgress:setProgress(pct)
            -- small yield so UI can update
            -- os.pullEvent("timer")
        end

        -- Write track entry metadata
        statusText:setText("Writing track metadata for " .. name .. ".")
        local entry_offset = track_table_offset + (i - 1) * track_entry_size
        cd.write(entry_offset + 0x20, string.pack("<I4I4I4I4I4", start, length, rate, channels, 0))
        cd.write(entry_offset + 0x34, string.rep("\0", 12))

        data_offset = data_offset + length

        totalProgress:setProgress(math.floor((i / totalFiles) * 100))
    end

    -- Finalize
    statusText:setText("Finalizing disc...")
    cd.finalizeDisc()

    -- Finished
    statusText
        :setText("Finished. Press a key to exit.")
        :setColor(colors.green)
        :setBackground(colors.black)

    os.pullEvent("key")
    shell.exit()
end

return burnCD