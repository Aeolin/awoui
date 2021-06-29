Window = {
    body = nil,
    header = nil,
    gBody = nil,
    gHeader = nil,
    title = "",
    minWidth = 0,
    minHeight = 0,
    priority = 0,
    prefWidth= 0,
    prefHeight= 0,
    visible = true,
    layoutId = "",
    layoutIndex = 0
}

function Window:new(parent, x, y, width, height, title)
    if height < 3 then
        return nil
    end

    local header = window.create(parent, x, y, width, 2);
    local body = window.create(parent, x, y + 2, width, height - 2)

    local gHeader = Graphics.Graphics:new(header)
    local gBody = Graphics.Graphics:new(body)

    local self = {
        body = body,
        header = header,
        gBody = gBody,
        gHeader = gHeader,
        title = title or ""
    }
    setmetatable(self, {
        __index = Window
    })
    self:redraw()
    return self
end

function Window:inside(x,y,header)
    local window = header and self.header or self.body
    local posX,posY = window.getPosition()
    return x >= posX and x <= self:getWidth() and y >= posY and y <= self:getHeight()
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
    local g = self.gHeader;
    g:fillBox(1, 1, g:getWidth(), 1, "0");
    g:write(1, 1, self.title, "f", "0")
    g:write(1, 2, string.rep("-", g:getWidth()))
    self.header.redraw()
    self.body.redraw()
end

function Window:reposition(x, y, width, height)
    if height < 3 then
        return false
    end

    self.header.reposition(x, y, width, 2)
    self.body.reposition(x, y + 2, width, height - 2)
    self.gBody:updateSize()
    self.gHeader:updateSize()
    self:redraw()
    return true
end

function Window:getPosition()
    return self.header.getPosition()
end

function Window:getGraphics()
    return self.gBody
end
