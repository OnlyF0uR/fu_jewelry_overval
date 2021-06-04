local holdingup = false
local store = ""
local blipRobbery = nil
local vetrineRotte = 0 

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(15)
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

RegisterNetEvent('fu_jewelry_overval:currentlyrobbing')
AddEventHandler('fu_jewelry_overval:currentlyrobbing', function(robb)
	holdingup = true
	store = robb
end)

RegisterNetEvent('fu_jewelry_overval:toofarlocal')
AddEventHandler('fu_jewelry_overval:toofarlocal', function(robb)
	holdingup = false
    Notify('De overval is geannuleerd')
	robbingName = ""
	incircle = false
end)


RegisterNetEvent('fu_jewelry_overval:robberycomplete')
AddEventHandler('fu_jewelry_overval:robberycomplete', function(robb)
	holdingup = false
    Notify('De overval is geslaagd!')
	store = ""
	incircle = false
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(JewelryStore.Coords.x, JewelryStore.Coords.y, JewelryStore.Coords.z)

    SetBlipSprite(blip, 439)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Jewelier Overval")
    EndTextCommandSetBlipName(blip)
end)

animazione = false
incircle = false

local borsa = nil
 
Citizen.CreateThread(function()
	while true do
	  Citizen.Wait(1000)
	  TriggerEvent('skinchanger:getSkin', function(skin)
		borsa = skin['bags_1']
	  end)
	  Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		local pos = GetEntityCoords(GetPlayerPed(-1), true)

        if(Vdist(pos.x, pos.y, pos.z, JewelryStore.Coords.x, JewelryStore.Coords.y, JewelryStore.Coords.z) < 15.0)then
            if not holdingup then
                DrawMarker(27, JewelryStore.Coords.x, JewelryStore.Coords.y, JewelryStore.Coords.z -0.9, 0, 0, 0, 0, 0, 0, 2.001, 2.0001, 0.5001, 255, 0, 0, 200, 0, 0, 0, 0)

                if(Vdist(pos.x, pos.y, pos.z, JewelryStore.Coords.x, JewelryStore.Coords.y, JewelryStore.Coords.z) < 1.0)then
                    if (incircle == false) then
                        DisplayHelpText('Schiet om te starten!')
                    end
                    incircle = true
                    if IsPedShooting(GetPlayerPed(-1)) then
                        if Config.NeedBag then
                            if borsa == 40 or borsa == 41 or borsa == 44 or borsa == 45 then
                                ESX.TriggerServerCallback('fu_jewelry_overval:getCopAmount', function(CopsConnected)
                                    if CopsConnected >= Config.RequiredCopsRob then
                                        ESX.TriggerServerCallback('fu_jewelry_overval:hasCooldown', function(Cooldown)
                                            if Cooldown then
                                                ESX.TriggerServerCallback('fu_jewelry_overval:hasCooldown', function(Time)
                                                    Notify('De juwelier is al overvallen. Wacht: ' .. Time .. ' seconden.')
                                                end)
                                            else                                                
                                                TriggerServerEvent('fu_jewelry_overval:rob', k)

                                                Citizen.Wait(2500)
                                                local playerCoords = GetEntityCoords(PlayerPedId())
                                                streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                                streetName = GetStreetNameFromHashKey(streetName)
                                                TriggerServerEvent("fu_alerts:jewelryRobbery", playerCoords, streetName)
                                            end
                                        end)
                                    else
                                        Notify('Er moeten minimaal ' .. Config.RequiredCopsRob .. ' in de stad zijn.')
                                    end
                                end)		
                            else
                                Notify('Je hebt een tas nodig!')
                            end
                        else
                            ESX.TriggerServerCallback('fu_jewelry_overval:getCopAmount', function(CopsConnected)
                                if CopsConnected >= Config.RequiredCopsRob then
                                    TriggerServerEvent('fu_jewelry_overval:rob', k)
                                    
                                    -- Notify Cops
                                    local playerCoords = GetEntityCoords(PlayerPedId())
                                    streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                    streetName = GetStreetNameFromHashKey(streetName)
                                    TriggerServerEvent("fu_alerts:jewelryRobbery", playerCoords, streetName)
                                else
                                    Notify('Er moeten minimaal ' .. Config.RequiredCopsRob .. ' in de stad zijn.')
                                end
                            end)	
                        end	
                    end
                elseif(Vdist(pos.x, pos.y, pos.z, JewelryStore.Coords.x, JewelryStore.Coords.y, JewelryStore.Coords.z) > 1.0) then
                    incircle = false
                end		
            end
        end

		if holdingup then
			for i,v in pairs(JewelryVetrine) do 
				if(GetDistanceBetweenCoords(pos, v.x, v.y, v.z, true) < 10.0) and not v.isOpen and Config.EnableMarker then 
					DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 0, 255, 0, 200, 1, 1, 0, 0)
				end
				if(GetDistanceBetweenCoords(pos, v.x, v.y, v.z, true) < 0.75) and not v.isOpen then
                    exports.fu_text:drawHologram(v.x, v.y, v.z, '[~g~E~w~] Looten')
					if IsControlJustPressed(0, 38) then
						animazione = true
					    SetEntityCoords(GetPlayerPed(-1), v.x, v.y, v.z-0.95)
					    SetEntityHeading(GetPlayerPed(-1), v.heading)
						v.isOpen = true 
						PlaySoundFromCoord(-1, "Glass_Smash", v.x, v.y, v.z, "", 0, 0, 0)
					    if not HasNamedPtfxAssetLoaded("scr_jewelheist") then
					        RequestNamedPtfxAsset("scr_jewelheist")
					    end
					    while not HasNamedPtfxAssetLoaded("scr_jewelheist") do
					        Citizen.Wait(5)
					    end
					    SetPtfxAssetNextCall("scr_jewelheist")
					    StartParticleFxLoopedAtCoord("scr_jewel_cab_smash", v.x, v.y, v.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
					    loadAnimDict( "missheist_jewel" ) 
						TaskPlayAnim(GetPlayerPed(-1), "missheist_jewel", "smash_case", 8.0, 1.0, -1, 2, 0, 0, 0, 0 ) 
					    DrawSubtitleTimed(5000, 1)

                        TriggerEvent("mythic_progbar:client:progress", {
                            name = "juwelry_overval",
                            duration = 5000,
                            label = "Juwelen looten",
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "mini@repair",
                                anim = "fixing_a_ped",
                            },
                        }, function(status)
                            if not status then
                                ClearPedTasksImmediately(GetPlayerPed(-1))
                                TriggerServerEvent('fu_jewelry_overval:giveItem')
                                PlaySound(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                vetrineRotte = vetrineRotte+1
                                animazione = false
        
                                if vetrineRotte == Config.MaxWindows then 
                                    for i,v in pairs(JewelryVetrine) do 
                                        v.isOpen = false
                                        vetrineRotte = 0
                                    end
                                    TriggerServerEvent('fu_jewelry_overval:endrob', store)
                                    Notify('Overval afgerond!')
                                    holdingup = false
                                end
                            end
                        end)

					end
				end	
			end

			if (GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), -622.566, -230.183, 38.057, true) > 11.5 ) then
				TriggerServerEvent('fu_jewelry_overval:toofar', store)
				holdingup = false
				for i,v in pairs(JewelryVetrine) do 
					v.isOpen = false
					vetrineRotte = 0
				end
			end

		end
		Citizen.Wait(5)
	end
end)

Citizen.CreateThread(function()
	while true do
		if animazione == true then
			if not IsEntityPlayingAnim(PlayerPedId(), 'missheist_jewel', 'smash_case', 3) then
				TaskPlayAnim(PlayerPedId(), 'missheist_jewel', 'smash_case', 8.0, 8.0, -1, 17, 1, false, false, false)
			end
		end
		Wait(5)
	end
end)

function Notify(msg)
	TriggerEvent("pNotify:SendNotification", {
		text = msg,
		type = 'success',
		queue = "juwelry_overval",
		timeout = 2500,
		layout = "bottomCenter"
	})
end