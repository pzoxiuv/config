-- Standard awesome library
local revelation = require("revelation")
local wibox = require("wibox")
local awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local gears = require("gears")

-- Load Debian menu entries
require("debian.menu")

local vicious = require("vicious")

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
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/alex/.config/awesome/theme.lua")
revelation.init()

for s = 1, screen.count() do
	--gears.wallpaper.maximized("/home/alex/Pictures/Backgrounds/winterlake.jpg", s, true)
	gears.wallpaper.maximized("/home/alex/Pictures/Backgrounds/TorontoKingStDatacenter.jpg", s, false)
end

-- This is used later as the default terminal and editor to run.
--terminal = "x-terminal-emulator"
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

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
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7 }, s, layouts[2])
end
-- }}}

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

--mylauncher = awful.widget.launcher({ image = set_image(beautiful.awesome_icon),
--                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Volume widget:
vol = wibox.widget.textbox() --widget( { type = "textbox" } )
vicious.register(vol, vicious.widgets.volume, 
		function (widget, args)
			if args [1] == 0 or args [2] == "♩" then
				--return "<span color=\"" .. beautiful.clock_fg .. "\">Mute </span>"
				return "<span color=\"#1ABF46\">Mute </span>"
			else
				--return "<span color=\"" .. beautiful.clock_fg .. "\">" .. args[1] .. "% </span>"
				return "<span color=\"#1ABF46\">" .. args[1] .. "% </span>"
			end
		end , 1, "Master")
--volicon = widget( { type = "imagebox" } )
volicon = wibox.widget.imagebox()
--volicon.image = image (awful.util.getdir("config") .. "/icons/green/volume.png")
volicon:set_image (awful.util.getdir("config") .. "/icons/green/volume.png")

-- Battery widget:
--baticon = widget( { type = "imagebox" } )
baticon = wibox.widget.imagebox()
--bat = widget( { type = "textbox" } )
bat = wibox.widget.textbox()
vicious.register(bat, vicious.widgets.bat, 
		function (widget, args)
			if args [1] == "+" or args [1] == "↯" then
				baticon:set_image(awful.util.getdir("config") .. "/icons/green/power.png")
			else
				baticon:set_image(awful.util.getdir("config") .. "/icons/green/battery_2.png")
			end
			return "<span color=\"#1ABF46\">" .. args[2] .. "% </span>"
		end, 60, "BAT0")

--mypadding = widget( { type = "textbox" } )
mypadding = wibox.widget.textbox()
mypadding.text = " "

-- Create a textclock widget
--mytextclock = awful.widget.textclock( { align = "right" },
--				"<span color=\"" .. beautiful.clock_fg .. "\">%m/%d %I:%M</span>")
mytextclock = awful.widget.textclock("<span color=\"#1ABF46\">%m/%d %I:%M</span>")
--clockicon = widget ( { type = "imagebox" } )
clockicon = wibox.widget.imagebox()
clockicon:set_image(awful.util.getdir("config") .. "/icons/green/clock.png")
--clockicon.image = image (awful.util.getdir("config") .. "/icons/green/clock.png")

-- Create a systray
-- mysystray = widget({ type = "systray" })
--mysystray = wibox.wibox.systray()

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
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    --mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    --mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
--    mytasklist[s] = awful.widget.tasklist(function(c)
                                              	--return awful.widget.tasklist.label.currenttags(c, s)
												-- don't return the icon (last return value)
--												local tmptask = { awful.widget.tasklist.label.currenttags (c, s) }
--												return tmptask [1], tmptask [2], tmptask [3], nil
--                                          end, mytasklist.buttons)
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylayoutbox[s])
	left_layout:add(mypadding)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])

	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(volicon)
	right_layout:add(mypadding)
	right_layout:add(vol)
	right_layout:add(baticon)
	right_layout:add(mypadding)
	right_layout:add(bat)
	right_layout:add(clockicon)
	right_layout:add(mypadding)
	right_layout:add(mytextclock)
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)
--    mywibox[s].widgets = {
  --      {
    --        --mylauncher,
    --    	mylayoutbox[s],
	--		mypadding,
     --       mytaglist[s],
      --      mypromptbox[s],
      --      layout = awful.widget.layout.horizontal.leftright
       -- },
       -- mytextclock,
		--mypadding,
	--	clockicon,
	--	bat,
	--	mypadding,
--		baticon,
	--	vol,
	--	mypadding,
	--	volicon,
        --s == 1 and mysystray or nil,
     --   mytasklist[s],
     --   layout = awful.widget.layout.horizontal.rightleft
    --}
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
    awful.key({            }, "XF86AudioMute", function () awful.util.spawn("amixer -D pulse set Master toggle") end),
    awful.key({            }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 5%+") end),
    awful.key({            }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 5%-") end),
    
	awful.key({ modkey, "Control" }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey, "Control" }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
    --awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
    --awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Revelation
    awful.key({ modkey, }, "p", revelation),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
--    awful.key({ modkey,           }, "Tab",
    --awful.key({ modkey,           }, "j",
--        function ()
--            awful.client.focus.history.previous()
--            if client.focus then
--                client.focus:raise()
--            end
--        end),

    -- Standard program
    --awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
	-- Opens a terminal in the most common CWD for this tag
    awful.key({ modkey,           }, "Return",
				function ()
					paths = {}
					pathname = ""
					most_common_num = 0
					most_common_str = ""
					current_tag = tags[mouse.screen][awful.tag.getidx()]
					for _, c in pairs(current_tag:clients()) do
						pid = c.pid
						if string.find(c.name, "Terminal") then
							pathname = string.sub(c.name, 26)
							if paths[pathname] == nil then
								paths[pathname] = 1
							else
								paths[pathname] = paths[pathname] + 1
							end
							if paths[pathname] > most_common_num then
								most_common_num = paths[pathname]
								most_common_str = pathname
							end
						end
					end
					expanded_str = most_common_str:gsub("~", os.getenv("HOME") .. "/")
					awful.util.spawn("xfce4-terminal --working-directory=\"" .. expanded_str .. "\"")
				end),

    awful.key({ "Control"           }, "space", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(1, mouse.screen, layouts) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1, mouse.screen, layouts) end),
    awful.key({ modkey, "Control" }, "a",
				function ()
					paths = {}
					pathname = ""
					most_common_num = 0
					most_common_str = ""
					current_tag = tags[mouse.screen][awful.tag.getidx()]
					for _, c in pairs(current_tag:clients()) do
						pid = c.pid
						if string.find(c.name, "Terminal") then
							pathname = string.sub(c.name, 26)
							if paths[pathname] == nil then
								paths[pathname] = 1
							else
								paths[pathname] = paths[pathname] + 1
							end
							if paths[pathname] > most_common_num then
								most_common_num = paths[pathname]
								most_common_str = pathname
							end
						end
					end
					expanded_str = most_common_str:gsub("~", os.getenv("HOME") .. "/")
					awful.util.spawn("xfce4-terminal --working-directory=\"" .. expanded_str .. "\"")
				end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    --awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
--            c.minimized = true
        end)
    --awful.key({ modkey,           }, "m",
    --    function (c)
      --      c.maximized_horizontal = not c.maximized_horizontal
        --    c.maximized_vertical   = not c.maximized_vertical
       -- end)
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
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
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
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

awful.util.spawn_with_shell("numlockx")
awful.util.spawn_with_shell("xmodmap /home/alex/.xmodmap")
-- }}}
