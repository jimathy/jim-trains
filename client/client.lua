local trainTable, entPool, hasTicket, freightStop, getOffNextStop = {}, {}, false, {}, false

LoadTrainModels()
for _, i in pairs({ 0, 3 }) do -- pick the only looping tracks
	SwitchTrainTrack(i, true)
	SetTrainTrackSpawnFrequency(i, 480000)
end
SetRandomTrains(true)  -- enable

if Config.General.showStationBlips then
	for _, coord in pairs(MetroLocations) do
		makeBlip({
			coords = coord,
			sprite = 783,
			col = 1,
			scale = 0.5,
			disp = 6,
			category = nil,
			name = Loc[Config.Lan].lsmetro
		})
		Wait(100)
	end
end

CreateThread(function()
	while Config.General.ShowTrainBlips do
		for _, v in pairs(GetGamePool('CVehicle')) do
			for _, model in pairs({`freight`, `freight2`, `metrotrain`}) do
				if GetEntityModel(v) == model then
					if not DoesBlipExist(GetBlipFromEntity(v)) then
						if GetTrainCarriage(v, 1) ~= 0 then
							entPool[GetTrainCarriage(v, 1)] = true
						end
						if not entPool[v] then
							makeEntityBlip({
								entity = v,
								sprite = (model == `metrotrain` and 795 or 528),
								col = (model == `metrotrain` and 3 or 5),
								name = (model == `metrotrain` and Loc[Config.Lan].metrain or Loc[Config.Lan].freight),
								preview = (model == `metrotrain` and "https://i.imgur.com/12nQ7GN.png" or "https://i.imgur.com/eQIXb7S.png")
							})
							trainTable[#trainTable+1] = v
							CreateThread(function()
								while DoesBlipExist(GetBlipFromEntity(v)) do
									if GetEntitySpeed(v) <= 0.1 then
										SetBlipColour(GetBlipFromEntity(v), 1) -- turn
									else
										SetBlipSprite(GetBlipFromEntity(v), (model == `metrotrain` and 795 or 528))
										SetBlipRotation(GetBlipFromEntity(v), math.ceil(GetEntityHeading(v) -180))
									end
									Wait(1000)
									if entPool[v] then RemoveBlip(GetBlipFromEntity(v)) end
								end
							end)
						end
					end
				end
			end
		end
		Wait(5000)
	end
end)

CreateThread(function()
	while true do
		for _, train in pairs(trainTable) do
			local trainModel = GetEntityModel(train)
			if trainModel == `freight` or trainModel == `freight2` then
				local closestStation = getClosestCoord(GetEntityCoords(train), freightStops)
				local dist = #(GetEntityCoords(train) - closestStation)
				-- if the train is near a station and not stopped already, stop it
				if dist <= 15 and not freightStop[train] then
					stopTrain(train)
				end
			end
			if DoesEntityExist(train) then
				local driver = GetPedInVehicleSeat(train, -1)
				if not IsPedAPlayer(driver) then -- make driver invincible
					SetBlockingOfNonTemporaryEvents(driver, true)
					SetPedFleeAttributes(driver, true)
					SetEntityInvincible(driver, true)
				end
				SetTrainsForceDoorsOpen(true)
				SetEntityInvincible(train, true) -- set train invincible
				SetVehicleDoorsLocked(train, 10)
			end
		end
		Wait(1000)
	end
end)

function stopTrain(train) -- stop train, set timer, start train again
	if freightStop[train] then return end
	debugPrint("^5Debug^7: ^2Stopping Train ^7'^6"..train.."^7'")
	freightStop[train] = true
	local speed = GetEntitySpeed(train)
	while speed > 0.0 do speed -= 0.05 SetTrainCruiseSpeed(train, speed) Wait(0) end
	SetTrainsForceDoorsOpen(false)
	debugPrint("^5Debug^7: ^2Train fully stopped ^7'^6"..train.."^7'")
	local stoppedTimer = GetGameTimer()
	debugPrint("^5Debug^7: ^2Starting Train Stop timeout ^7'^6"..train.."^7'")
	while true do
		SetTrainCruiseSpeed(train, -0.01)
		if (GetGameTimer() - stoppedTimer < (40 * 1000)) then -- 40 second timer
		else break end
		Wait(0)
	end
	debugPrint("^5Debug^7: ^2Starting Train ^7'^6"..train.."^7'")
	while speed < 15 do speed += 0.01 SetTrainCruiseSpeed(train, speed) Wait(0) end
	local timer = GetGameTimer()
	while (GetGameTimer() - timer < 5000) do Wait(0) end -- extra timer to let train leave station before allowing it to stop again
	debugPrint("^5Debug^7: ^2Revmoing stopped train from pool ^7'^6"..train.."^7'")
	freightStop[train] = nil
end

if Config.General.requireMetroTicket then
	CreateThread(function()
		for k, v in pairs(TicketPurchase) do
			local name = getScript()..":TicketPurchase:"..k
			createBoxTarget({name,
				vec3(v.coords.x, v.coords.y, v.coords.z-1), v.w or 1.0, v.d or 0.8,
				{ name = name,
				heading = v.coords.w, debugPoly = debugMode, minZ = v.coords.z-1.0, maxZ = v.coords.z+1.5 }, }, {
				{
					label = Loc[Config.Lan].buy,
					icon = "fas fa-ticket",
					action = function()
						buyTicket()
					end,
				}
			}, 2.0)
		end
	end)

	CreateThread(function()
		local ridingInTrain = false
		while true do
			local Ped = PlayerPedId()
			local pedCoords = GetEntityCoords(Ped)
			local isPedIn, Train = isPedInTrain(Ped)
			if hasTicket and isPedIn and not ridingInTrain then
				if Config.General.seatPlayer then
					if GetVehiclePedIsIn(Ped) ~= Train then
						triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].seating, "success")
						putPlayerInSeat(Train)
					end
				else
					triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].welcome, "success")
				end
				ridingInTrain = true
			end
			if not hasTicket and isPedIn then
				triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].noticket, "error")
				removePlayerFromTrain(Ped, pedCoords)
				hideText()
			end
			if hasTicket and ridingInTrain then
				drawText(nil, {
					(getOffNextStop and Loc[Config.Lan].gettingoff) or
					((Config.System.drawText == "gta" and "~INPUT_VEH_FLY_UNDERCARRIAGE~ " or "[G] - ")..
					Loc[Config.Lan].getoff)},
					"g")
				if Config.General.seatPlayer then
					if getOffNextStop and GetEntitySpeed(Train) <= 0.1 then
						triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].arrived, "success")
						hasTicket = false
						removePlayerFromTrain(Ped, pedCoords)
						getOffNextStop = false
						hideText()
						ridingInTrain = false
					end
				else
					if hasTicket and not isPedIn then
						ridingInTrain = false
						triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].arrived, "success")
						hasTicket = false
					end
				end
			end
			Wait(1000)
		end
	end)
end

RegisterKeyMapping('getoffnext', 'Get Off Next Stop', 'keyboard', 'G')
RegisterCommand('getoffnext', function() getOffNextStop = not getOffNextStop end)

function buyTicket()
	if hasTicket then
		triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].already, "success")
		return
	end
	local Player = getPlayer()
	local hasCash = (Config.General.chargeBank and Player.bank >= Config.General.chargeAmount) or (not Config.General.chargeBank and Player.cash >= Config.General.chargeAmount)
	if hasCash then
		hasTicket = true
		TriggerServerEvent(getScript()..":server:buyTicket", Config.General.chargeAmount, Config.General.chargeBank and "bank" or "cash")
		triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].purchased, "success")
	else
		triggerNotify(Loc[Config.Lan].lsmetro, Loc[Config.Lan].nocash, "error")
	end
end