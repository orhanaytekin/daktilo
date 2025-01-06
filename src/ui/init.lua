local Object = require('lib.classic')
local inspect = require('lib.inspect')

-- Modern UI Component base class
local UIComponent = Object:extend()

function UIComponent:new(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.visible = true
    self.children = {}
    self.animations = {}
end

-- Paper component
local Paper = UIComponent:extend()

function Paper:new(x, y, width, height)
    Paper.super.new(self, x, y, width, height)
    
    -- Create a default paper texture if we don't have one
    if love.filesystem.getInfo('assets/images/paper_texture.png') then
        self.texture = love.graphics.newImage('assets/images/paper_texture.png')
    else
        local imageData = love.image.newImageData(32, 32)
        for i = 0, 31 do
            for j = 0, 31 do
                local noise = math.random() * 0.1 + 0.9
                imageData:setPixel(i, j, noise, noise, noise, 1)
            end
        end
        self.texture = love.graphics.newImage(imageData)
    end
    
    self.shader = nil  -- Will be set by main app
end

function Paper:draw()
    if self.shader then
        love.graphics.setShader(self.shader)
    end
    
    -- Draw paper background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    if self.shader then
        love.graphics.setShader()  -- Reset shader
    end
end

-- Typewriter Keys component
local Keys = UIComponent:extend()

function Keys:new(x, y)
    Keys.super.new(self, x, y, 700, 300)
    self.keys = {}
    self:initializeKeys()
end

function Keys:initializeKeys()
    local keyLayout = {
        {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='},
        {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'},
        {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'"},
        {'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'}
    }
    
    local keySize = 40
    local spacing = 5
    
    for row, keys in ipairs(keyLayout) do
        local rowOffset = (row - 1) * (keySize + spacing)
        for col, key in ipairs(keys) do
            local keyX = self.x + (col - 1) * (keySize + spacing)
            local keyY = self.y + rowOffset
            
            self.keys[key] = {
                x = keyX,
                y = keyY,
                width = keySize,
                height = keySize,
                pressed = false,
                animation = 0
            }
        end
    end
end

function Keys:draw()
    for key, data in pairs(self.keys) do
        -- Key shadow
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle('fill', 
            data.x + 2, 
            data.y + 2 + (data.pressed and 2 or 0), 
            data.width, 
            data.height)
        
        -- Key body
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.rectangle('fill', 
            data.x, 
            data.y + (data.pressed and 2 or 0), 
            data.width, 
            data.height)
        
        -- Key text
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(key, 
            data.x + data.width/2 - 5, 
            data.y + data.height/2 - 8 + (data.pressed and 2 or 0))
    end
end

-- Settings Panel component
local SettingsPanel = UIComponent:extend()

function SettingsPanel:new(x, y)
    SettingsPanel.super.new(self, x, y, 200, 300)
    self.visible = false
    self.settings = {
        soundEnabled = true,
        particleEffects = true,
        shaderEffects = true,
        theme = 'classic'
    }
end

function SettingsPanel:draw()
    if not self.visible then return end
    
    -- Panel background
    love.graphics.setColor(0.95, 0.95, 0.95, 0.9)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    
    -- Settings controls
    local y = self.y + 20
    for setting, value in pairs(self.settings) do
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(setting .. ': ' .. tostring(value), self.x + 10, y)
        y = y + 30
    end
end

-- Export UI components
return {
    Paper = Paper,
    Keys = Keys,
    SettingsPanel = SettingsPanel
} 