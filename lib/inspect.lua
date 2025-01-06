local inspect = {
  _VERSION = 'inspect.lua 3.1.0',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE
    Copyright (c) 2013 Enrique García Cota
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

-- Simple table to string conversion
local function basicToString(value)
  if type(value) == 'string' then
    return string.format('%q', value)
  end
  return tostring(value)
end

-- Convert table to string
local function tableToString(t, indent)
  indent = indent or ''
  local result = '{\n'
  for k, v in pairs(t) do
    result = result .. indent .. '  [' .. basicToString(k) .. '] = '
    if type(v) == 'table' then
      result = result .. tableToString(v, indent .. '  ')
    else
      result = result .. basicToString(v)
    end
    result = result .. ',\n'
  end
  return result .. indent .. '}'
end

-- Main inspect function
function inspect.inspect(value)
  if type(value) == 'table' then
    return tableToString(value)
  end
  return basicToString(value)
end

return inspect 