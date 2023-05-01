---@param source number
local function playerLoaded(source)
    server.voice:setPlayerRadio(source, 0)
end

AddEventHandler('playerDropped', function()
    if server.players[source] then
        server.players[source] = nil
    end
end)

local frameworkEvents = {
    esx = {
        playerLoadedEvent = 'esx:playerLoaded',
        setJobEvent = 'esx:setJob',
        getPlayerData = function(player) return { [player.job.name] = player.job.grade } end
    },
    qb = {
        playerLoadedEvent = 'QBCore:Server:PlayerLoaded',
        setJobEvent = 'QBCore:Server:OnJobUpdate',
        getPlayerData = function(player) return { [player.PlayerData.job.name] = player.PlayerData.job.grade.level } end
    },
    ox = {
        playerLoadedEvent = 'ox:playerLoaded',
        setJobEvent = 'ox:setGroup',
        getPlayerData = function(player) return player.groups end
    }
}

local function setupFrameworkEvents()
    local eventsConfig = frameworkEvents[server.core]

    if eventsConfig then
        AddEventHandler(eventsConfig.playerLoadedEvent, function(player)
            local source = player.source or player
            server.players[source] = eventsConfig.getPlayerData(player)
            playerLoaded(source)
        end)

        AddEventHandler(eventsConfig.setJobEvent, function(source, job)
            local jobData = server.core == 'ox' and { [job] = source } or { [job.name] = job.grade.level or job.grade }
            server.players[source] = jobData
        end)

        for _, player in pairs(server.getPlayers()) do
            local source = player.source or player.PlayerData.source
            server.players[source] = eventsConfig.getPlayerData(player)
        end
    end
end

setupFrameworkEvents()
