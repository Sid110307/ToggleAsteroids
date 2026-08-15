local SHORTCUT_NAME = "toggle-asteroids"


local function get_state()
    storage.toggle_asteroids = storage.toggle_asteroids or {}
    storage.toggle_asteroids.platform_enabled =
        storage.toggle_asteroids.platform_enabled or {}

    return storage.toggle_asteroids
end


local function get_player_platform(player)
    if not (player and player.valid) then
        return nil
    end

    local surface = player.physical_surface

    if not surface then
        return nil
    end

    local platform = surface.platform

    if not (platform and platform.valid) then
        return nil
    end

    return platform
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


local function update_shortcut(player)
    if not (player and player.valid) then
        return
    end

    local platform = get_player_platform(player)

    player.set_shortcut_toggled(
        SHORTCUT_NAME,
        platform ~= nil and asteroids_are_enabled(platform)
    )
end


local function toggle_asteroids(player)
    local platform = get_player_platform(player)

    if not platform then
        player.print("You are not currently on a space platform.")
        update_shortcut(player)
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

    update_shortcut(player)
end


script.on_init(function()
    get_state()

    for _, player in pairs(game.players) do
        update_shortcut(player)
    end
end)


script.on_configuration_changed(function()
    get_state()

    for _, player in pairs(game.players) do
        update_shortcut(player)
    end
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

        toggle_asteroids(player)
    end
)


script.on_event(
    defines.events.on_player_changed_surface,
    function(event)
        local player = game.get_player(event.player_index)

        if player then
            update_shortcut(player)
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
