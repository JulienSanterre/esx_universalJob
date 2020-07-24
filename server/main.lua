ESX                    = nil
PlayersHarvesting      = {}
PlayersCrafting        = {}
PlayersCrafting2       = {}
local PlayersSelling   = {}
local CreatedInstances = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)
	
	local _source = source
	
	TriggerClientEvent('esx_'..Config.JobName..':setTimeDiff', _source, os.time())
	TriggerClientEvent('esx_'..Config.JobName..':onCreatedInstanceData', _source, CreatedInstances)

end)

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', Config.JobName, Config.MaxInService)
end

TriggerEvent('esx_society:registerSociety', Config.JobName, Config.JobName, 'society_'..Config.JobName, 'society_'..Config.JobName, 'society_'..Config.JobName, {type = 'private'})

local function debug(information, fxname, name)
	if Config.DEBUG then
		print(fxname .. " -> " .. name)
		print(tostring(json.encode(information)))
	end
end

------------ COLLECTE --------------
local function callFarm(source)
local _source = source
local xPlayer  = ESX.GetPlayerFromId(source)
local value = 0
local targetItem = {}
local playerWeight = 0
local maxitemcollect = Config.maxitemcollect
local UserDbInventoryLimit = Config.InventoryLimit
debug(UserDbInventoryLimit, "Fx : callFarm","UserDbInventoryLimit")

  SetTimeout(Config.timeTocollect, function()
	
	if UserDbInventoryLimit ~= 0 then
		if Config.UserDbInventoryLimit then
			data = MySQL.Sync.fetchAll('SELECT `maxweight` FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier})
			UserDbInventoryLimit = data[1].maxweight
			debug(UserDbInventoryLimit, "Fx : callFarm", "UserDbInventoryLimitDb")
		end
		playerInventoryCheck = MySQL.Sync.fetchAll('SELECT `name`, `limit`, `weight`, `price`, `can_remove`, `count` FROM user_inventory INNER JOIN items ON user_inventory.item = items.name AND user_inventory.identifier = @identifier ', { ['@identifier'] = xPlayer.identifier })	
		for i = 1, #playerInventoryCheck, 1 do
			playerWeight = playerWeight + playerInventoryCheck[i].weight * playerInventoryCheck[i].count
			if playerInventoryCheck[i].name == Config.itemcollect.name then
				targetItem = playerInventoryCheck[i]
			end
		end
		debug(playerWeight, "Fx : callFarm", "playerWeight")
		debug(targetItem, "Fx : callFarm", "targetItem")
		if Config.ItemDbCount then
			maxitemcollect = targetItem.limit
		end
		debug(maxitemcollect, "Fx : callFarm", "maxitemcollect")
	end
	
    if PlayersHarvesting[source] == true then
      
		if UserDbInventoryLimit ~= 0 or UserDbInventoryLimit ~= nil then
			if (playerWeight + (targetItem.weight * Config.itemcollect.give)) < UserDbInventoryLimit then
				if xPlayer.getInventoryItem(Config.itemcollect.name).count >= maxitemcollect then
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('you_do_not_room'))
				else
					value = targetItem.count + Config.itemcollect.give
					MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
					xPlayer.addInventoryItem(Config.itemcollect.name, Config.itemcollect.give)
					callFarm(_source)
				end
			else
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('weight_over'))
			end
		else
			if xPlayer.getInventoryItem(Config.itemcollect.name).count >= maxitemcollect then
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('you_do_not_room'))
			else
				xPlayer.addInventoryItem(Config.itemcollect.name, Config.itemcollect.give)
				callFarm(_source)
			end
		end
    end
  end)
end

RegisterServerEvent('esx_'.. Config.JobName ..':startHarvest')
AddEventHandler('esx_'.. Config.JobName ..':startHarvest', function()
  local _source = source
  PlayersHarvesting[_source] = true
  TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('recovery_tabacblond'))
  callFarm(_source)
end)

RegisterServerEvent('esx_'.. Config.JobName ..':stopHarvest')
AddEventHandler('esx_'.. Config.JobName ..':stopHarvest', function()
  local _source = source
  PlayersHarvesting[_source] = false
end)


------------ Fabrication RAFINAGE --------------
local function callCraft(source)
local _source = source
local value = 0
local value2 = 0
local targetItem = {}
local targetItem2 = {}
local playerWeight = 0
local xPlayer  = ESX.GetPlayerFromId(source)
local maxitemrefined = Config.maxitemrefined
local UserDbInventoryLimit = Config.InventoryLimit
debug(UserDbInventoryLimit, "Fx : callCraft", "UserDbInventoryLimit")
	
	SetTimeout(Config.timeToRefined, function()
		if Config.InventoryLimit ~= 0 then	
			if Config.UserDbInventoryLimit then
				data = MySQL.Sync.fetchAll('SELECT `maxweight` FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier})
				UserDbInventoryLimit = data[1].maxweight
				debug(UserDbInventoryLimit, "Fx : callCraft", "UserDbInventoryLimit")
			end
			playerInventoryCheck = MySQL.Sync.fetchAll('SELECT `name`, `limit`, `weight`, `price`, `can_remove`, `count` FROM user_inventory INNER JOIN items ON user_inventory.item = items.name AND user_inventory.identifier = @identifier ', { ['@identifier'] = xPlayer.identifier })		
			for i = 1, #playerInventoryCheck, 1 do
				playerWeight = playerWeight + playerInventoryCheck[i].weight * playerInventoryCheck[i].count
				if playerInventoryCheck[i].name == Config.itemrefined.name then
					targetItem = playerInventoryCheck[i]
					debug(targetItem, "Fx : callCraft", "targetItem")
				end
				if playerInventoryCheck[i].name == Config.itemcollect.name then

					targetItem2 = playerInventoryCheck[i]
					debug(targetItem2, "Fx : callCraft", "targetItem2")
				end
			end
			if Config.ItemDbCount then
				maxitemrefined = targetItem2.limit
				debug(maxitemrefined, "Fx : callCraft", "maxitemrefined")
			end
		end
		
		if PlayersCrafting[source] == true then
			if UserDbInventoryLimit ~= 0 or UserDbInventoryLimit ~= nil then
				if (playerWeight + (targetItem.weight * Config.itemrefined.give - targetItem2.weight * Config.itemcollect.get)) < UserDbInventoryLimit then
					if xPlayer.getInventoryItem(targetItem2.name).count >= Config.itemcollect.get then
						if xPlayer.getInventoryItem(targetItem.name).count < maxitemrefined then
							xPlayer.removeInventoryItem(targetItem2.name, Config.itemcollect.get)
							xPlayer.addInventoryItem(targetItem.name, Config.itemrefined.give)
							value2 = targetItem2.count - Config.itemcollect.get
							debug(value2, "Fx : callCraft", "value2")
							value = targetItem.count + Config.itemrefined.give
							debug(value, "Fx : callCraft", "value")
							MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem2.name, ['@count'] = value2})
							MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
							callCraft(_source)
						else
							TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,_U('max_item_refined'))
						end
					else
						TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,_U('not_enough_tabacblond'))
					end
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('weight_over'))
				end
			else
				if xPlayer.getInventoryItem(targetItem2.name).count >= Config.itemcollect.get then
					if xPlayer.getInventoryItem(targetItem.name).count < maxitemrefined then
						xPlayer.removeInventoryItem(targetItem2.name, Config.itemcollect.get)
						xPlayer.addInventoryItem(targetItem.name, Config.itemrefined.give)
						callCraft(_source)
					else
						TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,_U('max_item_refined'))
					end
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,_U('not_enough_tabacblond'))
				end
			end
		end
	end)
end

RegisterServerEvent('esx_'.. Config.JobName ..':startCraft')
AddEventHandler('esx_'.. Config.JobName ..':startCraft', function()
  local _source = source
  PlayersCrafting[_source] = true
  TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,_U('sechage_tabacblond'))
  callCraft(_source)
end)

RegisterServerEvent('esx_'.. Config.JobName ..':stopCraft')
AddEventHandler('esx_'.. Config.JobName ..':stopCraft', function()
  local _source = source
  PlayersCrafting[_source] = false
end)


------------ Fabrication ITEM de vente --------------
local function callCraft2(source)
local _source = source
local xPlayer  = ESX.GetPlayerFromId(source)
local value = 0
local value2 = 0
local targetItem = {}
local targetItem2 = {}
local playerWeight = 0
local maxitemsell = Config.maxitemsell
local UserDbInventoryLimit = Config.InventoryLimit
debug(UserDbInventoryLimit, "Fx : callCraft2", "UserDbInventoryLimit")

  SetTimeout(Config.timeToRefined, function()
	if Config.InventoryLimit ~= 0 then
		if Config.UserDbInventoryLimit then
			data = MySQL.Sync.fetchAll('SELECT `maxweight` FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier})
			UserDbInventoryLimit = data[1].maxweight
			debug(UserDbInventoryLimit, "Fx : callCraft2", "UserDbInventoryLimit")
		end	
		playerInventoryCheck = MySQL.Sync.fetchAll('SELECT `name`, `limit`, `weight`, `price`, `can_remove`, `count` FROM user_inventory INNER JOIN items ON user_inventory.item = items.name AND user_inventory.identifier = @identifier ', { ['@identifier'] = xPlayer.identifier })		
		for i = 1, #playerInventoryCheck, 1 do
			playerWeight = playerWeight + playerInventoryCheck[i].weight * playerInventoryCheck[i].count
			if playerInventoryCheck[i].name == Config.itemsell.name then
				targetItem = playerInventoryCheck[i]
				debug(targetItem, "Fx : callCraft2", "targetItem")
			end
			if playerInventoryCheck[i].name == Config.itemrefined.name then
				targetItem2 = playerInventoryCheck[i]
				debug(targetItem, "Fx : callCraft2", "targetItem")
			end
		end
		if Config.ItemDbCount then
			maxitemsell = targetItem.limit
			debug(maxitemsell, "Fx : callCraft2", "maxitemsell")
		end
	end
	
    if PlayersCrafting2[source] == true then
		if UserDbInventoryLimit ~= 0 or UserDbInventoryLimit ~= nil then
			if (playerWeight + (targetItem.weight * Config.itemsell.give - targetItem2.weight * Config.itemrefined.get)) < UserDbInventoryLimit then	  
				if xPlayer.getInventoryItem(targetItem2.name).count >= Config.itemrefined.get then
					if xPlayer.getInventoryItem(targetItem.name).count < maxitemsell then
						xPlayer.removeInventoryItem(targetItem2.name, Config.itemrefined.get)
						xPlayer.addInventoryItem(targetItem.name , Config.itemsell.give)
						value = targetItem.count + Config.itemsell.give
						debug(value, "Fx : callCraft2", "value")
						value2 = targetItem2.count - Config.itemrefined.get
						debug(value2, "Fx : callCraft2", "value2")
						MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
						MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem2.name, ['@count'] = value2})
						callCraft2(_source)
					else
						TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('max_item_sell'))
					end
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('not_enough_tabacblond_sec'))
				end
			else
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('weight_over'))
			end
		else
			if xPlayer.getInventoryItem(targetItem2.name).count >= Config.itemrefined.get then
				if xPlayer.getInventoryItem(targetItem.name).count < maxitemsell then
					xPlayer.removeInventoryItem(targetItem2.name, Config.itemrefined.get)
					xPlayer.addInventoryItem(targetItem.name , Config.itemsell.give)
					callCraft2(_source)
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('max_item_sell'))
				end
			else
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('not_enough_tabacblond_sec'))
			end
		end
	end
  end)
end

RegisterServerEvent('esx_'.. Config.JobName ..':startCraft2')
AddEventHandler('esx_'.. Config.JobName ..':startCraft2', function()
  local _source = source
  PlayersCrafting2[_source] = true
  TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('assemblage_malbora'))
  callCraft2(_source)
end)

RegisterServerEvent('esx_'.. Config.JobName ..':stopCraft2')
AddEventHandler('esx_'.. Config.JobName ..':stopCraft2', function()
  local _source = source
  PlayersCrafting2[_source] = false
end)

----------------ACHAT PNJ---------------
RegisterServerEvent('esx_'.. Config.JobName ..':pedBuyCig')
AddEventHandler('esx_'.. Config.JobName ..':pedBuyCig', function(int)
  
  local _source       = source
  local xPlayer       = ESX.GetPlayerFromId(_source)
  local maxPercent    = Config.maxPercentBonusSellPed  / int
  local maxPrice 	  = math.floor(math.abs(Config.CraftJobprice * maxPercent / 100 + Config.CraftJobprice))
  local pricePerUnit  = math.random(Config.CraftJobprice, maxPrice)
  local quantity      = math.random(1, 5)
  local item          = xPlayer.getInventoryItem(Config.itemsell.name)
  local societyAccount  = nil

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'.. Config.JobName, function(account)
    societyAccount = account
  end)

  if item.count > 0 then

    if item.count < quantity then

      local price = math.floor(item.count * pricePerUnit)

      xPlayer.removeInventoryItem(Config.itemsell.name, item.count)
      societyAccount.addMoney(price/2)
      xPlayer.addMoney(price/4)

	  TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('is_dangerous') )
    else
	  TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('not_inof'))
    end
  else
	TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('end_stock'))
  end

end)

RegisterServerEvent('esx_'.. Config.JobName ..':pedCallPolice')
AddEventHandler('esx_'.. Config.JobName ..':pedCallPolice', function()
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do

		local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
			
		if xPlayer2.job.name == 'crypted' then
			 TriggerClientEvent('esx_cryptedphone:onMessage', xPlayer2.source, '', 'Une personne a essayé de me vendre des cigarettes', xPlayer.get('coords'), true, 'Alerte Moldu', false)
		end
	end
end)

----------------------------------
---- Ajout Gestion Stock Boss ----
----------------------------------

RegisterServerEvent('esx_'.. Config.JobName ..':getStockItem')
AddEventHandler('esx_'.. Config.JobName ..':getStockItem', function(itemName, count)
	
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local canPut = 0	
	local value = 0
	local targetItem = xPlayer.getInventoryItem(itemName)
	local invPos = 0
	local playerWeight = 0
	local UserDbInventoryLimit = Config.InventoryLimit
	
	if Config.InventoryLimit ~= 0 then	
		if Config.UserDbInventoryLimit then
			data = MySQL.Sync.fetchAll('SELECT `maxweight` FROM users WHERE identifier = @identifier', { ['@identifier'] = xPlayer.identifier})
			UserDbInventoryLimit = data[1].maxweight
		end	
		playerInventoryCheck = MySQL.Sync.fetchAll('SELECT `name`, `limit`, `weight`, `price`, `can_remove`, `count` FROM user_inventory INNER JOIN items ON user_inventory.item = items.name AND user_inventory.identifier = @identifier ', { ['@identifier'] = xPlayer.identifier })

		for i = 1, #playerInventoryCheck, 1 do
			playerWeight = playerWeight + playerInventoryCheck[i].weight * playerInventoryCheck[i].count
			if playerInventoryCheck[i].name == targetItem.name then
				invPos = i
			end
		end
	end
	
	for j = 1, #Config.cantPutThis, 1 do
		if Config.cantPutThis[j] == itemName then
			canPut = 1
		end
	end
	
	if UserDbInventoryLimit ~= 0 or UserDbInventoryLimit ~= nil then
		if canPut == 0 then
			if ( playerWeight + (playerInventoryCheck[invPos].weight * count)) < UserDbInventoryLimit then 
				if targetItem.count + count <= targetItem.limit then
					
					TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'.. Config.JobName, function(inventory)
						if (inventory.getItem(itemName).count >= count and count > 0) then
							
							inventory.removeItem(itemName, count)
							xPlayer.addInventoryItem(itemName, count)
							value = count + targetItem.count
							
							MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
							TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,'Vous avez pris ~g~'.. count .. "~w~ x ~g~" .. targetItem.label .. "~w~ du coffre")
						else
							TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('invalid_qte'))
						end
					
					end)
					
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('max_inventory'))
				end
			
			else
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('not_inof'))
			end
		else
			TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('store_vip'))
		end
	else
		if canPut == 0 then				
			TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'.. Config.JobName, function(inventory)
				if (inventory.getItem(itemName).count >= count and count > 0) then
					
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					value = count + targetItem.count
					
					MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle,'Vous avez pris ~g~'.. count .. "~w~ x ~g~" .. targetItem.label .. "~w~ du coffre")
				else
					TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('invalid_qte'))
				end
			
			end)
		else
			TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('store_vip'))
		end
	end
end)

ESX.RegisterServerCallback('esx_'.. Config.JobName ..':getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'.. Config.JobName, function(inventory)
    cb(inventory.items)
  end)

end)

----------------------------------
---- Ajout Gestion GET Boss ----
----------------------------------

RegisterServerEvent('esx_'.. Config.JobName ..':putStockItems')
AddEventHandler('esx_'.. Config.JobName ..':putStockItems', function(itemName, count)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local playerItemCount = xPlayer.getInventoryItem(itemName).count
  local targetItem = xPlayer.getInventoryItem(itemName)
  local canGet = 0
  
  for i = 1, #Config.cantPutThis, 1 do
	if Config.cantPutThis[i] == itemName then
		canGet = 1
	end
  end

	if canGet == 0 then
		if (playerItemCount >= count and count > 0) then
			TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'.. Config.JobName, function(inventory)

				inventory.addItem(itemName, count)
				xPlayer.removeInventoryItem(itemName, count)
				value = targetItem.count - count
				
				MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
				TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,'Vous avez déposé ~g~'.. count .. "~w~ x ~g~" .. targetItem.label .. "~w~ dans l'inventaire")
			end)
		else
			TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('not_inof'))
		end
	else
		TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('store_vip'))
	end
end)

ESX.RegisterServerCallback('esx_'.. Config.JobName ..':putStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'.. Config.JobName, function(inventory)
    cb(inventory.items)
  end)

end)

ESX.RegisterServerCallback('esx_'.. Config.JobName ..':getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)

ESX.RegisterServerCallback('esx_'.. Config.JobName ..':tryRemoveInventoryItem', function(source, cb, itemName, itemCount)

  local xPlayer = ESX.GetPlayerFromId(source)
  local item    = xPlayer.getInventoryItem(itemName)

  if item.count >= itemCount then
    xPlayer.removeInventoryItem(itemName, itemCount)
    cb(true)
  else
    cb(false)
  end
end)

RegisterServerEvent('esx_'.. Config.JobName ..':annonce')
AddEventHandler('esx_'.. Config.JobName ..':annonce', function(result)
  local _source  = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
  local xPlayers = ESX.GetPlayers()
  local text     = result

  for i=1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    TriggerClientEvent('esx_'.. Config.JobName ..':annonce', xPlayers[i],text)
  end

  Wait(8000)

  local xPlayers = ESX.GetPlayers()
  for i=1, #xPlayers, 1 do
    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
    TriggerClientEvent('esx_'.. Config.JobName ..':annoncestop', xPlayers[i])
  end

end)

----------------------------
----    USABLE ITEM     ----
----------------------------
ESX.RegisterUsableItem(Config.canUseSellItem , function(source)
	if Config.canUseSellItem then
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		debug(Config.canUseSellItem, "Fx : RegisterUsableItem", "Config.canUseSellItem")
		xPlayer.removeInventoryItem(Config.itemsell.name , 1)

		TriggerClientEvent('esx_'.. Config.JobName ..':onSmokeCig', source)
		TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('smoke_marlboro'))
	end
end)


----------------------------
---- 	SELL CRAFT 1    ----
----------------------------
local function callSell(source, zone)
  local _source = source
  local sellItem = 0
  local value = 0
  local targetItem = {}
  local playerWeight = 0
  print("SELLZONE")
  if PlayersSelling[source] == true then
	local xPlayer  = ESX.GetPlayerFromId(source)
	if Config.InventoryLimit ~= 0 then	
		playerInventoryCheck = MySQL.Sync.fetchAll('SELECT `name`, `limit`, `weight`, `price`, `can_remove`, `count` FROM user_inventory INNER JOIN items ON user_inventory.item = items.name AND user_inventory.identifier = @identifier ', { ['@identifier'] = xPlayer.identifier })		
		for i = 1, #playerInventoryCheck, 1 do
			playerWeight = playerWeight + playerInventoryCheck[i].weight * playerInventoryCheck[i].count
			if playerInventoryCheck[i].name == Config.itemsell.name then
				targetItem = playerInventoryCheck[i]
				debug(targetItem, "Fx : callSell", "targetItem")
			end
		end
	end
	if zone == 'SellFarm' then
	  if xPlayer.getInventoryItem(Config.itemsell.name ).count < Config.itemsell.give then
		sellItem = 0
	  else
		sellItem = 1
	  end

	  if sellItem == 0 then
		 TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('no_product_sale'))
		return
	  elseif xPlayer.getInventoryItem(Config.itemsell.name ).count < Config.itemsell.give then
		TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('no_malbora_sale'))
		sellItem = 0
		return
	  else
		  SetTimeout(Config.timeToSell, function()
			if Config.ComSealer > Config.CraftJobprice then -- Soon player Config so need to patch glitch way
				Config.ComSealer  = Config.CraftJobprice
				debug(Config.ComSealer, "Fx : callSell", "Config.ComSealer (ComSealer was greater than Crafjobprice")
			end
			local money = Config.CraftJobprice - Config.ComSealer
			value = targetItem.count - Config.itemsell.give
			debug(value, "Fx : callSell", "value")
			MySQL.Sync.execute('UPDATE user_inventory SET count = @count WHERE identifier = @identifier AND item = @item ', { ['@identifier'] = xPlayer.identifier, ['@item'] = targetItem.name, ['@count'] = value})
			xPlayer.removeInventoryItem(Config.itemsell.name , Config.itemsell.give)
			
			local societyAccount = nil

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'.. Config.JobName, function(account)
			  societyAccount = account
			end)
			if societyAccount ~= nil then
			  societyAccount.addMoney(money)
			  debug(money, "Fx : callSell", "money")
			  xPlayer.addMoney(Config.ComSealer)
			  debug(Config.ComSealer, "Fx : callSell", "Config.ComSealer")
			end
			callSell(_source, zone)
		  end)
	  end
	end
  end
end

RegisterServerEvent('esx_'.. Config.JobName ..':startSell')
AddEventHandler('esx_'.. Config.JobName ..':startSell', function(zone)
  local _source = source
  
  if PlayersSelling[_source] == false then
	TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('try_glitch'))
    PlayersSelling[_source]=false
  else
    PlayersSelling[_source]=true
	TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('sale_in_prog'))
    callSell(_source, zone)
  end

end)

RegisterServerEvent('esx_'.. Config.JobName ..':stopSell')
AddEventHandler('esx_'.. Config.JobName ..':stopSell', function()
  local _source = source
  
  if PlayersSelling[_source] == true then
    PlayersSelling[_source]=false
	TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('out_zone'))
    
  else
	TriggerClientEvent('esx_'.. Config.JobName ..':RageMsg',_source,Config.NotifTitle, _U('sell_zone'))
    PlayersSelling[_source]=true
  end

end)
