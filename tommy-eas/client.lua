RegisterNetEvent('eas:client:show', function(data)
    SendNUIMessage({
        action = 'show',
        cfg = {
            height = Config.BannerHeight,
            bg = Config.BannerBg,
            color = Config.BannerTextColor,
            border = Config.BannerBorder,
            font = Config.FontFamily,
            size = Config.FontSize,
            speed = Config.MarqueeSpeed,
            restartMode = Config.MarqueeRestartMode,
            header = Config.HeaderText,
            headerGap = Config.HeaderGap
        },
        title = data.title,
        text = data.text,
        duration = data.duration,
        volume = data.volume,
        playSound = data.playSound
    })
    SetNuiFocus(false, false)
end)

local function deptOptions()
    local opts = {}
    for _, d in ipairs(Config.Departments or {}) do
        local label = d.label or d.value
        opts[#opts+1] = { value = d.value, label = label }
    end
    if #opts == 0 then
        opts = { { value = 'EMERGENCY ALERT', label = 'EMERGENCY ALERT' } }
    end
    return opts
end

local function openSenderInner()
    local volDefault = math.floor(math.min((Config.DefaultVolume or 0.4), 0.5) * 100)

    local input = lib.inputDialog('Emergency Alert Sender', {
        {
            type = 'select',
            label = 'Department / Title',
            options = deptOptions(),
            default = 1,
            required = true
        },
        { type = 'textarea', label = 'Message text', placeholder = 'Describe the alert', required = true, min = 3, max = 800 },
        { type = 'number', label = 'Duration seconds', default = Config.DefaultDuration, min = 5, max = 600, step = 1, required = true },
        { type = 'slider', label = 'Volume (0-50)', default = volDefault, min = 0, max = 50, step = 1 },
        { type = 'checkbox', label = 'Play sound', checked = Config.PlaySoundByDefault }
    })
    if not input then return end

    local title = input[1]
    local text = input[2]
    local dur  = tonumber(input[3]) or Config.DefaultDuration
    local vol  = (tonumber(input[4]) or volDefault) / 100.0
    local snd  = input[5] and true or false

    TriggerServerEvent('eas:server:broadcast', {
        title = title,
        text = text,
        duration = dur,
        volume = vol,
        playSound = snd
    })
    lib.notify({ title = 'EAS', description = 'Alert sent', type = 'success' })
end

local function promptForCodeThenOpen()
    lib.callback('eas:server:isAuthed', false, function(ok)
        if ok then
            openSenderInner()
            return
        end

        local code = lib.inputDialog('Emergency Alert System Firewall', {
            { type = 'input', label = 'Access Code', password = true, required = true, placeholder = 'Enter code' }
        })
        if not code then return end

        lib.callback('eas:server:auth', false, function(ok, msg)
            if ok then
                lib.notify({ title = 'EAS', description = 'Access granted', type = 'success' })
                openSenderInner()
            else
                lib.notify({ title = 'EAS', description = msg or 'Access denied', type = 'error' })
            end
        end, code[1])
    end)
end

RegisterCommand(Config.OpenMenuCommand, promptForCodeThenOpen)
