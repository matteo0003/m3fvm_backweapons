local current_weapon_hash = nil

local ped <const> = PlayerPedId()
local ox_inventory <const> = exports.ox_inventory

local slots <const> = {
        [1] = {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.19, -0.04),
        },
        [2] = {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.15, -0.16),
        },
        [3] = {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.15, 0.07),
        },
}

local clear_slot = function(index)
        print("clearing " .. tostring(index))

        DetachEntity(slots[index].entity)
        DeleteEntity(slots[index].entity)

        slots[index].hash = nil
        slots[index].entity = nil
        slots[index].weapon = nil
end

local get_free_slot_index = function(hash)
        for i = 1, #slots do
                if slots[i].hash == hash then return false end
        end
        for i = 1, #slots do
                local slot = slots[i]
                if not slot.entity then
                        return i
                end
        end
        return false
end


local put = function(hash)
        local index <const> = get_free_slot_index(hash)

        print("index : " .. tostring(index))

        if index then
                current_weapon_hash = nil

                local item = Config.Weapons[hash].item
                local object = Config.Weapons[hash].object

                lib.requestModel(object, 500)

                local coords <const> = GetEntityCoords(ped)
                local prop <const> = CreateObject(object, coords.x, coords.y, coords.z, true, true, true)

                slots[index].hash = hash
                slots[index].entity = prop
                slots[index].weapon = item

                AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 24816), slots[index].position.x, slots[index].position.y, slots[index].position.z, Config.Weapons[hash].rotation.x, Config.Weapons[hash].rotation.y, Config.Weapons[hash].rotation.z, true, true, false, true, 2, true)
        end
end

local remove_from_slot = function(hash)
        print("we MUST remove")
        if Config.Weapons[hash] == nil then return end
        print("we passed hash")

        local count <const> = ox_inventory:Search(2, Config.Weapons[hash].item)

        for index = 1, #slots do
                if slots[index].hash == hash then
                        print('l86 is true')
                        if count == 0 or hash == current_weapon_hash then
                                print("we remove")
                                clear_slot(index)
                        end
                end
        end
end

AddEventHandler('ox_inventory:currentWeapon', function(data)
        if data then
                print("yes data")
                if Config.Weapons[data.hash] then
                        print("we have it")
                        put(current_weapon_hash)
                        current_weapon_hash = data.hash
                        remove_from_slot(data.hash)
                end
        else
                if current_weapon_hash then
                        print("same")
                        put(current_weapon_hash)
                end
        end
end)

AddEventHandler('ox_inventory:updateInventory', function(changes)
        for key, value in pairs(changes) do
                if type(value) == 'table' then
                        local hash <const> = joaat(value.name)
                        if Config.Weapons[hash] then
                                if current_weapon_hash ~= hash then
                                        put(hash)
                                else
                                        remove_from_slot(hash)
                                end
                        end
                end

                if type(value) == 'boolean' then
                        for index = 1, #slots do
                                local count <const> = ox_inventory:Search(2, slots[index].weapon)
                                if count == 0 then
                                        remove_from_slot(slots[index].hash)
                                end
                        end
                end
        end
end)

lib.onCache('vehicle', function(value)
        print(vehicle)

        if value then
                for index = 1, #slots do
                        clear_slot(index)
                end
        else
                for key, v2 in pairs(Config.Weapons) do
                        local count <const> = ox_inventory:Search(2, v2.item)
                        if count >= 1 then
                                put(key)
                        end
                end
        end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
        print("isnew : ", tostring(isnew))

        if IsPedInAnyVehicle(ped) then return end

        for key, v2 in pairs(Config.Weapons) do
                local count <const> = ox_inventory:Search(2, v2.item)
                if count >= 1 then
                        print("v2" .. tostring(v2.label))
                        put(key)
                end
        end
end)
