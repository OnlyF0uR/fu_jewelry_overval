local rob = false
local robbers = {}
PlayersCrafting    = {}
local CopsConnected  = 0
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

function CountCops()
	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(120 * 1000, CountCops)
end

CountCops()

RegisterServerEvent('fu_jewelry_overval:toofar')
AddEventHandler('fu_jewelry_overval:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	if(robbers[source])then
		TriggerClientEvent('fu_jewelry_overval:toofarlocal', source)
		robbers[source] = nil
	end
end)

RegisterServerEvent('fu_jewelry_overval:endrob')
AddEventHandler('fu_jewelry_overval:endrob', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	if(robbers[source])then
		TriggerClientEvent('fu_jewelry_overval:robberycomplete', source)
		robbers[source] = nil
	end
end)

ESX.RegisterServerCallback('fu_jewelry_overval:hasCooldown', function(source, cb)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

    if (os.time() - JewelryStore.LastRobbed) < Config.SecBetwNextRob and JewelryStore.LastRobbed ~= 0 then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('fu_jewelry_overval:getCooldown', function(source, cb)
	cb(Config.SecBetwNextRob - (os.time() - JewelryStore.LastRobbed))
end)

RegisterServerEvent('fu_jewelry_overval:rob')
AddEventHandler('fu_jewelry_overval:rob', function(robb)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

    if rob == false then
        rob = true
        TriggerClientEvent('fu_jewelry_overval:currentlyrobbing', source, robb)
        CancelEvent()
        JewelryStore.LastRobbed = os.time()
    end

end)

RegisterServerEvent('fu_jewelry_overval:giveItem')
AddEventHandler('fu_jewelry_overval:giveItem', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem('juwelen', math.random(Config.MinJewels, Config.MaxJewels))
end)

ESX.RegisterServerCallback('fu_jewelry_overval:getCopAmount', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(CopsConnected)
end)

