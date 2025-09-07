Config = {}

Config.BannerHeight = 160
Config.BannerBg = 'FF202020'
Config.BannerTextColor = '#ffffff'
Config.BannerBorder = 'red'
Config.FontFamily = 'Montserrat, Arial, sans-serif'
Config.FontSize = 28

Config.MarqueeSpeed = 120
Config.MarqueeRestartMode = 'clear' -- edge = restart on left edge hit, clear = wait until fully off

Config.HeaderText = 'EMERGENCY ALERT SYSTEM'
Config.HeaderGap   = 4

Config.DefaultDuration = 20
Config.DefaultVolume = 0.4
Config.PlaySoundByDefault = true

Config.OpenMenuCommand = 'eas'
Config.AccessMinutes = 30

Config.Departments = {
    { value = 'STATE EMERGENCY' },
    { value = 'UNITED STATES GOVERNMENT' },
    { value = 'WEATHER ALERT' },
    { value = "BLAINE COUNTY SHERIFF'S OFFICE" },
    { value = "SAN ANDREAS STATE TROOPERS" },
    { value = "SAN ANDREAS FIRE & RESCUE" },
}
