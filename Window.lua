Window = {
    body = nil,
    parent = nil,
    header = nil,
    gBody = nil,
    gHeader = nil,
    title = "",
    minWidth = 0,
    minHeight = 0,
    priority = 0,
    prefWidth = 0,
    prefHeight = 0,
    visible = true,
    layoutId = "",
    layoutIndex = 0
}

function Window:new(parent, x, y, width, height, title)
    local header = nil
    local gHeader = nil

    if title ~= nil then
        if height < 3 then
            return nil
        end

        header = window.create(parent, x, y, width, 2);
        y = y + 2
        height = height - 2
        gHeader = Graphics.Graphics:new(header)
    end

    local body = window.create(parent, x, y, width, height)
    local gBody = Graphics.Graphics:new(body)

    local self = {
        body = body,
        header = header,
        gBody = gBody,
        gHeader = gHeader,
        title = title or "",
        parent = parent
    }
    setmetatable(self, {
        __index = Window
    })
    self:redraw()
    return self
end

function Window:setTitle(title)
    self.title = title

    if self:hasTitle() == false and title ~= nil then
        if self:getHeight() < 3 then
            return
        end
        local x, y = self:getPosition()
        self.header = window.create(self.parent, x, y, self:getWidth(), 2)
        self.gHeader = Graphics.Graphics:new(self.header)
        self.body.reposition(x, y + 2, self:getWidth(), self:getHeight() - 2)
    end

    if self:hasTitle() and title == nil then
        local x, y = self:getPosition()
        self.body.reposition(x, y, self:getWidth(), self:getHeight() + 2)
        self.header = nil
        self.gHeader = nil
    end

    self:redraw()
end

function Window:hasTitle()
    return self.header ~= nil
end

function Window:inside(x, y, header)
    local window = header and self.header or self.body
    local posX, posY = window.getPosition()
    return x >= posX and x <= posX + self:getWidth() and y >= posY and y <= posY + self:getHeight()
end

function Window:setLayoutId(id)
    self.layoutId = id
end

function Window:getLayoutId()
    return self.layoutId
end

function Window:getLayoutIndex()
    return self.layoutIndex;
end

function Window:setLayoutIndex(index)
    self.layoutIndex = index;
end

function Window:setVisible(visible)
    self.visible = visible;
    self.body.setVisible(visible);
    self.header.setVisible(visible);
end

function Window:isVisible()
    return self.visible;
end

function Window:setMinSize(width, height)
    self.minWidth = width
    self.minHeight = height
end

function Window:setLayoutPriority(priority)
    self.priority = priority
end

function Window:setPrefSize(width, height)
    self.prefHeight = height
    self.prefWidth = width
end

function Window:getWidth()
    local w, _ = self.body.getSize()
    return w
end

function Window:getHeight()
    local _, h = self.body.getSize()
    if self:hasTitle() then
        h = h + 2
    end
    return h
end

function Window:getPrefWidth()
    return self.prefWidth
end

function Window:getPrefHeight()
    return self.prefHeight
end

function Window:getMinWidth()
    return self.minWidth
end

function Window:getMinHeight()
    return self.minHeight
end

function Window:getLayoutPriority()
    return self.priority
end

function Window:redraw()
    if self:hasTitle() then
        local g = self.gHeader;
        g:fillBox(1, 1, g:getWidth(), 1, "0");
        g:write(1, 1, self.title, "f", "0")
        g:write(1, 2, string.rep("-", g:getWidth()))
        self.header.redraw()
    end
    self.body.redraw()
end

function Window:reposition(x, y, width, height)
    if self:hasTitle() then
        if height < 3 then
            return false
        end

        self.header.reposition(x, y, width, 2)
        y = y + 2
        height = height - 2
    end

    self.body.reposition(x, y, width, height)
    self.gBody:updateSize()
    self.gHeader:updateSize()
    self:redraw()
    return true
end

function Window:getPosition()
    if self:hasTitle() then
        return self.header.getPosition()
    else
        return self.body.getPosition()
    end
end

function Window:getGraphics()
    return self.gBody
end
