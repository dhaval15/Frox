-- NOTE:
-- This widget runs a script in the background
-- When awesome restarts, its process will remain alive!
-- Don't worry though! The cleanup script that runs in rc.lua takes care of it :)

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Set colors
local active_color = beautiful.volume_bar_color
local muted_color = beautiful.volume_bar_color_muted
local active_background_color = "#00000000"
local muted_background_color = "#00000000"

local volume_bar = wibox.widget{
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
    color         = beautiful.volume_bar_color,
    background_color = "#00000000",
    border_width  = 1,
    border_color  = beautiful.volume_bar_color,
    widget        = wibox.widget.progressbar,
}

local function update_widget()
  awful.spawn.easy_async({"sh", "-c", "pactl list sinks"},
    function(stdout)
      local volume = stdout:match('(%d+)%% /')
      local muted = stdout:match('Mute:(%s+)[yes]')
      local fill_color
      local bg_color
      if muted ~= nil then
        fill_color = muted_color
        bg_color = muted_background_color
      else
        fill_color = active_color
        bg_color = active_background_color
      end
      volume_bar.value = tonumber(volume)
      volume_bar.color = fill_color
      volume_bar.background_color = bg_color
    end
  )
end

update_widget()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
  bash -c '
  pactl subscribe 2> /dev/null | grep --line-buffered "sink #0"
  ']]

awful.spawn.with_line_callback(volume_script, {
                                 stdout = function(line)
                                   update_widget()
                                 end
})

return volume_bar
