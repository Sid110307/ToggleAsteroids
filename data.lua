data:extend({
    {
        type = "shortcut",
        name = "toggle-asteroids",
        order = "z[toggle-asteroids]",
        action = "lua",

        toggleable = false,
        style = "red",

        localised_name = "Toggle asteroids",
        localised_description =
            "Choose a space platform and enable or disable asteroids",

        icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
        icon_size = 64,

        small_icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
        small_icon_size = 64
    }
})