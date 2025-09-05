local function notify(src, ntype, msg)
    TriggerClientEvent('tommy_deport:notify', src, ntype, msg)
end

lib.callback.register('tommy_deport:validateId', function(_, targetId)
    return targetId and tonumber(targetId) and GetPlayerName(targetId) ~= nil
end)

RegisterNetEvent('tommy_deport:deportRequest', function(targetId, reason)
    local src = source

    if not Config.testing and not IsPlayerAceAllowed(src, Config.permission) then
        notify(src, 'error', ('No permission; requires %s.'):format(Config.permission))
        return
    end

    if not targetId or not tonumber(targetId) or not GetPlayerName(targetId) then
        notify(src, 'error', 'Invalid or offline player id.')
        return
    end

    TriggerClientEvent('tommy_deport:teleport', targetId, Config.destination.coords, Config.destination.heading)

    local srcName = GetPlayerName(src) or ('ID '..src)
    local tgtName = GetPlayerName(targetId) or ('ID '..targetId)
    local r = (reason and reason ~= '') and reason or 'No reason given'

    notify(src, 'success', ('%s sent to immigration. Reason: %s'):format(tgtName, r))
    TriggerClientEvent('tommy_deport:deportMsg', targetId, srcName, r)

    print(('[Deport Log] %s (ID %d) deported %s (ID %d). Reason: %s'):format(srcName, src, tgtName, targetId, r)) -- so ppl w tx can see who deports who 🔥
end)
