-- original code published on https://awesomewm.org/wiki/Farhavens_volume_widget
local wibox = require("wibox")
local awful = require("awful")

-- Sound Widget
local cardid  = 0
local channel = "Master"
function volume (mode, widget)
   if mode == "update" then
      local fd = io.popen("amixer -c " .. cardid .. " -- sget " .. channel)
      local status = fd:read("*all")
      fd:close()
      
      local volume = string.match(status, "(%d?%d?%d)%%")
      volume = string.format("% 3d", volume)
      
      status = string.match(status, "%[(o[^%]]*)%]")
      
      if string.find(status, "on", 1, true) then
	 volume = "Vol: <span color='green'>" .. volume .. "</span>% | "
      else
	 volume = "Vol: <span color='red'>" .. volume .. "</span>M | "
      end
      widget:set_markup(volume)
   elseif mode == "up" then
      io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+"):read("*all")
      volume("update", widget)
   elseif mode == "down" then
      io.popen("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-"):read("*all")
      volume("update", widget)
   else
      io.popen("amixer set Master toggle"):read("*all")
      volume("update", widget)
   end
end

-- Create Volume Control Widget
tb_volume = wibox.widget.textbox()
tb_volume:set_align("right")
tb_volume:buttons(awful.util.table.join(
		     awful.button({ }, 4, function () volume("up", tb_volume) end),
		     awful.button({ }, 5, function () volume("down", tb_volume) end),
		     awful.button({ }, 1, function () volume("mute", tb_volume) end)
))
volume("update", tb_volume)

-- refresh the Volume Control Widget
vol_timer = timer({timeout = 1})
vol_timer:connect_signal("timeout", function() volume("update", tb_volume) end)
vol_timer:start()
