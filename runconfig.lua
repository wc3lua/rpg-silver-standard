-- This is how you tell Ceres how to launch your game.
-- Without this, `ceres run` will not work.
-- Uncomment and fill in the fields that you want
ceres.runConfig = {
    command = "C:\\Program Files\\Warcraft III\\x86_64\\Warcraft III.exe", -- mandatory, path to WC3 or a shell script
    -- prefix = "", -- this will be prepended to the map path when launching. useful under Wine. leave this commented out on Windows.
    mapDataDir = "C:\\Users\\WriteCoin\\Documents\\Warcraft III\\CustomMapData\\", -- points Ceres to the CustomMapData folder for interop with the WC3 client. optional.
    args = {"-windowmode", "windowed"} -- extra args if you want to specify any.
}