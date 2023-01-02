local wezterm = require 'wezterm'

wezterm.on("open-htop-pane", function(window, pane)
    window:perform_action(wezterm.action{ SplitVertical = { domain = "CurrentPaneDomain", args = { "htop" }, }, }, pane)
end)

return {
    -- styles
    color_scheme = "Dracula",
    font = wezterm.font('JetBrains Mono', { weight = 'Bold', italic = true }),
    font = wezterm.font_with_fallback({
		"Fira Code",
	}),

    -- Fonts
    font_size   = 14,
    line_height = 1.1,
    default_cursor_style = "BlinkingBar",
    use_ime = true,

    -- Tab Bar Options
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = false,
	tab_max_width = 25,

    -- Padding
	window_padding = { left = 10, right = 10, top = 10, bottom = 10 },

    hyperlink_rules = {
		-- Linkify things that look like URLs
		-- This is actually the default if you don't specify any hyperlink_rules
		{
			regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},

		-- match the URL with a PORT
		-- such 'http://localhost:3000/index.html'
		{
			regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
			format = "$0",
		},

		-- linkify email addresses
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},

		-- file:// URI
		{
			regex = "\\bfile://\\S*\\b",
			format = "$0",
		},
	},

    -- keybindings
    -- https://wezfurlong.org/wezterm/config/default-keys.html?highlight=key%20bindings#default-shortcut--key-binding-assignments
	disable_default_key_bindings = true,
	quick_select_alphabet = "colemak",
    -- https://wezfurlong.org/wezterm/config/keys.html?highlight=key%20bindings#leader-key
    -- press leadner key and "after that" press another key
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }, 
	keys = {
        -- { key = "r", mods = "LEADER", action = "ReloadConfiguration" },
        { key = "r", mods = "CTRL", action = "ReloadConfiguration" },
        --
        { key = "t", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{
			key = "h",
			mods = "CTRL",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
        {
			key = "v",
			mods = "CTRL",
			action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
		},
        -- 
        { key = "p", mods = "LEADER", action = wezterm.action({ EmitEvent = "open-htop-pane" })},
        --
		{ key = "r", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "u", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "d", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
        --
		{ key = "c", mods = "LEADER", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "LEADER", action = wezterm.action({ PasteFrom = "Clipboard" }) },
        -- 
        -- https://github.com/wez/wezterm/issues/641
        { key = "q", mods = "LEADER", action = "ShowDebugOverlay" },
	},
}