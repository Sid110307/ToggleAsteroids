local SHORTCUT_NAME = "toggle-asteroids"
local GUI_NAME = "toggle-asteroids-platform-picker"


local function get_state()
    storage.toggle_asteroids = storage.toggle_asteroids or {}
    storage.toggle_asteroids.platform_enabled =
        storage.toggle_asteroids.platform_enabled or {}

    return storage.toggle_asteroids
end


local function asteroids_are_enabled(platform)
    if not (platform and platform.valid) then
        return true
    end

    local state = get_state()

    if state.platform_enabled[platform.index] == nil then
        state.platform_enabled[platform.index] = true
    end

    return state.platform_enabled[platform.index]
end


local function remove_asteroids_from_platform(platform)
    if not (platform and platform.valid) then
        return
    end

    local surface = platform.surface

    if not surface then
        return
    end

    local asteroids = surface.find_entities_filtered {
        type = "asteroid"
    }

    for _, asteroid in pairs(asteroids) do
        if asteroid.valid then
            asteroid.destroy()
        end
    end

    platform.destroy_asteroid_chunks {}
end


local function toggle_asteroids_on_platform(player, platform)
    if not (platform and platform.valid) then
        return
    end

    local enabled = not asteroids_are_enabled(platform)
    local state = get_state()
    state.platform_enabled[platform.index] = enabled

    if enabled then
        player.print(
            "Asteroids enabled on \"" ..
            platform.name ..
            "\"."
        )
    else
        remove_asteroids_from_platform(platform)

        player.print(
            "Asteroids disabled on \"" ..
            platform.name ..
            "\"."
        )
    end
end

local function close_platform_picker(player)
    local frame = player.gui.screen[GUI_NAME]

    if frame and frame.valid then
        frame.destroy()
    end
end


local function open_platform_picker(player)
    close_platform_picker(player)

    local frame = player.gui.screen.add {
        type = "frame",
        name = GUI_NAME,
        caption = "Toggle asteroids",
        direction = "vertical"
    }

    frame.force_auto_center()

    frame.add {
        type = "label",
        caption = "Choose a space platform:"
    }

    local platforms = {}

    for _, platform in pairs(player.force.platforms) do
        if platform.valid
            and platform.surface
            and platform.scheduled_for_deletion == 0 then

            platforms[#platforms + 1] = platform
        end
    end

    table.sort(platforms, function(a, b)
        return a.name < b.name
    end)

    if #platforms == 0 then
        frame.add {
            type = "label",
            caption = "No space platforms available."
        }
    else
        for _, platform in ipairs(platforms) do
            local enabled = asteroids_are_enabled(platform)

            frame.add {
                type = "button",

                caption =
                    platform.name ..
                    " — Asteroids " ..
                    (enabled and "ON" or "OFF"),

                tooltip =
                    enabled
                    and "Click to disable asteroids"
                    or "Click to enable asteroids",

                tags = {
                    action = "toggle-platform-asteroids",
                    platform_index = platform.index
                }
            }
        end
    end

    frame.add {
        type = "button",
        caption = "Close",
        tags = {
            action = "close-platform-picker"
        }
    }

    player.opened = frame
end


script.on_init(function()
    get_state()
end)


script.on_configuration_changed(function()
    get_state()
end)


script.on_event(
    defines.events.on_lua_shortcut,
    function(event)
        if event.prototype_name ~= SHORTCUT_NAME then
            return
        end

        local player = game.get_player(event.player_index)

        if not player then
            return
        end

        open_platform_picker(player)
    end
)

script.on_event(
    defines.events.on_gui_click,
    function(event)
        local element = event.element

        if not (element and element.valid) then
            return
        end

        local player = game.get_player(event.player_index)

        if not player then
            return
        end

        local tags = element.tags

        if tags.action == "close-platform-picker" then
            close_platform_picker(player)
            return
        end

        if tags.action ~= "toggle-platform-asteroids" then
            return
        end

        local platform =
            player.force.platforms[tags.platform_index]

        if not (platform and platform.valid) then
            player.print("That space platform no longer exists.")
            open_platform_picker(player)
            return
        end

        toggle_asteroids_on_platform(player, platform)
        open_platform_picker(player)
    end
)

script.on_event(
    defines.events.on_gui_closed,
    function(event)
        if event.element
            and event.element.valid
            and event.element.name == GUI_NAME then

            event.element.destroy()
        end
    end
)


script.on_nth_tick(10, function()
    local state = get_state()

    for _, force in pairs(game.forces) do
        for _, platform in pairs(force.platforms) do
            if platform.valid
                and state.platform_enabled[platform.index] == false then

                remove_asteroids_from_platform(platform)
            end
        end
    end
end)
