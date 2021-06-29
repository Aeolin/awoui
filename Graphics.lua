Graphics = {
    terminal = nil,
    width = 0,
    height = 0
}

function Graphics:new(term)
    local self = {
        terminal = term
    }
    setmetatable(self, {
        __index = Graphics
    })
    self:updateSize()
    return self
end

function Graphics:updateSize()
    local w, h = self.terminal.getSize()
    self.width = w
    self.height = h
end

function Graphics:getWidth()
    return self.width
end

function Graphics:getHeight()
    return self.height
end

function Graphics:clearLine(index, color)
    self:fillBox(1, index, self:getWidth(), 1, color or "f")
end

function Graphics:write(x, y, str, color, background)
    color = color or "0"
    if str:len() == 0 then
        return
    end

    background = background or "f"
    if str:len() > 1 then
        if color:len() == 1 then
            color = str.rep(color, str:len())
        end

        if background:len() == 1 then
            background = str.rep(background, str:len())
        end
    end

    local term = self.terminal;
    local ox, oy = term.getCursorPos()
    term.setCursorPos(x, y)
    term.blit(str, color, background);
    term.setCursorPos(ox, oy)
end

function Graphics:drawBox(x, y, width, height, color, background)
    if width > self:getWidth() - (x - 1) or height > self:getHeight() - (y - 1) then
        -- return false
        print(string.format("warning box to long: x: %d, y: %d, w: %d, h: %d, sw: %d, sh: %d", x, y, width, height,
            self:getWidth(), self:getHeight()));
    end

    if color == nil then
        color = "0"
    end

    if background == nil then
        background = "f"
    end

    local boxStr = string.rep(" ", width);
    local colorStr = string.rep(color, width);
    local innerStr = colorStr;
    if width >= 3 then
        innerStr = string.rep(background, width - 2);
        innerStr = color .. innerStr .. color
    end

    self:write(x, y, boxStr, colorStr, colorStr);
    for i = y + 1, height + y - 1, 1 do
        self:write(x, i, boxStr, innerStr, innerStr)
    end
    if height > 1 then
        self:write(x, y + height - 1, boxStr, colorStr, colorStr)
    end

    return true
end

function Graphics:fillBox(x, y, width, height, color)
    return self:drawBox(x, y, width, height, color, color)
end

function Graphics:round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function Graphics:drawBarHorizontal(x, y, width, height, val, max, color, background, border, borderColor, flipped,
    percentageColor)
    if border == nil or height < 3 or width < 3 then
        border = false
    end

    if (border) then
        self:fillBox(x, y, width, height, borderColor)
        x = x + 1
        y = y + 1
        width = width - 2
        height = height - 2
    end

    local widthAdjusted = Graphics:round((val / max) * width)
    self:fillBox(x, y, width, height, background);
    if flipped then
        local offset = width - widthAdjusted;
        self:fillBox(x + offset, y, widthAdjusted, height, color)
    else
        self:fillBox(x, y, widthAdjusted, height, color)
    end

    if percentageColor ~= nil then
        local percentage = Graphics:round((val / max) * 100) .. "%"
        if percentage:len() > width then
            return
        end

        local yOffset = Graphics:round(height / 2)
        local offset = math.min(widthAdjusted, width - percentage:len())
        local bg = background
        local overLap = widthAdjusted - offset
        if overLap > 0 then
            bg = string.rep(color, overLap) .. string.rep(background, percentage:len() - overLap)
        end

        if flipped then
            self:write(x + width - offset - percentage:len(), yOffset, percentage, percentageColor, string.reverse(bg))
        else
            self:write(x + offset, yOffset, percentage, percentageColor, bg)
        end

    end
end

function Graphics:drawBarVertical(x, y, width, height, val, max, color, background, border, borderColor, flipped)
    if border == nil or height < 3 or width < 3 then
        border = false
    end

    if (border) then
        self:fillBox(x, y, width, height, borderColor)
        x = x + 1
        y = y + 1
        width = width - 2
        height = height - 2
    end

    local heightAdjusted = Graphics:round((val / max) * height);
    self:fillBox(x, y, width, height, background);
    if flipped then
        local offset = height - heightAdjusted
        self:fillBox(x, y + offset, width, heightAdjusted, color)
    else
        self:fillBox(x, y, width, heightAdjusted, color)
    end
end
