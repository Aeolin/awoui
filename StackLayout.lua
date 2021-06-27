StackLayout = {
    horizontal = true,
    windows = {},
    content = nil,
    parent = nil,
    indexCounter = 0
}

function StackLayout:new(parent, x, y, width, height, horizontal)
    local content = window.create(parent, x, y, width, height)

    local self = {
        content = content,
        horizontal = horizontal,
        parent = parent,
        windows = {},
        indexCounter = 0
    }
    setmetatable(self, {
        __index = StackLayout
    })

    return self
end

function StackLayout:getHeight()
    local w, h = self.content.getSize()
    return h
end

function StackLayout:getWidth()
    local w, h = self.content.getSize()
    return w
end

function StackLayout:createWindow(id, length, minLength, title, priority)
    if self.windows[id] ~= nil then
        print(self.windows[id])
        return nil
    end

    local window = nil
    if self.horizontal then
        window = Window.Window:new(self.content, 1, 1, minLength, self:getHeight(), title)
        window:setMinSize(minLength, self:getHeight())
        window:setPrefSize(length, self:getHeight())
    else
        window = Window.Window:new(self.content, 1, 1, self:getWidth(), minLength, title)
        window:setMinSize(self:getWidth(), minLength)
        window:setPrefSize(self:getWidth(), length)
    end

    window:setLayoutId(id)
    window:setLayoutIndex(self.indexCounter)
    window:setLayoutPriority(priority or 0)
    self.indexCounter = self.indexCounter + 1
    self.windows[id] = window
    self:layout()
    return window
end

function StackLayout:sizeLeft(priority, available)
    for id, window in pairs(self.windows) do
        if window:isVisible() then
            local needed = 0
            if self.horizontal then
                needed = window:getLayoutPriority() > priority and window:getPrefWidth() or window:getMinWidth()
            else
                needed = window:getLayoutPriority() > priority and window:getPrefHeight() or window:getMinHeight()
            end
            local required = math.min(available, needed)
            available = available - required
        end
    end

    return available
end

function StackLayout:getSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    local res = {}
    for i, key in ipairs(keys) do
        table.insert(res, tbl[key])
    end
    return res
end

function StackLayout:layout()
    local sized = {}
    local byPrio = self:getSortedByValue(self.windows, function(a, b)
        return a:getLayoutPriority() > b:getLayoutPriority()
    end)

    local available = self.horizontal and self:getWidth() or self:getHeight()
    for i, window in ipairs(byPrio) do
        if window:isVisible() then
            local needed = 0
            if self.horizontal then
                needed = window:getMinWidth()
            else
                needed = window:getMinHeight()
            end
            local required = math.min(available, needed)
            sized[window:getLayoutId()] = required
            -- print(string.format("pass1: window: %s, avail: %d, size: %d, prio: %d", window:getLayoutId(), available, required, window:getLayoutPriority()))
            available = available - required
        end
    end

    for i, window in ipairs(byPrio) do
        if window:isVisible() then
            local needed = sized[window:getLayoutId()]
            local diff = 0
            if self.horizontal then
                diff = window:getPrefWidth() - needed
            else
                diff = window:getPrefWidth() - needed
            end

            local additional = math.min(available, diff)
            sized[window:getLayoutId()] = needed + additional
            --print(string.format("pass2: window: %s, avail: %d, size: %d, prio: %d", window:getLayoutId(), available, needed + additional, window:getLayoutPriority()))
            available = available - additional
            if available <= 0 then
                break
            end
        end
    end

    local byIndex = self:getSortedByValue(self.windows, function(a, b)
        return a:getLayoutIndex() < b:getLayoutIndex()
    end)
    self.content.clear()
    local offset = 1
    for i, window in ipairs(byIndex) do
        if window:isVisible() then
            local size = sized[window:getLayoutId()]
            if self.horizontal then
                window:reposition(offset, 1, size, self:getHeight())
            else
                window:reposition(1, offset, self:getWidth(), size)
            end
            window:redraw()
            --print(string.format("align: window: %s, size: %d, offset: %d", window:getLayoutId(), size, offset))
            offset = offset + size
        end
    end
end
