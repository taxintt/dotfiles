local wezterm = require 'wezterm'

return {
    -- styles
    color_scheme = "Dracula",
    font = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = true }),

    -- Fonts
    font_size   = 14,
    line_height = 1.1,
    default_cursor_style = "BlinkingBar",
}