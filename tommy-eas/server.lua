local SECRET_CODE = '371X-282D-1Y0Z'
local ACCESS_MIN  = (Config.AccessMinutes)

local authed = {}
local strikes = {}

local function now() return os.time() end

local function isAuthed(src)
    local exp = authed[src]
    return exp and exp > now()
end

local function tryAuth(src, code)
    local st = strikes[src] or { fails = 0, lock = 0 }
    if st.lock and st.lock > now() then
        return false, ('Locked. Try again in %ds.'):format(st.lock - now())
    end

    if type(code) == 'string' and code == SECRET_CODE then
        authed[src] = now() + (ACCESS_MIN * 60)
        strikes[src] = nil
        return true
    end

    st.fails = (st.fails or 0) + 1
    if st.fails >= 3 then
        st.fails = 0
        st.lock = now() + 60
    end
    strikes[src] = st
    return false, 'Invalid code.'
end

lib.callback.register('eas:server:isAuthed', function(src)
    return isAuthed(src)
end)

lib.callback.register('eas:server:auth', function(src, code)
    local ok, msg = tryAuth(src, code or '')
    return ok, msg
end)

local function oneline(s)
    s = tostring(s or '')
    s = s:gsub('[\r\n]+', ' ')
    return s
end

RegisterNetEvent('eas:server:broadcast', function(payload)
    local src = source
    local msg = {
        title = tostring(payload.title or 'Emergency Alert'),
        text = tostring(payload.text or ''),
        duration = tonumber(payload.duration) or Config.DefaultDuration,
        volume = tonumber(payload.volume) or Config.DefaultVolume,
        playSound = payload.playSound ~= false
    }

    local pname = (src == 0) and 'CONSOLE' or (GetPlayerName(src) or ('ID '..tostring(src)))
    print(('[EAS ALERT] %s has sent an emergency broadcast. Message: %s'):format(pname, oneline(msg.text)))

    TriggerClientEvent('eas:client:show', -1, msg)
end)

AddEventHandler('playerDropped', function()
    local src = source
    authed[src] = nil
    strikes[src] = nil
end)
