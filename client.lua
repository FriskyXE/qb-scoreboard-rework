local QBCore = exports['qb-core']:GetCoreObject()
local scoreboardOpen = false
local playerOptin = {}

-- Functions

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetPlayers()
    local players = {}
    local activePlayers = GetActivePlayers()
    for i = 1, #activePlayers do
        local player = activePlayers[i]
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            players[#players + 1] = player
        end
    end
    return players
end

local function GetPlayersFromCoords(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}
    coords = coords or GetEntityCoords(PlayerPedId())
    distance = distance or 5.0
    for i = 1, #players do
        local player = players[i]
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - vector3(coords.x, coords.y, coords.z))
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    
    return closePlayers
end

-- Events

RegisterNetEvent('qb-scoreboard:client:SetActivityBusy', function(activity, busy)
    Config.IllegalActions[activity].busy = busy
    if scoreboardOpen then
        SendNUIMessage({
            action = 'updateActivity',
            activity = activity,
            requiredCops = Config.IllegalActions,
        })
    end
end)

RegisterNetEvent('qb-scoreboard:client:UpdateScoreboard', function(players, cops, ems, mechanic)
    if scoreboardOpen then
        SendNUIMessage({
            action = 'update',
            players = players,
            maxPlayers = Config.MaxPlayers,
            requiredCops = Config.IllegalActions,
            currentCops = cops,
            currentEms = ems,
            currentMechanic = mechanic
        })
    end
end)

-- Command

if Config.Toggle then
    RegisterCommand('scoreboard', function()
        if not scoreboardOpen then
            local players, cops, ems, mechanic, playerList = lib.callback.await('qb-scoreboard:server:GetScoreboardData', false)
            playerOptin = playerList

            SendNUIMessage({
                action = 'open',
                players = players,
                maxPlayers = Config.MaxPlayers,
                requiredCops = Config.IllegalActions,
                currentCops = cops,
                currentEms = ems,
                currentMechanic = mechanic
            })

            scoreboardOpen = true
        else
            SendNUIMessage({
                action = 'close',
            })

            scoreboardOpen = false
        end
    end, false)

    RegisterKeyMapping('scoreboard', 'Open Scoreboard', 'keyboard', Config.OpenKey)
else
    RegisterCommand('+scoreboard', function()
        if scoreboardOpen then return end
        local players, cops, ems, mechanic, playerList = lib.callback.await('qb-scoreboard:server:GetScoreboardData', false)
        playerOptin = playerList

        SendNUIMessage({
            action = 'open',
            players = players,
            maxPlayers = Config.MaxPlayers,
            requiredCops = Config.IllegalActions,
            currentCops = cops,
            currentEms = ems,
            currentMechanic = mechanic
        })

        scoreboardOpen = true
    end, false)

    RegisterCommand('-scoreboard', function()
        if not scoreboardOpen then return end
        SendNUIMessage({
            action = 'close',
        })

        scoreboardOpen = false
    end, false)

    RegisterKeyMapping('+scoreboard', 'Open Scoreboard', 'keyboard', Config.OpenKey)
end

-- Threads

CreateThread(function()
    Wait(1000)
    local actions = {}
    for k, v in pairs(Config.IllegalActions) do
        actions[k] = {
            label = v.label,
            icon = v.icon or 'fa-mask'
        }
    end
    SendNUIMessage({
        action = 'setup',
        items = actions
    })
end)

CreateThread(function()
    while true do
        if scoreboardOpen then
            -- Update scoreboard data every 3 seconds
            local players, cops, ems, mechanic, playerList = lib.callback.await('qb-scoreboard:server:GetScoreboardData', false)
            playerOptin = playerList

            SendNUIMessage({
                action = 'update',
                players = players,
                maxPlayers = Config.MaxPlayers,
                requiredCops = Config.IllegalActions,
                currentCops = cops,
                currentEms = ems,
                currentMechanic = mechanic
            })
            
            Wait(3000)
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        if scoreboardOpen then
            local playerCoords = GetEntityCoords(cache.ped)
            for _, player in ipairs(GetPlayersFromCoords(playerCoords, 10.0)) do
                local playerId = GetPlayerServerId(player)
                local playerPed = GetPlayerPed(player)
                local coords = GetEntityCoords(playerPed)
                if Config.ShowIDforALL or (playerOptin[playerId] and playerOptin[playerId].optin) then
                    DrawText3D(coords.x, coords.y, coords.z + 1.0, '[' .. playerId .. ']')
                end
            end
            Wait(0)
        else
            Wait(100)
        end
    end
end)
