local wezterm = require('wezterm')

local colors = {
    foreground = '#abb2bf',
    background = '#202326',
    cursor_bg = '#528bff',
    cursor_fg = 'black',
    cursor_border = '#528bff',
    ansi = {'#202326', '#d41a1a', '#12963d', '#fbb829', '#2c78bf', '#985fc5', '#259cc1', '#bbbbbb'},
    brights = {
        '#5e6c7b', '#f75341', '#58c379', '#e1d359', '#429ae5', '#af85ef', '#62c1d8', '#d3dae3'
    },
    indexed = {
        [16] = '#202326',
        [17] = '#3e4452',
        [60] = '#636d83',
        [69] = '#528bff',
        [73] = '#56b6c2',
        [75] = '#61afef',
        [102] = '#828997',
        [114] = '#98c379',
        [130] = '#be5046',
        [168] = '#e06c75',
        [173] = '#d19a66',
        [176] = '#c678dd',
        [180] = '#e5c07b',
        [235] = '#202326',
        [236] = '#282c34',
        [237] = '#313640',
        [238] = '#3b4048',
        [239] = '#4b5263',
        [241] = '#5c6370',
        [249] = '#abb2bf'
    },
    compose_cursor = '#5294e2'
}

local ac = wezterm.action
local keys = {
    {key = 'C', mods = 'CTRL|SHIFT', action = ac {CopyTo = 'Clipboard'}},
    {key = 'V', mods = 'CTRL|SHIFT', action = ac {PasteFrom = 'Clipboard'}},
    {key = 'Insert', mods = 'SHIFT', action = ac {PasteFrom = 'PrimarySelection'}},
    {key = 'PageUp', mods = 'SHIFT', action = ac {ScrollByPage = -1}},
    {key = 'PageDown', mods = 'SHIFT', action = ac {ScrollByPage = 1}},
    {key = 'Home', mods = 'SHIFT', action = 'ScrollToTop'},
    {key = 'End', mods = 'SHIFT', action = 'ScrollToBottom'},
    {key = '=', mods = 'CTRL|ALT', action = 'ResetFontSize'},
    {key = '=', mods = 'CTRL', action = 'IncreaseFontSize'},
    {key = '-', mods = 'CTRL', action = 'DecreaseFontSize'},
    -- Map Control-([1-9]|[0;']) to Control-[F1-F12] (F25-F36)
    {key = '1', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x35\x50'}},
    {key = '2', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x35\x51'}},
    {key = '3', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x35\x52'}},
    {key = '4', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x35\x53'}},
    {key = '5', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x35\x3b\x35\x7e'}},
    {key = '6', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x37\x3b\x35\x7e'}},
    {key = '7', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x38\x3b\x35\x7e'}},
    {key = '8', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x39\x3b\x35\x7e'}},
    {key = '9', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x38\x3b\x35\x7e'}},
    {key = '0', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x32\x31\x3b\x35\x7e'}},
    {key = ';', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x32\x33\x3b\x35\x7e'}},
    {key = [[']], mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x32\x34\x3b\x35\x7e'}},
    -- Map Control-Alt-([1-9]) and Control-[,.] to Control-Shift-[F1-F12] (F37-F48)
    {key = '1', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x3b\x36\x50'}},
    {key = '2', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x3b\x36\x51'}},
    {key = '3', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x3b\x36\x52'}},
    {key = '4', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x3b\x36\x53'}},
    {key = '5', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x35\x3b\x36\x7e'}},
    {key = '6', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x37\x3b\x36\x7e'}},
    {key = '7', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x38\x3b\x36\x7e'}},
    {key = '8', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x31\x39\x3b\x36\x7e'}},
    {key = '9', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x32\x30\x3b\x36\x7e'}},
    {key = '0', mods = 'CTRL|ALT', action = ac {SendString = '\x1b\x5b\x32\x31\x3b\x36\x7e'}},
    {key = ',', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x32\x33\x3b\x36\x7e'}},
    {key = '.', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x32\x34\x3b\x36\x7e'}},
    -- Map Control-[ and Control-m to Alt-Shift-[F1-F2] (F61-F62)
    {key = '[', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x34\x50'}},
    {key = 'm', mods = 'CTRL', action = ac {SendString = '\x1b\x5b\x31\x3b\x34\x51'}}
}

return {
    check_for_updates = false,
    debug_key_events = false,
    font_size = 12.0,
    font = wezterm.font_with_fallback({'Hack Nerd Font', 'Noto Sans CJK SC'}),
    hide_tab_bar_if_only_one_tab = true,
    custom_block_glyphs = false,
    initial_rows = 50,
    initial_cols = 120,
    adjust_window_size_when_changing_font_size = false,
    window_padding = {left = 0, right = 0, top = 0, bottom = 0},
    use_ime = true,
    disable_default_key_bindings = true,
    colors = colors,
    keys = keys
}
