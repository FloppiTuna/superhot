local function setView(manager, root, view)
    root:clear()
    
    view(manager, root)
end

return setView