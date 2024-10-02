TMW_GLOBAL_DISPEL_LIST = {
    -- RAID
    ---- Dragonflight
    ------ Amirdrassil
    417807, -- Fyrakk
    165123, -- Venom Burst
    169658, -- Poisonous Claws
    427460, -- Toxic Bloom
    -- Proving Grounds
    145206
}

function CheckMembersBelowHealthPercent(members, healthThreshold, requiredCount)
    local count = 0
    for _, unit in ipairs(members) do
        if unit.HP < healthThreshold then
            count = count + 1
            if count >= requiredCount then
                return true
            end
        end
    end
    return false
end