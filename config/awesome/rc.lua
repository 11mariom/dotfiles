-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("vicious")
require("shifty")


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init("/home/mariom/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
browser = "/home/mariom/bin/firefox-bin"
mpds = "/home/mariom/.config/awesome/"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- naughty cfg (!)
-- naughty.config.default_preset.opacity = .85

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- {{ Layouts
layouts =
{
    awful.layout.suit.tile,            --1
    awful.layout.suit.tile.left,       --2
    awful.layout.suit.tile.bottom,     --3
    awful.layout.suit.tile.top,        --4
    awful.layout.suit.fair,            --5
    awful.layout.suit.fair.horizontal, --6
    awful.layout.suit.spiral,          --7
    awful.layout.suit.spiral.dwindle,  --8
    awful.layout.suit.max,             --9
    awful.layout.suit.max.fullscreen,  --10
    awful.layout.suit.magnifier,       --11
    awful.layout.suit.floating         --12
}
-- }}}
-- {{ Shifty next tag
--function next_tag( name )
--   local n = 0
--   for _ in pairs( awful.tag.gettags(1) ) do
--      n = n +1
--   end
--
--   return n .. ":" .. name
--end

-- }}
-- {{ Shifty tags
shifty.config.tags = {
   ["1:main"] = { layout = awful.layout.suit.tile.right, mwfact = 0.675, 
		  init = true, exclusive = true, max_clients = 3, position = 1, },
   ["4:gimp"] = { layout = awful.layout.suit.tile, mwfact = 0.18, exclusive = true, },
   ["3:movie"] = { layout = awful.layout.suit.floating, exclusive = true, },
   ["4:rest"] = { layout = awful.layout.suit.floating, },
   ["4:wine"] = { layout = awful.layout.suit.floating, exclusive = true, },
   ["2:steam"] = { layout = awful.layout.suit.tile.right, mwfact = 0.8, nopopup = true},
}

shifty.config.apps = {
   { match = { "" }, 
     tag = "4:rest" },
   { match = { "Navigator", "Minefield", "Nightly", "urxvt" }, 
     tag = "1:main", minimized = false, },
   { match = { "urxvt" }, 
     slave = true, },
   { match = { "mplayer2" }, 
     tag = "3:movie", },
   { match = { "Gimp" }, 
     tag = "4:gimp", },
   { match = { "gimp%-image%-window" }, 
     slave = true, },
   { match = { class = { "Steam" }, }, 
     tag = "2:steam", },
--   { match = { class = { "Steam" }, name = { "czat" } },
--     float = true,
--     tag = "2:steam", },
   { match = { "" }, buttons = awful.util.table.join (
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, function (c) awful.mouse.client.move() end),
	awful.button({ modkey }, 3, function (c) awful.mouse.client.resize() end))
  },
}

shifty.config.defaults = {
   layout = awful.layout.suit.floating,
   guess_position = true,
   persist = false,
   leave_kill = false,
   exclusive = false,
   remember_index = true,
   mwfact = 0.675,
   run = function(tag) naughty.notify({ text = tag.name }) end,
}
-- }}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
-- Create a systray
-- mysystray = widget({ type = "systray" })

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
--clocki = widget({ type = "imagebox" })
--clocki.image = image("/home/mario/.config/awesome/tray/clocki.png")
clocki = widget({ type = "textbox" })
clocki.text = '<span color="#d5fc0d">TIME</span>'
mytextclock = widget({ type = "textbox" })
vicious.register(mytextclock, vicious.widgets.date, "%H:%M", 60)

--memi = widget({ type = "imagebox" })
--memi.image = image("/home/mario/.config/awesome/tray/memi.png")
--memi = widget({ type = "textbox" })
--memi.text = '<span color="#d5fc0d">MEM</span>'
--memtext = widget({ type = "textbox" })
--vicious.register(memtext, vicious.widgets.mem, "$2MB", 10)

--cpui = widget({ type = "imagebox" })
--cpui.image = image("/home/mario/.config/awesome/tray/cpui.png")
--cputext = widget({ type = "textbox" })
--vicious.register(cputext, vicious.widgets.cpu, "$1%", 1)

--maili = widget({ type = "imagebox" })
--maili.image = image("/home/mario/.config/awesome/tray/maili.png")
maili = widget({ type = "textbox" })
maili.text = '<span color="#d5fc0d">MAIL</span>'
mail = widget({ type = "textbox" })
mail.text = "-"

--mpdi = widget({ type = "imagebox" })
--mpdi.image = image("/home/mario/.config/awesome/tray/mpdi.png")
mpdi = widget({ type = "textbox" })
mpdi.text = '<span color="#d5fc0d">MPD</span>'
vicious.cache(vicious.widgets.mpd)
mpdc = { nil, "127.0.0.1", "6600" }
mpd = widget({ type = "textbox" })
vicious.register(mpd, vicious.widgets.mpd, "${Artist} - ${Title}", 1, mpdc)
mpd:buttons(awful.util.table.join( 
      awful.button({ }, 1, 
	    function () awful.util.spawn_with_shell(mpds .. "mpd_change toggle") end),
      awful.button({ }, 2,
	    function () awful.util.spawn_with_shell(mpds .. "mpd_change prev") end),
      awful.button({ }, 3,
	    function () awful.util.spawn_with_shell(mpds .. "mpd_change next") end)
	 ))

--weai = widget({ type = "imagebox" })
--weai.image = image("/home/mario/.config/awesome/tray/weai.png")
--vicious.cache(vicious.widgets.weather)
--wea = widget({ type = "textbox" })
--vicious.register(wea, vicious.widgets.weather, "  ${tempc}&#176;C  ", 60, "EPSC")

--pkgi = widget({ type = "imagebox" })
--pkgi.image = image("/home/mario/.config/awesome/tray/pkgi.png")
pkgi = widget({ type = "textbox" })
pkgi.text = '<span color="#d5fc0d">PKG</span>'
pkg = widget({ type = "textbox" })
pkg.text = "-"

--rssi = widget({ type = "imagebox" })
--rssi.image = image("/home/mario/.config/awesome/tray/rssi.png")
rssi = widget({ type = "textbox" })
rssi.text = '<span color="#d5fc0d">RSS</span>'
rss = widget({ type = "textbox" })
rss.text = "-"

separator = widget({ type = "textbox" })
separator.text = "  "

--voli = widget({ type = "imagebox" })
--voli.image = image("/home/mario/.config/awesome/tray/voli.png")
voli = widget({ type = "textbox" })
voli.text = '<span color="#d5fc0d">VOL</span>'
vol = widget({ type = "textbox" })
vicious.register(vol, vicious.widgets.volume, "$1%", 2, "Master")
vol:buttons(awful.util.table.join(
	       awful.button({ }, 2, function () awful.util.spawn("mute") end),
	       awful.button({ }, 4, function () 
			awful.util.spawn("amixer -q set Master 05%+") end),
	       awful.button({ }, 5, function () 
			awful.util.spawn("amixer -q set Master 05%-") end)
	 ))

for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    --mylayoutbox[s] = awful.widget.layoutbox(s)
    --mylayoutbox[s]:buttons(awful.util.table.join(
	     --awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
             --awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
             --awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
             --awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist(function(c)
		     return awful.widget.tasklist.label.focused(c, s, 
						   { bg_focus = "#121212",
						     fg_focus = "#fefefe" }) end )

    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "12", 
			    opacity = .9 })
    mywibox[s].widgets = {
        {
            --mylauncher,
	   mytaglist[s],
	   mypromptbox[s], separator,
	   layout = awful.widget.layout.horizontal.leftright
        },
	--mylayoutbox[s],
	separator,
	mytextclock, separator, clocki, separator,
	--memtext, separator, memi, separator,
	--cputext, separator, cpui, separator,
	pkg, separator, pkgi, separator,
	mail, separator, maili, separator,
	rss, separator, rssi, separator,
	vol, separator, voli, separator,
	mpd, separator, mpdi, separator,
	mytasklist,
	layout = awful.widget.layout.horizontal.rightleft
    }
end

shifty.taglist = mytaglist
shifty.init()

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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
--    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
    awful.key({ modkey }, "t", function() shifty.add({ rel_index = 1 }) end),
    awful.key({ modkey }, "w", shifty.del),
    awful.key({ modkey }, ";", shifty.rename),
    -- Layout manipulation
     awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(-1) end),
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
    awful.key({ modkey,           }, "f",      function () awful.util.spawn(browser) end),
    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn_with_shell(mpds .. "mpd_change toggle") end),
    awful.key({ }, "XF86AudioStop", function () awful.util.spawn_with_shell(mpds .. "mpd_chage pause") end),
    awful.key({ }, "XF86AudioNext", function () awful.util.spawn_with_shell(mpds .. "mpd_change next") end),
    awful.key({ }, "XF86AudioPrev", function () awful.util.spawn_with_shell(mpds .. "mpd_change prev") end),
    awful.key({ }, "XF86AudioMute", function () awful.util.spawn("mute") end),
    awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q sset Master 05%-") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q sset Master 05%+") end),

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

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end)

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.

for i=1,9 do

   globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey }, i,
		    function ()
		       local t = awful.tag.viewonly(shifty.getpos(i))
		    end))
   globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control" }, i,
		    function ()
		       local t = shifty.getpos(i)
		       t.selected = not t.selected
		    end))
   globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Control", "Shift" }, i,
		     function ()
			if client.focus then
			   awful.client.toggletag(shifty.getpos(i))
			end
		     end))
  -- move clients to other tags
   globalkeys = awful.util.table.join(globalkeys, awful.key({ modkey, "Shift" }, i,
		     function ()
			if client.focus then
			   local t = shifty.getpos(i)
			   awful.client.movetotag(t)
			   awful.tag.viewonly(t)
			end
		     end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))


clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey, "Shift"   }, "n",      function (c) local tag = awful.tag.selected()
		 for i = 1, #tag:clients() do
		    tag:clients()[i].minimized = false
		    tag:clients()[i]:redraw()
		 end
					       end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Set keys
root.keys(globalkeys)
shifty.config.globalkeys = globalkeys
shifty.config.clientkeys = clientkeys
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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

client.add_signal("focus", function(c) 
--	c.border_width = beautiful.border_width
	c.border_color = beautiful.border_focus
--	c.opacity = 1
 end)
client.add_signal("unfocus", function(c) 
--	c.border_width = "2"
	c.border_color = beautiful.border_normal
--	c.opacity = 0.9
 end)
-- }}}

awful.util.spawn_with_shell("/home/mariom/.config/awesome/runonce.sh")
