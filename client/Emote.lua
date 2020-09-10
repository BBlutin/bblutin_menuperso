-- You probably shouldnt touch these.
local AnimationDuration = -1
local ChosenAnimation = ""
local ChosenDict = ""
local IsInAnimation = false
local MostRecentChosenAnimation = ""
local MostRecentChosenDict = ""
local MovementType = 0
local PlayerGender = "male"
local PlayerHasProp = false
local PlayerProps = {}
local PlayerParticles = {}
local SecondPropEmote = false
local lang = Config.MenuLanguage
local PtfxNotif = false
local PtfxPrompt = false
local PtfxWait = 500
local PtfxNoProp = false
local isInRagdoll = false


Citizen.CreateThread(function()
  while true do
     Citizen.Wait(10)
     if isInRagdoll then
       SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
     end
   end
 end)
 
 Citizen.CreateThread(function()
     while true do
     Citizen.Wait(0)
     if IsControlJustPressed(2, Config.RagdollKeybind) and Config.RagdollEnabled and IsPedOnFoot(PlayerPedId()) then
         if isInRagdoll then
             isInRagdoll = false
         else
             isInRagdoll = true
             Wait(500)
         end
     end
   end
 end)

function WalkMenuStart(name)
  RequestWalking(name)
  SetPedMovementClipset(PlayerPedId(), name, 0.2)
  RemoveAnimSet(name)
end

function RequestWalking(set)
  RequestAnimSet(set)
  while not HasAnimSetLoaded(set) do
    Citizen.Wait(1)
  end 
end

function WalksOnCommand(source, args, raw)
  local WalksCommand = ""
  for a in pairsByKeys(DP.Walks) do
    WalksCommand = WalksCommand .. ""..string.lower(a)..", "
  end
  EmoteChatMessage(WalksCommand)
  EmoteChatMessage("To reset do /walk reset")
end

function WalkCommandStart(source, args, raw)
  local name = firstToUpper(args[1])

  if name == "Reset" then
      ResetPedMovementClipset(PlayerPedId()) return
  end

  local name2 = table.unpack(DP.Walks[name])
  if name2 ~= nil then
    WalkMenuStart(name2)
  else
    EmoteChatMessage("'"..name.."' is not a valid walk")
  end
end

Citizen.CreateThread(function()
  while true do

    if IsPedShooting(PlayerPedId()) and IsInAnimation then
      EmoteCancel()
    end

    if PtfxPrompt then
      if not PtfxNotif then
          SimpleNotify(PtfxInfo)
          PtfxNotif = true
      end
      if IsControlPressed(0, 47) then
        PtfxStart()
        Wait(PtfxWait)
        PtfxStop()
      end
    end

    if Config.EnableXtoCancel then if (IsControlPressed(0, 73) or IsControlPressed(0, 200))then EmoteCancel() end end
    Citizen.Wait(1)
  end
end)

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/e', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
    TriggerEvent('chat:addSuggestion', '/e', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
    TriggerEvent('chat:addSuggestion', '/emote', 'Play an emote', {{ name="emotename", help="dance, camera, sit or any valid emote."}})
    if Config.SqlKeybinding then
      TriggerEvent('chat:addSuggestion', '/emotebind', 'Bind an emote', {{ name="key", help="num4, num5, num6, num7. num8, num9. Numpad 4-9!"}, { name="emotename", help="dance, camera, sit or any valid emote."}})
      TriggerEvent('chat:addSuggestion', '/emotebinds', 'Check your currently bound emotes.')
    end
    TriggerEvent('chat:addSuggestion', '/emotemenu', 'Open dpemotes menu (F3) by default.')
    TriggerEvent('chat:addSuggestion', '/emotes', 'List available emotes.')
    TriggerEvent('chat:addSuggestion', '/walk', 'Set your walkingstyle.', {{ name="style", help="/walks for a list of valid styles"}})
    TriggerEvent('chat:addSuggestion', '/walks', 'List available walking styles.')
end)

RegisterCommand('e', function(source, args, raw) EmoteCommandStart(source, args, raw) end)
RegisterCommand('emote', function(source, args, raw) EmoteCommandStart(source, args, raw) end)
if Config.SqlKeybinding then
  RegisterCommand('emotebind', function(source, args, raw) EmoteBindStart(source, args, raw) end)
  RegisterCommand('emotebinds', function(source, args, raw) EmoteBindsStart(source, args, raw) end)
end
RegisterCommand('emotemenu', function(source, args, raw) OpenEmoteMenu() end)
RegisterCommand('emotes', function(source, args, raw) EmotesOnCommand() end)
RegisterCommand('walk', function(source, args, raw) WalkCommandStart(source, args, raw) end)
RegisterCommand('walks', function(source, args, raw) WalksOnCommand() end)

AddEventHandler('onResourceStop', function(resource)
  if resource == GetCurrentResourceName() then
    DestroyAllProps()
    ClearPedTasksImmediately(GetPlayerPed(-1))
    ResetPedMovementClipset(PlayerPedId())
  end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteCancel()

  if ChosenDict == "MaleScenario" and IsInAnimation then
    ClearPedTasksImmediately(PlayerPedId())
    IsInAnimation = false
    DebugPrint("Forced scenario exit")
  elseif ChosenDict == "Scenario" and IsInAnimation then
    ClearPedTasksImmediately(PlayerPedId())
    IsInAnimation = false
    DebugPrint("Forced scenario exit")
  end

  PtfxNotif = false
  PtfxPrompt = false

  if IsInAnimation then
    PtfxStop()
    ClearPedTasks(GetPlayerPed(-1))
    DestroyAllProps()
    IsInAnimation = false
  end
end

function EmoteChatMessage(args)
  if args == display then
    TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format(""))
  else
    TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format(""..args..""))
  end
end

function DebugPrint(args)
  if Config.DebugDisplay then
    print(args)
  end
end

function PtfxStart()
    if PtfxNoProp then
      PtfxAt = PlayerPedId()
    else
      PtfxAt = prop
    end
    UseParticleFxAssetNextCall(PtfxAsset)
    Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtfxName, PtfxAt, Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, GetEntityBoneIndexByName(PtfxName, "VFX"), 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
    SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0)
    table.insert(PlayerParticles, Ptfx)
end

function PtfxStop()
  for a,b in pairs(PlayerParticles) do
    DebugPrint("Stopped PTFX: "..b)
    StopParticleFxLooped(b, false)
    table.remove(PlayerParticles, a)
  end
end

function EmotesOnCommand(source, args, raw)
  local EmotesCommand = ""
  for a in pairsByKeys(DP.Emotes) do
    EmotesCommand = EmotesCommand .. ""..a..", "
  end
  EmoteChatMessage(EmotesCommand)
  EmoteChatMessage(Config.Languages[lang]['emotemenucmd'])
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function EmoteMenuStart(args, hard)
    local name = args
    local etype = hard

    if etype == "dances" then
        if DP.Dances[name] ~= nil then
          if OnEmotePlay(DP.Dances[name]) then end
        end
    elseif etype == "props" then
        if DP.PropEmotes[name] ~= nil then
          if OnEmotePlay(DP.PropEmotes[name]) then end
        end
    elseif etype == "emotes" then
        if DP.Emotes[name] ~= nil then
          if OnEmotePlay(DP.Emotes[name]) then end
        else
          if name ~= "🕺 Dance Emotes" then end
        end
    elseif etype == "expression" then
        if DP.Expressions[name] ~= nil then
          if OnEmotePlay(DP.Expressions[name]) then end
        end
    end
end

function EmoteCommandStart(source, args, raw)
    if #args > 0 then
    local name = string.lower(args[1])
    if name == "c" then
        if IsInAnimation then
            EmoteCancel()
        else
            EmoteChatMessage(Config.Languages[lang]['nocancel'])
        end
      return
    elseif name == "help" then
      EmotesOnCommand()
    return end

    if DP.Emotes[name] ~= nil then
      if OnEmotePlay(DP.Emotes[name]) then end return
    elseif DP.Dances[name] ~= nil then
      if OnEmotePlay(DP.Dances[name]) then end return
    elseif DP.PropEmotes[name] ~= nil then
      if OnEmotePlay(DP.PropEmotes[name]) then end return
    else
      EmoteChatMessage("'"..name.."' "..Config.Languages[lang]['notvalidemote'].."")
    end
  end
end

function LoadAnim(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

function LoadPropDict(model)
  while not HasModelLoaded(GetHashKey(model)) do
    RequestModel(GetHashKey(model))
    Wait(10)
  end
end

function PtfxThis(asset)
  while not HasNamedPtfxAssetLoaded(asset) do
    RequestNamedPtfxAsset(asset)
    Wait(10)
  end
  UseParticleFxAssetNextCall(asset)
end

function DestroyAllProps()
  for _,v in pairs(PlayerProps) do
    DeleteEntity(v)
  end
  PlayerHasProp = false
  DebugPrint("Destroyed Props")
end

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
  local Player = PlayerPedId()
  local x,y,z = table.unpack(GetEntityCoords(Player))

  if not HasModelLoaded(prop1) then
    LoadPropDict(prop1)
  end

  prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
  AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
  table.insert(PlayerProps, prop)
  PlayerHasProp = true
  SetModelAsNoLongerNeeded(prop1)
end

-----------------------------------------------------------------------------------------------------
-- V -- This could be a whole lot better, i tried messing around with "IsPedMale(ped)"
-- V -- But i never really figured it out, if anyone has a better way of gender checking let me know.
-- V -- Since this way doesnt work for ped models.
-- V -- in most cases its better to replace the scenario with an animation bundled with prop instead.
-----------------------------------------------------------------------------------------------------

function CheckGender()
  local hashSkinMale = GetHashKey("mp_m_freemode_01")
  local hashSkinFemale = GetHashKey("mp_f_freemode_01")

  if GetEntityModel(PlayerPedId()) == hashSkinMale then
    PlayerGender = "male"
  elseif GetEntityModel(PlayerPedId()) == hashSkinFemale then
    PlayerGender = "female"
  end
  DebugPrint("Set gender as = ("..PlayerGender..")")
end

-----------------------------------------------------------------------------------------------------
------ This is the major function for playing emotes! -----------------------------------------------
-----------------------------------------------------------------------------------------------------

function OnEmotePlay(EmoteName)

  InVehicle = IsPedInAnyVehicle(PlayerPedId(), true)
  if not Config.AllowedInCars and InVehicle == 1 then
    return
  end

  if not DoesEntityExist(GetPlayerPed(-1)) then
    return false
  end

  if Config.DisarmPlayer then
    if IsPedArmed(GetPlayerPed(-1), 7) then
      SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_UNARMED'), true)
    end
  end

  ChosenDict,ChosenAnimation,ename = table.unpack(EmoteName)
  AnimationDuration = -1

  if PlayerHasProp then
    DestroyAllProps()
  end

  if ChosenDict == "Expression" then
    SetFacialIdleAnimOverride(PlayerPedId(), ChosenAnimation, 0)
    return
  end

  if ChosenDict == "MaleScenario" or "Scenario" then 
    CheckGender()
    if ChosenDict == "MaleScenario" then if InVehicle then return end
      if PlayerGender == "male" then
        ClearPedTasks(GetPlayerPed(-1))
        TaskStartScenarioInPlace(GetPlayerPed(-1), ChosenAnimation, 0, true)
        DebugPrint("Playing scenario = ("..ChosenAnimation..")")
        IsInAnimation = true
      else
        EmoteChatMessage(Config.Languages[lang]['maleonly'])
      end return
    elseif ChosenDict == "ScenarioObject" then if InVehicle then return end
      BehindPlayer = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0 - 0.5, -0.5);
      ClearPedTasks(GetPlayerPed(-1))
      TaskStartScenarioAtPosition(GetPlayerPed(-1), ChosenAnimation, BehindPlayer['x'], BehindPlayer['y'], BehindPlayer['z'], GetEntityHeading(PlayerPedId()), 0, 1, false)
      DebugPrint("Playing scenario = ("..ChosenAnimation..")")
      IsInAnimation = true
      return
    elseif ChosenDict == "Scenario" then if InVehicle then return end
      ClearPedTasks(GetPlayerPed(-1))
      TaskStartScenarioInPlace(GetPlayerPed(-1), ChosenAnimation, 0, true)
      DebugPrint("Playing scenario = ("..ChosenAnimation..")")
      IsInAnimation = true
    return end 
  end

  LoadAnim(ChosenDict)

  if EmoteName.AnimationOptions then
    if EmoteName.AnimationOptions.EmoteLoop then
      MovementType = 1
    if EmoteName.AnimationOptions.EmoteMoving then
      MovementType = 51
  end

  elseif EmoteName.AnimationOptions.EmoteMoving then
    MovementType = 51
  elseif EmoteName.AnimationOptions.EmoteMoving == false then
    MovementType = 0
  elseif EmoteName.AnimationOptions.EmoteStuck then
    MovementType = 50
  end

  else
    MovementType = 0
  end

  if InVehicle == 1 then
    MovementType = 51
  end

  if EmoteName.AnimationOptions then
    if EmoteName.AnimationOptions.EmoteDuration == nil then 
      EmoteName.AnimationOptions.EmoteDuration = -1
      AttachWait = 0
    else
      AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
      AttachWait = EmoteName.AnimationOptions.EmoteDuration
    end

    if EmoteName.AnimationOptions.PtfxAsset then
      PtfxAsset = EmoteName.AnimationOptions.PtfxAsset
      PtfxName = EmoteName.AnimationOptions.PtfxName
      if EmoteName.AnimationOptions.PtfxNoProp then
        PtfxNoProp = EmoteName.AnimationOptions.PtfxNoProp
      else
        PtfxNoProp = false
      end
      Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(EmoteName.AnimationOptions.PtfxPlacement)
      PtfxInfo = EmoteName.AnimationOptions.PtfxInfo
      PtfxWait = EmoteName.AnimationOptions.PtfxWait
      PtfxNotif = false
      PtfxPrompt = true
      PtfxThis(PtfxAsset)
    else
      DebugPrint("Ptfx = none")
      PtfxPrompt = false
    end
  end

  TaskPlayAnim(GetPlayerPed(-1), ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
  RemoveAnimDict(ChosenDict)
  IsInAnimation = true
  MostRecentDict = ChosenDict
  MostRecentAnimation = ChosenAnimation

  if EmoteName.AnimationOptions then
    if EmoteName.AnimationOptions.Prop then
        PropName = EmoteName.AnimationOptions.Prop
        PropBone = EmoteName.AnimationOptions.PropBone
        PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(EmoteName.AnimationOptions.PropPlacement)
        if EmoteName.AnimationOptions.SecondProp then
          SecondPropName = EmoteName.AnimationOptions.SecondProp
          SecondPropBone = EmoteName.AnimationOptions.SecondPropBone
          SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
          SecondPropEmote = true
        else
          SecondPropEmote = false
        end
        Wait(AttachWait)
        AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
        if SecondPropEmote then
          AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6)
        end
    end
  end
  return true
end

if Config.SqlKeybinding then
  local emob1 = ""
  local emob2 = ""
  local emob3 = ""
  local emob4 = ""
  local emob5 = ""
  local emob6 = ""
  local keyb1 = ""
  local keyb2 = ""
  local keyb3 = ""
  local keyb4 = ""
  local keyb5 = ""
  local keyb6 = "" 
  local Initialized = false
  
  -----------------------------------------------------------------------------------------------------
  -- Commands / Events --------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------
  
  Citizen.CreateThread(function()
    while true do
  
      if NetworkIsPlayerActive(PlayerId()) and not Initialized then
          if not Initialized then
              TriggerServerEvent("dp:ServerKeybindExist")
              Wait(5000)
          end
      end
  
      if not IsPedSittingInAnyVehicle(PlayerPedId()) then
          for k, v in pairs(Config.KeybindKeys) do
              if IsControlJustReleased(0, v) then
                  if k == keyb1 then if emob1 ~= "" then EmoteCommandStart(nil,{emob1, 0}) end end
                  if k == keyb2 then if emob2 ~= "" then EmoteCommandStart(nil,{emob2, 0}) end end
                  if k == keyb3 then if emob3 ~= "" then EmoteCommandStart(nil,{emob3, 0}) end end
                  if k == keyb4 then if emob4 ~= "" then EmoteCommandStart(nil,{emob4, 0}) end end
                  if k == keyb5 then if emob5 ~= "" then EmoteCommandStart(nil,{emob5, 0}) end end
                  if k == keyb6 then if emob6 ~= "" then EmoteCommandStart(nil,{emob6, 0}) end end
                  Wait(1000)
              end
          end
      end
      Citizen.Wait(1)
    end
  end)
  
  RegisterNetEvent("dp:ClientKeybindExist")
  AddEventHandler("dp:ClientKeybindExist", function(does)
      if does then
        TriggerServerEvent("dp:ServerKeybindGrab")
      else
        TriggerServerEvent("dp:ServerKeybindCreate")
      end
  end)
  
  RegisterNetEvent("dp:ClientKeybindGet")
  AddEventHandler("dp:ClientKeybindGet", function(k1, e1, k2, e2, k3, e3, k4, e4, k5, e5, k6, e6)
      keyb1 = k1 emob1 = e1 keyb2 = k2 emob2 = e2 keyb3 = k3 emob3 = e3 keyb4 = k4 emob4 = e4 keyb5 = k5 emob5 = e5 keyb6 = k6 emob6 = e6
      Initialized = true
  end)
  
  RegisterNetEvent("dp:ClientKeybindGetOne")
  AddEventHandler("dp:ClientKeybindGetOne", function(key, e)
      SimpleNotify(Config.Languages[lang]['bound'].."~y~"..e.."~w~ "..Config.Languages[lang]['to'].." ~g~"..firstToUpper(key).."~w~")
    if key == "num4" then emob1 = e keyb1 = "num4" elseif key == "num5" then emob2 = e keyb2 = "num5" elseif key == "num6" then emob3 = e keyb3 = "num6" elseif key == "num7" then emob4 = e keyb4 = "num7" elseif key == "num8" then emob5 = e keyb5 = "num8" elseif key == "num9" then emob6 = e keyb6 = "num9" end
  end)
  
  -----------------------------------------------------------------------------------------------------
  ------ Functions and stuff --------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------
  
  function EmoteBindsStart()
      EmoteChatMessage(Config.Languages[lang]['currentlyboundemotes'].."\n"
          ..firstToUpper(keyb1).." = '^2"..emob1.."^7'\n"
          ..firstToUpper(keyb2).." = '^2"..emob2.."^7'\n"
          ..firstToUpper(keyb3).." = '^2"..emob3.."^7'\n"
          ..firstToUpper(keyb4).." = '^2"..emob4.."^7'\n"
          ..firstToUpper(keyb5).." = '^2"..emob5.."^7'\n"
          ..firstToUpper(keyb6).." = '^2"..emob6.."^7'\n")
  end
  
  function EmoteBindStart(source, args, raw)
      if #args > 0 then
          local key = string.lower(args[1])
          local emote = string.lower(args[2])
          if (Config.KeybindKeys[key]) ~= nil then
            if DP.Emotes[emote] ~= nil then
                TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
            elseif DP.Dances[emote] ~= nil then
                TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
            elseif DP.PropEmotes[emote] ~= nil then
                TriggerServerEvent("dp:ServerKeybindUpdate", key, emote)
            else
                EmoteChatMessage("'"..emote.."' "..Config.Languages[lang]['notvalidemote'].."")
            end
          else
            EmoteChatMessage("'"..key.."' "..Config.Languages[lang]['notvalidkey'])
          end
      else
          print("invalid")
      end
  end
  
  end