-- Original code made by baojie and published on https://gist.github.com/baojie/6336134
-- Work with awesome 3.5
-- Standard awesome library
local awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")
-- Notification library
local naughty = require("naughty")
-- Theme handling library
local beautiful = require("beautiful")
local wibox = require("wibox")

-- Load Debian menu entries
require("debian.menu")
-- Load widget
local cal = require("cal")
require("volume")
require("perf")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
		    title = "Oops, there were errors during startup!",
		    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
			     -- Make sure we don't go into an endless error loop
			     if in_error then return end
			     in_error = true

			     naughty.notify({ preset = naughty.config.presets.critical,
					      title = "Oops, an error happened!",
					      text = err })
			     in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "emacs"
editor_cmd = terminal .. " -e " .. editor .. "-nw"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
   {
      awful.layout.suit.floating,
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      awful.layout.suit.tile.bottom,
      awful.layout.suit.tile.top,
      awful.layout.suit.fair,
      awful.layout.suit.fair.horizontal,
      awful.layout.suit.spiral,
      awful.layout.suit.spiral.dwindle,
      awful.layout.suit.max,
      awful.layout.suit.max.fullscreen,
      awful.layout.suit.magnifier
   }
-- }}}
awful.screen.focus_relative( 1)
-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tags[1] = {
   names  = { "main", "network", "graphic", "office" },
   layout = { layouts[3], layouts[3], layouts[3], layouts[3] }}

tags[2] = {
   names  = { "main", "network", "media", "office" },
   layout = { layouts[2], layouts[2], layouts[2], layouts[2] }}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
			     { "Debian", debian.menu.Debian_menu.Debian },
			     { "open terminal", terminal }
}
		       })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- declare all hash table
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytasklist = {}

local taglist_buttons = awful.util.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
	 if client.focus then
	    client.focus:move_to_tag(t)
	 end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
	 if client.focus then
	    client.focus:toggle_tag(t)
	 end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
	 if c == client.focus then
	    c.minimized = true
	 else
	    if not c:isvisible() and c.first_tag then
	       c.first_tag:view_only()
	    end
	    -- This will also un-minimize
	    -- the client, if needed
	    client.focus = c
	    c:raise()
	 end
   end),
   awful.button({ }, 3, function ()
	 if instance then
	    instance:hide()
	    instance = nil
	 else
	    instance = awful.menu.clients({ width=250 })
	 end
   end),
   awful.button({ }, 4, function ()
	 awful.client.focus.byidx(1)
	 if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 5, function ()
	 awful.client.focus.byidx(-1)
	 if client.focus then client.focus:raise() end
   end)
)

mycalendar = wibox.widget.textclock()
mycalendar:set_align("right")

cal.register(mycalendar)

local idx = 1
awful.screen.connect_for_each_screen(function(s)
      -- Each screen has its own tag table
      awful.tag(tags[idx].names,s,tags[idx].layout)
      -- Create a promptbox for each screen
      s.mypromptbox = awful.widget.prompt()
      -- Create an imagebox widget which will contains an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      s.mylayoutbox = awful.widget.layoutbox(s)
      s.mylayoutbox:buttons(awful.util.table.join(
			       awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			       awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			       awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			       awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

      -- Create a taglist widget
      s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

      -- Create a tasklist widget
      s.mytasklist = awful.widget.tasklist(s,awful.widget.tasklist.filter.currenttags,tasklist_buttons)
      
      -- Create the wibox
      s.mywibox = awful.wibar({ position = "top", screen = s })

      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(s.mytaglist)
      left_layout:add(s.mypromptbox)

      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(wibox.widget.systray())
      right_layout:add(meminfo)
      right_layout:add(cpuinfo)
      right_layout:add(tb_volume)
      right_layout:add(mycalendar)
      right_layout:add(s.mylayoutbox)

      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_middle(s.mytasklist)
      layout:set_right(right_layout)
      
      s.mywibox:set_widget(layout)
      idx = idx + 1
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev       ),
   awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext       ),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

   awful.key({ modkey,           }, "j",
      function ()
	 awful.client.focus.byidx( 1)
	 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "k",
      function ()
	 awful.client.focus.byidx(-1)
	 if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey, "Control" }, "w", function () mymainmenu:show({keygrabber=true}) end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
   awful.key({ modkey,           }, "Tab",
      function ()
	 awful.client.focus.history.previous()
	 if client.focus then
	    client.focus:raise()
	 end
   end),

   -- Standard program
   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
   awful.key({ modkey, "Control" }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

   awful.key({ modkey, "Control" }, "n", awful.client.restore),

   -- Prompt
   awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end),
   
   awful.key({ modkey, "Shift" }, "x",
      function ()
	 awful.prompt.run {
	    prompt       = "Run Lua code: ",
	    textbox      = awful.screen.focused().mypromptbox.widget,
	    exe_callback = awful.util.eval,
	    history_path = awful.util.get_cache_dir() .. "/history_eval"
	 }
   end),
   -- Lock screen
   awful.key({ modkey, "Control" }, "l", function () awful.spawn("xscreensaver-command -lock") end),
   --keys to sort the volume
   awful.key( {}, "XF86AudioLowerVolume", function () volume("down", tb_volume) end),
   awful.key( {}, "XF86AudioRaiseVolume", function () volume("up", tb_volume) end),
   awful.key( {}, "XF86AudioMute", function () volume("mute", tb_volume) end)

)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "n",
      function (c)
	 -- The client currently has the input focus, so it cannot be
	 -- minimized, since minimized clients can't have the focus.
	 c.minimized = true
   end),
   awful.key({ modkey,           }, "m",
      function (c)
	 c.maximized_horizontal = not c.maximized_horizontal
	 c.maximized_vertical   = not c.maximized_vertical
   end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 4 do
   globalkeys = awful.util.table.join(globalkeys,
				      awful.key({ modkey }, "#" .. i + 9,
					 function ()
					    local screen = awful.screen.focused()
					    local tag = screen.tags[i]
					    if tag then
					       tag:view_only()
					    end
				      end),
				      awful.key({ modkey, "Control" }, "#" .. i + 9,
					 function ()
					    local screen = awful.screen.focused()
					    local tag = screen.tags[i]
					    if tag then
					       awful.tag.viewtoggle(tag)
					    end
				      end),
				      awful.key({ modkey, "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus then
					       local tag = client.focus.screen.tags[i]
					       if tag then
						  client.focus:move_to_tag(tag)
					       end
					    end
				      end),
				      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus then
					       local tag = client.focus.screen.tags[i]
					       if tag then
						  client.focus:toggle_tag(tag)
					       end
					    end
   end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
		    border_color = beautiful.border_normal,
		    focus = true,
		    keys = clientkeys,
		    buttons = clientbuttons,
		    screen = awful.screen.preferred,
		    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		    size_hints_honor = false } },
   --{ rule = { class = "MPlayer" },
   --  properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
			 -- Enable sloppy focus
			 c:connect_signal("mouse::enter", function(c)
					     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
					     and awful.client.focus.filter(c) then
						client.focus = c
					     end
			 end)

			 if not startup then
			    -- Set the windows at the slave,
			    -- i.e. put it at the end of others instead of setting it master.
			    -- awful.client.setslave(c)

			    -- Put windows in a smart way, only if they does not set an initial position.
			    if not c.size_hints.user_position and not c.size_hints.program_position then
			       awful.placement.no_overlap(c)
			       awful.placement.no_offscreen(c)
			    end
			 end
end)
-- }}}

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
