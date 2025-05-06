function LoadTrainModels() -- Load train models
    for _, model in pairs({
        "freight",
        "freight2",
        "freightcar",
        "freightcar2",
        "freightgrain",
        "freightcont1",
        "freightcont2",
        "freighttrailer",
        "tankercar",
        "metrotrain"
    }) do
        loadModel(model)
    end
    debugPrint("Train Models Loaded")
end

function getClosest(coords)
    for _, v in pairs(GetGamePool('CVehicle')) do
        if GetEntityModel(v) == `metrotrain` then
            if #(coords - GetEntityCoords(v)) <= 20 then
                return v
            end
        end
    end
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, PlayerPedId(), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function isPedInTrain(Ped) local inout, vehicle = false, nil
	if IsPedInAnyTrain(Ped) then
        if IsPedInAnyVehicle(Ped) then
            if IsThisModelATrain(GetEntityModel(GetVehiclePedIsIn(Ped))) then
                vehicle = GetVehiclePedIsIn(Ped) inout = true
            end
        else
            vehicle = getClosest(GetEntityCoords(Ped))
            if IsThisModelATrain(GetEntityModel(vehicle)) then inout = true end
        end
	end
	return inout, vehicle
end

-- Add a table to store restricted seat indices
local restrictedSeats = {-1, 0, 1, 5} -- Replace with the indices of restricted seats

function isSeatRestricted(seatIndex)
    for _, restrictedIndex in ipairs(restrictedSeats) do
        if seatIndex == restrictedIndex then
            return true
        end
    end
    return false
end

function putPlayerInSeat(train)
    if IsPedSeated then return end
    local carrige = GetTrainCarriage(train, 1)
    for i = 0, (GetVehicleModelNumberOfSeats(GetEntityModel(train)) - 1) do
        if GetPedInVehicleSeat(train, i) == 0 and not isSeatRestricted(i) then
            SetPedIntoVehicle(PlayerPedId(), train, i)
            IsPedSeated = true
            break
        end
    end

    for i = 0, (GetVehicleModelNumberOfSeats(GetEntityModel(carrige)) - 1) do
        if GetPedInVehicleSeat(carrige, i) == 0 and not isSeatRestricted(i) then
            SetPedIntoVehicle(PlayerPedId(), carrige, i)
            IsPedSeated = true
            break
        end
    end
end

function putPedInSeat(train, ped)
    local carrige = GetTrainCarriage(train, 1)
    for i = 0, (GetVehicleModelNumberOfSeats(GetEntityModel(train)) - 1) do
        if GetPedInVehicleSeat(train, i) == 0 and not isSeatRestricted(i) then
            SetPedIntoVehicle(ped, train, i)
            break
        end
    end

    for i = 0, (GetVehicleModelNumberOfSeats(GetEntityModel(carrige)) - 1) do
        if GetPedInVehicleSeat(carrige, i) == 0 and not isSeatRestricted(i) then
            SetPedIntoVehicle(ped, carrige, i)
            break
        end
    end
end

function getClosestCoord(coords, table)
    local closestCoordinate = nil
    local minDistance = math.huge
	for _, v in pairs(table) do
		local distance = math.sqrt((v.x - coords.x)^2 + (v.y - coords.y)^2 + (v.z - coords.z)^2)
		if distance < minDistance then
            minDistance = distance
            closestCoordinate = v
        end
	end
    return closestCoordinate
end

function removePlayerFromTrain(Ped)
    local closestCoordinate = getClosestCoord(GetEntityCoords(Ped), MetroRemoveStops)
	SetEntityCoords(Ped, closestCoordinate.x, closestCoordinate.y, closestCoordinate.z, nil, nil, nil, nil)
    IsPedSeated = false
end