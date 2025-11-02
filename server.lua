local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('qb-scoreboard:server:GetScoreboardData', function(source)
    local totalPlayers = 0
    local policeCount = 0
    local emsCount = 0
    local mechanicCount = 0
    local players = {}
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v then
            totalPlayers += 1
            if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
                policeCount += 1
            elseif v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
                emsCount += 1
            elseif v.PlayerData.job.name == 'mechanic' and v.PlayerData.job.onduty then
                mechanicCount += 1
            end
            players[v.PlayerData.source] = {}
            players[v.PlayerData.source].optin = QBCore.Functions.IsOptin(v.PlayerData.source)
        end
    end
    return totalPlayers, policeCount, emsCount, mechanicCount, players
end)

RegisterNetEvent('qb-scoreboard:server:SetActivityBusy', function(activity, bool)
    Config.IllegalActions[activity].busy = bool
    TriggerClientEvent('qb-scoreboard:client:SetActivityBusy', -1, activity, bool)
end)
