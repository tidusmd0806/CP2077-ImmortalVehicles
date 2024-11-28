--------------------------------------------------------
-- CopyRight (C) 2024, tidusmd. All rights reserved.
-- This mod is under the MIT License.
-- https://opensource.org/licenses/mit-license.php
--------------------------------------------------------

ImmortalVeh = {
	description = "Immortal Vehicles",
	version = "1.0.0",
    is_enabled = true,
    -- System
    is_ready = false,
    cet_required_version = 32.1, -- 1.32.1
    cet_recommended_version = 32.3, -- 1.32.3
}

registerForEvent('onTweak', function()

    if not ImmortalVeh.is_enabled then
        return
    end

    TweakDB:CreateRecord("Vehicle.VehicleDestructionParamsNone", "gamedataVehicleDestruction_Record")
    local all_vehicle_twdb_ids = TweakDB:GetFlat("Vehicle.vehicle_list.list")
    for _, vehicle_twdb_id in pairs(all_vehicle_twdb_ids) do
        if vehicle_twdb_id ~= nil then
            AddImmortalTag(vehicle_twdb_id)
            DisableDestruction(vehicle_twdb_id)
        end
    end

end)

registerForEvent('onInit', function()

    if not ImmortalVeh.is_enabled then
        print("[ImmortalVeh][Info] Immortal Vehicles disabled.")
        return
    end

    if not ImmortalVeh:CheckDependencies() then
        print('[ImmortalVeh][Error] Immortal Vehicles failed to load due to missing dependencies.')
        return
    end

    Override("VehicleComponent", "EvaluateDamageLevel",
    ---@param this VehicleComponent
    ---@param destruction Float
    function(this, destruction, wrapped_method)
        if this:GetEntity():IsPlayerVehicle() then
            destruction = 100
        end
        return wrapped_method(destruction)
    end)

    ImmortalVeh.is_ready = true

    print("[ImmortalVeh][Info] Ready to Immortal Vehicles.")

end)

function GetVehTags(vehicle_twdb_id)
    local vehicle_tag_list = TweakDB:GetFlat(vehicle_twdb_id.value .. ".tags")
    return vehicle_tag_list
end

function AddImmortalTag(vehicle_twdb_id)

    local vehicle_tag_list = GetVehTags(vehicle_twdb_id)
    for _, vehicle_tag in pairs(vehicle_tag_list) do
        if vehicle_tag == CName.new("Immortal") then
            return
        end
    end
    table.insert(vehicle_tag_list, CName.new("Immortal"))
    TweakDB:SetFlat(TweakDBID.new(vehicle_twdb_id.value .. ".tags"), vehicle_tag_list)

end

function DisableDestruction(vehicle_twdb_id)
    TweakDB:SetFlat(vehicle_twdb_id.value .. ".destruction", "Vehicle.VehicleDestructionParamsNone")
end


function ImmortalVeh:CheckDependencies()

    -- Check Cyber Engine Tweaks Version
    local cet_version_str = GetVersion()
    local cet_version_major, cet_version_minor = cet_version_str:match("1.(%d+)%.*(%d*)")
    ImmortalVeh.cet_version_num = tonumber(cet_version_major .. "." .. cet_version_minor)

    if ImmortalVeh.cet_version_num < ImmortalVeh.cet_required_version then
        print("[ImmortalVeh][Error] requires Cyber Engine Tweaks version 1." .. ImmortalVeh.cet_required_version .. " or higher.")
        return false
    end

    return true

end

function ImmortalVeh:Version()
    return ImmortalVeh.version
end

return ImmortalVeh