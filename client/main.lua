local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


ESX                           = nil
TimeDiff                      = 0
CurrentCig                    = nil
SpawnedObjects                = {}
SpawnedPeds                   = {}
local PlayerData              = {}
local GUI                     = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local LastPart                = nil
local LastData                = {}
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local OnJob                   = false
local TargetCoords            = nil
local CurrentlyTowedVehicle   = nil
local PedBlacklist            = {}
local PedAttacking            = nil
local Blips                   = {}
local JobBlips                = {}
GUI.Time                      = 0
local asCar = false


Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(1)
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
  CreateJobBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
  DeleteJobBlips()
  CreateJobBlips()
end)

if Config.EnablePlayerManagement then
  RegisterNetEvent('esx_phone:loaded')
  AddEventHandler('esx_phone:loaded', function (phoneNumber, contacts)
    local specialContact = {
      name       = _U(Config.JobName),
      number     = Config.JobName,
      base64Icon = Config.PhoneIcon,
    }

    TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
  end)
end

function IsJobTrue()
  if PlayerData ~= nil then
    local IsJobTrue = false
    if PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
      IsJobTrue = true
    end
    return IsJobTrue
  end
end

function CreateJobBlips()
    if IsJobTrue() then   
	
		if Config.collectPoint then
		  local blip2 = AddBlipForCoord(Config.Blip2.Pos.x, Config.Blip2.Pos.y, Config.Blip2.Pos.z)
		  SetBlipSprite (blip2, Config.Blip2.Sprite)
		  SetBlipDisplay(blip2, Config.Blip2.Display)
		  SetBlipScale  (blip2, Config.Blip2.Scale)
		  SetBlipColour (blip2, Config.Blip2.Colour)
		  SetBlipAsShortRange(blip2, true)
		  BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString(Config.Blip2.Name)
		  EndTextCommandSetBlipName(blip2)
		  table.insert(JobBlips, blip2)
		 end
	  
		if Config.refinedPoint1 then
		  local blip3 = AddBlipForCoord(Config.Blip3.Pos.x, Config.Blip3.Pos.y, Config.Blip3.Pos.z)
		  SetBlipSprite (blip3, Config.Blip3.Sprite)
		  SetBlipDisplay(blip3, Config.Blip3.Display)
		  SetBlipScale  (blip3, Config.Blip3.Scale)
		  SetBlipColour (blip3, Config.Blip3.Colour)
		  SetBlipAsShortRange(blip3, true)
		  BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString(Config.Blip3.Name)
		  EndTextCommandSetBlipName(blip3)
		  table.insert(JobBlips, blip3)
		end
	  
		if Config.refinedPoint2 then
		  local blip4 = AddBlipForCoord(Config.Blip4.Pos.x, Config.Blip4.Pos.y, Config.Blip4.Pos.z)
		  SetBlipSprite (blip4, Config.Blip4.Sprite)
		  SetBlipDisplay(blip4, Config.Blip4.Display)
		  SetBlipScale  (blip4, Config.Blip4.Scale)
		  SetBlipColour (blip4, Config.Blip4.Colour)
		  SetBlipAsShortRange(blip4, true)
		  BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString(Config.Blip4.Name)
		  EndTextCommandSetBlipName(blip4)
		  table.insert(JobBlips, blip4)
		end
	  
		if Config.sellPoint then
		  local blip5 = AddBlipForCoord(Config.Blip5.Pos.x, Config.Blip5.Pos.y, Config.Blip5.Pos.z)
		  SetBlipSprite (blip5, Config.Blip5.Sprite)
		  SetBlipDisplay(blip5, Config.Blip5.Display)
		  SetBlipScale  (blip5, Config.Blip5.Scale)
		  SetBlipColour (blip5, Config.Blip5.Colour)
		  SetBlipAsShortRange(blip5, true)
		  BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString(Config.Blip5.Name)
		  EndTextCommandSetBlipName(blip5)
		  table.insert(JobBlips, blip5)
		end
	  
	  if Config.VehicleBack then
		  local blip6 = AddBlipForCoord(Config.Blip6.Pos.x, Config.Blip6.Pos.y, Config.Blip6.Pos.z)
		  SetBlipSprite (blip6, Config.Blip6.Sprite)
		  SetBlipDisplay(blip6, Config.Blip6.Display)
		  SetBlipScale  (blip6, Config.Blip6.Scale)
		  SetBlipColour (blip6, Config.Blip6.Colour)
		  SetBlipAsShortRange(blip6, true)
		  BeginTextCommandSetBlipName("STRING")
		  AddTextComponentString(Config.Blip6.Name)
		  EndTextCommandSetBlipName(blip6)
		  table.insert(JobBlips, blip6)
	  end
    end 
end

function DeleteJobBlips()
  if JobBlips[1] ~= nil then
    for i=1, #JobBlips, 1 do
      RemoveBlip(JobBlips[i])
      JobBlips[i] = nil
    end
  end
end

function Message()
  Citizen.CreateThread(function()
    while messagenotfinish do
        Citizen.Wait(1)

      DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
           Citizen.Wait(1)
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            messagenotfinish = false
           TriggerServerEvent('esx_'..Config.JobName ..':annonce',result)
           
        end
    end
  end)
  
end

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)

function StartWalking(ped)
  Citizen.CreateThread(function()
    RequestAnimDict('move_m@generic_variations@walk')
    while not HasAnimDictLoaded('move_m@generic_variations@walk') do
      Citizen.Wait(1)
    end
    TaskPlayAnim(ped,  'move_m@generic_variations@walk',  'walk_a',  1.0,  -1.0,  -1,  0,  1,  false,  false,  false)
  end)
end


-- SPECIAL FUCNTION TO TEST  IF PLAYER ALREASY HAVE SOCIETY CAR // Need other scripts to word
RegisterNetEvent('esx_jobs:setsocietystatutcar'..Config.JobName)
AddEventHandler('esx_jobs:setsocietystatutcar'..Config.JobName, function(result)
	local _result = result
	if _result ~= nil then
		asCar = true
	end
end)

function OpenActionsMenu()

  local elements = {
    {label = _U('vehicle_list'), value = 'vehicle_list'},
    {label = _U('work_wear'), value = 'cloakroom'},
    {label = _U('civ_wear'), value = 'cloakroom2'},
    {label = _U('deposit_stock'), value = 'put_stock'}
  }
  if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name ~= 'recrue' then
  	table.insert(elements, {label = _U('withdraw_stock'), value = 'get_stock'})
  end

  if Config.EnablePlayerManagement and PlayerData.job ~= nil and PlayerData.job.grade_name == 'boss' then
    table.insert(elements, {label = _U('boss_actions'), value = 'boss_actions'})
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), Config.JobName ..'_actions',
    {
      title    = 'Menu '..Config.JobName,
      elements = elements,
	  align    = Config.menuAlign,
    },
    function(data, menu)
      if data.current.value == 'vehicle_list' then

        if Config.EnableSocietyOwnedVehicles then

            local elements = {}

            ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)

              for i=1, #vehicles, 1 do
                table.insert(elements, {label = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']', value = vehicles[i]})
              end

              ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'vehicle_spawner',
                {
                  title    = _U('service_vehicle'),
                  align    = Config.menuAlign,
                  elements = elements,
                },
                function(data, menu)

                  menu.close()

                  local vehicleProps = data.current.value
                  local playerPed = GetPlayerPed(-1)
                  local coords    = Config.Zones.VehicleSpawnPoint.Pos
                  local platenum = math.random(100, 900)

                  ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0, function(vehicle)
                  ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
                  SetVehicleNumberPlateText(vehicle, Config.jobPlatePrefix .. platenum)
                  TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
                  local plate = GetVehicleNumberPlateText(vehicle)
              	  plate = string.gsub(plate, " ", "")
				  
                  end)
				
                  TriggerServerEvent('esx_society:removeVehicleFromGarage', Config.JobName, vehicleProps)

                end,
                function(data, menu)
                  menu.close()
                end
              )

            end, Config.JobName)

          else

            local elements = {
              {label = Config.jobCarLabel, value = Config.jobCarSpawnName}
            }

            if Config.EnablePlayerManagement and PlayerData.job ~= nil and
              (PlayerData.job.grade_name == 'boss') then
				if Config.bossCar then
					table.insert(elements, {label = Config.jobCarBossLabel, value = Config.jobCarBossSpawnName})
				end
            end

            ESX.UI.Menu.CloseAll()

            ESX.UI.Menu.Open(
              'default', GetCurrentResourceName(), 'spawn_vehicle',
              {
                title    = _U('service_vehicle'),
                elements = elements,
				align    = Config.menuAlign,
              },
              function(data, menu)
                  if Config.MaxInService == -1 then
					menu.close()
					TriggerServerEvent('esx_vehicleshop:hassocietycar',Config.JobName)
					Citizen.Wait(1000)
					if asCar then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle, _U('max_vehicle'))
					else
						ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
							local playerPed = GetPlayerPed(-1)
							local plate = string.sub(Config.JobName, 1, 3) .. math.random(1000, 9999)
							SetVehicleNumberPlateText(vehicle, plate)
							plate = string.gsub(plate, " ", "")
							
							local plate = GetVehicleNumberPlateText(vehicle)
							
							local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
							
							if Config.ExternalKeyProduct then
								TriggerServerEvent('esx_vehicleshop:societycargive',vehicleProps, plate, Config.JobName)
								TriggerServerEvent('esx_vehiclelock:registerkey', plate, 'no') -- donne clef
							end

							TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

						end,Config.JobName)
					end
                end
                menu.close()
              end,
              function(data, menu)
                menu.close()
                OpenActionsMenu()
              end
            )

          end
      end

      if data.current.value == 'cloakroom' then
      TriggerServerEvent("player:serviceOn", Config.JobName)	
        menu.close()
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

            if skin.sex == 0 then
                TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
            else
                TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
            end

        end)
      end

      if data.current.value == 'cloakroom2' then
      TriggerServerEvent("player:serviceOff", Config.JobName)	
        menu.close()
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

            TriggerEvent('skinchanger:loadSkin', skin)

        end)
      end

      if data.current.value == 'put_stock' then
        OpenPutStocksMenu()
      end

      if data.current.value == 'get_stock' then
        OpenGetStocksMenu()
      end

      if data.current.value == 'boss_actions' then
        local options = {
            wash      = Config.EnableMoneyWash,
          }

          ESX.UI.Menu.CloseAll()

          TriggerEvent('esx_society:openBossMenu', Config.JobName, function(data, menu)

            menu.close()
            CurrentAction     = 'menu_boss_actions'
            CurrentActionMsg  = _U('open_bossmenu')
            CurrentActionData = {}

          end,options)
      end
	  

    end,
    function(data, menu)
      menu.close()
      CurrentAction     = Config.JobName .. '_actions_menu'
      CurrentActionMsg  = _U('open_actions')
      CurrentActionData = {}
    end
  )
end

function OpenHarvestMenu()

  if Config.EnablePlayerManagement and PlayerData.job ~= nil then
    local elements = {
      {label = Config.itemcollect.label, value = Config.itemcollect.name},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), Config.JobName..'_harvest',
      {
        title    = _U('harvest'),
        elements = elements,
		align    = Config.menuAlign,
      },
      function(data, menu)
        if data.current.value == Config.itemcollect.name then
          menu.close()
          TriggerServerEvent('esx_'.. Config.JobName ..':startHarvest')
		
        end       

      end,
      function(data, menu)
        menu.close()
        CurrentAction     = Config.JobName..'_harvest_menu'
        CurrentActionMsg  = _U('harvest_menu')
        CurrentActionData = {}
      end
    )
  else
    TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('not_experienced_enough'))
  end

end

function OpenCraftMenu()
  if Config.EnablePlayerManagement and PlayerData.job ~= nil then

    local elements = {
	  {label = Config.itemrefinedlvl2.label, value = Config.itemrefinedlvl2.name},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), Config.JobName .. '_craft',
      {
        title    = _U('craft'),
        elements = elements,
		align    = Config.menuAlign,
      },
      function(data, menu)
        if data.current.value == Config.itemrefinedlvl2.name then
          menu.close()
          TriggerServerEvent('esx_'.. Config.JobName ..':startCraft')
        end

      end,

      function(data, menu)
        menu.close()
        CurrentAction     = Config.JobName .. '_craft_menu'
        CurrentActionMsg  = _U('craft_menu')
        CurrentActionData = {}
      end
    )
  else
    TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('not_experienced_enough'))
  end
end

function OpenCraft2Menu()
  if Config.EnablePlayerManagement and PlayerData.job ~= nil then

    local elements = {
      {label = Config.itemsell.label, value = Config.itemsell.name}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), Config.JobName .. '_craft2',
      {
        title    = _U('craft'),
        elements = elements,
		align    = Config.menuAlign,
      },
      function(data, menu)
        if data.current.value == Config.itemsell.name then
          menu.close()
          TriggerServerEvent('esx_'.. Config.JobName ..':startCraft2')
        end

      end,

      function(data, menu)
        menu.close()
        CurrentAction     = Config.JobName ..'_craft2_menu'
        CurrentActionMsg  = _U('craft_menu')
        CurrentActionData = {}
      end
    )
  else
	 TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('not_experienced_enough'))
  end
end

function OpenFactuActionsMenu()

ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'factu_'.. Config.JobName ..'_actions',
    {
      title    = 'Menu '.. Config.JobName ..' & Facturation',
      align    = Config.menuAlign,
      elements = {
        --{label = 'Intéraction Client',    value = 'facture_client'},
        {label = 'Passer une annonce', value = 'announce'}        
      },
    },


    function(data, menu)

      if data.current.value == 'facture_client' then

        ESX.UI.Menu.Open(
          'default', GetCurrentResourceName(), 'facture_client',
          {
            title    = 'Facturation Client',
            align    = Config.menuAlign,
            elements = {

              {label = 'Facture',       value = 'billing'}              
            },
          },
             
          function(data2, menu2)
                
            local player, distance = ESX.Game.GetClosestPlayer()        

            if distance ~= -1 and distance <= 3.0 then
            
              if data2.current.value == 'billing' then
                ESX.UI.Menu.Open(
                  'dialog', GetCurrentResourceName(), 'billing',
                  {
                    title = _U('invoice_amount'),
					align    = Config.menuAlign,
                  },
                  function(data2, menu2)
                    local amount = tonumber(data2.value)
                    if amount == nil then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('amount_invalid'))
                      else
                      menu2.close()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                      if closestPlayer == -1 or closestDistance > 3.0 then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('no_players_nearby'))
                      else
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_'.. Config.JobName, _U(Config.JobName), amount)
                      end
                    end
                  end,
                function(data2, menu2)
                  menu2.close()
                end                  
                )
              end

            else
				TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('no_players_nearby'))
            end    
          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end

      if data.current.value == 'announce' then
        messagenotfinish = true
        Message()
      end      

    end,
    function(data, menu)
      menu.close()
    end
  )

end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('esx_' .. Config.JobName .. ':getStockItems', function(items)

    local elements = {}

    for i=1, #items, 1 do

      local item = items[i]

      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = Config.JobName ..' Stock',
        elements = elements,
		align    = Config.menuAlign,
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity'),
			align    = Config.menuAlign,
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
				TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('invalid_quantity'))
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()
              TriggerServerEvent('esx_'.. Config.JobName ..':getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutStocksMenu()

ESX.TriggerServerCallback('esx_'.. Config.JobName ..':getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('inventory'),
        elements = elements,
		align    = Config.menuAlign,
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
          {
            title = _U('quantity'),
			align    = Config.menuAlign,
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
				TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('invalid_quantity'))
            else
              menu2.close()
              menu.close()
              OpenPutStocksMenu()

              TriggerServerEvent('esx_'.. Config.JobName ..':putStockItems', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end


AddEventHandler('esx_'.. Config.JobName ..':hasEnteredMarker', function(zone)

  if zone == 'Actions' then
    CurrentAction     = Config.JobName .. '_actions_menu'
    CurrentActionMsg  = _U('open_actions')
    CurrentActionData = {}
  end
  
  if zone == 'SellFarm' and PlayerData.job ~= nil and PlayerData.job.name == Config.JobName  then
    CurrentAction     = 'farm_resell'
    CurrentActionMsg  = _U('press_sell')
    CurrentActionData = {zone = zone}
  end

  if zone == 'Recolte' then
    CurrentAction     = Config.JobName .. '_harvest_menu'
    CurrentActionMsg  = _U('harvest_menu')
    CurrentActionData = {}
  end

  if zone == 'Craft' then
    CurrentAction     =  Config.JobName .. '_craft_menu'
    CurrentActionMsg  = _U('craft_menu')
    CurrentActionData = {}
  end

  if zone == 'Craft2' then
    CurrentAction     = Config.JobName .. '_craft2_menu'
    CurrentActionMsg  = _U('craft_menu')
    CurrentActionData = {}
  end
  
  if Config.VehicleBack then
	  if zone == 'VehicleDeleter' then

		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed,  false) then

		  local vehicle = GetVehiclePedIsIn(playerPed,  false)

		  CurrentAction     = 'delete_vehicle'
		  CurrentActionMsg  = _U('veh_stored')
		  CurrentActionData = {vehicle = vehicle}
		end
	  end
  end

end)

AddEventHandler('esx_'.. Config.JobName ..':hasExitedMarker', function(zone)
 
  if (zone == 'SellFarm') and PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
    TriggerServerEvent('esx_'.. Config.JobName ..':stopSell')
  end

  if zone == 'Craft' then
    TriggerServerEvent('esx_'.. Config.JobName ..':stopCraft')
  end

  if zone == 'Craft2' then
    TriggerServerEvent('esx_'.. Config.JobName ..':stopCraft2')
  end  

  if zone == 'Recolte' then
    TriggerServerEvent('esx_'.. Config.JobName ..':stopHarvest')
  end

  CurrentAction = nil
  ESX.UI.Menu.CloseAll()
end)


RegisterNetEvent('esx_'.. Config.JobName ..':setTimeDiff')
AddEventHandler('esx_'.. Config.JobName ..':setTimeDiff', function(time)
  TimeDiff = GetPosixTime() - time 
end)


-- Display markers
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
		if Config.showMarker then
		  local coords = GetEntityCoords(GetPlayerPed(-1))
		  
		  for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
			  DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		  end
		end
    end
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
      local coords      = GetEntityCoords(GetPlayerPed(-1))
      local isInMarker  = false
      local currentZone = nil
      for k,v in pairs(Config.Zones) do
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
          isInMarker  = true
          currentZone = k
        end
      end
      if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
        HasAlreadyEnteredMarker = true
        LastZone                = currentZone
        TriggerEvent('esx_'.. Config.JobName ..':hasEnteredMarker', currentZone)
      end
      if not isInMarker and HasAlreadyEnteredMarker then
        HasAlreadyEnteredMarker = false
        TriggerEvent('esx_'.. Config.JobName ..':hasExitedMarker', LastZone)
      end
    end
  end
end)


-- Key Controls
Citizen.CreateThread(function()

  while ESX == nil or not ESX.IsPlayerLoaded() do
    Citizen.Wait(1)
  end

    while true do
        Citizen.Wait(1)

        if CurrentAction ~= nil then

          SetTextComponentFormat('STRING')
          AddTextComponentString(CurrentActionMsg)
          DisplayHelpTextFromStringLabel(0, 0, 1, -1)

          if IsControlJustReleased(0, 38) and PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then

            if CurrentAction == Config.JobName ..'_actions_menu' then
                OpenActionsMenu()
            end
            if CurrentAction == 'farm_resell' then
                TriggerServerEvent('esx_'.. Config.JobName ..':startSell', CurrentActionData.zone)
            end

            if CurrentAction == Config.JobName ..'_harvest_menu' then
                OpenHarvestMenu()
            end

            if CurrentAction == Config.JobName ..'_craft_menu' then
                OpenCraftMenu()
            end
            
            if CurrentAction == Config.JobName ..'_craft2_menu' then
                OpenCraft2Menu()
            end

            if CurrentAction == 'delete_vehicle' then

              if Config.EnableSocietyOwnedVehicles then

                local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
                local playerPed    = GetPlayerPed(-1)
                local vehicle      = GetVehiclePedIsIn(playerPed,  false)
                local hash         = GetEntityModel(vehicle)
                local plate        = GetVehicleNumberPlateText(vehicle)
                TriggerServerEvent('esx_society:putVehicleInGarage', Config.JobName, vehicleProps)

              else

                if
                  GetEntityModel(vehicle) == GetHashKey(Config.jobCarSpawnName)   or
                  GetEntityModel(vehicle) == GetHashKey(Config.jobCarBossSpawnName)
                then
                  TriggerServerEvent('esx_service:disableService', Config.JobName)
                end

              end

              ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
              --TriggerServerEvent('esx_vehiclelock:deletekeyjobs', 'no', plate) --vehicle lock
            end

            CurrentAction = nil
          end
        end

		if Config.F6Menu then
			if IsControlJustReleased(0, Keys[Config.billingKey]) and PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then
				OpenFactuActionsMenu()
			end
		end

		if Config.sellToPed then
			if IsControlJustReleased(0, Keys[Config.pedSellKey]) and PlayerData.job ~= nil and PlayerData.job.name == Config.JobName then

			  local playerPed = GetPlayerPed(-1)
			  local coords    = GetEntityCoords(playerPed)
			  
			  local closestPed, closestDistance = ESX.Game.GetClosestPed({
				x = coords.x,
				y = coords.y,
				z = coords.z
			  }, {playerPed})

			  -- Fallback code
			  if closestDistance == -1 then

				local success, ped = GetClosestPed(coords.x,  coords.y,  coords.z,  5.0, 1, 0, 0, 0,  26)

				if DoesEntityExist(ped) then
				  local pedCoords = GetEntityCoords(ped)
				  closestPed      = ped
				  closestDistance = GetDistanceBetweenCoords(coords.x,  coords.y,  coords.z,  pedCoords.x,  pedCoords.y,  pedCoords.z,  true)
				end

			  end

			  if closestPed ~= -1 and closestDistance <= 5.0 then

				if IsPedInAnyVehicle(closestPed,  false) then
					TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('invalid_action_car'))
				else

				  local playerData    = ESX.GetPlayerData()
				  local isBlacklisted = false

				  for i=1, #PedBlacklist, 1 do
					if PedBlacklist[i] == closestPed then
					  isBlacklisted = true
					end
				  end

				  if isBlacklisted then
					TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('early_call'))
				  else

					table.insert(PedBlacklist, closestPed)

					local hasCig = {}

					for i=1, #playerData.inventory, 1 do
						if playerData.inventory[i].name == Config.itemsell.name and playerData.inventory[i].count > 0 then
						  hasCig = playerData.inventory[i]
						end
					end

					if hasCig.count > 0 then

					  local magic = GetRandomIntInRange(1, 100)

					  TaskStandStill(closestPed,  -1)
					  TaskLookAtEntity(closestPed,  playerPed,  -1,  2048,  3)

					  if magic <= 1 then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('deal_refuse'))

						TaskStandStill(closestPed,  -1)

						ESX.SetTimeout(5000, function()

						  StartWalking(closestPed)

						  ESX.SetTimeout(20000, function()
							
							TaskStartScenarioInPlace(closestPed, 'WORLD_HUMAN_STAND_MOBILE', 0, true);
							if Config.PedCallPolice then
								if math.random(1, 100) > Config.percentCallPoliceRate then
									TriggerServerEvent('esx_'.. Config.JobName ..':pedCallPolice')
								end
							end

							ESX.SetTimeout(20000, function()
							  StartWalking(closestPed)
							end)

						  end)

						end)

					  elseif magic <= 30 then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('deal_accept'))
						TriggerServerEvent('esx_'.. Config.JobName ..':pedBuyCig', 3)
						StartWalking(closestPed)

					  elseif magic <= 70 then
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('deal_accept_hight'))

						TriggerServerEvent('esx_'.. Config.JobName ..':pedBuyCig', 2)

						ESX.SetTimeout(5000, function()
						  StartWalking(closestPed)
						end)

					  elseif magic <= 90 then

						PedAttacking = closestPed
						
						SetPedAlertness(closestPed,  3)
						SetPedCombatAttributes(closestPed,  46,  true)

						ESX.SetTimeout(120000, function()
						  PedAttacking = nil
						end)

					  else
						
						TriggerServerEvent('esx_'.. Config.JobName ..':pedBuyCig', 1)
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('deal_accept_veryhight'))

						TaskStandStill(closestPed,  -1)

						ESX.SetTimeout(5000, function()
						  StartWalking(closestPed)
						end)
					  
					  end

					else
						TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('no_product_sell'))
					end

				  end

				end

			  else
				TriggerEvent('esx_'.. Config.JobName ..':RageMsg',Config.NotifTitle,_U('nobody_close'))
			  end

			end
		end

    end
end)


Citizen.CreateThread(function()
  while true do

    Citizen.Wait(1)

    if PedAttacking ~= nil then
      TaskCombatPed(PedAttacking,  GetPlayerPed(-1),  0,  16)
    end

  end
end)


----------------------------
---- UTILISER CIGARETTE ----
----------------------------

RegisterNetEvent('esx_'.. Config.JobName ..':onSmokeCig')
AddEventHandler('esx_'.. Config.JobName ..':onSmokeCig', function()
  TaskStartScenarioInPlace(GetPlayerPed(-1), Config.animOnUseItem, 0, 1)
  emotePlay = true
  Citizen.Wait(120000)
  ClearPedTasksImmediately(GetPlayerPed(-1))
  emotePlay = false
end)

function stopEmote()
  ClearPedTasks(GetPlayerPed(-1))
  emotePlay = false
end


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    if emotePlay then
      if IsControlJustPressed(1, 22) or IsControlJustPressed(1, 30) or IsControlJustPressed(1, 31) then
        stopEmote()
      end
    end
  end
end)


function DrawAdvancedTextCNN (x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end


 Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)    
                           
                if (affichenews == true) then
               
                DrawRect(0.494, 0.227, 5.185, 0.118, 0, 0, 0, 150)
                DrawAdvancedTextCNN(0.588, 0.14, 0.005, 0.0028, 0.8, "~r~ ".. Config.JobName .." ~d~", 255, 255, 255, 255, 1, 0)
                DrawAdvancedTextCNN(0.586, 0.199, 0.005, 0.0028, 0.6, texteafiche, 255, 255, 255, 255, 7, 0)
                DrawAdvancedTextCNN(0.588, 0.246, 0.005, 0.0028, 0.4, "", 255, 255, 255, 255, 0, 0)

            end                
       end
    end)



RegisterNetEvent('esx_'.. Config.JobName ..':annonce')
AddEventHandler('esx_'.. Config.JobName ..':annonce', function(text)
    texteafiche = text
    affichenews = true
    
  end) 


RegisterNetEvent('esx_'.. Config.JobName ..':annoncestop')
AddEventHandler('esx_'.. Config.JobName ..':annoncestop', function()
    affichenews = false
    
  end)

Citizen.CreateThread(function()

  local blip = AddBlipForCoord(Config.Blip.Pos.x, Config.Blip.Pos.y, Config.Blip.Pos.z)

  SetBlipSprite (blip, Config.Blip.Sprite)
  SetBlipDisplay(blip, Config.Blip.Display)
  SetBlipScale  (blip, Config.Blip.Scale)
  SetBlipColour (blip, Config.Blip.Colour)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(Config.Blip.Name)
  EndTextCommandSetBlipName(blip)

end)

RegisterNetEvent('esx_'.. Config.JobName ..':RageMsg')
AddEventHandler('esx_'.. Config.JobName ..':RageMsg', function(source, title, text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	SetNotificationMessage(Config.NotifPict, Config.NotifPict, flase, 4, source, title, text)
	DrawNotification(false, true)
 end)

