local current_hash = nil

local ped <const> = PlayerPedId()
local ox_inventory <const> = exports.ox_inventory

local slots <const> = {
        {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.19, -0.04),
        },
        {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.15, -0.16),
        },
        {
                hash = nil,
                entity = nil,
                weapon = nil,
                position = vec3(0.13, -0.15, -0.07),
        },
}

local clear = function(index)
        DetachEntity(slots[index].entity)
        DeleteEntity(slots[index].entity)

        slots[index].hash = nil
        slots[index].entity = nil
        slots[index].weapon = nil
end

local get_free = function(hash)
        for index = 1, #slots do
                if slots[index].hash == hash then return false end
        end

        for index = 1, #slots do
                if slots[index].entity == nil then return index end
        end

        return false
end

local put = function(hash)
        local index <const> = get_free(hash)

        if index then
                current_hash = nil

                local item <const> = Config.Weapons[hash].item
                local object <const> = Config.Weapons[hash].object

                lib.requestModel(object, 500)

                local coords <const> = GetEntityCoords(ped)
                local prop <const> = CreateObject(object, coords.x, coords.y, coords.z, true, true, true)

                slots[index].hash = hash
                slots[index].entity = prop
                slots[index].weapon = item

                AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 24816), slots[index].position.x, slots[index].position.y, slots[index].position.z, Config.Weapons[hash].rotation.x, Config.Weapons[hash].rotation.y, Config.Weapons[hash].rotation.z, true, true, false, true, 2, true)
        end
end

local rem = function(hash)
        if Config.Weapons[hash] == nil then return end

        local count <const> = ox_inventory:Search(2, Config.Weapons[hash].item)

        for index = 1, #slots do
                if slots[index].hash == hash then
                        if count == 0 or hash == current_hash then
                                clear(index)
                        end
                end
        end
end

AddEventHandler("playerSpawned", function()
        if IsPedInAnyVehicle(ped) then return end

        for index = 1, #slots do
                clear(index)
        end

        for key, value in pairs(Config.Weapons) do
                local count <const> = ox_inventory:Search(2, value.item)

                if count >= 1 then put(key) end
        end
end)

AddEventHandler("respawnPlayerPedEvent", function()
        if IsPedInAnyVehicle(ped) then return end

        for index = 1, #slots do
                clear(index)
        end

        for key, value in pairs(Config.Weapons) do
                local count <const> = ox_inventory:Search(2, value.item)

                if count >= 1 then put(key) end
        end
end)

AddEventHandler("ox_inventory:currentWeapon", function(weapon)
        if weapon then
                if Config.Weapons[weapon.hash] then
                        put(current_hash)
                        current_hash = weapon.hash
                        rem(weapon.hash)
                end
        else
                if current_hash then
                        put(current_hash)
                end
        end
end)

AddEventHandler("ox_inventory:updateInventory", function(changes)
        for key, value in pairs(changes) do
                if type(value) == "table" then
                        local hash <const> = joaat(value.name)

                        if Config.Weapons[hash] then
                                if current_hash ~= hash then
                                        put(hash)
                                else
                                        rem(hash)
                                end
                        end
                elseif type(value) == "boolean" then
                        for index = 1, #slots do
                                local count <const> = ox_inventory:Search(2, slots[index].weapon)

                                if count == 0 then rem(slots[index].hash) end
                        end
                end
        end
end)

lib.onCache("vehicle", function(vehicle)
        if vehicle then
                for index = 1, #slots do
                        clear(index)
                end
        else
                for key, value in pairs(Config.Weapons) do
                        local count <const> = ox_inventory:Search(2, value.item)

                        if count >= 1 then put(key) end
                end
        end
end)