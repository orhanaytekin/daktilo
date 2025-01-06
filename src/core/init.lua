local Object = require('lib.classic')
local tween = require('lib.tween')
local inspect = require('lib.inspect')

-- Core Typewriter class
local Typewriter = Object:extend()

function Typewriter:new()
    self.state = {
        text = "",
        currentLine = "",
        lines = {},
        lineWidth = 60,
        paperY = 0,
        keyPressed = nil,
        isDirty = false,  -- For shader updates
        lastSave = os.time()
    }
    
    -- Modern settings with defaults
    self.settings = {
        soundEnabled = true,
        paperWidth = 600,
        paperHeight = 500,
        margin = 40,
        fontSize = 16,
        autoSave = true,
        autoSaveInterval = 300,  -- 5 minutes
        theme = 'classic',
        particleEffects = true,
        shaderEffects = true
    }
    
    -- Initialize systems
    self:initializeSounds()
    self:initializeAnimations()
    self:initializeParticles()
    self:initializeShaders()
end

function Typewriter:initializeSounds()
    -- Create a default beep sound if we don't have the actual sound files
    local defaultSound = love.sound.newSoundData(1024, 44100, 16, 1)
    for i = 0, 1023 do
        defaultSound:setSample(i, math.sin(i * 0.1) * 0.5)  -- Simple sine wave
    end
    
    -- Try to load sound files, fall back to default beep
    self.sounds = {
        keypress = love.filesystem.getInfo('assets/sounds/keypress.wav') 
            and love.audio.newSource('assets/sounds/keypress.wav', 'static')
            or love.audio.newSource(defaultSound),
            
        ding = love.filesystem.getInfo('assets/sounds/ding.wav')
            and love.audio.newSource('assets/sounds/ding.wav', 'static')
            or love.audio.newSource(defaultSound),
            
        return_sound = love.filesystem.getInfo('assets/sounds/return.wav')
            and love.audio.newSource('assets/sounds/return.wav', 'static')
            or love.audio.newSource(defaultSound),
            
        space = love.filesystem.getInfo('assets/sounds/space.wav')
            and love.audio.newSource('assets/sounds/space.wav', 'static')
            or love.audio.newSource(defaultSound)
    }
    
    -- Set properties for sound
    for _, sound in pairs(self.sounds) do
        sound:setVolume(0.7)
    end
end

function Typewriter:initializeAnimations()
    self.animations = {
        keys = {},
        paper = {
            target = 0,
            current = 0,
            tween = nil
        },
        carriage = {
            x = 0,
            target = 0,
            tween = nil
        }
    }
end

function Typewriter:initializeParticles()
    -- Create a default particle texture if we don't have one
    local particleTexture
    if love.filesystem.getInfo('assets/images/particle.png') then
        particleTexture = love.graphics.newImage('assets/images/particle.png')
    else
        local imageData = love.image.newImageData(8, 8)
        for i = 0, 7 do
            for j = 0, 7 do
                local dist = math.sqrt((i-3.5)^2 + (j-3.5)^2)
                local alpha = math.max(0, 1 - dist/4)
                imageData:setPixel(i, j, 1, 1, 1, alpha)
            end
        end
        particleTexture = love.graphics.newImage(imageData)
    end
    
    self.particles = love.graphics.newParticleSystem(
        particleTexture,
        1000  -- Max particles
    )
    
    self.particles:setEmissionRate(0)
    self.particles:setLinearDamping(1)
    self.particles:setSpeed(1, 2)
    self.particles:setSpin(0, 2*math.pi)
    self.particles:setParticleLifetime(0.5)
    self.particles:setSizes(0.02, 0.01)
end

function Typewriter:initializeShaders()
    -- Paper texture shader
    self.shaders = {
        paper = love.graphics.newShader([[
            vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
                return projection * transform * vertex;
            }
        ]], [[
            vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
                // Paper texture effect
                float noise = fract(sin(dot(texture_coords, vec2(12.9898, 78.233))) * 43758.5453);
                vec4 paperColor = vec4(0.98, 0.97, 0.95, 1.0);
                return mix(color, paperColor, noise * 0.1);
            }
        ]]),
        
        -- Ink spreading shader
        ink = love.graphics.newShader([[
            vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
                return projection * transform * vertex;
            }
        ]], [[
            uniform float time;
            
            vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
                float spread = sin(time * 10.0) * 0.005;
                vec2 offset = vec2(spread);
                vec4 inkColor = vec4(0.0, 0.0, 0.0, 1.0);
                return mix(color, inkColor, 0.9);
            }
        ]])
    }
end

function Typewriter:handleInput(text)
    -- Add character to current line
    self.state.currentLine = self.state.currentLine .. text
    
    -- Check if we need to start a new line
    if #self.state.currentLine >= self.state.lineWidth then
        self:newLine()
    end
end

function Typewriter:newLine()
    table.insert(self.state.lines, self.state.currentLine)
    self.state.currentLine = ""
    
    -- Calculate if we need to scroll
    if #self.state.lines * 20 > self.settings.paperHeight - self.settings.margin then
        self.animations.paper.target = self.animations.paper.target - 20
    end
end

-- Core update logic
function Typewriter:update(dt)
    -- Update particles
    if self.particles then
        self.particles:update(dt)
    end
    
    -- Update animations
    for key, anim in pairs(self.animations.keys) do
        if anim.tween then
            anim.tween:update(dt)
        end
    end
    
    -- Update paper movement
    if self.animations.paper.tween then
        self.animations.paper.tween:update(dt)
    end
    
    -- Update carriage movement
    if self.animations.carriage.tween then
        self.animations.carriage.tween:update(dt)
    end
    
    -- Auto-save check
    if self.settings.autoSave and os.time() - self.state.lastSave > self.settings.autoSaveInterval then
        self:saveState()
    end
end

-- Export the module
return Typewriter 