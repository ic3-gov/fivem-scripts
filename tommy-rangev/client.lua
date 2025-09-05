local active = false
local untilTime = 0
local radius = 0.0

RegisterCommand('range', function(_, args)
    local r = tonumber(args[1])
    if not r or r <= 0 then
        TriggerEvent('chat:addMessage', { args = { 'Range', 'Usage: /range <meters>' } })
        return
    end
    radius = r * 1.0
    untilTime = GetGameTimer() + 5000
    active = true
end, false)

CreateThread(function()
    while true do
        if active then
            if GetGameTimer() >= untilTime then
                active = false
            else
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                DrawMarker(
                    1, pos.x, pos.y, pos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius * 2.0, radius * 2.0, 0.2, 0, 150, 255, 100, false, false, 2, false, nil, nil, false
                )
            end
            Wait(0)
        else
            Wait(200)
        end
    end
end)
