local function hasResource(name)
    return GetResourceState(name):find('start') ~= nil
end

server = {
    core = (hasResource('es_extended') and 'esx') or (hasResource('qb-core') and 'qb') or (hasResource('ox_core') and 'ox') or '',
    voice = exports['pma-voice'],
    players = {}
}

local frameworks = {
    esx = {
        resource = 'es_extended',
        objectFunction = 'getSharedObject',
        registerItemFunction = 'RegisterUsableItem',
        getPlayersFunction = 'GetExtendedPlayers'
    },
    qb = {
        resource = 'qb-core',
        objectFunction = 'GetCoreObject',
        registerItemFunction = 'CreateUseableItem',
        getPlayersFunction = 'Functions.GetQBPlayers'
    }
}

local function configureFramework()
    local frameworkConfig = frameworks[server.core]

    if frameworkConfig then
        local framework = exports[frameworkConfig.resource][frameworkConfig.objectFunction]()
        server.getPlayers = framework[frameworkConfig.getPlayersFunction]

        if not ac.useCommand and not hasResource('ox_inventory') then
            framework[frameworkConfig.registerItemFunction]('radio', function(source)
                TriggerClientEvent('ac_radio:openRadio', source)
            end)
        end
    end
end

local function setupRestrictedChannels()
    for frequency, allowed in pairs(ac.restrictedChannels) do
        server.voice:addChannelCheck(tonumber(frequency), function(source)
            local groups = server.players[source]
            if not groups then return false end

            if type(allowed) == 'table' then
                for name, rank in pairs(allowed) do
                    local groupRank = groups[name]
                    if groupRank and groupRank >= (rank or 0) then
                        return true
                    end
                end
            else
                if groups[allowed] then
                    return true
                end
            end

            return false
        end)
    end
end

local convars = {
	radio_noRadioDisconnect = tostring(ac.noRadioDisconnect),
	voice_useNativeAudio = tostring(ac.radioEffect),
	voice_enableSubmix = ac.radioEffect and '1' or '0',
	voice_enableRadioAnim = ac.radioAnimation and '1' or '0',
	voice_defaultRadio = ac.radioKey
}
local function setConvars()
    for key, value in pairs(convars) do
        SetConvarReplicated(key, value)
    end
end


configureFramework()
setupRestrictedChannels()
setConvars()
