# rainworld

A Roblox UI library for executors, built 1:1 from the rainworld Figma design: a tabbed menu, a dock,
a watermark, a keybind list, hitlogs, notifications, a target hud, an esp preview, a config manager
and a lua editor. Every colour, font, text size and animation can be changed at runtime, and every
window can be resized.

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yffhc01-boop/Rwrld/HEAD/Library.lua"))()
```

[`Example.lua`](Example.lua) builds the whole interface from the design and is the quickest way to
see everything working. **RightShift** opens and closes the menu.

- [Menu](#menu) · [Elements](#elements) · [Flags and callbacks](#flags-and-callbacks) · [Configs](#configs)
- [Hud](#hud): [watermark](#watermark), [keybind list](#keybind-list), [hitlogs](#hitlogs), [notifications](#notifications), [target hud](#target-hud)
- [Windows](#windows): [dock](#dock), [esp preview](#esp-preview), [configs](#configs-window), [lua](#lua-window), [theme](#theme-window)
- [Lua api](#lua-api) · [Customising](#customising) · [Executor functions](#executor-functions)

Option tables are case-insensitive (`Name` and `name` are the same), and a plain string works
wherever only a name is needed: `Window:Tab("aimbot")`.

## Menu

```lua
local Window = Library:Window({ Name = "rainworld" })            -- Size, Position, Columns = 2

local Aimbot = Window:Tab("aimbot")                              -- Columns overrides the window's
local Section = Aimbot:Section({ Name = "aim assist", Side = "left" })
```

Sections go in the `"left"` or `"right"` column (or `Column = n` when a tab has more). A section
fills the space left in its column; pass `Height = 150` for a fixed height or `Height = "auto"` to
fit its content. Sections scroll when their content is taller than they are.

`Window:SetVisible(bool)`, `:Toggle()`, `:SetName(text)`, `:SetSize(Vector2)`,
`:SetPosition(Vector2)` and `:SelectTab(name)` do what they say. Windows are dragged by their
header and resized by the mark in their bottom right corner: `Resizable = false` pins the size and
`MinSize = Vector2.new(300, 200)` changes how small it can get. Sizes are saved with configs, and
`Window.Resized:Connect(function(size) end)` tells you when one changes.

A window without a tab bar is `Library:Window({ Name = "tools", Tabs = false, Columns = 1 })`; its
sections are added straight to it with `Window:Section({ Name = "section" })`. The configs, lua and
esp preview windows are made this way.

## Elements

```lua
local Toggle = Section:Toggle({ Name = "enabled", Flag = "aim_enabled", Default = true,
    Callback = function(value) end })

Section:Slider({ Name = "speed", Flag = "aim_speed", Min = 0, Max = 100, Default = 10, Suffix = "%" })
Section:Slider({ Name = "amount", Flag = "amount", Min = 0, Max = 100, Step = 0.1, Default = 73.7 })
Section:Slider({ Name = "range", Flag = "range", Min = 0, Max = 100, Default = { 9, 71 }, Range = true })

Section:Dropdown({ Name = "smoothing", Flag = "smoothing", Options = { "inertial", "linear" }, Default = "inertial" })
Section:Dropdown({ Name = "hitboxes", Flag = "hitboxes", Options = { "head", "chest", "legs" }, Multi = true })

Section:Textbox({ Name = "text", Flag = "text", Placeholder = "type here" })   -- Numeric = true for numbers
Section:List({ Name = "players", Flag = "player", Options = { "nova", "wraith" }, Height = 120 })
Section:PartPicker({ Name = "aim part", Flag = "aim_part", Default = "Head" })   -- see "Part picker"

Section:Button({ Name = "button", Callback = function() end })
Section:DoubleButton({ Name = "load" }, { Name = "save" })
Section:TripleButton({ Name = "a" }, { Name = "b" }, { Name = "c" })
Section:Buttons({ { Name = "any" }, { Name = "number" }, { Name = "of" }, { Name = "buttons" } })

Section:Label({ Name = "just text" })
Section:Divider("caption")                                       -- or Section:Divider() for a plain line
Section:Colorpicker({ Name = "colour", Flag = "colour", Default = Color3.fromRGB(255, 80, 80), Transparency = 0.25 })
Section:Keybind({ Name = "menu bind", Flag = "bind", Default = Enum.KeyCode.X, Mode = "Toggle" })
```

Toggles and labels take colour pickers and a keybind on their right side:

```lua
Toggle:Colorpicker({ Flag = "aim_color", Default = Color3.fromRGB(153, 129, 188) })
Toggle:Keybind({ Name = "aim assist", Flag = "aim_key", Mode = "Hold" })
```

| Element | Notes |
| --- | --- |
| Slider | Drag the bar or use the `−` / `+` ends to step. `Range = true` makes a two-ended slider. |
| Dropdown | `Multi = true` keeps it open and returns a list. `:SetOptions(list)` (alias `:Refresh`) replaces the options. |
| List | `Fill = true` makes the list take the height its section has left. `:SetOptions(list)` replaces the options. |
| Colour picker | Opens docked to the left of the menu, as in the design. Passing `Transparency` adds the transparency strip. The popup's **animation** row steps through `static`, `rainbow`, `pulse` and `fade` (with a speed, and a second colour for fade); callbacks and `Library.Flags` follow the moving colour. From code: `Animation = "Rainbow"`, `Speed = 2`, `Second = Color3`, `picker:SetAnimation(name, speed)`; `Animations = false` hides the rows. |
| Keybind | Click and press a key (or mouse button 2/3) to bind; Escape clears. Right-click picks `Toggle`, `Hold` or `Always`. Mouse buttons are saved too. |

Keybind options: `Mode`, `Callback(active)`, `KeyChanged(key)`, `Sync = true` (the bind drives its
toggle), `Hidden = true` (keep it out of the keybind list), `Modes = false` (no mode popup) and
`Display = false` (no key text in the row — bind by right-clicking the toggle, which is how the
design's `enabled` row works). `keybind:IsActive()` is true when the key is active *and* the
toggle it is attached to is on.

Every element has `:Set(value)`, `:Get()`, `:SetVisible(bool)` and `:OnChanged(callback)`.
Toggle, slider, dropdown and colour picker callbacks also run once when the element is created,
with its default value. `Save = false` keeps an element out of configs.

### Part picker

```lua
-- one part; the value is its name
Section:PartPicker({ Name = "aim part", Flag = "aim_part", Default = "Head" })

-- several parts, three at most; the value is a list
Section:PartPicker({ Flag = "hitboxes", Multi = true, Max = 3, Groups = Library.PartGroups,
    Default = { "head", "chest" } })
```

The picker shows your character in a viewport. Click a part to pick it: picked parts wear a block
in the accent colour, the others nothing. Drag to turn the character.

| Option | |
| --- | --- |
| `Multi` | `false` picks one part (clicking another moves the pick), `true` any number. |
| `Max` | With `Multi`: the most parts at once; picking one more drops the oldest pick. |
| `AllowNone` | Without `Multi`: clicking the picked part again clears it. |
| `Parts` | The part names that can be picked. Default: every body part of the character. |
| `Groups` | Parts picked together under one name, as `{ { "arms", { "Left Arm", "LeftHand" } }, ... }`. `Library.PartGroups` has `head`, `chest`, `stomach`, `arms` and `legs` for both R6 and R15. |
| `Character` | A model to show instead of your character (`false`: a blocky stand-in). Also `picker:SetCharacter(model)`. |
| `Height`, `Fill` | Height of the viewport (150), or `Fill = true` to take what the section has left. |

## Flags and callbacks

An element with a `Flag` publishes its value in `Library.Flags` and itself in `Library.Options`:

```lua
if Library.Flags.aim_enabled and Library.Flags.aim_key.Active then
    local speed = Library.Flags.aim_speed
end

Library.Options.aim_speed:Set(50)

local disconnect = Library:OnChanged("aim_speed", function(value) end)
Library.Changed:Connect(function(flag, value) end)               -- every flag
```

| Element | Value in `Library.Flags` |
| --- | --- |
| Toggle | `boolean` |
| Slider | `number`, or `{ Min = n, Max = n }` for a range |
| Dropdown, List, Part picker | the option, or a list of options for `Multi` |
| Textbox | `string` |
| Colour picker | `{ Color = Color3, Transparency = number, Animation = string, Speed = number }` |
| Keybind | `{ Key = EnumItem?, Mode = string, Active = boolean }` |

## Configs

Configs are JSON files in `<Library.Folder>/configs`. They hold every flag, plus window positions
and sizes, visibility, the theme and the animation settings; set `Library.SaveInterface = false` to
keep the interface's own settings out.

```lua
Library:SaveConfig("legit")        -- no name: next free number ("1", "2", ...) and returns it
Library:LoadConfigFile("legit")
Library:DeleteConfig("legit")
Library:ListConfigs()              -- { "1", "2", "legit" }

Library:SetAutoload("legit")       -- remembered in <Folder>/autoload.txt
Library:LoadAutoload()             -- call once, after building the menu

local json = Library:GetConfig()   -- the same data as a string, e.g. for the clipboard
Library:LoadConfig(json)
```

On executors without a filesystem configs are kept in memory for the session.

## Hud

Hud pieces stay on screen while the menu is closed and can be dragged while it is open. Their
positions are saved with configs. All of them have `:SetVisible(bool)`, `:Toggle()` and
`:SetPosition(Vector2)`.

### Watermark

```lua
local Watermark = Library:Watermark({
    Name = "rainworld.club",
    Tag = "$$$",                          -- optional, shown after a divider
    Stats = { "ram", "fps", "ping" },     -- also "time", "date", "user", "executor", or functions
    Animation = "None",                   -- "Bounce", "Wave" or "Shine"
})
```

By default the name is drawn with the design's gradient (accent at both ends, near-white in the
middle). To colour it yourself:

```lua
-- a domain: everything before the first dot, and the dot onwards
Library:Watermark({ Name = "drain.solutions", NameColor = Color3.new(1, 1, 1), DomainColor = Color3.fromRGB(190, 120, 255) })

-- any split, any number of parts; a colour can also be a theme key such as "accent"
Library:Watermark({ Name = { { "sharik", Color3.new(1, 1, 1) }, { "tools", Color3.fromRGB(255, 150, 40) } } })
```

`Watermark:SetName(options)` takes the same options later, `:SetAnimation(name, speed)` changes
the animation and `:SetStats(list)` the stats. Add your own stat with
`Library.StatProviders.kills = function() return "12 kills" end` and list it as `"kills"`.

### Keybind list

```lua
local Keybinds = Library:KeybindList({
    Mode = "All",                  -- "All": every bind, active ones highlighted; "Active": only active binds
    ShowKeys = true,               -- the "- [key]" part
    KeyColor = nil,                -- a colour just for the keys (nil: same as the row)
    ActiveColor = "accent_text",   -- highlight for active binds in "All" mode
})
```

`:SetMode`, `:SetShowKeys`, `:SetKeyColor` and `:SetActiveColor` change these later.
`ShowModes = true` adds `(hold)` / `(toggle)` after each name.

### Hitlogs

```lua
local Hitlogs = Library:Hitlogs({
    Side = "Left",                 -- edge the entries fly in from: "Left", "Right", "Top", "Bottom"
    Animation = "Slide",           -- "Slide", "Bounce", "Back" or "Fade"
    Duration = 4, Max = 6,
})

Hitlogs:Add("plain text")
Hitlogs:Add({ "hit ", { "player" }, " in the ", { "head" }, " for ", { "100", Color3.fromRGB(120, 220, 110) } })
```

`{ text }` is drawn in the accent colour and `{ text, colour }` in your own. While the menu is
open a small `hitlogs` handle shows where the stack starts; drag it to move the stack.
`Library:Notify(parts, duration)` is a shortcut that uses the hitlogs when they exist and a
[notification](#notifications) when they do not.

### Notifications

```lua
local Notifications = Library:Notifications({
    Position = "TopRight",         -- TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight
    Margin = Vector2.new(12, 40),  -- from the screen edges
    Width = 230, Max = 6, Duration = 5,
    Animation = "Slide",           -- "Slide", "Bounce", "Back" or "Fade"
})

local Notification = Library:Notification({
    Title = "config saved",
    Text = { "legit", { ".cfg" }, " was written" },   -- a string, or the same parts as hitlogs
    Type = "success",              -- "info", "success", "warning" or "error"
    Duration = 6,                  -- 0 keeps it until it is closed
    Buttons = { { Name = "undo", Callback = function() end }, { Name = "ok" } },
    Closed = function() end,
})
```

A notification is a small window: a title, wrapped text, optional buttons and a bar that runs down
with its time. Clicking it dismisses it (`Closable = false` turns that off, `Progress = false`
hides the bar), and a button closes it unless it has `Close = false`. `Library:Notification`
creates the stack with its defaults when you have not, so the first block is only needed to change
them.

`Notification:SetTitle(text)`, `:SetText(text)`, `:SetType(name)`, `:SetDuration(seconds)`,
`:SetProgress(0.4)` (drive the bar yourself, for a download or a countdown) and `:Close()` update
one that is on screen. `Notifications:SetPosition(name, margin)`, `:Clear()` and `:SetVisible(bool)`
act on the stack, which can also be added to the dock. Add a type of your own with
`Library.NotificationTypes.vip = { Line = Color3.new(1, 0.8, 0), Title = "text" }`.

### Target hud

```lua
local Target = Library:TargetHud({
    Mode = "Static",               -- or "Attached": follows the target on screen
    Offset = Vector2.new(40, -30), -- from the target, in "Attached" mode
    Stats = { "health", "distance", function(target, character) return "custom" end },
    Role = function(player) return "admin" end,     -- or GroupId = 123 to show the group role
    Armor = function(target, character) return 50, 100 end,
    Elements = { Avatar = true, Name = true, Role = true, Stats = true, Health = true, Armor = true },
})

Target:SetTarget(player)           -- a Player or a character model; nil clears it
Target:SetInfo("weapon", "ak-47")  -- extra line; nil removes it
```

`:SetMode(mode)`, `:SetElement("avatar", false)` and `:SetArmor(value, max)` are also available.
While the menu is open and there is no target, the hud shows you so it can be positioned.

## Windows

Windows are only visible while the menu is open.

### Dock

```lua
local Dock = Library:Dock({ Name = "rainworld.club", Mode = "Top" })   -- or "Float"
Dock:Add("menu", Window)           -- anything with :SetVisible, including hud pieces
Dock:Add("panic", function() Library:Unload() end)
Dock:Add("esp", { Get = function() return enabled end, Set = function(value) enabled = value end })
```

`"Top"` pins the bar across the top edge of the screen; `"Float"` makes it a compact bar in the
upper centre that can be dragged. `Dock:SetMode(mode)` switches at runtime. Items are lit when
their target is on. The name takes the same colouring options as the watermark.

### Esp preview

```lua
local Preview = Library:EspPreview({ Name = "esp preview" })

Preview:Bind("box", "esp_box", "esp_box_color")   -- follow a toggle's flag and a colour picker's
Preview:Set("skeleton", true)                     -- or drive the elements yourself
Preview:SetColor("skeleton", Color3.fromRGB(201, 164, 253))
Preview:SetLabel("weapon", "ak-47")               -- text of the name, distance and weapon elements
Preview:SetHealth(0.6)
```

The window shows a copy of your character in a viewport and draws the esp on it: `box`, `name`,
`health`, `distance`, `weapon` and `skeleton`. Drag the character to turn it. It keeps up with
respawns; `Preview:SetCharacter(model)` shows another model (anything else shows a blocky
stand-in) and `Preview:SetImage("rbxassetid://123")`, or an http(s) image url, shows a picture
instead.

`Preview.Holder` is the frame over the viewport — parent your own overlays to it — and
`Preview.View` is the viewport itself (`:Project(position)`, `:Bounds(parts)`, `.Changed`).
`Preview:SetText(text)` puts a caption in the bottom corner.

### Configs window

`Library:Configs()` is the config manager, made of the same window, section and elements as the
menu: a list of the configs, a name box and six buttons. **load** and **delete** act on the
selected config, **save** stores the current settings under the typed name (or the next free
number), **rewrite** overwrites the selected one, **refresh** re-reads the folder and **autoload**
marks the selected config for `Library:LoadAutoload()` (again to clear the mark). Every action
reports back with a notification. The same actions are methods: `Configs:Load()`, `:Save(name)`,
`:Rewrite()`, `:Delete()`, `:Reload()`, `:Autoload()` and `:Select(name)`.

### Lua window

`Library:Lua()` is the script editor, also made of the menu's own pieces. **execute** runs the
editor's contents with the [lua api](#lua-api); **save** writes them to
`<Folder>/scripts/main.lua`, which is loaded back into the editor next time; **clear** empties the
editor. Options: `File = "main"`, `AutoExecute = true`, `Placeholder`.

### Theme window

`Library:ThemeWindow()` builds a settings window with three tabs. **colors** has a colour picker
for every theme colour and the presets. **interface** has the menu key, ui scale, text size preset
and the options of the dock and hud pieces. **motion** has the [animation](#animations) settings —
on or off, speed, easing, how windows open, and which of tabs, elements, popups and notifications
animate — plus animated gradients and the notification stack's position, animation and duration.
Create it **after** the other pieces — it only lists what already exists — and add it to the dock.

`Library:MobileButton()` adds a small draggable button that toggles the menu; it is created
automatically on touch devices without a keyboard.

## Lua api

Scripts run from the lua window (or with `Library:RunScript(source, name)`) get an `api` table.
Its functions are also globals, alongside `library` and `flags`:

```lua
api.set("aim_speed", 42)                         -- through the element, so the menu updates
print(api.get("aim_speed"), flags.aim_enabled)

api.on("aim_speed", function(value) end)         -- a flag
api.on("render", function(delta) end)            -- also "heartbeat", "open", "config", "unload"
api.connect(workspace.ChildAdded, function() end)

notify({ "hello from ", { "lua" } })
notification({ Title = "lua", Text = "with a title and a type", Type = "success" })

local tab = api.tab("scripts")                   -- finds or creates a menu tab
tab:Section({ Name = "my script" }):Toggle({ Name = "thing", Flag = "my_thing" })
```

Everything connected through `api.on` and `api.connect` is disconnected when the script is run
again, when `api.unload()` is called, or when the library unloads.

## Customising

### Colours

```lua
Library:SetTheme("accent", Color3.fromRGB(150, 200, 60))
Library:ApplyTheme("gamesense")                  -- rainworld, gamesense, fatality, neverlose, onetap, blood, mono
Library:ApplyTheme({ accent = Color3.new(1, 0, 0), background = Color3.fromRGB(10, 10, 10) })
Library.Presets.mine = { accent = Color3.new(1, 0, 0) }
```

Theme keys: `accent`, `accent_text`, `text`, `text_dim`, `text_outline`, `outline`, `inline`,
`background`, `border`, `page`, `section`, `section_inline`, `element`, `element_outline`,
`button_top`, `button_bottom`, `button_outline`, `track`, `dock`.

### Fonts and text sizes

Every piece of text has a role in `Library.Text`. Change a role at any time:

```lua
Library:SetText("text", { Size = 12 })
Library:SetText("title", { Font = "TahomaBold", Size = 12 })
```

| Role | Used for | Default |
| --- | --- | --- |
| `title` | menu title | ProggyClean 12 |
| `tab` | tab names | ProggyClean 10 |
| `section` | section headers | ProggyClean 8 |
| `text` | element labels and values | ProggyClean 9 |
| `button` | buttons | ProggyClean 10 |
| `hud` | keybind list, hitlogs, notifications, target hud | ProggyClean 10 |
| `watermark` | watermark stats | ProggyClean 9 |
| `dock` | dock items | ProggyClean 12 |
| `brand`, `watermark_brand` | the name on the dock / watermark | TahomaBold 11 |

The sizes follow the Figma file, which draws ProggyClean smaller than its native pixel size.
ProggyClean is only pixel-perfect at size 12, so for sharper (and larger) text set those roles to
12, or pick **crisp** under *text* in the theme window.

Bundled font names: `ProggyClean`, `ProggyTiny`, `TahomaBold`, `Tahoma`, `SmallestPixel`,
`Minecraftia`, `Verdana`. They are downloaded once from
[i77lhm/storage](https://github.com/i77lhm/storage) into `<Folder>/fonts`; point
`Library.FontSource` at your own mirror if you prefer. To add a font:

```lua
Library:RegisterFont("MyFont", "https://example.com/MyFont.ttf")
Library:SetText("text", { Font = "MyFont" })
```

### Animations

Everything that moves reads `Library.Animations`, so it can be changed while the menu is open:

```lua
Library:SetAnimation("Speed", 1.5)          -- 2 is twice as fast
Library:SetAnimation("Style", "Back")       -- an Enum.EasingStyle name; "Direction" takes In, Out, InOut
Library:SetAnimation("Windows", "Slide")    -- how windows open and close: None, Fade, Slide or Scale
Library:SetAnimation("Elements", false)     -- also Tabs, Popups and Notifications
Library:SetAnimation("Gradients", true)     -- accent gradients travel sideways; "GradientSpeed" sets how fast
Library:SetAnimation("Enabled", false)      -- everything at once
Library:SetAnimations({ Speed = 2, Windows = "Scale" })
```

`Elements` covers toggles, sliders, buttons and list rows; `Popups` the dropdowns, the colour
picker and the keybind mode list; `Tabs` the page sliding in when the tab changes. With `Gradients`
on, the tab bar, slider and other accent gradients flow between `accent` and `accent_text` and
window titles get a moving sheen; off, they are the design's standing gradients. The same settings
are in the theme window's **motion** tab and are saved with configs.

### Everything else

```lua
Library.Name = "rainworld"                -- set these before creating anything
Library.Folder = "rainworld"              -- workspace folder for fonts, configs and scripts
Library.ToggleKey = Enum.KeyCode.Insert

Library:SetScale(1.25)                    -- scales the whole interface
Library:SetOpen(false)                    -- or Library:Toggle()
Library:Unload()                          -- removes everything and disconnects all events
```

Signals: `Library.Changed(flag, value)`, `Library.OpenChanged(open)`,
`Library.ThemeChanged(key, color)`, `Library.AnimationChanged(key, value)`,
`Library.ConfigLoaded(name)`, `Library.Unloading()`.

## Executor functions

All optional — the library falls back gracefully when one is missing.

| Function | Used for | Without it |
| --- | --- | --- |
| `gethui`, `cloneref`, `protectgui` | parenting and hiding the interface | CoreGui, then PlayerGui |
| `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`, `listfiles`, `delfile` | fonts, configs, scripts | configs live in memory |
| `getcustomasset` | custom fonts and preview images | built-in Roblox fonts |
| `loadstring` | the lua window | scripts cannot run |
| `identifyexecutor` | the `executor` watermark stat | shows `unknown` |

## Credits

Fonts are served from [i77lhm/storage](https://github.com/i77lhm/storage); the structure of the
library follows the conventions of [i77lhm/Libraries](https://github.com/i77lhm/Libraries).
