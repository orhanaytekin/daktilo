local tween = {
  _VERSION     = 'tween 2.1.1',
  _DESCRIPTION = 'tweening for lua',
  _URL         = 'https://github.com/kikito/tween.lua',
  _LICENSE     = [[
    MIT LICENSE
    Copyright (c) 2014 Enrique García Cota
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- Easing functions
local easing = {
  linear = function(t) return t end,
  outQuad = function(t) return t * (2 - t) end,
  inQuad = function(t) return t * t end
}

-- Creates a new tween
local function newTween(duration, subject, target, easing)
  local self = {
    duration = duration,
    subject = subject,
    target = target,
    easing = easing or 'linear',
    time = 0,
    finished = false
  }
  
  -- Update the tween
  function self:update(dt)
    if self.finished then return end
    
    self.time = self.time + dt
    local t = math.min(1, self.time / self.duration)
    local factor = easing[self.easing](t)
    
    for k, v in pairs(self.target) do
      if type(v) == 'number' then
        self.subject[k] = self.subject[k] + (v - self.subject[k]) * factor
      end
    end
    
    if t == 1 then
      self.finished = true
    end
  end
  
  return self
end

-- Main tween function
function tween.new(duration, subject, target, easing)
  return newTween(duration, subject, target, easing)
end

return tween 