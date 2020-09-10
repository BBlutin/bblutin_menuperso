ESX = nil

function notification(title, subject, msg)

	local mugshot, mugshotStr = ESX.Game.GetPedMugshot(GetPlayerPed(-1))
  
	ESX.ShowAdvancedNotification(title, subject, msg, mugshotStr, 1)
  
	UnregisterPedheadshot(mugshot)
  
end

_menuPool = nil
local personalmenu = {}

local invItem, wepItem, billItem, mainMenu, itemMenu, weaponItemMenu = {}, {}, {}, nil, nil, nil

local isDead, inAnim = false, false

local playerGroup, noclip, godmode, visible = nil, false, false, false


local societymoney, societymoney2 = nil, nil

local wepList = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	if Config.doublejob then
		while ESX.GetPlayerData().job2 == nil do
			Citizen.Wait(10)
		end
	end

	ESX.PlayerData = ESX.GetPlayerData()

	while playerGroup == nil do
		ESX.TriggerServerCallback('bblutin_menu:Admin_getUsergroup', function(group) playerGroup = group end)
		Citizen.Wait(10)
	end

	while actualSkin == nil do
		TriggerEvent('skinchanger:getSkin', function(skin) actualSkin = skin end)
		Citizen.Wait(10)
	end

	RefreshMoney()

	if Config.doublejob then
		RefreshMoney2()
	end

	wepList = ESX.GetWeaponList()

	if Config.CustomMenuEnabled then
		local RuntimeTXD = CreateRuntimeTxd('Custom_Menu_Head')
		local Object = CreateDui(Config.MenuImage, 512, 128)
		_G.Object = Object
		local TextureThing = GetDuiHandle(Object)
		local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'Custom_Menu_Head', TextureThing)
		Menuthing = "Custom_Menu_Head"
	else
		Menuthing = "shopui_title_sm_hangar"
	end

	_menuPool = NativeUI.CreatePool()

	mainMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('mainmenu_subtitle'), 0, 0, Menuthing, Menuthing)
	mainMenu:SetMenuWidthOffset(10)
	itemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('inventory_actions_subtitle'), 0, 0, Menuthing, Menuthing)
	itemMenu:SetMenuWidthOffset(10)
	weaponItemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('loadout_actions_subtitle'), 0, 0, Menuthing, Menuthing)
	weaponItemMenu:SetMenuWidthOffset(10)
	_menuPool:Add(mainMenu)
	_menuPool:Add(itemMenu)
	_menuPool:Add(weaponItemMenu)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
	_menuPool:CloseAllMenus()
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshMoney()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	ESX.PlayerData.job2 = job2
	RefreshMoney2()
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSocietyMoney(money)
		end, ESX.PlayerData.job.name)
	end
end

function RefreshMoney2()
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSociety2Money(money)
		end, ESX.PlayerData.job2.name)
	end
end

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		UpdateSocietyMoney(money)
	end
	if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job2.name == society then
		UpdateSociety2Money(money)
	end
end)

function UpdateSocietyMoney(money)
	societymoney = ESX.Math.GroupDigits(money)
end

function UpdateSociety2Money(money)
	societymoney2 = ESX.Math.GroupDigits(money)
end

--Message text joueur
function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.017, 0.977)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end


function changer_skin()
	_menuPool:CloseAllMenus()
	Citizen.Wait(100)
	TriggerEvent('esx_skin:openSaveableMenu', source)
end

function save_skin()
	TriggerEvent('esx_skin:requestSaveSkin', source)
end

function startAttitude(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimSet(anim)

		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(0)
		end

		SetPedMotionBlur(plyPed, false)
		SetPedMovementClipset(plyPed, anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
	end)
end

function startAnimAction(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(plyPed, lib, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(plyPed, anim, 0, false)
end


function AddMenuWeaponMenu(menu)
	weaponMenu = _menuPool:AddSubMenu(menu, _U('loadout_title'), "", "", Menuthing, Menuthing)
	weaponMenu.Item:RightLabel("→")
	weaponMenu.SubMenu:SetMenuWidthOffset(10)

	for i = 1, #wepList, 1 do
		local weaponHash = GetHashKey(wepList[i].name)

		if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
			local ammo 		= GetAmmoInPedWeapon(plyPed, weaponHash)
			local label	    = wepList[i].label .. ' [' .. ammo .. ']'
			local value	    = wepList[i].name

			wepItem[value] = NativeUI.CreateItem(label, "")
			weaponMenu.SubMenu:AddItem(wepItem[value])
		end
	end

	local giveItem = NativeUI.CreateItem(_U('loadout_give_button'), "")
	weaponItemMenu:AddItem(giveItem)

	local giveMunItem = NativeUI.CreateItem(_U('loadout_givemun_button'), "")
	weaponItemMenu:AddItem(giveMunItem)

	local dropItem = NativeUI.CreateItem(_U('loadout_drop_button'), "")
	dropItem:SetRightBadge(4)
	weaponItemMenu:AddItem(dropItem)

	weaponMenu.SubMenu.OnItemSelect = function(sender, item, index)
		_menuPool:CloseAllMenus(true)
		weaponItemMenu:Visible(true)

		for i = 1, #wepList, 1 do
			local weaponHash = GetHashKey(wepList[i].name)

			if HasPedGotWeapon(plyPed, weaponHash, false) and wepList[i].name ~= 'WEAPON_UNARMED' then
				local ammo 		= GetAmmoInPedWeapon(plyPed, weaponHash)
				local value	    = wepList[i].name
				local label	    = wepList[i].label

				if item == wepItem[value] then
					weaponItemMenu.OnItemSelect = function(sender, item, index)
						if item == giveItem then
							local foundPlayers = false
							personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

							if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
				 				foundPlayers = true
							end

							if foundPlayers == true then
								local closestPed = GetPlayerPed(personalmenu.closestPlayer)

								if not IsPedSittingInAnyVehicle(closestPed) then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_weapon', value, ammo)
									_menuPool:CloseAllMenus()
								else
									notification("Gestions Armes", "Notification", _U('in_vehicle_give', label))
								end
							else
								notification("Gestions Armes", "Notification", _U('players_nearby'))
							end
						elseif item == giveMunItem then
							local quantity = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount_ammo'), "", 8)

							if quantity ~= nil then
								local post = true
								quantity = tonumber(quantity)

								if type(quantity) == 'number' then
									quantity = ESX.Math.Round(quantity)

									if quantity <= 0 then
										post = false
									end
								end

								local foundPlayers = false
								personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

								if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
				 					foundPlayers = true
								end

								if foundPlayers == true then
									local closestPed = GetPlayerPed(personalmenu.closestPlayer)

									if not IsPedSittingInAnyVehicle(closestPed) then
										if ammo > 0 then
											if post == true then
												if quantity <= ammo and quantity >= 0 then
													local finalAmmo = math.floor(ammo - quantity)
													SetPedAmmo(plyPed, value, finalAmmo)
													TriggerServerEvent('bblutin_menu:Weapon_addAmmoToPedS', GetPlayerServerId(personalmenu.closestPlayer), value, quantity)

													ESX.ShowNotification(_U('gave_ammo', quantity, GetPlayerName(personalmenu.closestPlayer)))
													_menuPool:CloseAllMenus()
												else
													notification("Gestions Armes", "Notification", _U('not_enough_ammo'))
												end
											else
												notification("Gestions Armes", "Notification", _U('amount_invalid'))
											end
										else
											notification("Gestions Armes", "Notification", _U('no_ammo'))
										end
									else
										notification("Gestions Armes", "Notification", _U('in_vehicle_give', label))
									end
								else
									notification("Gestions Armes", "Notification", _U('players_nearby'))
								end
							end
						elseif item == dropItem then
							if not IsPedSittingInAnyVehicle(plyPed) then
								TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', value)
								_menuPool:CloseAllMenus()
							else
								notification("Gestions Armes", "Notification", _U('players_nearby', label))
							end
						end
					end
				end
			end
		end
	end
end

function AddMenuWalletMenu(menu)
	local moneyOption = {}
	
	moneyOption = {
		_U('wallet_option_give'),
		_U('wallet_option_drop')
	}

	walletmenu = _menuPool:AddSubMenu(menu, _U('wallet_title'), "", "", Menuthing, Menuthing)
	walletmenu.Item:RightLabel("→")
	walletmenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuFacturesMenu(walletmenu)


	local walletJob = NativeUI.CreateItem(_U('wallet_job_button', ESX.PlayerData.job.label, ESX.PlayerData.job.grade_label), "")
	walletmenu.SubMenu:AddItem(walletJob)

	local walletjob2 = nil

	if Config.doublejob then
		walletJob2 = NativeUI.CreateItem(_U('wallet_job2_button', ESX.PlayerData.job2.label, ESX.PlayerData.job2.grade_label), '')
		walletmenu.SubMenu:AddItem(walletJob2)
	end
	
	local walletMoney = NativeUI.CreateListItem(_U('wallet_money_button', ESX.Math.GroupDigits(ESX.PlayerData.money)), moneyOption, 1)
	walletmenu.SubMenu:AddItem(walletMoney)

	local walletdirtyMoney = nil
	local showID = nil
	local showDriver = nil
	local showFirearms = nil
	local checkID = nil
	local checkDriver = nil
	local checkFirearms = nil

	for i = 1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == 'black_money' then
			walletdirtyMoney = NativeUI.CreateListItem(_U('wallet_blackmoney_button', ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money)), moneyOption, 1)
			walletmenu.SubMenu:AddItem(walletdirtyMoney)
		end
	end

	walletmenu.SubMenu.OnListSelect = function(sender, item, index)
		if item == walletMoney or item == walletdirtyMoney then
			if index == 1 then
				local quantity = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount'), "", 8)

				if quantity ~= nil then
					local post = true
					quantity = tonumber(quantity)

					if type(quantity) == 'number' then
						quantity = ESX.Math.Round(quantity)

						if quantity <= 0 then
							post = false
						end
					end

					local foundPlayers = false
					personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

					if personalmenu.closestDistance ~= -1 and personalmenu.closestDistance <= 3 then
						foundPlayers = true
					end

					if foundPlayers == true then
						local closestPed = GetPlayerPed(personalmenu.closestPlayer)

						if not IsPedSittingInAnyVehicle(closestPed) then
							if post == true then
								if item == walletMoney then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_money', 'money', quantity)
									TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 2.0, 2.0, 1000, 51, 0, false, false, false)
									_menuPool:CloseAllMenus()
								elseif item == walletdirtyMoney then
									TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(personalmenu.closestPlayer), 'item_account', 'black_money', quantity)
									TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 2.0, 2.0, 1000, 51, 0, false, false, false)
									_menuPool:CloseAllMenus()
								end
							else
								ESX.ShowNotification(_U('amount_invalid'))
							end
						else
							ESX.ShowNotification(_U('in_vehicle_give'))
						end
					else
						ESX.ShowNotification(_U('players_nearby'))
					end
				end
			elseif index == 2 then
				local quantity = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount'), "", 8)

				if quantity ~= nil then
					local post = true
					quantity = tonumber(quantity)

					if type(quantity) == 'number' then
						quantity = ESX.Math.Round(quantity)

						if quantity <= 0 then
							post = false
						end
					end

					if not IsPedSittingInAnyVehicle(plyPed) then
						if post == true then
							if item == walletMoney then
								TriggerServerEvent('esx:removeInventoryItem', 'item_money', 'money', quantity)
								_menuPool:CloseAllMenus()
							elseif item == walletdirtyMoney then
								TriggerServerEvent('esx:removeInventoryItem', 'item_account', 'black_money', quantity)
								_menuPool:CloseAllMenus()
							end
						else
							ESX.ShowNotification(_U('amount_invalid'))
						end
					else
						if item == walletMoney then
							ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent'))
						elseif item == walletdirtyMoney then
							ESX.ShowNotification(_U('in_vehicle_drop', 'de l\'argent sale'))
						end
					end
				end
			end
		end
	end
end



function AddSubMenuFacturesMenu(menu)
	billMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('bills_title'), "", "", Menuthing, Menuthing)
	billMenu.Item:RightLabel("→") 
	billMenu.SubMenu:SetMenuWidthOffset(10)
	billItem = {}

	ESX.TriggerServerCallback('bblutin_menu:Bill_getBills', function(bills)
		for i = 1, #bills, 1 do
			local label = bills[i].label
			local amount = bills[i].amount
			local value = bills[i].id

			table.insert(billItem, value)

			billItem[value] = NativeUI.CreateItem(label, '')
			billItem[value]:RightLabel('$' .. ESX.Math.GroupDigits(amount))
			billMenu.SubMenu:AddItem(billItem[value])
		end

		billMenu.SubMenu.OnItemSelect = function(sender, item, index)
			for i = 1, #bills, 1 do
				local label  = bills[i].label
				local value = bills[i].id

				if item == billItem[value] then
					ESX.TriggerServerCallback('esx_billing:payBill', function()
						_menuPool:CloseAllMenus()
					end, value)
				end
			end
		end
	end)
end


function AddSubMenuClothesMenu(menu)
	clothesMenu = _menuPool:AddSubMenu(menu.SubMenu, _U('clothes_title'), "", "", Menuthing, Menuthing)
	clothesMenu.Item:RightLabel('→')
	clothesMenu.SubMenu:SetMenuWidthOffset(10)

	local tshirtItem = NativeUI.CreateItem(('T-Shirt'), "Retirer votre T-Shirt")
	clothesMenu.SubMenu:AddItem(tshirtItem)
	local torsoItem = NativeUI.CreateItem(_U('clothes_top'), "Retirer votre Torse")
	clothesMenu.SubMenu:AddItem(torsoItem)
	local pantsItem = NativeUI.CreateItem(_U('clothes_pants'), "Retirer votre Bas")
	clothesMenu.SubMenu:AddItem(pantsItem)
	local shoesItem = NativeUI.CreateItem(_U('clothes_shoes'), "Retirer vos Chaussures")
	clothesMenu.SubMenu:AddItem(shoesItem)
	local bagItem = NativeUI.CreateItem(_U('clothes_bag'), "Retirer votre Sac")
	clothesMenu.SubMenu:AddItem(bagItem)
	local bproofItem = NativeUI.CreateItem(_U('clothes_bproof'), "Retirer votre Gilet par Balle")
	clothesMenu.SubMenu:AddItem(bproofItem)
	local watchesItem = NativeUI.CreateItem(('Montre(s)'), "Retirer votre Montre")
	clothesMenu.SubMenu:AddItem(watchesItem)
	local braceletItem = NativeUI.CreateItem(('Bracelet(s)'), "Retirer votre Bracelet")
	clothesMenu.SubMenu:AddItem(braceletItem)
	local colierItem = NativeUI.CreateItem(('Chaine(s)'), "Retirer votre Chaine")
	clothesMenu.SubMenu:AddItem(colierItem)

	clothesMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == tshirtItem then
			setUniform('tshirt', plyPed)
		elseif item == torsoItem then
			setUniform('torso', plyPed)
		elseif item == pantsItem then
			setUniform('pants', plyPed)
		elseif item == shoesItem then
			setUniform('shoes', plyPed)
		elseif item == bagItem then
			setUniform('bag', plyPed)
		elseif item == bproofItem then
			setUniform('bproof', plyPed)
		elseif item == watchesItem then
			setUniform('watches', plyPed)
		elseif item == braceletItem then
			setUniform('bracelet', plyPed)
		elseif item == colierItem then
			setUniform('colier', plyPed)
		end
	end
end

function setUniform(value, plyPed)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:getSkin', function(skina)
			if value == 'tshirt' then
				startAnimAction("clothingtie", "try_tie_positive_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.tshirt_1 ~= skina.tshirt_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['tshirt_1'] = skin.tshirt_1, ['tshirt_2'] = skin.tshirt_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['tshirt_1'] = 15, ['tshirt_2'] = 0})
				end
			elseif value == 'torso' then
					startAnimAction("clothingtie", "try_tie_positive_a")
					Citizen.Wait(1000)
					ClearPedTasks(plyPed)
			if skin.torso_1 ~= skina.torso_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = skin.torso_1, ['torso_2'] = skin.torso_2, ['arms'] = skin.arms})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['torso_1'] = 15, ['torso_2'] = 0, ['arms'] = 15})
				end
			elseif value == 'pants' then
				startAnimAction("mp_clothing@female@trousers", "try_trousers_neutral_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)
				if skin.pants_1 ~= skina.pants_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = skin.pants_1, ['pants_2'] = skin.pants_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 61, ['pants_2'] = 1})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['pants_1'] = 15, ['pants_2'] = 0})
					end
				end
			elseif value == 'shoes' then
				if skin.shoes_1 ~= skina.shoes_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = skin.shoes_1, ['shoes_2'] = skin.shoes_2})
				else
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 34, ['shoes_2'] = 0})
					else
						TriggerEvent('skinchanger:loadClothes', skina, {['shoes_1'] = 35, ['shoes_2'] = 0})
					end
				end
			elseif value == 'bag' then
				if skin.bags_1 ~= skina.bags_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = skin.bags_1, ['bags_2'] = skin.bags_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bags_1'] = 0, ['bags_2'] = 0})
				end
			elseif value == 'bproof' then
				startAnimAction("clothingtie", "try_tie_positive_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.bproof_1 ~= skina.bproof_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = skin.bproof_1, ['bproof_2'] = skin.bproof_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bproof_1'] = 0, ['bproof_2'] = 0})
				end
			elseif value == 'watches' then
				startAnimAction("clothingtie", "try_tie_positive_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.watches_1 ~= skina.watches_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['watches_1'] = skin.watches_1, ['watches_2'] = skin.watches_2})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['watches_1'] = -1, ['watches_2'] = -1})
				end
			elseif value == 'bracelet' then
				startAnimAction("clothingtie", "try_tie_positive_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.bracelets_1 ~= skina.bracelets_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['bracelets_1'] = skin.bracelets_1})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['bracelets_1'] = -1})
				end
			elseif value == 'colier' then
				startAnimAction("clothingtie", "try_tie_positive_a")
				Citizen.Wait(1000)
				ClearPedTasks(plyPed)

				if skin.chain_1 ~= skina.chain_1 then
					TriggerEvent('skinchanger:loadClothes', skina, {['chain_1'] = skin.chain_1})
				else
					TriggerEvent('skinchanger:loadClothes', skina, {['chain_1'] = -1})
				end
			end
		end)
	end)
end

function AddMenuBossMenu(menu)
	bossMenu = _menuPool:AddSubMenu(menu, _U('bossmanagement_title', ESX.PlayerData.job.label), "", "", Menuthing, Menuthing)
	bossMenu.Item:RightLabel("→")
	bossMenu.SubMenu:SetMenuWidthOffset(10)

	local coffreItem = nil

	if societymoney ~= nil then
		coffreItem = NativeUI.CreateItem(_U('bossmanagement_chest_button'), "")
		coffreItem:RightLabel("$" .. societymoney)
		bossMenu.SubMenu:AddItem(coffreItem)
	end

	local recruterItem = NativeUI.CreateItem(_U('bossmanagement_hire_button'), "")
	bossMenu.SubMenu:AddItem(recruterItem)
	local virerItem = NativeUI.CreateItem(_U('bossmanagement_fire_button'), "")
	bossMenu.SubMenu:AddItem(virerItem)
	local promouvoirItem = NativeUI.CreateItem(_U('bossmanagement_promote_button'), "")
	bossMenu.SubMenu:AddItem(promouvoirItem)
	local destituerItem = NativeUI.CreateItem(_U('bossmanagement_demote_button'), "")
	bossMenu.SubMenu:AddItem(destituerItem)

	bossMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == recruterItem then
			if ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'capitaine' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('bblutin_menu:Boss_recruterplayer', GetPlayerServerId(personalmenu.closestPlayer), ESX.PlayerData.job.name, 0)
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == virerItem then
			if ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'capitaine' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('bblutin_menu:Boss_virerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == promouvoirItem then
			if ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'capitaine' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('bblutin_menu:Boss_promouvoirplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == destituerItem then
			if ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'capitaine' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification(_U('players_nearby'))
				else
					TriggerServerEvent('bblutin_menu:Boss_destituerplayer', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		end
	end
end

function AddMenuBossMenu2(menu)
	bossMenu2 = _menuPool:AddSubMenu(menu, _U('bossmanagement2_title', ESX.PlayerData.job2.label), "", "", Menuthing, Menuthing)
	bossMenu2.Item:RightLabel("→")
	bossMenu2.SubMenu:SetMenuWidthOffset(10)

	local coffre2Item = nil

	if societymoney2 ~= nil then
		coffre2Item = NativeUI.CreateItem(_U('bossmanagement2_chest_button'), "")
		coffre2Item:RightLabel("$" .. societymoney2)
		bossMenu2.SubMenu:AddItem(coffre2Item)
	end

	local recruter2Item = NativeUI.CreateItem(_U('bossmanagement2_hire_button'), "")
	bossMenu2.SubMenu:AddItem(recruter2Item)
	local virer2Item = NativeUI.CreateItem(_U('bossmanagement2_fire_button'), "")
	bossMenu2.SubMenu:AddItem(virer2Item)
	local promouvoir2Item = NativeUI.CreateItem(_U('bossmanagement2_promote_button'), "")
	bossMenu2.SubMenu:AddItem(promouvoir2Item)
	local destituer2Item = NativeUI.CreateItem(_U('bossmanagement2_demote_button'), "")
	bossMenu2.SubMenu:AddItem(destituer2Item)

	bossMenu2.SubMenu.OnItemSelect = function(sender, item, index)
		if item == recruter2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification("~r~Aucun joueur.")
				else
					TriggerServerEvent('bblutin_menu:Boss_recruterplayer2', GetPlayerServerId(personalmenu.closestPlayer), ESX.PlayerData.job2.name, 0)
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == virer2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification("~r~Aucun joueur.")
				else
					TriggerServerEvent('bblutin_menu:Boss_virerplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == promouvoir2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification("~r~Aucun joueur.")
				else
					TriggerServerEvent('bblutin_menu:Boss_promouvoirplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		elseif item == destituer2Item then
			if ESX.PlayerData.job2.grade_name == 'boss' then
				personalmenu.closestPlayer, personalmenu.closestDistance = ESX.Game.GetClosestPlayer()

				if personalmenu.closestPlayer == -1 or personalmenu.closestDistance > 3.0 then
					ESX.ShowNotification("~r~Aucun joueur.")
				else
					TriggerServerEvent('bblutin_menu:Boss_destituerplayer2', GetPlayerServerId(personalmenu.closestPlayer))
				end
			else
				ESX.ShowNotification(_U('missing_rights'))
			end
		end
	end
end


local activerposition = true
function activpos()
	activerposition = not activerposition
	local pPed = GetPlayerPed(-1)
	if not activerposition then
		showcoord = true
	elseif activerposition then
		showcoord = false
	end
end

local supersprint = true
function activsupersprint()
	supersprint = not supersprint
	if not supersprint then
		SetRunSprintMultiplierForPlayer(PlayerId(),1.49)
		ESX.ShowNotification("~g~Super Sprint activé.")
	elseif supersprint then
		SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
		ESX.ShowNotification("~r~Super Sprint désactivé.")
	end
end

local superjump = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if superjump then
			SetSuperJumpThisFrame(PlayerId())
			ESX.ShowNotification("~g~Super Jump activé.")
		end
	end
end)

local deleteveh = false


-- Weapon Menu --

RegisterNetEvent("bblutin_menu:Weapon_addAmmoToPedC")
AddEventHandler("bblutin_menu:Weapon_addAmmoToPedC", function(value, quantity)
	local weaponHash = GetHashKey(value)

	if HasPedGotWeapon(plyPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
		AddAmmoToPed(plyPed, value, quantity)
	end
end)

-- Admin Menu --

RegisterNetEvent('bblutin_menu:Admin_BringC')
AddEventHandler('bblutin_menu:Admin_BringC', function(plyPedCoords)
	SetEntityCoords(plyPed, plyPedCoords)
end)

-- GOTO JOUEUR
function admin_tp_toplayer()
	local plyId = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local targetPlyCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(plyId)))
			SetEntityCoords(plyPed, targetPlyCoords)
		end
	end
end
-- FIN GOTO JOUEUR

-- TP UN JOUEUR A MOI
function admin_tp_playertome()
	local plyId = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			local plyPedCoords = GetEntityCoords(plyPed)
			TriggerServerEvent('bblutin_menu:Admin_BringS', plyId, plyPedCoords)
		end
	end
end
-- FIN TP UN JOUEUR A MOI

-- TP A POSITION
function admin_tp_pos()
	local pos = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_xyz'), "", 50)

	if pos ~= nil and pos ~= '' then
		local _, _, x, y, z = string.find(pos, "([%d%.]+) ([%d%.]+) ([%d%.]+)")

		if x ~= nil and y ~= nil and z ~= nil then
			SetEntityCoords(plyPed, x + .0, y + .0, z + .0)
		end
	end
end
-- FIN TP A POSITION

-- FONCTION NOCLIP 
function admin_no_clip()
	noclip = not noclip

	if noclip then
		SetEntityInvincible(plyPed, true)
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification("Noclip ~g~activé")
	else
		SetEntityInvincible(plyPed, false)
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification("Noclip ~r~désactivé")
	end
end

function getPosition()
	local x, y, z = table.unpack(GetEntityCoords(plyPed, true))

	return x, y, z
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(plyPed)
	local pitch = GetGameplayCamRelativePitch()

	local x = -math.sin(heading * math.pi/180.0)
	local y = math.cos(heading * math.pi/180.0)
	local z = math.sin(pitch * math.pi/180.0)

	local len = math.sqrt(x * x + y * y + z * z)

	if len ~= 0 then
		x = x/len
		y = y/len
		z = z/len
	end

	return x, y, z
end

function isNoclip()
	return noclip
end

-- GOD MODE
function admin_godmode()
	godmode = not godmode

	if godmode then
		SetEntityInvincible(plyPed, true)
		ESX.ShowNotification("~g~Godmode activé.")
	else
		SetEntityInvincible(plyPed, false)
		ESX.ShowNotification("~r~Godmode désactivé.")
	end
end
-- FIN GOD MODE

-- INVISIBLE
function admin_mode_fantome()
	invisible = not invisible

	if invisible then
		SetEntityVisible(plyPed, false, false)
		ESX.ShowNotification("~g~Invisibilité activé.")
	else
		SetEntityVisible(plyPed, true, false)
		ESX.ShowNotification("~r~Invisibilité désactivé.")
	end
end
-- FIN INVISIBLE

-- Réparer vehicule
function admin_vehicle_repair()
	local car = GetVehiclePedIsIn(plyPed, false)

	SetVehicleFixed(car)
	SetVehicleDirtLevel(car, 0.0)
end
-- FIN Réparer vehicule

-- Spawn vehicule
function admin_vehicle_spawn()
	local vehicleName = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_vehiclespawner'), "", 50)

	if vehicleName ~= nil then
		vehicleName = tostring(vehicleName)
		
		if type(vehicleName) == 'string' then
			local car = GetHashKey(vehicleName)
				
			Citizen.CreateThread(function()
				RequestModel(car)

				while not HasModelLoaded(car) do
					Citizen.Wait(0)
				end

				local x, y, z = table.unpack(GetEntityCoords(plyPed, true))

				local veh = CreateVehicle(car, x, y, z, 0.0, true, false)
				local id = NetworkGetNetworkIdFromEntity(veh)

				SetEntityVelocity(veh, 2000)
				SetVehicleOnGroundProperly(veh)
				SetVehicleHasBeenOwnedByPlayer(veh, true)
				SetNetworkIdCanMigrate(id, true)
				SetVehRadioStation(veh, "OFF")
				SetPedIntoVehicle(plyPed, veh, -1)
			end)
		end
	end
end
-- FIN Spawn vehicule

-- flipVehicle
function admin_vehicle_flip()
	local plyCoords = GetEntityCoords(plyPed)
	local closestCar = GetClosestVehicle(plyCoords['x'], plyCoords['y'], plyCoords['z'], 10.0, 0, 70)
	local plyCoords = plyCoords + vector3(0, 2, 0)

	SetEntityCoords(closestCar, plyCoords)

	ESX.ShowNotification("~g~Véhicule retourné.")
end
-- FIN flipVehicle

-- GIVE DE L'ARGENT
function admin_give_money()
	local amount = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('bblutin_menu:Admin_giveCash', amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT

-- GIVE DE L'ARGENT EN BANQUE
function admin_give_bank()
	local amount = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('bblutin_menu:Admin_giveBank', amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT EN BANQUE

-- GIVE DE L'ARGENT SALE
function admin_give_dirty()
	local amount = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_amount'), "", 8)

	if amount ~= nil then
		amount = tonumber(amount)
		
		if type(amount) == 'number' then
			TriggerServerEvent('bblutin_menu:Admin_giveDirtyMoney', amount)
		end
	end
end
-- FIN GIVE DE L'ARGENT SALE

-- Afficher Coord
function modo_showcoord()
	showcoord = not showcoord
end
-- FIN Afficher Coord

-- Afficher Nom
function modo_showname()
	showname = not showname
end
-- FIN Afficher Nom

-- TP MARKER
function admin_tp_marker()
	local WaypointHandle = GetFirstBlipInfoId(8)

	if DoesBlipExist(WaypointHandle) then
		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

		for height = 1, 1000 do
			SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end

		ESX.ShowNotification("~g~Téléportation effectuée.")
	else
		ESX.ShowNotification("~r~Aucun marqueur.")
	end
end
-- FIN TP MARKER

-- HEAL JOUEUR
function admin_heal_player()
	local plyId = KeyboardInput("FMMC_KEY_TIP1", _U('dialogbox_playerid'), "", 8)

	if plyId ~= nil then
		plyId = tonumber(plyId)
		
		if type(plyId) == 'number' then
			TriggerServerEvent('esx_ambulancejob:revive', plyId)
		end
	end
end
-- FIN HEAL JOUEUR

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if deleteveh then
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed, false)
			local vehicle   = ESX.Game.GetVehicleInDirection()
			if IsPedInAnyVehicle(playerPed, true) then
				vehicle = GetVehiclePedIsIn(playerPed, false)
			end
			local entity = vehicle
			NetworkRequestControlOfEntity(entity)
			SetEntityAsMissionEntity(entity, true, true)
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
			if (DoesEntityExist(entity)) then
				DeleteEntity(entity)
			end
		end
	end
end)

function AddMenuAdminMenu(menu)
	adminMenu = _menuPool:AddSubMenu(menu, _U('admin_title'), "", "", Menuthing, Menuthing)
	adminMenu.Item:RightLabel("→")
	adminMenu.SubMenu:SetMenuWidthOffset(10)

	if playerGroup == 'superadmin' or playerGroup == 'mod'or playerGroup == 'admin' then
		local openmenustaffpmenu = NativeUI.CreateItem("Menu staff", "")
		adminMenu.SubMenu:AddItem(openmenustaffpmenu)

		adminMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == openmenustaffpmenu then
				_menuPool:CloseAllMenus()
				Citizen.Wait(1)
				TriggerEvent('openmenustaff')
			end
		end
	end
end

function AddMenuPersoMenu(menu)
	persoMenu = _menuPool:AddSubMenu(menu, 'Divers', "", "", Menuthing, Menuthing)
	persoMenu.Item:RightLabel("→")
	persoMenu.SubMenu:SetMenuWidthOffset(10)

		local syncplayer = NativeUI.CreateItem("~g~Synchroniser mon personnage", "Sauvegarde votre dernière position")
		persoMenu.SubMenu:AddItem(syncplayer)
		local debugitem = NativeUI.CreateItem("Debug mon personnage", "Replace votre personnage a la dernière position sauvegardé")
		persoMenu.SubMenu:AddItem(debugitem)
		local opti = NativeUI.CreateItem("Optimiser son client FiveM", "Optimise votre client en effectuant des oppérations de nettoyage")
		persoMenu.SubMenu:AddItem(opti)
		local conseil = NativeUI.CreateItem("Conseil EscapeLife", "Quelques conseils utiles pour votre séjour sur EscapeLife")
		persoMenu.SubMenu:AddItem(conseil)

		persoMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == debugitem then
				_menuPool:CloseAllMenus()
				Citizen.Wait(1)
				TriggerEvent("playerSpawned")
				ESX.ShowNotification("~g~Débug : \n~w~Vous avez été replacé a votre dernière Position.", 25)
			elseif item == syncplayer then
				TriggerServerEvent('SavellPlayer')
				PlaySoundFrontend(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset", 0)
			elseif item == deconnect then
				TriggerServerEvent('SavellPlayer')
				ESX.ShowNotification("EscapeLife\n~r~Vous allez être déconnecté.")
				Citizen.Wait(3000)
				TriggerServerEvent("bblutin:deconnection")
			elseif item == opti then
				DoScreenFadeIn(2000)
				ESX.ShowColoredNotification("Optimisation de votre client en cours ...", 25)
				Citizen.Wait(2000)
				DoScreenFadeOut(2000)
				Citizen.Wait(4000)
				DoScreenFadeIn(1500)
				ClearAllBrokenGlass()
				ClearAllHelpMessages()
				LeaderboardsReadClearAll()
				ClearBrief()
				ClearGpsFlags()
				ClearPrints()
				ClearSmallPrints()
				ClearReplayStats()
				LeaderboardsClearCacheData()
				ClearFocus()
				ClearHdArea()
				ClearHelp()
				ClearNotificationsPos()
				ClearPedInPauseMenu()
				ClearFloatingHelp()
				ClearGpsPlayerWaypoint()
				ClearGpsRaceTrack()
				ClearReminderMessage()
				ClearThisPrint()
				print('Client FiveM optimisé.')
				ESX.ShowColoredNotification("✅ Optimisation effectuée.", 25)
				RemoveLoadingPrompt()
				Citizen.Wait(100)
				PlaySoundFrontend(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset", 0)
			elseif item == conseil then
				ESX.ShowHelpNotification('Conseil N°1: Dans les paramètres de votre jeu, baissez au maximum la densité & variété des PNJ.')
				Citizen.Wait(8000)
				ESX.ShowHelpNotification('Conseil N°2: Videz régulièrement le cache de votre FiveM.')
				Citizen.Wait(6000)
				ESX.ShowHelpNotification('Conseil N°3: Inutile de mettre vos paramètres au maximum, privilègiez la performance.')
				Citizen.Wait(7000)
				ESX.ShowHelpNotification('Conseil N°4: De temps en temps, allez sur le menu F3, puis Menu Divers et Optimiser votre FiveM.')
				Citizen.Wait(7000)
				ESX.ShowHelpNotification('Profitez-bien, bon jeu à vous sur EscapeLife !')
				Citizen.Wait(5000)
				ESX.ShowHelpNotification('Séquence de tutoriel terminée.')
				PlaySoundFrontend(-1, "Boss_Message_Orange", "GTAO_Boss_Goons_FM_Soundset", 0)
			end
		end
end

function AddMenuHUDMenu(menu)
	hudMenu = _menuPool:AddSubMenu(menu, 'Options', "", "", Menuthing, Menuthing)
	hudMenu.Item:RightLabel("→")
	hudMenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuHUDsMenu(hudMenu)
	AddSubMenuFiltresMenu(hudMenu)
end

function AddMenuAnimMenu(menu)
	animMenu = _menuPool:AddSubMenu(menu, 'Animations', "", "", Menuthing, Menuthing)
	animMenu.Item:RightLabel("→")
	animMenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuClassiqueMenu(animMenu)
	AddSubMenuPropsMenu(animMenu)
	--AddSubMenuSalutMenu(animMenu)
	--AddSubMenuSportMenu(animMenu)
	--AddSubMenuDiversMenu(animMenu)
end

function AddSubMenuClassiqueMenu(menu)
	classMenu = _menuPool:AddSubMenu(menu.SubMenu, 'Animations Classiques', "", "", Menuthing, Menuthing)
	classMenu.Item:RightLabel("→")
	classMenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuDanse1Menu(classMenu)
	AddSubMenuTravail1Menu(classMenu)

end

function AddSubMenuPropsMenu(menu)
	propsMenu = _menuPool:AddSubMenu(menu.SubMenu, 'Animations Props', "", "", Menuthing, Menuthing)
	propsMenu.Item:RightLabel("→")
	propsMenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuDanse2Menu(propsMenu)
	AddSubMenuDiver1Menu(propsMenu)
end

function AddSubMenuDanse1Menu(menu)
	danseMenu = _menuPool:AddSubMenu(menu.SubMenu, "Danses", "", "", Menuthing, Menuthing)
	danseMenu.Item:RightLabel('→')
	danseMenu.SubMenu:SetMenuWidthOffset(10)

	local danse1 = NativeUI.CreateItem("Danse 1", "/e dance")
	danseMenu.SubMenu:AddItem(danse1)
	local danse2 = NativeUI.CreateItem("Danse 2", "/e dance2")
	danseMenu.SubMenu:AddItem(danse2)
	local danse3 = NativeUI.CreateItem("Danse 3", "/e dance3")
	danseMenu.SubMenu:AddItem(danse3)
	local danse4 = NativeUI.CreateItem("Danse 4", "/e dance4")
	danseMenu.SubMenu:AddItem(danse4)
	local danse5 = NativeUI.CreateItem("Danse 5", "/e dance5")
	danseMenu.SubMenu:AddItem(danse5)
	local danse6 = NativeUI.CreateItem("Danse 6", "/e dance6")
	danseMenu.SubMenu:AddItem(danse6)
	local danse7 = NativeUI.CreateItem("Danse 7", "/e dance7")
	danseMenu.SubMenu:AddItem(danse7)
	local danse8 = NativeUI.CreateItem("Danse 8", "/e dance8")
	danseMenu.SubMenu:AddItem(danse8)
	local danse9 = NativeUI.CreateItem("Danse 9", "/e dance9")
	danseMenu.SubMenu:AddItem(danse9)
	local danse10 = NativeUI.CreateItem("Danse Femme 1", "/e dancef")
	danseMenu.SubMenu:AddItem(danse10)
	local danse11 = NativeUI.CreateItem("Danse Femme 2", "/e dancef2")
	danseMenu.SubMenu:AddItem(danse11)
	local danse12 = NativeUI.CreateItem("Danse Femme 3", "/e dancef3")
	danseMenu.SubMenu:AddItem(danse12)
	local danse13 = NativeUI.CreateItem("Danse Femme 4", "/e dancef4")
	danseMenu.SubMenu:AddItem(danse13)
	local danse14 = NativeUI.CreateItem("Danse Femme 5", "/e dancef5")
	danseMenu.SubMenu:AddItem(danse14)
	local danse15 = NativeUI.CreateItem("Danse Femme 6", "/e dancef6")
	danseMenu.SubMenu:AddItem(danse15)

    danseMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == danse1 then
			ExecuteCommand('e dance')
		elseif item == danse2 then
			ExecuteCommand('e dance2')
		elseif item == danse3 then
			ExecuteCommand('e dance3')
		elseif item == danse4 then
			ExecuteCommand('e dance4')
		elseif item == danse5 then
			ExecuteCommand('e dance5')
		elseif item == danse6 then
			ExecuteCommand('e dance6')
		elseif item == danse7 then
			ExecuteCommand('e dance7')
		elseif item == danse8 then
			ExecuteCommand('e dance8')
		elseif item == danse9 then
			ExecuteCommand('e dance9')
		elseif item == danse10 then
			ExecuteCommand('e dancef')
		elseif item == danse11 then
			ExecuteCommand('e dancef2')
		elseif item == danse12 then
			ExecuteCommand('e dancef3')
		elseif item == danse13 then
			ExecuteCommand('e dancef4')
		elseif item == danse14 then
			ExecuteCommand('e dancef5')
		elseif item == danse15 then
			ExecuteCommand('e dancef6')
        end
    end

end

function AddSubMenuDanse2Menu(menu)
	danse2Menu = _menuPool:AddSubMenu(menu.SubMenu, "Danses", "", "", Menuthing, Menuthing)
	danse2Menu.Item:RightLabel('→')
	danse2Menu.SubMenu:SetMenuWidthOffset(10)

	local danse1 = NativeUI.CreateItem("Danse Batonnets 1", "/e danceglowstick")
	danse2Menu.SubMenu:AddItem(danse1)
	local danse2 = NativeUI.CreateItem("Danse Batonnets 2", "/e danceglowstick2")
	danse2Menu.SubMenu:AddItem(danse2)
	local danse3 = NativeUI.CreateItem("Danse Batonnets 3", "/e danceglowstick3")
	danse2Menu.SubMenu:AddItem(danse3)
	local danse4 = NativeUI.CreateItem("Danse Cheval 1", "/e dancehorse")
	danse2Menu.SubMenu:AddItem(danse4)
	local danse5 = NativeUI.CreateItem("Danse Cheval 2", "/e dancehorse2")
	danse2Menu.SubMenu:AddItem(danse5)
	local danse6 = NativeUI.CreateItem("Danse Cheval 3", "/e dancehorse3")
	danse2Menu.SubMenu:AddItem(danse6)

    danse2Menu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == danse1 then
			ExecuteCommand('e danceglowstick')
		elseif item == danse2 then
			ExecuteCommand('e danceglowstick2')
		elseif item == danse3 then
			ExecuteCommand('e danceglowstick3')
		elseif item == danse4 then
			ExecuteCommand('e dancehorse')
		elseif item == danse5 then
			ExecuteCommand('e dancehorse2')
		elseif item == danse6 then
			ExecuteCommand('e dancehorse3')
        end
    end

end

function AddSubMenuDiver1Menu(menu)
	danse2Menu = _menuPool:AddSubMenu(menu.SubMenu, "Danses", "", "", Menuthing, Menuthing)
	danse2Menu.Item:RightLabel('→')
	danse2Menu.SubMenu:SetMenuWidthOffset(10)

	local danse1 = NativeUI.CreateItem("Danse Batonnets 1", "/e danceglowstick")
	danse2Menu.SubMenu:AddItem(danse1)
	local danse2 = NativeUI.CreateItem("Danse Batonnets 2", "/e danceglowstick2")
	danse2Menu.SubMenu:AddItem(danse2)
	local danse3 = NativeUI.CreateItem("Danse Batonnets 3", "/e danceglowstick3")
	danse2Menu.SubMenu:AddItem(danse3)
	local danse4 = NativeUI.CreateItem("Danse Cheval 1", "/e dancehorse")
	danse2Menu.SubMenu:AddItem(danse4)
	local danse5 = NativeUI.CreateItem("Danse Cheval 2", "/e dancehorse2")
	danse2Menu.SubMenu:AddItem(danse5)
	local danse6 = NativeUI.CreateItem("Danse Cheval 3", "/e dancehorse3")
	danse2Menu.SubMenu:AddItem(danse6)

    danse2Menu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == danse1 then
			ExecuteCommand('e danceglowstick')
		elseif item == danse2 then
			ExecuteCommand('e danceglowstick2')
		elseif item == danse3 then
			ExecuteCommand('e danceglowstick3')
		elseif item == danse4 then
			ExecuteCommand('e dancehorse')
		elseif item == danse5 then
			ExecuteCommand('e dancehorse2')
		elseif item == danse6 then
			ExecuteCommand('e dancehorse3')
        end
    end

end

function AddSubMenuTravail1Menu(menu)
	travail1Menu = _menuPool:AddSubMenu(menu.SubMenu, "Travail", "", "", Menuthing, Menuthing)
	travail1Menu.Item:RightLabel('→')
	travail1Menu.SubMenu:SetMenuWidthOffset(10)

	local danse1 = NativeUI.CreateItem("Lire des notes", "/e clipboard2")
	travail1Menu.SubMenu:AddItem(danse1)
	local danse2 = NativeUI.CreateItem("Police 1", "/e cop")
	travail1Menu.SubMenu:AddItem(danse2)
	local danse3 = NativeUI.CreateItem("Police 2", "/e cop2")
	travail1Menu.SubMenu:AddItem(danse3)
	local danse4 = NativeUI.CreateItem("Police Circulation", "/e copbeacon")
	travail1Menu.SubMenu:AddItem(danse4)
	local danse5 = NativeUI.CreateItem("EMS 1", "/e cpr")
	travail1Menu.SubMenu:AddItem(danse5)
	local danse6 = NativeUI.CreateItem("EMS 2", "/e cpr2")
	travail1Menu.SubMenu:AddItem(danse6)
	local danse7 = NativeUI.CreateItem("Marteau", "/e hammer")
	travail1Menu.SubMenu:AddItem(danse7)
	local danse8 = NativeUI.CreateItem("Balais", "/e janitor")
	travail1Menu.SubMenu:AddItem(danse8)
	local danse9 = NativeUI.CreateItem("Inspecter", "/e inspect")
	travail1Menu.SubMenu:AddItem(danse9)
	local danse10 = NativeUI.CreateItem("Souffleuse", "/e leafblower")
	travail1Menu.SubMenu:AddItem(danse10)
	local danse11 = NativeUI.CreateItem("Nettoyer", "/e maid")
	travail1Menu.SubMenu:AddItem(danse11)
	local danse12 = NativeUI.CreateItem("Réparer", "/e mechanic")
	travail1Menu.SubMenu:AddItem(danse12)
	local danse13 = NativeUI.CreateItem("Holster", "/e reaching")
	travail1Menu.SubMenu:AddItem(danse13)
	local danse14 = NativeUI.CreateItem("Ordinateur", "/e type3")
	travail1Menu.SubMenu:AddItem(danse14)
	local danse15 = NativeUI.CreateItem("Souder", "/e weld")
	travail1Menu.SubMenu:AddItem(danse15)

    travail1Menu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == danse1 then
			ExecuteCommand('e clipboard2')
		elseif item == danse2 then
			ExecuteCommand('e cop')
		elseif item == danse3 then
			ExecuteCommand('e cop2')
		elseif item == danse4 then
			ExecuteCommand('e copbeacon')
		elseif item == danse5 then
			ExecuteCommand('e cpr')
		elseif item == danse6 then
			ExecuteCommand('e cpr2')
		elseif item == danse7 then
			ExecuteCommand('e hammer')
		elseif item == danse8 then
			ExecuteCommand('e janitor')
		elseif item == danse9 then
			ExecuteCommand('e inspect')
		elseif item == danse10 then
			ExecuteCommand('e leafblower')
		elseif item == danse11 then
			ExecuteCommand('e maid')
		elseif item == danse12 then
			ExecuteCommand('e mechanic')
		elseif item == danse13 then
			ExecuteCommand('e reaching')
		elseif item == danse14 then
			ExecuteCommand('e type3')
		elseif item == danse15 then
			ExecuteCommand('e weld')
        end
    end

end

function AddSubMenuHUDsMenu(menu)
	hudsMenu = _menuPool:AddSubMenu(menu.SubMenu, "HUD", "", "", Menuthing, Menuthing)
	hudsMenu.Item:RightLabel('→')
	hudsMenu.SubMenu:SetMenuWidthOffset(10)

	local nomap = NativeUI.CreateCheckboxItem("Cacher le GPS", map, "")
	hudsMenu.SubMenu:AddItem(nomap)
	local nostatus = NativeUI.CreateCheckboxItem("Cacher la Faim/Soif", status, "")
	hudsMenu.SubMenu:AddItem(nostatus)
	local cinmode = NativeUI.CreateCheckboxItem("Mode cinématique", cin, "")
	hudsMenu.SubMenu:AddItem(cinmode)

    hudsMenu.SubMenu.OnCheckboxChange = function(sender, item, checked_)
		if item == nomap then
			if checked_ then
				DisplayRadar(false)
			else
				DisplayRadar(true)
			end
		elseif item == nostatus then
			if checked_ then
				TriggerEvent('esx_status:setDisplay', 0.0)
			else
				TriggerEvent('esx_status:setDisplay', 1.0)
			end
		elseif item == cinmode then
			if checked_ then
				SendNUIMessage({openCinema = true})
				ESX.UI.HUD.SetDisplay(0.0)
				TriggerEvent('esx_status:setDisplay', 0.0)
				DisplayRadar(false)
				TriggerEvent('ui:toggle', false)
			else
				SendNUIMessage({openCinema = false})
				ESX.UI.HUD.SetDisplay(1.0)
				TriggerEvent('esx_status:setDisplay', 1.0)
				DisplayRadar(true)
				TriggerEvent('ui:toggle', true)
			end
        end
    end

end

function AddSubMenuFiltresMenu(menu)
	filMenu = _menuPool:AddSubMenu(menu.SubMenu, 'Filtres', "", "", Menuthing, Menuthing)
	filMenu.Item:RightLabel("→")
	filMenu.SubMenu:SetMenuWidthOffset(10)

	local default = NativeUI.CreateItem("~g~Par défaut","Restaurer les couleurs par défaut")
	filMenu.SubMenu:AddItem(default)

	-- AddSubMenuContrasteMenu(filMenu)
	-- AddSubMenuFinDuMondeMenu(filMenu)
	-- AddSubMenuBrouillardMenu(filMenu)
	AddSubMenuAmplifiMenu(filMenu)
	AddSubMenuColorMenu(filMenu)

	filMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == default then
			SetTimecycleModifier('default')
		end
	end


end

function AddSubMenuColorMenu(menu)
	colMenu = _menuPool:AddSubMenu(menu.SubMenu, 'Couleurs', "", "", Menuthing, Menuthing)
	colMenu.Item:RightLabel("→")
	colMenu.SubMenu:SetMenuWidthOffset(10)

		local col1 = NativeUI.CreateItem("Noir et Blanc","")
		colMenu.SubMenu:AddItem(col1)
		local col2 = NativeUI.CreateItem("Violet et Bleu","")
		colMenu.SubMenu:AddItem(col2)
		local col3 = NativeUI.CreateItem("Rouge","")
		colMenu.SubMenu:AddItem(col3)
		local col4 = NativeUI.CreateItem("Sous l'Eau","")
		colMenu.SubMenu:AddItem(col4)

		colMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == col1 then
				SetTimecycleModifier('rply_saturation_neg')
			elseif item == col2 then
				SetTimecycleModifier('PPPurple01')
			elseif item == col3 then
				SetTimecycleModifier('li')
			elseif item == col4 then
				SetTimecycleModifier('SALTONSEA')
			end
		end
end

function AddSubMenuAmplifiMenu(menu)
	vueMenu = _menuPool:AddSubMenu(menu.SubMenu, 'Vue / Couleur Amplifie', "", "", Menuthing, Menuthing)
	vueMenu.Item:RightLabel("→")
	vueMenu.SubMenu:SetMenuWidthOffset(10)

		local vue1 = NativeUI.CreateItem("Vue & lumières améliorées","")
		vueMenu.SubMenu:AddItem(vue1)
		local vue2 = NativeUI.CreateItem("Couleurs amplifiées","")
		vueMenu.SubMenu:AddItem(vue2)
		local vue3 = NativeUI.CreateItem("Couleurs amplifiées 2","")
		vueMenu.SubMenu:AddItem(vue3)

		vueMenu.SubMenu.OnItemSelect = function(sender, item, index)
			if item == vue1 then
				SetTimecycleModifier('Tunnel')
			elseif item == vue2 then
				SetTimecycleModifier('rply_saturation')
			elseif item == vue3 then
				SetTimecycleModifier('BombCamFlash')
			end
		end
end

function AddMenuAdminMenu1(menu)
	adminMenu1 = _menuPool:AddSubMenu(menu, _U('admin_title'), "", "", Menuthing, Menuthing)
	adminMenu1.Item:RightLabel("→")
	adminMenu1.SubMenu:SetMenuWidthOffset(10)

	if playerGroup == 'superadmin' or playerGroup == 'owner' then
		local tptoPlrItem = NativeUI.CreateItem(_U('admin_goto_button'), "")
		adminMenu1.SubMenu:AddItem(tptoPlrItem)
		local tptoMeItem = NativeUI.CreateItem(_U('admin_bring_button'), "")
		adminMenu1.SubMenu:AddItem(tptoMeItem)
		--local tptoXYZItem = NativeUI.CreateItem(_U('admin_tpxyz_button'), "")
		--adminMenu1.SubMenu:AddItem(tptoXYZItem)
		local noclipItem = NativeUI.CreateItem(_U('admin_noclip_button'), "")
		adminMenu1.SubMenu:AddItem(noclipItem)
		local godmodeItem = NativeUI.CreateItem(_U('admin_godmode_button'), "")
		adminMenu1.SubMenu:AddItem(godmodeItem)
		local ghostmodeItem = NativeUI.CreateItem(_U('admin_ghostmode_button'), "")
		adminMenu1.SubMenu:AddItem(ghostmodeItem)
		local spawnVehItem = NativeUI.CreateItem(_U('admin_spawnveh_button'), "")
		adminMenu1.SubMenu:AddItem(spawnVehItem)
		local repairVehItem = NativeUI.CreateItem(_U('admin_repairveh_button'), "")
		adminMenu1.SubMenu:AddItem(repairVehItem)
		local returnVehItem = NativeUI.CreateItem(_U('admin_flipveh_button'), "")
		adminMenu1.SubMenu:AddItem(returnVehItem)
		local givecashItem = NativeUI.CreateItem(_U('admin_givemoney_button'), "")
		adminMenu1.SubMenu:AddItem(givecashItem)
		local givebankItem = NativeUI.CreateItem(_U('admin_givebank_button'), "")
		adminMenu1.SubMenu:AddItem(givebankItem)
		local givedirtyItem = NativeUI.CreateItem(_U('admin_givedirtymoney_button'), "")
		adminMenu1.SubMenu:AddItem(givedirtyItem)
		local showXYZItem = NativeUI.CreateItem(_U('admin_showxyz_button'), "")
		adminMenu1.SubMenu:AddItem(showXYZItem)
		local showPlrNameItem = NativeUI.CreateItem(_U('admin_showname_button'), "")
		adminMenu1.SubMenu:AddItem(showPlrNameItem)
		local tptoWaypointItem = NativeUI.CreateItem(_U('admin_tpmarker_button'), "")
		adminMenu1.SubMenu:AddItem(tptoWaypointItem)
		local revivePlrItem = NativeUI.CreateItem(_U('admin_revive_button'), "")
		adminMenu1.SubMenu:AddItem(revivePlrItem)
		local skinPlrItem = NativeUI.CreateItem(_U('admin_changeskin_button'), "")
		adminMenu1.SubMenu:AddItem(skinPlrItem)
		local saveSkinPlrItem = NativeUI.CreateItem(_U('admin_saveskin_button'), "")
		adminMenu1.SubMenu:AddItem(saveSkinPlrItem)
		local superjump = NativeUI.CreateItem(("Super Jump"), "")
		adminMenu1.SubMenu:AddItem(superjump)
		local supersprint = NativeUI.CreateItem(("Super Sprint"), "")
		adminMenu1.SubMenu:AddItem(supersprint)
		local activeadminpistol = NativeUI.CreateItem(("Gravity Pistol"), "")
		adminMenu1.SubMenu:AddItem(activeadminpistol)

		adminMenu1.SubMenu.OnItemSelect = function(sender, item, index)
			if item == tptoPlrItem then
				admin_tp_toplayer()
				--_menuPool:CloseAllMenus()
			elseif item == suppobjet then 
				local entity = GetClosestObject(GetEntityCoords(GetPlayerPed(-1)), 6.0)
				DeleteEntity(entity)
 			elseif item == tptoMeItem then
				admin_tp_playertome()
			elseif item == suppvehboucle then 
				deleteveh = true
				ESX.ShowNotification("~g~Suppression activé.")
			elseif item == asuppvehboucle then 
				deleteveh = false
				ESX.ShowNotification("~r~Suppression désactivé.")
			elseif item == supersprint then 
				activsupersprint()
			elseif item == superjump then
				superjump = true
			--_menuPool:CloseAllMenus()
			--elseif item == tptoXYZItem then
				--admin_tp_pos()
				--_menuPool:CloseAllMenus()
			elseif item == noclipItem then
				admin_no_clip()
				--_menuPool:CloseAllMenus()
			elseif item == godmodeItem then
				admin_godmode()
			elseif item == ghostmodeItem then
				admin_mode_fantome()
			elseif item == activeadminpistol then 
				TriggerEvent("actiuvepistolgravity")
			elseif item == spawnVehItem then
				admin_vehicle_spawn()
				_menuPool:CloseAllMenus()
			elseif item == repairVehItem then
				admin_vehicle_repair()
			elseif item == returnVehItem then
				admin_vehicle_flip()
			elseif item == givecashItem then
				admin_give_money()
				--_menuPool:CloseAllMenus()
			elseif item == givebankItem then
				admin_give_bank()
				--_menuPool:CloseAllMenus()
			elseif item == givedirtyItem then
				admin_give_dirty()
				--_menuPool:CloseAllMenus()
			elseif item == showXYZItem then
				activpos()
			elseif item == showPlrNameItem then
				modo_showname()
			elseif item == tptoWaypointItem then
				admin_tp_marker()
			elseif item == revivePlrItem then
				admin_heal_player()
				--_menuPool:CloseAllMenus()
			elseif item == skinPlrItem then
				changer_skin()
			elseif item == saveSkinPlrItem then
				save_skin()
			end
		end
	end
end

function AddSubMenuAccessoryMenu(menu)
	accessoryMenu = _menuPool:AddSubMenu(menu.SubMenu, "Accessoires", "", "", Menuthing, Menuthing)
	accessoryMenu.Item:RightLabel("→")
	accessoryMenu.SubMenu:SetMenuWidthOffset(10)

	local earsItem = NativeUI.CreateItem("Accessories d'oreilles", "")
	accessoryMenu.SubMenu:AddItem(earsItem)
	local glassesItem = NativeUI.CreateItem("Lunettes", "")
	accessoryMenu.SubMenu:AddItem(glassesItem)
	local helmetItem = NativeUI.CreateItem("Chapeau", "")
	accessoryMenu.SubMenu:AddItem(helmetItem)
	local maskItem = NativeUI.CreateItem("Masque", "")
	accessoryMenu.SubMenu:AddItem(maskItem)

	accessoryMenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == earsItem then
			SetUnsetAccessory('Ears')
		elseif item == glassesItem then
			SetUnsetAccessory('Glasses')
		elseif item == helmetItem then
			SetUnsetAccessory('Helmet')
		elseif item == maskItem then
			SetUnsetAccessory('Mask')
		end
	end
end


function GeneratePersonalMenu()	
	AddMenubarre1Menu(mainMenu)
	AddMenuWeaponMenu(mainMenu)
	AddMenuWalletMenu(mainMenu)
	AddMenuAnimMenu(mainMenu)

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'capitaine' then
		AddMenuBossMenu(mainMenu)
	end

	if Config.doublejob then
		if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
			AddMenuBossMenu2(mainMenu)
		end
	end

	AddMenuPersoMenu(mainMenu)
	AddMenuHUDMenu(mainMenu)

	if playerGroup ~= nil and (playerGroup == 'mod' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
		AddMenuAdminMenu1(mainMenu)
	end
	Deconnection(mainMenu)

	_menuPool:RefreshIndex()
end

function Deconnection(menu) 
    local click = NativeUI.CreateItem("~r~Se déconnecter", "Êtes vous sûr ?")
    menu:AddItem(click)
    menu.OnItemSelect = function(sender, item, index)
        if item == click then
            TriggerServerEvent('SavellPlayer')
			ESX.ShowNotification("EscapeLife\n~r~Vous allez être déconnecté.")
			Citizen.Wait(3000)
			TriggerServerEvent("bblutin:deconnection")
        end
    end
end

function AddMenubarre1Menu(menu)
	inventorymenu = _menuPool:AddSubMenu(menu, _U('inventory_title'), "", "", Menuthing, Menuthing)
	inventorymenu.Item:RightLabel("→")
	inventorymenu.SubMenu:SetMenuWidthOffset(10)

	AddSubMenuClothesMenu(inventorymenu)
	AddSubMenuAccessoryMenu(inventorymenu)
end


function SetUnsetAccessory(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == 'ears' then
				elseif _accessory == "glasses" then
					mAccessory = 0
					startAnimAction("clothingspecs", "try_glasses_positive_a")
					Citizen.Wait(1000)
					ClearPedTasks(plyPed)
				elseif _accessory == 'helmet' then
					startAnimAction("missfbi4", "takeoff_mask")
					Citizen.Wait(1000)
					ClearPedTasks(plyPed)
				elseif _accessory == "mask" then
					mAccessory = 0
					startAnimAction("missfbi4", "takeoff_mask")
					Citizen.Wait(850)
					ClearPedTasks(plyPed)
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			if _accessory == 'ears' then
				ESX.ShowNotification("Accessoires\n~r~Pas d'accessoire d'oreilles.")
			elseif _accessory == 'glasses' then
				ESX.ShowNotification("Accessoires\n~r~Pas de lunettes.")
			elseif _accessory == 'helmet' then
				ESX.ShowNotification("Accessoires\n~r~Pas de chapeau.")
			elseif _accessory == 'mask' then
				ESX.ShowNotification("Accessoires\n~r~Pas de masque.")
			end
		end

	end, accessory)
end

Citizen.CreateThread(function()
	while true do
		if IsControlJustReleased(0, Config.Menu.clavier) and not isDead then
			if mainMenu ~= nil and not mainMenu:Visible() then
				ESX.PlayerData = ESX.GetPlayerData()
				GeneratePersonalMenu()
				mainMenu:Visible(true)
				Citizen.Wait(10)
			end
		end
		
		Citizen.Wait(0)
	end
end)

RegisterKeyMapping('+openmenu', 'Ouvrir le menu personnel (F3)', 'keyboard', 'f3')


RegisterCommand('+openmenu', function()
	if mainMenu ~= nil and not mainMenu:Visible() then
		ESX.PlayerData = ESX.GetPlayerData()
		GeneratePersonalMenu()
		mainMenu:Visible(true)
		Citizen.Wait(10)
	end
end)

Citizen.CreateThread(function()
	while true do
		if _menuPool ~= nil then
			_menuPool:ProcessMenus()
		end
		
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		while _menuPool ~= nil and _menuPool:IsAnyMenuOpen() do
			Citizen.Wait(0)

			if not _menuPool:IsAnyMenuOpen() then
				mainMenu:Clear()
				itemMenu:Clear()
				weaponItemMenu:Clear()

				_menuPool:Clear()
				_menuPool:Remove()

				personalmenu = {}

				invItem = {}
				wepItem = {}
				billItem = {}

				collectgarbage()

				_menuPool = NativeUI.CreatePool()

				mainMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('mainmenu_subtitle'), 0, 0, Menuthing, Menuthing)
				mainMenu:SetMenuWidthOffset(10)
				itemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('inventory_actions_subtitle'), 0, 0, Menuthing, Menuthing)
				itemMenu:SetMenuWidthOffset(10)
				weaponItemMenu = NativeUI.CreateMenu(GetPlayerName(PlayerId()), _U('loadout_actions_subtitle'), 0, 0, Menuthing, Menuthing)
				weaponItemMenu:SetMenuWidthOffset(10)
				_menuPool:Add(mainMenu)
				_menuPool:Add(itemMenu)
				_menuPool:Add(weaponItemMenu)
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		if ESX ~= nil then
			ESX.TriggerServerCallback('bblutin_menu:Admin_getUsergroup', function(group) playerGroup = group end)

			Citizen.Wait(30 * 1000)
		else
			Citizen.Wait(100)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		plyPed = PlayerPedId()
		
		if IsControlJustReleased(0, Config.stopAnim.clavier) and GetLastInputMethod(2) and not isDead then
			ClearPedTasks(plyPed)
		end

		if playerGroup ~= nil and (playerGroup == 'mod' or playerGroup == 'admin' or playerGroup == 'superadmin' or playerGroup == 'owner') then
			if IsControlPressed(1, Config.TPMarker.clavier1) and IsControlJustReleased(1, Config.TPMarker.clavier2) and GetLastInputMethod(2) and not isDead then
				admin_tp_marker()
			end
		end

		if showcoord then
			local playerPos = GetEntityCoords(plyPed)
			local playerHeading = GetEntityHeading(plyPed)
			Text("~r~X~s~: " .. playerPos.x .. " ~b~Y~s~: " .. playerPos.y .. " ~g~Z~s~: " .. playerPos.z .. " ~y~Angle~s~: " .. playerHeading)
		end

		if noclip then
			local x, y, z = getPosition()
			local dx, dy, dz = getCamDirection()
			local speed = 2.5

			SetEntityVelocity(plyPed, 0.0001, 0.0001, 0.0001)

			if IsControlPressed(0, 32) then
				x = x + speed * dx
				y = y + speed * dy
				z = z + speed * dz
			end

			if IsControlPressed(0, 269) then
				x = x - speed * dx
				y = y - speed * dy
				z = z - speed * dz
			end

			SetEntityCoordsNoOffset(plyPed, x, y, z, true, true, true)
		end

		if showname then
			for id = 0, 256 do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= plyPed then
					local headId = Citizen.InvokeNative(0xBFEFE3321A3F5015, GetPlayerPed(id), (GetPlayerServerId(id) .. ' - ' .. GetPlayerName(id)), false, false, "", false)
				end
			end
		end
		
		Citizen.Wait(0)
	end
end)