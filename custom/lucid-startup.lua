-- written by Lucid Settings > Startup, and rewritten on every change there
return {
    xdg = false,
    env = {
        { name = "HYPRCURSOR_THEME", value = "lucid-cursors" },
        { name = "HYPRCURSOR_SIZE", value = "24" },
    },
    apps = {
        { name = "hypridle", cmd = "hypridle" },
    },
}
