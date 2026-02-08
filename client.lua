-- Minimalist client.lua for FiveM - Bus/Airbus player can use as passenger (with player-inside check)
Citizen.CreateThread(function()
    local function warpVehiclePed(ped, veh)
        Citizen.CreateThread(function()
            while true do
                TaskWarpPedIntoVehicle(ped, veh, 3)
--                TaskEnterVehicle(ped, veh, 10, i, 2.0, 16, 0)
                TaskWarpPedIntoVehicle(ped, veh, 1)
--                print("warping vehicle:", veh, "ped:", ped)
                Citizen.Wait(1000)
            end
        end)
    end
        
    while true do
    local waitTime = 1000
--    local waitTime = 3000
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    -- Skip if player is already in a vehicle (optimize)
    if playerVehicle == 0 then
        local foundTarget = false
        local vehicles = GetGamePool('CVehicle')

        for _, vehicle in ipairs(vehicles) do

            if DoesEntityExist(vehicle) and not foundTarget then
                local vehCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehCoords)

                -- Check distance (optimize - 50.0 units radius)
                if distance < 50.0 then
                    local modelHash = GetEntityModel(vehicle)
                    local modelName = GetDisplayNameFromVehicleModel(modelHash)

                    -- Check for bus or airbus
                    if modelName == "BUS" or modelName == "AIRBUS" then
                        local driver = GetPedInVehicleSeat(vehicle, -1)
                        busveh = vehicle
                        -- If driver exists and is NPC set him as a bus driver
                        if DoesEntityExist(driver) and not IsPedAPlayer(driver) then
                            SetPedCanBeDraggedOut(driver, false)
                            SetPedCanBeTargetted(driver, false)
                            SetPedStayInVehicleWhenJacked(driver, true)
                            SetBlockingOfNonTemporaryEvents(driver, true)
                            SetPedConfigFlag(driver, 251, true)
                            SetPedConfigFlag(driver, 24, true) -- new
                            SetPedConfigFlag(driver, 64, true)

                            SetPedConfigFlag(driver, 374, true)
                            SetPedConfigFlag(driver, 402, true)

                            waitTime = 100  -- Found target, check more frequently
                            foundTarget = true  -- Stop loop for this vehicle/ped
                            break
                        end
                    end
                end
            end
        end
    end

    if IsPedInAnyVehicle(playerPed, true) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        playerisdriver = GetPedInVehicleSeat(vehicle, -1)
        if veh == busveh then
            TaskWarpPedIntoVehicle(ped, veh, 3)
            TaskWarpPedIntoVehicle(ped, veh, 1)
--            warpVehiclePed(playerPed, veh)
        end
    end

    Citizen.Wait(waitTime)
    end
end)
