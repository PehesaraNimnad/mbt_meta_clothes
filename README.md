### Dependencies:
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [ox_lib](https://github.com/overextended/ox_lib)

### Real clothing images (CDN)
If you also run `uz_AutoShot` with CDN upload enabled, removed clothing items will automatically show the player's actual clothing photo in their inventory instead of the generic icon above — no setup needed here beyond making sure `AUTOSHOT_RESOURCE` in `server/cdn_images.lua` matches your uz_AutoShot resource folder name.
<br />
An item only gets its real photo once that exact drawable has been shot & uploaded on your server — anything not uploaded yet just falls back to the local `client.image` icon set below.
<br />
Set `MBT.Debug = true` in `config.lua` to print each CDN lookup (and whether it found a match) to the server console — handy for checking why a particular item isn't showing its real photo yet.

### ⚠️Important:
Add to your items the following ones (customize the settings to fit your needs) DO NOT CHANGE THE ITEMS NAME!
<br/>
The resource has been tested ONLY on Ox Core and ESX
<br />
Remember to check and change if needed the ```Default``` clothes in ```MBT.Drawables``` and ```MBT.Props ```
<br />
Copy the PNG files from this resource's ```item_image/``` folder into ```ox_inventory/web/images/``` — they're used as the fallback icon whenever a specific drawable hasn't been uploaded to your CDN yet (see the CDN section further down).

## ox_inventory/data/items.lua

```
['tshirt'] = {
    label = 'T-Shirt',
    description = 'A stylish T-shirt for your everyday outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'tshirt.png',
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', flag = 51 },
        usetime = 1200,
    }
},

['arms'] = {
    label = 'Arms',
    description = 'A pair of clothing sleeves to complete your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'arms.png',
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', flag = 51 },
        usetime = 1200,
    }
},

['jacket'] = {
    label = 'Jacket',
    description = 'A fashionable jacket to complete your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'jacket.png',
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d', flag = 51 },
        usetime = 1200,
    }
},

['mask'] = {
    label = 'Mask',
    description = 'A mask that covers your face and completes your look.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'mask.png',
        anim = { dict = 'clothingspecs', clip = 'take_off', flag = 51 },
        usetime = 1200,
    }
},

['trousers'] = {
    label = 'Trousers',
    description = 'A pair of trousers for a complete outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'trousers.png',
        anim = { dict = 're@construction', clip = 'out_of_breath', flag = 51 },
        usetime = 1200,
    }
},

['shoes'] = {
    label = 'Shoes',
    description = 'A pair of shoes to complete your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'shoes.png',
        anim = { dict = 'random@domestic', clip = 'pickup_low', flag = 0 },
        usetime = 1200,
    }
},

['hat'] = {
    label = 'Hat',
    description = 'A stylish hat to complete your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'hat.png',
        anim = { dict = 'missheist_agency2ahelmet', clip = 'take_off_helmet_stand', flag = 51 },
        usetime = 1200,
    }
},

['glasses'] = {
    label = 'Glasses',
    description = 'A pair of glasses to complete your look.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'glasses.png',
        anim = { dict = 'clothingspecs', clip = 'take_off', flag = 51 },
        usetime = 1200,
    }
},

['earaccess'] = {
    label = 'Ear Accessories',
    description = 'Stylish ear accessories to add a finishing touch to your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'earaccess.png',
        anim = { dict = 'mp_cp_stolen_tut', clip = 'b_think', flag = 51 },
        usetime = 1200,
    }
},

['chaincloth'] = {
    label = 'Chain',
    description = 'A stylish chain accessory worn around the neck.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'chain.png',
        anim = { dict = 'clothingtie', clip = 'try_tie_positive_a', flag = 51 },
        usetime = 2500,
    }
},

['watch'] = {
    label = 'Watch',
    description = 'A stylish wristwatch that adds a finishing touch to your outfit.',
    weight = 100,
    stack = true,
    close = true,
    client = {
        image = 'watch.png',
        anim = { dict = 'nmt_3_rcm-10', clip = 'cs_nigel_dual-10', flag = 51 },
        usetime = 900,
    }
},
  
```
## ox_inventory/modules/items/client.lua

```
local function ClothingNotify(description, type)
    lib.notify({
        title = 'Clothing',
        description = description,
        type = type or 'inform',
        position = 'top-right'
    })
end

local function NormalizeSex(raw)
    if raw == nil then return nil end

    if type(raw) == 'boolean' then
        return raw and "m" or "f"
    end

    if type(raw) == 'number' then
        return raw == 0 and "m" or "f"
    end

    if type(raw) == 'string' then
        local lower = raw:lower()
        if lower == 'm' or lower == 'male' or lower == '0' then return "m" end
        if lower == 'f' or lower == 'female' or lower == '1' then return "f" end
    end

    return nil
end

local function GetPlayerSex()
    return NormalizeSex(PlayerData and PlayerData.sex)
end

local function CheckClothingGender(slot)
    local sexLabel = {
        ["m"] = "man",
        ["f"] = "woman"
    }

    local playerSex = GetPlayerSex()
    local itemSex = NormalizeSex(slot.metadata.sex)
    if not playerSex or not itemSex then
        print(('^1[mbt_meta_clothes]^0 Could not resolve sex - PlayerData.sex=%s slot.metadata.sex=%s'):format(
            tostring(PlayerData and PlayerData.sex), tostring(slot.metadata.sex)))
        return true
    end

    if playerSex ~= itemSex then
        ClothingNotify(
            "This piece of clothing is not for " .. (sexLabel[playerSex] or "your gender") .. ".",
            "error"
        )
        return false
    end

    return true
end

Item('tshirt', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this T-Shirt.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('arms', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this clothing item.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('jacket', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this jacket.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('mask', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this mask.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('trousers', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear these trousers.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('shoes', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear these shoes.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('chaincloth', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Drawables",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this chain.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyDress", slot.metadata)
                end
            end)
        end
    })
end)

Item('watch', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Props",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this watch.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyProps", slot.metadata)
                end
            end)
        end
    })
end)

Item('hat', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Props",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear this hat.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyProps", slot.metadata)
                end
            end)
        end
    })
end)

Item('glasses', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Props",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear these glasses.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyProps", slot.metadata)
                end
            end)
        end
    })
end)

Item('earaccess', function(data, slot)
    if not CheckClothingGender(slot) then return end

    TriggerEvent("mbt_metaclothes:checkDress", {
        type = "Props",
        index = slot.metadata.index,
        sex = GetPlayerSex(),
        cb = function(canDress)
            if not canDress then
                ClothingNotify("You cannot wear these ear accessories.", "error")
                return
            end

            ox_inventory:useItem(data, function(data)
                if data then
                    TriggerEvent("mbt_metaclothes:applyProps", slot.metadata)
                end
            end)
        end
    })
end)


```



# Change Log

## Fixed issues:

* client.lua — Fixed sex format mismatch ("male"/"female" → "m"/"f") in handleUndress / handleProps functions, so item metadata sent to the server now matches the format expected by the gender check.
* config.lua — Renamed item chain → chaincloth to stay consistent with the item name used in items.lua.
* client.lua (placed in ox_inventory's modules/items/client.lua) — Removed cross-resource dependency on MBT / QBCore globals (not accessible from ox_inventory's own resource context), and rewrote the gender check to use ox_inventory's own PlayerData.sex instead.
