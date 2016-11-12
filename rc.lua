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
-- local mocp=require("mocp")

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
tags_s1 = {
   names  = { "main", "network", "graphic", "office" },
   layout = { layouts[3], layouts[3], layouts[3], layouts[3]
}}
tags_s2 = {
   names  = { "main", "network", "media", "office" },
   layout = { layouts[2], layouts[2], layouts[2], layouts[2]
   }}

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
   if s == 1 then tags[s] = awful.tag(tags_s1.names, s, tags_s1.layout)
   else tags[s] = awful.tag(tags_s2.names, s, tags_s2.layout) end --Specific tags and disposition for screen2
end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
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

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
		     awful.button({ }, 1, awful.tag.viewonly),
		     awful.button({ modkey }, 1, awful.client.movetotag),
		     awful.button({ }, 3, awful.tag.viewtoggle),
		     awful.button({ modkey }, 3, awful.client.toggletag),
		     awful.button({ }, 4, awful.tag.viewnext),
		     awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
		      awful.button({ }, 1, function (c)
			    if c == client.focus then
			       c.minimized = true
			    else
			       if not c:isvisible() then
				  awful.tag.viewonly(c:tags()[1])
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

mycalendar = awful.widget.textclock()
mycalendar:set_align("right")

cal.register(mycalendar)

-- mocpwidget = wibox.widget.textbox()
-- mocpwidget:set_align("right")
-- mocp.setwidget(mocpwidget)
-- mocpwidget:buttons({
-- 		      button({ }, 1, function () mocp.play(); mocp.popup() end ),
-- 		      button({ }, 2, function () awful.util.spawn('mocp --toggle-pause') end),
-- 		      button({ }, 4, function () awful.util.spawn('mocp --toggle-pause') end),
-- 		      button({ }, 3, function () awful.util.spawn('mocp --previous'); mocp.popup() end),
-- 		      button({ }, 5, function () awful.util.spawn('mocp --previous'); mocp.popup() end)
-- 		   })
-- mocpwidget.mouse_enter = function() mocp.popup() end
-- awful.hooks.timer.register(mocp.settings.interval,mocp.scroller)

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   -- mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
			     awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			     awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			     awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			     awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
			 ))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s,awful.widget.tasklist.filter.currenttags,mytasklist.buttons)
   
   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   local right_layout = wibox.layout.fixed.horizontal()
   if s == 1 then right_layout:add(wibox.widget.systray()) end
   right_layout:add(meminfo)
   right_layout:add(cpuinfo)
   right_layout:add(tb_volume)
   right_layout:add(mycalendar)
   right_layout:add(mylayoutbox[s])

   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)
   
   mywibox[s]:set_widget(layout)
end
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
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
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
   awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

   awful.key({ modkey, "Shift" }, "x",
      function ()
	 awful.prompt.run({ prompt = "Run Lua code: " },
	    mypromptbox[mouse.screen].widget,
	    awful.util.eval, nil,
	    awful.util.getdir("cache") .. "/history_eval")
   end),
   -- Lock screen
   awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("xscreensaver-command -lock") end),
   --keys to sort the volume
   awful.key( {}, "XF86AudioLowerVolume", function () volume("down", tb_volume) end),
   awful.key( {}, "XF86AudioRaiseVolume", function () volume("up", tb_volume) end),
   awful.key( {}, "XF86AudioMute", function () volume("mute", tb_volume) end)

   -- awful.key( {}, "XF86AudioPlay", function () mocp_control("play") end),
   -- awful.key( {}, "XF86AudioNext", function () mocp_control("next") end),
   -- awful.key( {}, "XF86AudioPrev", function () mocp_control("prev") end)
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
   awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
				      awful.key({ modkey }, "#" .. i + 9,
					 function ()
					    local screen = mouse.screen
					    if tags[screen][i] then
					       awful.tag.viewonly(tags[screen][i])
					    end
				      end),
				      awful.key({ modkey, "Control" }, "#" .. i + 9,
					 function ()
					    local screen = mouse.screen
					    if tags[screen][i] then
					       awful.tag.viewtoggle(tags[screen][i])
					    end
				      end),
				      awful.key({ modkey, "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus and tags[client.focus.screen][i] then
					       awful.client.movetotag(tags[client.focus.screen][i])
					    end
				      end),
				      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
					 function ()
					    if client.focus and tags[client.focus.screen][i] then
					       awful.client.toggletag(tags[client.focus.screen][i])
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
		    size_hints_honor = false } },
   --{ rule = { class = "MPlayer" },
   --  properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { tag = tags[1][2] } },
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
