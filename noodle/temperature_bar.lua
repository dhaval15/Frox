local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Set colors
local active_color = beautiful.temperature_bar_active_color or "#5AA3CC"
local background_color = beautiful.temperature_bar_background_color or "#222222"

-- Configuration
local update_interval = 15            -- in seconds

local temperature_bar = wibox.widget{
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
  color         = beautiful.temperature_bar_color,
  background_color = "#00000000",
  border_width  = 1,
  border_color  = beautiful.temperature_bar_color,
  widget        = wibox.widget.progressbar,
}

local function update_widget(temp)
  temperature_bar.value = tonumber(temp)
end

local temp_script = [[
  bash -c "
  sensors | grep Package | awk '{print $4}' | cut -c 2-3
  "]]

awful.widget.watch(temp_script, update_interval, function(widget, stdout)
                     local temp = stdout
                     update_widget(temp)
end)

return temperature_bar
