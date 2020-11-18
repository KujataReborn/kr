---------------------------------------
--
-- Assault
--
---------------------------------------
require("scripts/globals/keyitems")
require("scripts/globals/missions")
require("scripts/globals/quests")
---------------------------------------
tpz = tpz or {}
tpz.assault = tpz.assault or {}
---------------------------------------

tpz.assault.missions =
{
    LEUJAOAM_CLEANSING                =  1,
    ORICHALCUM_SURVEY                 =  2,
    ESCORT_PROFESSOR_CHANOIX          =  3,
    SHANARHA_GRASS_CONSERVATION       =  4,
    COUNTING_SHEEP                    =  5,
    SUPPLIES_RECOVERY                 =  6,
    AZURE_EXPERIMENTS                 =  7,
    IMPERIAL_CODE                     =  8,
    RED_VERSUS_BLUE                   =  9,
    BLOODY_RONDO                      = 10,
    IMPERIAL_AGENT_RESCUE             = 11,
    PREEMPTIVE_STRIKE                 = 12,
    SAGELORD_ELIMINATION              = 13,
    BREAKING_MORALE                   = 14,
    THE_DOUBLE_AGENT                  = 15,
    IMPERIAL_TREASURE_RETRIEVAL       = 16,
    BLITZKRIEG                        = 17,
    MARIDS_IN_THE_MIST                = 18,
    AZURE_AILMENTS                    = 19,
    THE_SUSANOO_SHUFFLE               = 20,
    EXCAVATION_DUTY                   = 21,
    LEBROS_SUPPLIES                   = 22,
    TROLL_FUGITIVES                   = 23,
    EVADE_AND_ESCAPE                  = 24,
    SIEGEMASTER_ASSASSINATION         = 25,
    APKALLU_BREEDING                  = 26,
    WAMOURA_FARM_RAID                 = 27,
    EGG_CONSERVATION                  = 28,
    OPERATION__BLACK_PEARL            = 29,
    BETTER_THAN_ONE                   = 30,
    SEAGULL_GROUNDED                  = 31,
    REQUIEM                           = 32,
    SAVING_PRIVATE_RYAAF              = 33,
    SHOOTING_DOWN_THE_BARON           = 34,
    BUILDING_BRIDGES                  = 35,
    STOP_THE_BLOODSHED                = 36,
    DEFUSE_THE_THREAT                 = 37,
    OPERATION__SNAKE_EYES             = 38,
    WAKE_THE_PUPPET                   = 39,
    THE_PRICE_IS_RIGHT                = 40,
    GOLDEN_SALVAGE                    = 41,
    LAMIA_NO_13                       = 42,
    EXTERMINATION                     = 43,
    DEMOLITION_DUTY                   = 44,
    SEARAT_SALVATION                  = 45,
    APKALLU_SEIZURE                   = 46,
    LOST_AND_FOUND                    = 47,
    DESERTER                          = 48,
    DESPERATELY_SEEKING_CEPHALOPODS   = 49,
    BELLEROPHON_S_BLISS               = 50,
    NYZUL_ISLE_INVESTIGATION          = 51,
    NYZUL_ISLE_UNCHARTED_AREA_SURVEY  = 52,
}

tpz.assault.info =
{
    [tpz.assault.missions.IMPERIAL_AGENT_RESCUE] = {suggestedLevel = 60, minimumPoints = 1100}
}

tpz.assault.instance =
{
    [tpz.zone.BHAFLAU_THICKETS] = tpz.zone.MAMOOL_JA_TRAINING_GROUNDS
}

-- ------------------------------------------------------------------------------------------------
-- Stagging Point Sentries (aka Armband NPCs)

tpz.assault.armband = {}

tpz.assault.armband.onTrigger = function(player, npc, csid1, csid2, csid3, csid4, csid5, csid6, csid7, beginningsKI, orders)
    local mission = player:getCurrentMission(TOAU)

    -- ToAU 02 - Immortal Sentries
    if mission == tpz.mission.id.toau.IMMORTAL_SENTRIES then
        if player:hasKeyItem(tpz.keyItem.SUPPLIES_PACKAGE) then
            player:startEvent(csid1)
        elseif player:getCharVar("AhtUrganStatus") == 1 then
            player:startEvent(csid2)
        end

    -- ToAU Quest - BEGINNINGS (BLU AF1)
    elseif player:getQuestStatus(AHT_URHGAN, tpz.quest.id.ahtUrhgan.BEGINNINGS) == QUEST_ACCEPTED then
        if not player:hasKeyItem(beginningsKI) then
            player:startEvent(csid3)
        else
            player:startEvent(csid4)
        end

    -- Assault
    elseif mission >= tpz.mission.id.toau.PRESIDENT_SALAHEEM then
        local imperialPoint = player:getCurrency("imperial_standing")

        if
            player:getCharVar("assaultEntered") == 0 and
            player:hasKeyItem(orders) and
            not player:hasKeyItem(tpz.keyItem.ASSAULT_ARMBAND)
        then
            player:startEvent(csid5, 50, imperialPoint)
        else
            player:startEvent(csid6)
        end

    -- Default dialogue
    else
        player:startEvent(csid7)
    end
end

tpz.assault.armband.onEventFinish = function(player, csid, option, csid1, csid2, csid3, beginningsKI)
    -- ToAU 02 - Immortal Sentries
    if csid == csid1 and option == 1 then
        player:delKeyItem(tpz.keyItem.SUPPLIES_PACKAGE)
        player:setCharVar("AhtUrganStatus", 1)

    -- ToAU Quest - BEGINNINGS (BLU AF1)
    elseif csid == csid2 then
        npcUtil.giveKeyItem(player, beginningsKI)

    -- Assault
    elseif csid == csid3 and option == 1 then
        npcUtil.giveKeyItem(player, tpz.keyItem.ASSAULT_ARMBAND)
        player:delCurrency("imperial_standing", 50)
    end
end

-- ------------------------------------------------------------------------------------------------
-- Runic Seals

tpz.assault.runicSeal = {}

tpz.assault.runicSeal.onTrigger = function(player, npc, csid, orders, index)
    if player:hasKeyItem(orders) and player:getCharVar("assaultEntered") == 0 then
        local assaultID = player:getCurrentAssault()
        local level = tpz.assault.info[assaultID].suggestedLevel
        local armband = 0

        if player:hasKeyItem(tpz.keyItem.ASSAULT_ARMBAND) then
            armband = 1
        end

        player:startEvent(csid, assaultID, -4, 0, level, index, armband)
    else
        player:messageText(player, zones[player:getZoneID()].text.NOTHING_HAPPENS)
    end
end

tpz.assault.runicSeal.onEventUpdate = function(player, csid, option, target, orders)
    if player:getGMLevel() == 0 and player:getPartySize() < 3 then
        player:messageSpecial(zones[player:getZoneID()].text.PARTY_MIN_REQS, 3)
        player:instanceEntry(target, 1)

        return
    elseif player:checkSoloPartyAlliance() == 2 then
        player:messageText(player, zones[player:getZoneID()].text.MEMBER_NO_REQS + 1, false)
        player:instanceEntry(target, 1)

        return
    end

    local cap = bit.band(option, 0x03)

    if     cap == 0 then cap = 0
    elseif cap == 1 then cap = 70
    elseif cap == 2 then cap = 60
    else                 cap = 50
    end

    player:setCharVar("AssaultCap", cap)

    local assaultID = player:getCurrentAssault()

    local party = player:getParty()

    if party then
        for _, member in ipairs(party) do
            if
                not member:hasKeyItem(orders) or
                member:getCurrentAssault() ~= assaultID or
                member:getCharVar("assaultEntered") ~= 0 or
                member:getMainLvl() < 50
            then
                player:messageText(player, zones[player:getZoneID()].text.MEMBER_NO_REQS, false)
                player:instanceEntry(target, 1)

                return
            elseif
                member:getZoneID() ~= player:getZoneID() or
                member:checkDistance(player) > 50
            then
                player:messageText(player, zones[player:getZoneID()].text.MEMBER_TOO_FAR, false)
                player:instanceEntry(target, 1)
                
                return
            end
        end
    end

    player:createInstance(assaultID, tpz.assault.instance[player:getZoneID()])
end

tpz.assault.runicSeal.onEventFinish = function(player, csid, option, assaultCs, assaultOpt)
    if csid == assaultCs and option == assaultOpt then
        player:setPos(0, 0, 0, 0, tpz.assault.instance[player:getZoneID()])
    end
end

tpz.assault.runicSeal.onInstanceCreated = function(player, target, instance, csid)
    
    if instance then
        instance:setLevelCap(player:getCharVar("AssaultCap"))
        player:setCharVar("AssaultCap", 0)

        player:setCharVar("assaultEntered", 99)
        player:setInstance(instance)
        player:instanceEntry(target, 4)

        player:setCharVar("Assault_Armband", 1)
        player:delKeyItem(tpz.keyItem.ASSAULT_ARMBAND)

        local party = player:getParty()

        if party then
            for _,member in ipairs(party) do
                if
                    member:getID() ~= player:getID() and
                    member:getZoneID() == player:getZoneID()
                then
                    member:setCharVar("assaultEntered", 99)
                    member:setInstance(instance)
                    member:startEvent(csid)
                end
            end
        end
    else
        player:messageText(player, zones[player:getZoneID()].text.CANNOT_ENTER, false)
        player:instanceEntry(target, 3)
    end
end

