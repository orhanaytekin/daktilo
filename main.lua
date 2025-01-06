-- Modern typewriter simulation
local typewriter = {
    text = "",
    lines = {},
    currentLine = "",
    lineWidth = 50,
    paperY = 0,
    cursorBlink = 0,
    cursorVisible = true,
    pressedKeys = {},  -- Track pressed keys for animation
    carriagePosition = 0,  -- For carriage animation
    allowedChars = {  -- Historically accurate typewriter characters
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
        '.', ',', ';', ':', '?', '!', '"', '\'', '-', '(', ')', ' '
    }
}

-- Convert array to lookup table for faster checking
local allowedCharsSet = {}
for _, char in ipairs(typewriter.allowedChars) do
    allowedCharsSet[char] = true
end

function love.load()
    -- Calculate window center
    local width, height = love.graphics.getDimensions()
    typewriter.centerX = width / 2
    typewriter.centerY = height / 2
    
    -- Load font
    typewriter.font = love.graphics.newFont("resources/JetBrainsMono-Regular.ttf", 20)
    if not love.filesystem.getInfo("resources/JetBrainsMono-Regular.ttf") then
        typewriter.font = love.graphics.newFont(20)
    end
    love.graphics.setFont(typewriter.font)
    
    -- Create rounded rectangle function
    function love.graphics.roundrect(x, y, w, h, radius)
        radius = radius or 10
        love.graphics.rectangle("fill", x + radius, y, w - radius * 2, h)
        love.graphics.rectangle("fill", x, y + radius, w, h - radius * 2)
        
        love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, 3*math.pi/2)
        love.graphics.arc("fill", x + w - radius, y + radius, radius, 3*math.pi/2, 2*math.pi)
        love.graphics.arc("fill", x + radius, y + h - radius, radius, math.pi/2, math.pi)
        love.graphics.arc("fill", x + w - radius, y + h - radius, radius, 0, math.pi/2)
    end
end

function love.update(dt)
    -- Update cursor blink
    typewriter.cursorBlink = typewriter.cursorBlink + dt
    if typewriter.cursorBlink >= 0.5 then
        typewriter.cursorBlink = 0
        typewriter.cursorVisible = not typewriter.cursorVisible
    end
    
    -- Update key animations
    for key, time in pairs(typewriter.pressedKeys) do
        typewriter.pressedKeys[key] = time - dt
        if typewriter.pressedKeys[key] <= 0 then
            typewriter.pressedKeys[key] = nil
        end
    end
    
    -- Animate carriage movement
    if typewriter.carriageTarget then
        local diff = typewriter.carriageTarget - typewriter.carriagePosition
        typewriter.carriagePosition = typewriter.carriagePosition + diff * dt * 10
        if math.abs(diff) < 0.1 then
            typewriter.carriagePosition = typewriter.carriageTarget
            typewriter.carriageTarget = nil
        end
    end
end

function love.draw()
    -- Draw dark background
    love.graphics.setBackgroundColor(0.15, 0.15, 0.15)
    
    -- Center everything
    local paperWidth = 600
    local paperHeight = 500
    local paperX = typewriter.centerX - paperWidth/2
    local paperY = 50
    
    -- Draw paper holder (metallic look)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle('fill', paperX - 50, paperY - 20, paperWidth + 100, 20)
    
    -- Draw paper
    love.graphics.setColor(0.95, 0.95, 0.95)
    love.graphics.rectangle('fill', paperX, paperY, paperWidth, paperHeight)
    
    -- Draw paper texture (subtle grid)
    love.graphics.setColor(0.9, 0.9, 0.9)
    for i = 0, paperHeight, 20 do
        love.graphics.line(paperX, paperY + i, paperX + paperWidth, paperY + i)
    end
    
    -- Draw text
    love.graphics.setColor(0.1, 0.1, 0.1)
    local textY = paperY + 20 + typewriter.paperY
    
    -- Draw existing lines
    for i, line in ipairs(typewriter.lines) do
        love.graphics.print(line, paperX + 20 - typewriter.carriagePosition, textY + (i-1) * 25)
    end
    
    -- Draw current line with cursor
    love.graphics.print(typewriter.currentLine, paperX + 20 - typewriter.carriagePosition, textY + #typewriter.lines * 25)
    if typewriter.cursorVisible then
        local cursorX = paperX + 20 + typewriter.font:getWidth(typewriter.currentLine) - typewriter.carriagePosition
        love.graphics.rectangle('fill', cursorX, textY + #typewriter.lines * 25, 2, 20)
    end
    
    -- Draw keyboard
    local keySize = 45
    local spacing = 8
    local keyboardWidth = 10 * (keySize + spacing)
    local startX = typewriter.centerX - keyboardWidth/2
    local startY = paperY + paperHeight + 50
    
    local keyLayout = {
        {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'},
        {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'},
        {'⇧', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'},
        {'123', '⌨', ' space ', 'return'}
    }
    
    local rowOffsets = {0, 20, 40, 60}
    
    for row, keys in ipairs(keyLayout) do
        for col, key in ipairs(keys) do
            local keyWidth = keySize
            if key == ' space ' then keyWidth = keySize * 4 end
            if key == 'return' then keyWidth = keySize * 1.5 end
            
            local x = startX + rowOffsets[row] + (col-1) * (keySize + spacing)
            local y = startY + (row-1) * (keySize + spacing)
            
            -- Key press animation
            local keyOffset = 0
            if typewriter.pressedKeys[key] then
                keyOffset = 3 * (typewriter.pressedKeys[key] / 0.1)  -- 3 pixels max depression
            end
            
            -- Key shadow
            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.roundrect(x+2, y+2, keyWidth, keySize)
            
            -- Key body
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.roundrect(x, y + keyOffset, keyWidth, keySize)
            
            -- Key highlight
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.roundrect(x, y + keyOffset, keyWidth, keySize/2)
            
            -- Key text
            love.graphics.setColor(1, 1, 1)
            local textX = x + keyWidth/2 - typewriter.font:getWidth(key)/2
            local textY = y + keyOffset + keySize/2 - typewriter.font:getHeight()/2
            love.graphics.print(key, textX, textY)
        end
    end
end

function love.textinput(text)
    text = text:upper()  -- Convert to uppercase for typewriter feel
    if allowedCharsSet[text] then
        -- Add character to current line
        typewriter.currentLine = typewriter.currentLine .. text
        
        -- Animate key press
        typewriter.pressedKeys[text] = 0.1  -- Animation duration
        
        -- Move carriage
        typewriter.carriagePosition = typewriter.carriagePosition + typewriter.font:getWidth(text)
        
        -- Check if we need to start a new line
        if #typewriter.currentLine >= typewriter.lineWidth then
            table.insert(typewriter.lines, typewriter.currentLine)
            typewriter.currentLine = ""
            typewriter.carriagePosition = 0
            
            -- Scroll paper if needed
            if #typewriter.lines * 25 > 460 then
                typewriter.paperY = typewriter.paperY - 25
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' then
        typewriter.pressedKeys['return'] = 0.1
        table.insert(typewriter.lines, typewriter.currentLine)
        typewriter.currentLine = ""
        typewriter.carriagePosition = 0
        
        -- Scroll paper if needed
        if #typewriter.lines * 25 > 460 then
            typewriter.paperY = typewriter.paperY - 25
        end
    elseif key == 'backspace' then
        if #typewriter.currentLine > 0 then
            local removedChar = typewriter.currentLine:sub(-1)
            typewriter.currentLine = typewriter.currentLine:sub(1, -2)
            typewriter.carriagePosition = typewriter.carriagePosition - typewriter.font:getWidth(removedChar)
            typewriter.pressedKeys['⌫'] = 0.1
        end
    elseif key == 'space' then
        typewriter.pressedKeys[' space '] = 0.1
    end
end 