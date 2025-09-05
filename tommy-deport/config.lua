Config = {}

Config.testing = false
Config.permission = 'group.leo'

Config.nearestRadius = 3.0

Config.destination = {
  coords = vec3(4910.18, -5205.02, 2.55), heading = 219.0
}

Config.notifyTitles = {
  success = 'Deported',
  failure = 'Deport Failed'
}

Config.notifyDurations = {
    success = 4000,
    error   = 4500,
    info    = 6000
}

Config.deportMessage = 'You were deported by %s. Reason: %s'
Config.cadMessage = 'Register in the CAD to avoid being deported!'