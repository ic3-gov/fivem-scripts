local function getNearestPlayer(radius)
    local me = PlayerPedId()
    local myCoords = GetEntityCoords(me)
    local nearestId, nearestDist = nil, radius or Config.nearestRadius
    for _, ply in ipairs(GetActivePlayers()) do
        if ply ~= PlayerId() then
            local ped = GetPlayerPed(ply)
            local dist = #(GetEntityCoords(ped) - myCoords)
            if dist < nearestDist then
                nearestDist = dist
                nearestId = GetPlayerServerId(ply)
            end
        end
    end
    return nearestId
end

RegisterCommand('deport', function()
    local input = lib.inputDialog('Deportation Menu', {
        { type = 'checkbox', label = 'Use nearest player', checked = false },
        { type = 'number', label = 'Player ID', placeholder = 'Enter player server ID' },
        { type = 'input', label = 'Reason (optional)', placeholder = 'Reason...' }
    })
    if not input then return end

    local useNearest = input[1] == true
    local targetId = nil

    if useNearest then
        targetId = getNearestPlayer(Config.nearestRadius)
        if not targetId then
            lib.notify({ title = Config.notifyTitles.failure, description = 'No nearby players found.', type = 'error', duration = Config.notifyDurations.error })
            return
        end
    else
        targetId = tonumber(input[2])
    end

    if not targetId or targetId == -1 then
        lib.notify({ title = Config.notifyTitles.failure, description = 'Invalid player ID.', type = 'error', duration = Config.notifyDurations.error })
        return
    end

    local valid = lib.callback.await('tommy_deport:validateId', false, targetId)
    if not valid then
        lib.notify({ title = Config.notifyTitles.failure, description = 'Player is offline or invalid.', type = 'error', duration = Config.notifyDurations.error })
        return
    end

    local reason = input[3] or ''
    TriggerServerEvent('tommy_deport:deportRequest', targetId, reason)
end, false)

TriggerEvent('chat:removeSuggestion', '/deport')
TriggerEvent('chat:addSuggestion', '/deport', 'Open Deportation Menu', {})

RegisterNetEvent('tommy_deport:notify', function(ntype, desc)
    lib.notify({
        title = (ntype == 'success' and Config.notifyTitles.success)
             or (ntype == 'error' and Config.notifyTitles.failure)
             or 'Notice',
        description = desc,
        type = ntype,
        duration = Config.notifyDurations[ntype] or 4000
    })
end)

RegisterNetEvent('tommy_deport:teleport', function(coords, heading)
    local ped = PlayerPedId()
    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do Wait(10) end
    ClearPedTasksImmediately(ped)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, heading or 0.0)
    local timeout = GetGameTimer() + 3000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do Wait(0) end
    DoScreenFadeIn(400)
end)

RegisterNetEvent('tommy_deport:deportMsg', function(staff, reason)
    lib.notify({
        title = Config.notifyTitles.success,
        description = Config.deportMessage:format(staff, reason),
        type = 'success',
        duration = Config.notifyDurations.success
    })
    if Config.cadMessage and Config.cadMessage ~= '' then
        lib.notify({
            title = 'CAD',
            description = Config.cadMessage,
            type = 'info',
            duration = Config.notifyDurations.info
        })
    end
end)
