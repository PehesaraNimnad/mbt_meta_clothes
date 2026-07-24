local ox_inventory = exports.ox_inventory
local currLang = MBT.Labels[MBT.Language]

if MBT.Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
elseif MBT.Framework == 'QB' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif MBT.Framework == 'OX' then
    local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
    local import = LoadResourceFile('ox_core', file)
    local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
    chunk()
end

if MBT.Framework == 'ESX' then
    RegisterNetEvent('mbt_metaclothes:saveSkin', function(appearance)
        local xPlayer = ESX.GetPlayerFromId(source)
        MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', {json.encode(appearance), xPlayer.identifier})
    end)
end

RegisterNetEvent('mbt_metaclothes:giveDress', function(data)
    local _source = source
    local xPlayer = (MBT.Framework == "OX" and Ox.GetPlayer(_source)) or (MBT.Framework == "ESX" and ESX.GetPlayerFromId(_source)) or (MBT.Framework == "QB" and QBCore.Functions.GetPlayer(_source))
    if xPlayer then
        local playerIdentity = (MBT.Framework == "OX" and xPlayer.name) or (MBT.Framework == "ESX" and xPlayer.getName()) or (MBT.Framework == "QB" and xPlayer.PlayerData.name)
        local metadata = {description = currLang["clothes_desc"]:format(playerIdentity), index = data.Index, sex = data.Sex, drawable = data.Drawable, texture = data.Texture, palette = data.Palette}

        local image = GetClothingCdnImage(data.Sex, 'component', data.Index, data.Drawable)
        if image then
            metadata.imageurl = image
        elseif MBT.Debug then
            print(('^3[mbt_meta_clothes]^0 No CDN image for %s/%s/%s (item: %s) — falling back to the default item icon'):format(data.Sex, data.Index, data.Drawable, data.Item))
        end

        ox_inventory:AddItem(_source, data.Item, 1, metadata)
    end
end)

RegisterNetEvent('mbt_metaclothes:giveProp', function(data)
    local _source = source

    local xPlayer = (MBT.Framework == "OX" and Ox.GetPlayer(_source)) or (MBT.Framework == "ESX" and ESX.GetPlayerFromId(_source)) or (MBT.Framework == "QB" and QBCore.Functions.GetPlayer(_source))

    if xPlayer then
        local playerIdentity = (MBT.Framework == "OX" and xPlayer.name) or (MBT.Framework == "ESX" and xPlayer.getName()) or (MBT.Framework == "QB" and xPlayer.PlayerData.name) 
        local metadata = {description = currLang["props_desc"]:format(playerIdentity), index = data.Index, sex = data.Sex, drawable = data.Drawable, texture = data.Texture}

        local image = GetClothingCdnImage(data.Sex, 'prop', data.Index, data.Drawable)
        if image then
            metadata.imageurl = image
        elseif MBT.Debug then
            print(('^3[mbt_meta_clothes]^0 No CDN image for %s/prop_%s/%s (item: %s) — falling back to the default item icon'):format(data.Sex, data.Index, data.Drawable, data.Item))
        end

        ox_inventory:AddItem(_source, data.Item, 1, metadata)
    end

end)
