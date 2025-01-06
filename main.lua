-- Modern typewriter simulation
local typewriter = {
    text = "",
    lines = {},
    currentLine = "",
    lineWidth = 70,
    paperY = 0,
    cursorBlink = 0,
    cursorVisible = true,
    pressedKeys = {},  -- Track pressed keys for animation
    carriagePosition = 0,  -- For carriage animation
    carriageMaxWidth = 500,  -- Maximum distance before auto-return
    returnSpeed = 800,       -- Speed of return animation in pixels per second
    returnAnimation = 0,     -- 0 = not returning, 1 = returning
    paperOffset = 0,         -- Track total paper offset
    keyLayout = {  -- Define keyboard layout as part of typewriter
        {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='},
        {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'},
        {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'", 'ENTER'},
        {'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', 'DEL'}
    },
    allowedChars = {  -- Define allowed characters
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
        '-', '=', '[', ']', ';', "'", ',', '.', ' ', 'DEL', 'ENTER'
    },
    gridSize = 25,  -- Height between grid lines
    textBaselineOffset = 20,  -- Offset to align text with grid lines
    paperStartX = 0,  -- Will be set in love.load()
    paperColor = {0.98, 0.98, 0.95},  -- Slightly off-white for paper
    backgroundColor = {0.3, 0.3, 0.35},  -- Dark gray for desk/background
    paperShadowSize = 5,  -- Size of paper shadow
    paperPadding = 30,    -- Extra space around paper content
    paperWidth = 600,  -- Increased paper width
    paperHeight = 500, -- Increased paper height
    paperVisible = 800, -- How much of the paper is visible in the window
    paperMinX = 10,     -- Less left padding
    paperMaxOffset = 0, -- Will be calculated based on paper width
    paperRightPadding = 100,  -- More right padding
    returnDuration = 5.0,    -- Match carriage sound duration (5 seconds)
    returnProgress = 0,      -- Progress of return animation (0 to 1)
    returnStartX = 0,        -- Starting X position for return animation
    returnTargetX = 0,       -- Target X position for return animation
    sounds = {}, -- Will hold our sound effects
}

-- Convert array to lookup table for faster checking
local allowedCharsSet = {}
for _, char in ipairs(typewriter.allowedChars) do
    allowedCharsSet[char] = true
end

function love.load()
    -- Calculate window center and paper positions
    local width, height = love.graphics.getDimensions()
    typewriter.centerX = width / 2
    typewriter.centerY = height / 2
    
    -- Start paper from right side with more padding
    typewriter.paperStartX = width - typewriter.paperWidth - typewriter.paperRightPadding
    typewriter.paperMinX = 10  -- Less left edge padding
    typewriter.paperMaxOffset = typewriter.paperStartX - typewriter.paperMinX
    
    -- Move paper up slightly to accommodate larger height
    typewriter.paperStartY = 15
    
    -- Adjust font settings for better alignment
    typewriter.font = love.graphics.newFont(16)
    typewriter.font:setLineHeight(1.0)  -- Ensure consistent line height
    love.graphics.setFont(typewriter.font)
    
    -- Load sound effects with error handling
    local function loadSound(name)
        local path = "assets/sounds/" .. name
        local success, source = pcall(function()
            return love.audio.newSource(path, "static")
        end)
        
        if success then
            return source
        else
            print("Warning: Could not load sound " .. path)
            return nil
        end
    end
    
    -- Load the two existing sounds
    typewriter.sounds = {
        key_click = loadSound("key-press-263640.mp3"),
        -- key_click = loadSound("click.mp3"),     -- For key clicks
        carriage = loadSound("carriage.mp3")    -- For carriage return
    }
    
    -- Set sound volumes
    for name, sound in pairs(typewriter.sounds) do
        if sound then
            sound:setVolume(0.5)
            print("Loaded sound: " .. name)
        end
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
    
    -- Update return animation with easing
    if typewriter.returnAnimation > 0 then
        typewriter.returnProgress = typewriter.returnProgress + dt / typewriter.returnDuration
        
        if typewriter.returnProgress >= 1 then
            typewriter.returnProgress = 0
            typewriter.returnAnimation = 0
            typewriter.carriagePosition = 0
            
            -- Stop carriage sound if it's still playing
            if typewriter.sounds.carriage then
                typewriter.sounds.carriage:stop()
            end
        else
            -- Easing function for smooth movement
            local t = typewriter.returnProgress
            local easeOut = 1 - (1 - t) * (1 - t)  -- Quadratic ease-out
            
            typewriter.carriagePosition = typewriter.returnStartX * (1 - easeOut)
        end
    end
end

function love.draw()
    -- Draw dark background
    love.graphics.setBackgroundColor(typewriter.backgroundColor)
    
    -- Calculate paper position with bounds
    local baseX = typewriter.paperStartX - typewriter.carriagePosition
    local paperX = math.max(typewriter.paperMinX, baseX)
    local paperY = typewriter.paperStartY
    
    -- Draw paper shadow
    love.graphics.setColor(0.1, 0.1, 0.1, 0.3)
    love.graphics.rectangle('fill', 
        paperX + typewriter.paperShadowSize, 
        paperY + typewriter.paperShadowSize, 
        typewriter.paperWidth, 
        typewriter.paperHeight
    )
    
    -- Draw paper background (fixed size)
    love.graphics.setColor(typewriter.paperColor)
    love.graphics.rectangle('fill', 
        paperX, 
        paperY, 
        typewriter.paperWidth, 
        typewriter.paperHeight
    )
    
    -- Create stencil for content area
    love.graphics.stencil(function()
        love.graphics.rectangle('fill', 
            paperX + typewriter.paperPadding, 
            paperY + typewriter.paperPadding, 
            typewriter.paperWidth - typewriter.paperPadding * 2, 
            typewriter.paperHeight - typewriter.paperPadding * 2
        )
    end, 'replace', 1)
    love.graphics.setStencilTest('greater', 0)
    
    -- Draw grid (fixed to paper)
    love.graphics.setColor(0.9, 0.9, 0.9)
    local contentWidth = typewriter.paperWidth - typewriter.paperPadding * 2
    
    -- Draw vertical lines (fixed to paper)
    for x = 0, contentWidth, 20 do
        love.graphics.line(
            paperX + typewriter.paperPadding + x,
            paperY + typewriter.paperPadding,
            paperX + typewriter.paperPadding + x,
            paperY + typewriter.paperHeight - typewriter.paperPadding
        )
    end
    
    -- Draw horizontal lines (fixed to paper)
    for y = 0, typewriter.paperHeight - typewriter.paperPadding * 2, typewriter.gridSize do
        love.graphics.line(
            paperX + typewriter.paperPadding,
            paperY + typewriter.paperPadding + y,
            paperX + typewriter.paperPadding + contentWidth,
            paperY + typewriter.paperPadding + y
        )
    end
    
    -- Draw text (fixed to paper)
    love.graphics.setColor(0.1, 0.1, 0.1)
    local textStartX = paperX + typewriter.paperPadding + contentWidth/4
    local textStartY = paperY + typewriter.paperPadding + typewriter.textBaselineOffset + typewriter.paperY
    
    -- Draw existing lines
    for i, line in ipairs(typewriter.lines) do
        love.graphics.print(
            line, 
            textStartX, 
            textStartY + (i-1) * typewriter.gridSize
        )
    end
    
    -- Draw current line with cursor
    love.graphics.print(
        typewriter.currentLine, 
        textStartX, 
        textStartY + #typewriter.lines * typewriter.gridSize + typewriter.returnAnimation * 2
    )
    
    -- Draw cursor
    if typewriter.cursorVisible then
        local cursorX = textStartX + typewriter.font:getWidth(typewriter.currentLine)
        local cursorY = textStartY + #typewriter.lines * typewriter.gridSize + typewriter.returnAnimation * 2
        love.graphics.rectangle('fill', 
            cursorX, 
            cursorY, 
            2, 
            typewriter.font:getHeight()
        )
    end
    
    -- Disable stencil test after drawing content
    love.graphics.setStencilTest()
    
    -- Draw paper edge highlight
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.line(
        paperX, paperY,
        paperX + typewriter.paperWidth, paperY
    )
    love.graphics.line(
        paperX, paperY,
        paperX, paperY + typewriter.paperHeight
    )
    
    -- Draw keyboard
    local keySize = 45  -- Slightly smaller keys
    local spacing = 5   -- Reduced spacing
    local maxRowLength = #typewriter.keyLayout[1]
    local keyboardWidth = maxRowLength * (keySize + spacing)
    local startX = typewriter.centerX - keyboardWidth/2
    local startY = typewriter.paperStartY + typewriter.paperHeight + 30  -- Adjusted spacing
    
    -- Calculate row offsets to center each row
    local rowOffsets = {}
    for i, row in ipairs(typewriter.keyLayout) do
        local rowWidth = #row * (keySize + spacing)
        rowOffsets[i] = (keyboardWidth - rowWidth) / 2
    end
    
    -- Draw keyboard with centered rows and special keys
    for row, keys in ipairs(typewriter.keyLayout) do
        for col, key in ipairs(keys) do
            -- Adjust width for special keys
            local keyWidth = keySize
            if key == 'DEL' then
                keyWidth = keySize * 1.5  -- 1.5x width for delete
            elseif key == 'ENTER' then
                keyWidth = keySize * 2    -- 2x width for enter
            end
            
            local x = startX + rowOffsets[row] + (col-1) * (keySize + spacing)
            local y = startY + (row-1) * (keySize + spacing)
            
            -- Key press animation
            local keyOffset = 0
            if typewriter.pressedKeys[key] then
                keyOffset = 4 * (typewriter.pressedKeys[key] / 0.1)  -- Increased animation
            end
            
            -- Key shadow (darker and more pronounced)
            love.graphics.setColor(0.05, 0.05, 0.05)
            love.graphics.rectangle('fill', x+2, y+2, keyWidth, keySize, 10)
            
            -- Key body
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.rectangle('fill', x, y + keyOffset, keyWidth, keySize, 10)
            
            -- Key highlight
            love.graphics.setColor(0.35, 0.35, 0.35)
            love.graphics.rectangle('fill', x, y + keyOffset, keyWidth, keySize/2, 10)
            
            -- Key text (larger and brighter)
            love.graphics.setColor(1, 1, 1)
            local textX = x + keyWidth/2 - typewriter.font:getWidth(key)/2
            local textY = y + keyOffset + keySize/2 - typewriter.font:getHeight()/2
            love.graphics.print(key, textX, textY)
        end
    end
end

-- Helper function to play sounds
local function playSound(name)
    if typewriter.sounds[name] then
        if name == 'carriage' then
            -- Stop any existing carriage sound
            typewriter.sounds.carriage:stop()
            -- Play from start
            typewriter.sounds.carriage:play()
        else
            -- For other sounds, use cloning as before
            local clone = typewriter.sounds[name]:clone()
            clone:play()
        end
    end
end

-- Helper function for starting return animation
local function startReturn()
    typewriter.returnAnimation = 1.0
    typewriter.returnProgress = 0
    typewriter.returnStartX = typewriter.carriagePosition
    table.insert(typewriter.lines, typewriter.currentLine)
    typewriter.currentLine = ""
    
    -- Play carriage return sound
    playSound('carriage')
    
    -- Move paper up if needed
    if #typewriter.lines * typewriter.gridSize > typewriter.paperHeight - 50 then
        typewriter.paperY = typewriter.paperY - typewriter.gridSize
    end
end

function love.textinput(text)
    if typewriter.returnAnimation > 0 then return end
    
    text = text:upper()
    if allowedCharsSet[text] then
        -- Check if we have room to move
        local charWidth = typewriter.font:getWidth(text)
        if typewriter.carriagePosition + charWidth <= typewriter.paperMaxOffset then
            typewriter.currentLine = typewriter.currentLine .. text
            typewriter.pressedKeys[text] = 0.1
            typewriter.carriagePosition = typewriter.carriagePosition + charWidth
            
            -- Play key click sound
            playSound('key_click')
            
            -- Check if we need to return
            if typewriter.carriagePosition >= typewriter.paperMaxOffset or 
               #typewriter.currentLine >= typewriter.lineWidth then
                startReturn()
            end
        end
    end
end

function love.keypressed(key)
    if typewriter.returnAnimation > 0 then return end
    
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' then
        startReturn()
        typewriter.pressedKeys['ENTER'] = 0.1
    elseif key == 'backspace' then
        if #typewriter.currentLine > 0 then
            local removedChar = typewriter.currentLine:sub(-1)
            typewriter.currentLine = typewriter.currentLine:sub(1, -2)
            typewriter.carriagePosition = typewriter.carriagePosition - typewriter.font:getWidth(removedChar)
            typewriter.pressedKeys['DEL'] = 0.1
            -- Play backspace sound
            playSound('backspace')
        end
    elseif key == 'space' then
        if typewriter.carriagePosition < typewriter.carriageMaxWidth then
            typewriter.currentLine = typewriter.currentLine .. ' '
            typewriter.pressedKeys[' '] = 0.1
            typewriter.carriagePosition = typewriter.carriagePosition + typewriter.font:getWidth(' ')
            -- Play space bar sound
            playSound('space')
        end
    end
end

-- Add mouse click handling for keyboard
function love.mousepressed(x, y, button)
    if button ~= 1 then return end  -- Only handle left clicks
    
    -- Get keyboard dimensions
    local keySize = 45
    local spacing = 5
    local maxRowLength = #typewriter.keyLayout[1]
    local keyboardWidth = maxRowLength * (keySize + spacing)
    local startX = typewriter.centerX - keyboardWidth/2
    local startY = typewriter.paperStartY + typewriter.paperHeight + 30
    
    -- Check each key
    for row, keys in ipairs(typewriter.keyLayout) do
        local rowOffset = (keyboardWidth - #keys * (keySize + spacing)) / 2
        for col, key in ipairs(keys) do
            local keyWidth = keySize
            if key == 'DEL' then
                keyWidth = keySize * 1.5
            elseif key == 'ENTER' then
                keyWidth = keySize * 2
            end
            
            local keyX = startX + rowOffset + (col-1) * (keySize + spacing)
            local keyY = startY + (row-1) * (keySize + spacing)
            
            -- Check if click is within key bounds
            if x >= keyX and x <= keyX + keyWidth and
               y >= keyY and y <= keyY + keySize then
                -- Handle key press
                if key == 'ENTER' then
                    if typewriter.returnAnimation == 0 then  -- Check if not already returning
                        startReturn()
                        typewriter.pressedKeys['ENTER'] = 0.1
                    end
                elseif key == 'DEL' then
                    if #typewriter.currentLine > 0 then
                        local removedChar = typewriter.currentLine:sub(-1)
                        typewriter.currentLine = typewriter.currentLine:sub(1, -2)
                        typewriter.carriagePosition = typewriter.carriagePosition - typewriter.font:getWidth(removedChar)
                        typewriter.pressedKeys['DEL'] = 0.1
                        playSound('key_click')  -- Use key click for backspace
                    end
                else
                    -- Regular character key
                    if typewriter.returnAnimation == 0 then  -- Fixed comparison
                        love.textinput(key)
                    end
                end
                break
            end
        end
    end
end 