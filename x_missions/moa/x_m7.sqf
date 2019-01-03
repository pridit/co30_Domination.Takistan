// by Xeno
private ["_vehicle", "_poss", "_ogroup", "_unit", "_officer", "_endtime"];
#include "x_setup.sqf"

_mpos = markerPos QGVAR(sm_7);
_mpos set [2,0];
GVAR(x_sm_pos) = [_mpos]; //  destroy scud
GVAR(x_sm_type) = "normal"; // "convoy"

#ifdef __SMMISSIONS_MARKER__
if (true) exitWith {};
#endif

if (X_Client && {!GVAR(IS_HC_CLIENT)}) then {
    GVAR(current_mission_text) = (localize "STR_DOM_MISSIONSTRING_874");
    GVAR(current_mission_resolved_text) = (localize "STR_DOM_MISSIONSTRING_875");
    [(localize "STR_DOM_MISSIONSTRING_874"), "Destroy", _mpos] call FUNC(x_newtask);
};

if (call FUNC(checkSHC)) then {
    _MissionCompleted = {
        GVAR(side_mission_winner) = 2;
        GVAR(side_mission_resolved) = true;
        if (GVAR(IS_HC_CLIENT)) then {
            [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);
        };
    };

    __PossAndOther
    // TODO: Check if A3 still has SCUD
    _vehicle = createVehicle [GVAR(sm_SCUD), _poss, [], 0, "NONE"];
    _vehicle setDir (markerDir QGVAR(sm_7));
    _vehicle setPos _poss;
    _vehicle setFuel 0;
    __GetEGrp(_ogroup)
    _unit = _ogroup createUnit [GVAR(sm_simple_soldier_east), _poss, [], 0, "FORM"];
    if (GVAR(without_nvg) == 0) then {
        if (_unit hasWeapon "NVGoggles") then {_unit removeWeapon "NVGoggles"};
    };
    _unit setVariable ["BIS_noCoreConversations", true];
    __addDead(_unit)
    _unit moveInDriver _vehicle;
    __AddToExtraVec(_unit)
    __AddToExtraVec(_vehicle)
    sleep 2.123;
    ["specops", 2, "basic", 2, _poss,200,true] spawn FUNC(CreateInf);
    sleep 2.321;
    ["shilka", 1, "bmp", 1, "tank", 0, _poss,1,350,true] spawn FUNC(CreateArmor);
    
    _endtime = time + 900 + random 100;
    waitUntil {sleep 0.321;!alive _vehicle || {time > _endtime}};
    if (alive _vehicle) then {
        [QGVAR(smsg)] call FUNC(NetCallEventToClients);
        _vehicle action ["ScudLaunch",_vehicle];
    };
    sleep 30;
    if (alive _vehicle) then {
        _vehicle action ["ScudStart",_vehicle];
        GVAR(side_mission_winner) = -879;
        GVAR(side_mission_resolved) = true;
        if (GVAR(IS_HC_CLIENT)) then {
            [QGVAR(sm_var), GVAR(side_mission_winner)] call FUNC(NetCallEventCTS);
        };
    } else {
        call _MissionCompleted;
    };
};