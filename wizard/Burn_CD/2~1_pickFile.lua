local setView = require "utils.setView"
local function pickFile(manager, root)
    root:addLabel()
        :setText("Please select an audio file to add.")
        :setPosition(1, 2)

    root:addLabel()
        :setText("(A)bort (S)elect")
        :setPosition(1, 18)

    local fileTree = root:addTree()
        :setPosition(2, 4)
        :setSize(15, 13)
        :setBackground(colors.black)
        :setForeground(colors.white)
        :setSelectedBackgroundColor(colors.blue)
        :setSelectedForegroundColor(colors.white)
        :setScrollBarColor(colors.lightGray)
        :setScrollBarBackgroundColor(colors.gray)

    -- Build a file system-like tree structure
    local function buildNode(path, depth)
        -- Prevent excessive recursion
        local name = path == "/" and "/" or (string.match(path, "[^/]+$") or path)
        if depth <= 0 then
            return { text = name, path = path }
        end

        local node = { text = name, path = path }

        local ok, entries = pcall(fs.list, path)
        if not ok or not entries then
            return node
        end

        -- Separate directories and files, sort each list
        local dirs, files = {}, {}
        for _, entry in ipairs(entries) do
            local entryPath = (path == "/" and "" or path .. "/") .. entry
            local success, isDir = pcall(fs.isDir, entryPath)
            if success and isDir then
                table.insert(dirs, entry)
            else
                table.insert(files, entry)
            end
        end
        table.sort(dirs, function(a,b) return a:lower() < b:lower() end)
        table.sort(files, function(a,b) return a:lower() < b:lower() end)

        local children = {}
        for _, entry in ipairs(dirs) do
            local entryPath = (path == "/" and "" or path .. "/") .. entry
            table.insert(children, buildNode(entryPath, depth - 1))
        end
        for _, entry in ipairs(files) do
            local entryPath = (path == "/" and "" or path .. "/") .. entry
            table.insert(children, { text = entry, path = entryPath })
        end

        if #children > 0 then
            node.children = children
        end
        return node
    end

    -- Use actual filesystem starting at root; limit depth to avoid huge trees
    local treeData = { buildNode("/", 4) }

    fileTree:setNodes(treeData)
    local textLabel = root:addLabel()
        :setPosition(18, 4)
        :setForeground(colors.yellow)
        :setText("Selected: None")

    -- Handle node selection
    fileTree:onSelect(function(self, node)
        local display = node.path or node.text or "None"
        textLabel
            :setText("Selected: " .. display)
            :setPosition(18, 4)
            :setForeground(colors.yellow)
    end)


    while true do
        local event, key = os.pullEvent("key")
        if key == keys.a then
            setView(manager, root, require("wizard.Burn_CD.2_addFiles"))
            break
        elseif key == keys.s then
            local selectedNode = fileTree:getSelectedNode()
            if selectedNode and selectedNode.path then
                -- if the selected node is a folder add every file inside it
                if fs.isDir(selectedNode.path) then
                    local function addFilesInDir(dirPath)
                        local entries = fs.list(dirPath)
                        for _, entry in ipairs(entries) do
                            local entryPath = (dirPath == "/" and "" or dirPath .. "/") .. entry
                            if fs.isDir(entryPath) then
                                addFilesInDir(entryPath)
                            else
                                local fileSize = fs.getSize(entryPath)
                                table.insert(_G.discBlueprint.files, { name = entryPath, size = fileSize })
                            end
                        end
                    end
                    addFilesInDir(selectedNode.path)
                else
                    local filePath = selectedNode.path
                    local fileSize = fs.getSize(filePath)
                    table.insert(_G.discBlueprint.files, { name = filePath, size = fileSize })
                end
            end
            setView(manager, root, require("wizard.Burn_CD.2_addFiles"))
            break
        end
    end
end

return pickFile
