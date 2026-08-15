data:extend({
    {
        type = "shortcut",
        name = "toggle-asteroids",
        order = "z[toggle-asteroids]",
        action = "lua",

        toggleable = true,
        style = "red",

        localised_name = "Toggle asteroids",
        localised_description =
            "Enable or disable asteroids on the current space platform",

        icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
        icon_size = 64,

        small_icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
        small_icon_size = 64
    }
})