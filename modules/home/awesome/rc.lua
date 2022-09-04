------------------------------------------------------------------------------------------
-- My Extremely Minimal AwesomeWM Setup
------------------------------------------------------------------------------------------
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

------------------------------------------------------------------------------------------
-- Error Handling
------------------------------------------------------------------------------------------
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		if in_error then
			return
		end

		in_error = true
		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

------------------------------------------------------------------------------------------
-- Variable Setup
------------------------------------------------------------------------------------------
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")
beautiful.init(theme_path)

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

terminal = "kitty"
browser = os.getenv("BROWSER") or "firefox"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

------------------------------------------------------------------------------------------
-- Enabled Layouts
------------------------------------------------------------------------------------------
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.max.fullscreen,
	-- TODO: can we get away with not specifying floating layout at all?
	-- awful.layout.suit.floating,
}

------------------------------------------------------------------------------------------
-- Initialise and set Wallpapers
------------------------------------------------------------------------------------------
local function set_wallpaper(s)
	gears.wallpaper.set("#222222")
end

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
	s.padding = -2
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)

------------------------------------------------------------------------------------------
-- Misc and General Keybinds
------------------------------------------------------------------------------------------
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "keybinds", group = "general" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "general" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "general" }),

	------------------------------------------------------------------------------------------
	-- Tag Manipulation Keybinds
	------------------------------------------------------------------------------------------
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "focus prev", group = "tags" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "focus next", group = "tags" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "toggle focus", group = "tags" }),

	------------------------------------------------------------------------------------------
	-- Client Manipulation Keybinds
	------------------------------------------------------------------------------------------
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus prev", group = "client" }),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap next", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap prev", group = "client" }),

	------------------------------------------------------------------------------------------
	-- Layout Manipulation Keybinds
	------------------------------------------------------------------------------------------
	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "inc. master", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "dec. master", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "next layout", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "prev layout", group = "layout" }),

	------------------------------------------------------------------------------------------
	-- Launcher Keybinds
	------------------------------------------------------------------------------------------
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "spawn terminal", group = "launchers" }),
	awful.key({ modkey }, "r", function()
		awful.spawn("rofi -show run")
	end, { description = "spawn launcher", group = "launchers" }),
	awful.key({ modkey }, "w", function()
		awful.spawn(browser)
	end, { description = "spawn web browser", group = "launchers" })
)

------------------------------------------------------------------------------------------
-- More Client Manipulation Keybinds
------------------------------------------------------------------------------------------
clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "maximize", group = "client" }),
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "kill client", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "master", group = "client" })
)

------------------------------------------------------------------------------------------
-- More Tag Manipulation Keybinds
------------------------------------------------------------------------------------------
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tags" }),
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move client to tag #" .. i, group = "tags" })
	)
end

root.keys(globalkeys)

------------------------------------------------------------------------------------------
-- Rules: global rules
------------------------------------------------------------------------------------------
awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	------------------------------------------------------------------------------------------
	-- Rules: always floating
	------------------------------------------------------------------------------------------
	{
		rule_any = {
			instance = {},
			class = { "Blueman-manager" },
			name = {},
			role = { "pop-up" },
		},
		properties = { floating = true },
	},

	------------------------------------------------------------------------------------------
	-- Rules: always titlebar
	------------------------------------------------------------------------------------------
	{
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	},
}

------------------------------------------------------------------------------------------
-- Signals: On Boot Up
------------------------------------------------------------------------------------------
client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

------------------------------------------------------------------------------------------
-- Signals: Build Titlebars If Needed
------------------------------------------------------------------------------------------
client.connect_signal("request::titlebars", function(c)
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)
	awful.titlebar(c, { size = dpi(40) }):setup({
		{
			{
				awful.titlebar.widget.titlewidget(c),
				spacing = dpi(8),
				layout = wibox.layout.fixed.horizontal,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		{
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{
			{
				awful.titlebar.widget.closebutton(c),
				spacing = dpi(8),
				layout = wibox.layout.fixed.horizontal,
			},
			margins = dpi(10),
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.horizontal,
	})
end)

------------------------------------------------------------------------------------------
-- Signals: Sloppy Focus
-- NOTE: the tag signal needs to exist, as switching tags won't trigger the mouse::enter
--       event for clients. Thus, on changing tag, forcibly focus the client directly
--       under the mouse.
------------------------------------------------------------------------------------------
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

tag.connect_signal("property::selected", function(t)
	if tostring(t.selected) == "false" then
		local focus_timer = timer({ timeout = 0.025 })
		focus_timer:connect_signal("timeout", function()
			local c = awful.mouse.client_under_pointer()
			if not (c == nil) then
				client.focus = c
				c:raise()
			end
			focus_timer:stop()
		end)
		focus_timer:start()
	end
end)

------------------------------------------------------------------------------------------
-- Signals: Reset Wallpaper on Geometry Change
------------------------------------------------------------------------------------------
screen.connect_signal("property::geometry", set_wallpaper)
