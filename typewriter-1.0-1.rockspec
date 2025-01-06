package = "typewriter"
version = "1.0-1"
source = {
   url = "git://github.com/orhanaytekin/daktilo",
   tag = "v1.0"
}
description = {
   summary = "A modern typewriter simulation",
   detailed = [[
      A beautiful and modern typewriter simulation built with LÖVR,
      featuring smooth animations, realistic sounds, and a modern architecture.
   ]],
   homepage = "http://github.com/orhanaytekin/daktilo",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "classic",  -- Modern OOP library
   "inspect",  -- Better debugging
   "luafilesystem",
   "tween",    -- For smooth animations
}
build = {
   type = "builtin",
   modules = {
      ["typewriter.core"] = "src/core/init.lua",
      ["typewriter.ui"] = "src/ui/init.lua",
      ["typewriter.utils"] = "src/utils/init.lua"
   }
} 