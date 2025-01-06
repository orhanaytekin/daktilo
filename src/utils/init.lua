local inspect = require('lib.inspect')

local Utils = {}

-- File operations
function Utils.saveToFile(filename, data)
    local success, message = love.filesystem.write(filename, data)
    return success
end

function Utils.loadFromFile(filename)
    if love.filesystem.getInfo(filename) then
        return love.filesystem.read(filename)
    end
    return nil
end

-- Sound utilities
function Utils.playSound(sound, volume, pitch)
    if sound then
        sound:setVolume(volume or 1.0)
        sound:setPitch(pitch or 1.0)
        sound:play()
    end
end

-- Animation utilities
function Utils.createTween(start, target, duration, easing)
    return tween.new(duration, start, target, easing or 'outQuad')
end

-- Particle effects
function Utils.createParticleEffect(x, y, count, color)
    local particles = love.graphics.newParticleSystem(
        love.graphics.newImage('assets/images/particle.png'),
        count
    )
    
    particles:setPosition(x, y)
    particles:setColors(unpack(color))
    particles:setEmissionRate(count)
    particles:setParticleLifetime(0.5)
    particles:setSizes(0.02, 0.01)
    
    return particles
end

-- Shader utilities
function Utils.loadShader(vertexPath, fragmentPath)
    local vertexShader = Utils.loadFromFile(vertexPath)
    local fragmentShader = Utils.loadFromFile(fragmentPath)
    
    if vertexShader and fragmentShader then
        return love.graphics.newShader(vertexShader, fragmentShader)
    end
    return nil
end

-- Math utilities
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Debug utilities
function Utils.debugPrint(...)
    if love.conf and love.conf.console then
        print(inspect.inspect(...))
    end
end

-- Asset management
function Utils.loadAssets(assetDir)
    local assets = {
        sounds = {},
        textures = {},
        shaders = {}
    }
    
    local items = love.filesystem.getDirectoryItems(assetDir)
    for _, item in ipairs(items) do
        local path = assetDir .. '/' .. item
        local ext = item:match("%.([^%.]+)$")
        
        if ext then
            if ext == 'wav' or ext == 'ogg' then
                assets.sounds[item] = love.audio.newSource(path, 'static')
            elseif ext == 'png' or ext == 'jpg' then
                assets.textures[item] = love.graphics.newImage(path)
            elseif ext == 'glsl' or ext == 'shader' then
                assets.shaders[item] = Utils.loadShader(path)
            end
        end
    end
    
    return assets
end

-- Settings management
function Utils.saveSettings(settings, filename)
    local serialized = inspect.inspect(settings)
    return Utils.saveToFile(filename, serialized)
end

function Utils.loadSettings(filename)
    local content = Utils.loadFromFile(filename)
    if content then
        local fn = load('return ' .. content)
        if fn then
            return fn()
        end
    end
    return nil
end

-- Export utilities
return Utils 