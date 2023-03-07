ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    ESX.PlayerData = ESX.GetPlayerData()
end)

function ReloadPlayerData()
    ESX.PlayerData = ESX.GetPlayerData()
end

Citizen.CreateThread(function(source, args, rawCommand)
    --createNPC(GetHashKey(Config.PNJ), vector3(Config.PositionBlanchisseurX,Config.PositionBlanchisseurY,Config.PositionBlanchisseurZ-1), Config.RotationBlanchisseur)
    createNPC(GetHashKey(Config.PNJ), Config.PositionBlanchisseur.pos, Config.PositionBlanchisseur.heading)
end)

function createNPC(pedHash, pos, pedHeading) 
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end
    local npc = CreatePed(0, pedHash, pos, pedHeading, false, false)
    SetEntityInvincible(npc, true)
    TaskSetBlockingOfNonTemporaryEvents(npc,true)
    FreezeEntityPosition(npc, true)
    if Config.PortArme then
        GiveWeaponToPed(npc, GetHashKey(Config.Arme), 1, true, true)
    end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", 10)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local iBlanchisseur = false

RMenu.Add('iBlanchisseur_menu', 'main', RageUI.CreateMenu('Blanchisseur', 'Que voulez-vous faire ?'))
RMenu:Get('iBlanchisseur_menu', 'main').Closed = function()
    iBlanchisseur = false
end

function OpenMenuBlanchisseur()
    if iBlanchisseur then
        iBlanchisseur = false
    else
        iBlanchisseur = true
        RageUI.Visible(RMenu:Get('iBlanchisseur_menu', 'main'), true)

        Citizen.CreateThread(function()
            while iBlanchisseur do
                Wait(0)
                RageUI.IsVisible(RMenu:Get('iBlanchisseur_menu', 'main'), true, true, true, function()
                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'black_money' then
                            RageUI.Separator("Argent Sale : ~r~"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."$")
                        end
                    end
                    RageUI.ButtonWithStyle("Blanchir", nil, {RightLabel = "→→→"}, true, function(h, a, s)
                        if s then
                            local argent_blanchi = KeyboardInput("Combien veux-tu blanchir ?", "", 20)
                            local argent_final = tonumber(argent_blanchi)
                            if argent_final == "" or argent_final == nil or not type(argent_final) == "number" then
                                ESX.ShowNotification('Veuillez entrer une valeur ~r~correcte')
                            else
                                TriggerServerEvent("blanchir_argent", argent_final)
                            end
                        end
                    end)
                end)
            end
        end)
    end
end

Citizen.CreateThread(function()
    local pos = Config.PositionBlanchisseur.pos
    while true do
        local interval = 200
        local playerpos = GetEntityCoords(PlayerPedId())
        
            if #(playerpos-Config.PositionBlanchisseur.pos) < 2 then
                interval = 0
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour parler à ~r~'..Config.Name)
                if IsControlJustPressed(1, 51) then
                    if Config.Dialog then
                        TexteBas('~b~[Vous]~s~ Salut, c\'est toi pour le blanchiment ?', 2500)
                        Citizen.Wait(2500)
                        TexteBas('~r~['..Config.Name..']~s~ Ouais c\'est moi tu veux blanchir combien ?', 2500)
                        Citizen.Wait(2500)
                    end
                    ReloadPlayerData()
                    if iBlanchisseur == false then
                        OpenMenuBlanchisseur()
                    end
                end
            end
        Citizen.Wait(interval)
    end
end)

function TexteBas(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, 1)
end