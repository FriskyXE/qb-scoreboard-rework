Config = Config or {}

Config.Toggle = true
Config.OpenKey = 'HOME'
Config.ShowIDforALL = false
Config.MaxPlayers = GetConvarInt('sv_maxclients', 48)

Config.IllegalActions = {
    ['storerobbery'] = {
        minimumPolice = 1,
        busy = false,
        label = 'Store Robbery',
        icon = 'fa-store'
    },
    ['bankrobbery'] = {
        minimumPolice = 3,
        busy = false,
        label = 'Bank Robbery',
        icon = 'fa-building-columns'
    },
    ['jewellery'] = {
        minimumPolice = 2,
        busy = false,
        label = 'Jewelery',
        icon = 'fa-gem'
    },
    ['pacific'] = {
        minimumPolice = 5,
        busy = false,
        label = 'Pacific Bank',
        icon = 'fa-landmark'
    },
    ['paleto'] = {
        minimumPolice = 4,
        busy = false,
        label = 'Paleto Bay Bank',
        icon = 'fa-university'
    }
}
