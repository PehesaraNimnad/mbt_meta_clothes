-- Looks up the real clothing thumbnail that uz_AutoShot already uploaded to
-- FiveManage (see uz_AutoShot/shots/cdn-map.json), so removed clothing items
-- can show the player's actual clothing image in the inventory instead of
-- the generic category placeholder in item_image/.
--
-- If you renamed the uz_AutoShot resource folder, update AUTOSHOT_RESOURCE below.

local AUTOSHOT_RESOURCE = 'uz_AutoShot'
local CDN_MAP_PATH = 'shots/cdn-map.json'
local CDN_MAP_CACHE_MS = 30000 -- re-read the file at most every 30s

local cdnMap = {}
local cdnMapLoadedAt = 0

local function loadCdnMap()
    if next(cdnMap) ~= nil and (GetGameTimer() - cdnMapLoadedAt) < CDN_MAP_CACHE_MS then
        return cdnMap
    end

    cdnMapLoadedAt = GetGameTimer()

    local raw = LoadResourceFile(AUTOSHOT_RESOURCE, CDN_MAP_PATH)
    if not raw then
        if MBT and MBT.Debug then
            print(('^1[mbt_meta_clothes]^0 Could not read %s/%s — check AUTOSHOT_RESOURCE in server/cdn_images.lua matches your uz_AutoShot resource folder name, and that it has been started at least once with CDN upload enabled.'):format(AUTOSHOT_RESOURCE, CDN_MAP_PATH))
        end
        cdnMap = {}
        return cdnMap
    end

    local ok, decoded = pcall(json.decode, raw)
    cdnMap = (ok and type(decoded) == 'table') and decoded or {}

    if MBT and MBT.Debug then
        local count = 0
        for _ in pairs(cdnMap) do count = count + 1 end
        print(('^2[mbt_meta_clothes]^0 Loaded %d CDN image(s) from %s/%s'):format(count, AUTOSHOT_RESOURCE, CDN_MAP_PATH))
    end

    return cdnMap
end

--- Returns the FiveManage CDN url for a worn drawable, or nil if uz_AutoShot
--- hasn't generated/uploaded that thumbnail yet.
--- @param sex string 'male' | 'female'
--- @param kind string 'component' | 'prop'
--- @param index number the ped component/prop index (e.g. 8 for torso, 0 for hat prop)
--- @param drawable number the drawable id currently worn
function GetClothingCdnImage(sex, kind, index, drawable)
    if sex == nil or index == nil or drawable == nil then return nil end

    local map = loadCdnMap()
    local seg = kind == 'prop' and ('prop_%d'):format(index) or tostring(index)
    local key = ('%s/%s/%d'):format(sex, seg, drawable)
    local url = map[key]

    if MBT and MBT.Debug then
        print(('^3[mbt_meta_clothes]^0 CDN lookup key "%s" -> %s'):format(key, url or 'NOT FOUND'))
    end

    return url
end
