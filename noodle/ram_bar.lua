local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Set colors
local active_color = beautiful.ram_bar_active_color or "#5AA3CC"
local background_color = beautiful.ram_bar_background_color or "#222222"

-- Configuration
local update_interval = 20            -- in seconds

local ram_bar = wibox.widget{
  max_value     = 100,
  value         = 50,
  forced_height = dpi(10),
  margins       = {
    top = dpi(8),
    bottom = dpi(8),
  },
  forced_width  = dpi(200),
  --shape         = gears.shape.rounded_bar,
  --bar_shape     = gears.shape.rounded_bar,
  color         = beautiful.ram_bar_color,
  background_color = "#00000000",
  border_width  = 1,
  border_color  = beautiful.ram_bar_color,
  widget        = wibox.widget.progressbar,
}

local function update_widget(used_ram_percentage)
  ram_bar.value = used_ram_percentage
end

local used_ram_script = [[
  bash -c "
  free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
  "]]

awful.widget.watch(used_ram_script, update_interval, function(widget, stdout)
                     local available = stdout:match('(.*)@@')
                     local total = stdout:match('@@(.*)@')
                     local used_ram_percentage = (total - available) / total * 100
                     update_widget(used_ram_percentage)
end)

return ram_bar
