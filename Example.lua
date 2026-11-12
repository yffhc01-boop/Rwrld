--[[
    rainworld example — builds the whole interface from the design.
    Run it in your executor; RightShift opens and closes the menu.
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yffhc01-boop/Rwrld/HEAD/Library.lua"))()

-- Everything is saved under this workspace folder (fonts, configs, scripts).
Library.Name = "rainworld"
Library.Folder = "rainworld"

--// Menu ------------------------------------------------------------------------

local Window = Library:Window({ Name = "rainworld" })

local Aimbot = Window:Tab("aimbot")
local Rage = Window:Tab("rage")
local Esp = Window:Tab("esp")
local Visuals = Window:Tab("visuals")
local Misc = Window:Tab("misc")

-- aimbot: the two sections from the design, and a part picker
local AimAssist = Aimbot:Section({ Name = "aim assist", Side = "left" })

local Enabled = AimAssist:Toggle({
    Name = "enabled",
    Flag = "aim_enabled",
    Default = true,
    Callback = function(value)
        print("aim assist:", value)
    end,
})
Enabled:Colorpicker({ Flag = "aim_color", Default = Color3.fromRGB(153, 129, 188) })
Enabled:Colorpicker({ Flag = "aim_fov_color", Default = Color3.fromRGB(200, 162, 255) })
-- Display = false keeps the key out of the row: right-click the toggle to bind it.
local AimKey = Enabled:Keybind({ Name = "aim assist", Flag = "aim_key", Mode = "Hold", Display = false })

AimAssist:Slider({ Name = "speed", Flag = "aim_speed", Min = 0, Max = 100, Default = 10, Suffix = "%" })
AimAssist:Dropdown({
    Name = "smoothing",
    Flag = "aim_smoothing",
    Options = { "inertial", "linear", "quadratic", "exponential" },
    Default = "inertial",
})
AimAssist:Button({
    Name = "button",
    Callback = function()
        Library:Notify({ "pressed ", { "button" } })
    end,
})

local Triggerbot = Aimbot:Section({ Name = "triggerbot", Side = "right", Height = "auto" })
Triggerbot:Toggle({ Name = "toggle", Flag = "trigger_enabled", Default = true })

-- click a part of the character to pick it, drag to turn the character
local AimPart = Aimbot:Section({ Name = "aim part", Side = "right" })
AimPart:PartPicker({ Flag = "aim_part", Default = "Head", Fill = true })

-- rage: the rest of the element set
local Elements = Rage:Section({ Name = "elements", Side = "left" })
Elements:Slider({ Name = "range", Flag = "demo_range", Min = 0, Max = 100, Default = { 9, 71 }, Range = true })
Elements:Slider({ Name = "amount", Flag = "demo_amount", Min = 0, Max = 100, Step = 0.1, Default = 73.7 })
Elements:Dropdown({
    Name = "hitboxes",
    Flag = "demo_hitboxes",
    Options = { "head", "chest", "stomach", "arms", "legs" },
    Default = { "head", "chest" },
    Multi = true,
})
Elements:Textbox({ Name = "text", Flag = "demo_text", Placeholder = "type here" })
Elements:Label({ Name = "menu bind" }):Keybind({ Name = "example bind", Flag = "demo_bind", Default = Enum.KeyCode.X })
Elements:Colorpicker({ Name = "colour", Flag = "demo_color", Default = Color3.fromRGB(255, 80, 80), Transparency = 0.25 })
-- a colour can animate: also "Pulse" and "Fade", or pick one in the colour popup
Elements:Colorpicker({ Name = "rainbow", Flag = "demo_rainbow", Default = Color3.fromRGB(255, 80, 80), Animation = "Rainbow" })
Elements:Divider("buttons")
Elements:Button({ Name = "button" })
Elements:DoubleButton({ Name = "button" }, { Name = "button" })
Elements:TripleButton({ Name = "button" }, { Name = "button" }, { Name = "button" })

local Lists = Rage:Section({ Name = "list", Side = "right" })
Lists:List({
    Name = "players",
    Flag = "demo_player",
    Height = 120,
    Options = { "nova", "wraith", "silhouette", "kestrel", "ember", "vellum", "harrow" },
    Save = false,
})

-- several parts at once, three at most, picked as groups that fit R6 and R15 alike
local Hitboxes = Rage:Section({ Name = "hitboxes", Side = "right" })
Hitboxes:PartPicker({
    Flag = "demo_parts",
    Multi = true,
    Max = 3,
    Groups = Library.PartGroups,
    Default = { "head", "chest" },
    Fill = true,
})

-- esp / visuals: plain toggles with colours, as a script would use them
local EspElements = { "box", "name", "health bar", "distance", "weapon", "skeleton" }
local Players = Esp:Section({ Name = "players", Side = "left" })
for _, name in EspElements do
    local flag = "esp_" .. string.gsub(name, " ", "_")
    local toggle = Players:Toggle({ Name = name, Flag = flag })
    toggle:Colorpicker({
        Flag = flag .. "_color",
        Default = name == "health bar" and Color3.fromRGB(120, 220, 110) or Color3.fromRGB(255, 255, 255),
    })
end

local World = Visuals:Section({ Name = "world", Side = "left" })
World:Toggle({ Name = "fullbright", Flag = "world_fullbright" })
World:Slider({ Name = "brightness", Flag = "world_brightness", Min = 0, Max = 10, Step = 0.5, Default = 2 })
World:Slider({ Name = "field of view", Flag = "world_fov", Min = 30, Max = 120, Default = 70, Suffix = "°" })

--// Hud and windows -------------------------------------------------------------

local Watermark = Library:Watermark({
    Name = "rainworld.club",
    Tag = "$$$",
    Stats = { "ram", "fps", "ping" },
    -- Animation = "Bounce",
    -- NameColor = Color3.new(1, 1, 1), DomainColor = Color3.fromRGB(201, 164, 253),
})

local Keybinds = Library:KeybindList({ Name = "keybinds", Mode = "All" })
local Hitlogs = Library:Hitlogs({ Side = "Left", Animation = "Slide" })
local Notifications = Library:Notifications({ Position = "TopRight" })
local Target = Library:TargetHud({ Mode = "Static" })
local Preview = Library:EspPreview({ Name = "esp preview" })
local Configs = Library:Configs()
local Lua = Library:Lua()
local Dock = Library:Dock({ Name = "rainworld.club", Mode = "Top" })
local Theme = Library:ThemeWindow() -- create last: it lists settings for the pieces above

-- the preview draws each esp element the way its toggle and colour picker say
for _, name in EspElements do
    local flag = "esp_" .. string.gsub(name, " ", "_")
    Preview:Bind(name, flag, flag .. "_color")
end

Dock:Add("menu", Window)
Dock:Add("watermark", Watermark)
Dock:Add("preview", Preview)
Dock:Add("configs", Configs)
Dock:Add("lua", Lua)
Dock:Add("theme", Theme)
Dock:Add("keybinds", Keybinds)
Dock:Add("hitlogs", Hitlogs)
Dock:Add("notifications", Notifications)
Dock:Add("target", Target)

--// Wiring ----------------------------------------------------------------------

local Settings = Misc:Section({ Name = "demo", Side = "left" })
Settings:Button({
    Name = "test hitlog",
    Callback = function()
        Hitlogs:Add({ "hit ", { "cursedbullet" }, " in the ", { "head" }, " for ", { "100", Color3.fromRGB(120, 220, 110) } })
    end,
})
Settings:DoubleButton({
    Name = "notification",
    Callback = function()
        Library:Notification({
            Title = "update ready",
            Text = { "version ", { Library.Version }, " adds notifications, resizing and animated colours" },
            Duration = 8,
            Buttons = {
                {
                    Name = "nice",
                    Callback = function()
                        print("nice")
                    end,
                },
                { Name = "dismiss" },
            },
        })
    end,
}, {
    Name = "warning",
    Callback = function()
        Library:Notification({ Title = "careful", Text = "something needs your attention", Type = "warning" })
    end,
})
Settings:DoubleButton({
    Name = "target me",
    Callback = function()
        Target:SetTarget(game:GetService("Players").LocalPlayer)
    end,
}, {
    Name = "clear target",
    Callback = function()
        Target:SetTarget(nil)
    end,
})
Settings:Button({
    Name = "unload",
    Callback = function()
        Library:Unload()
    end,
})

-- Values live in Library.Flags; listen to one flag or to all of them.
Library:OnChanged("aim_speed", function(value)
    print("speed is now", value)
end)
Library:OnChanged("aim_part", function(part)
    print("aiming at", part)
end)
AimKey.Changed:Connect(function(active)
    print("aim key", active and "held" or "released")
end)

Library:LoadAutoload()
Library:Notification({
    Title = Library.Name,
    Text = { "loaded - press ", { "right shift" }, " to toggle the menu" },
    Type = "success",
})
