-----------------------------------
-- Ability: Third Eye
-- Anticipates and dodges the next attack directed at you.
-- Obtained: Samurai Level 15
-- Recast Time: 0:01:00
-- Duration: 0:00:30
-----------------------------------
require("scripts/globals/status")
-----------------------------------

function onAbilityCheck(player, target, ability)
    if player:hasStatusEffect(tpz.effect.SEIGAN) then
        ability:setRecast(ability:getRecast() / 2) -- Seigan halves recast time
    end

    return 0, 0
end

function onUseAbility(player, target, ability)
    player:addStatusEffect(tpz.effect.THIRD_EYE, 0, 0, 30) -- Power keeps track of procs
end
