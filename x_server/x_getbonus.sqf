// by Xeno
#define THIS_FILE "x_getbonus.sqf"
#include "x_setup.sqf"
private ["_vehicle", "_number_v", "_object", "_chance", "_btype", "_vec_type", "_vecclass", "_d_bonus_create_pos", "_d_bonus_air_positions", "_d_bonus_vec_positions", "_d_bap_counter", "_d_bvp_counter", "_btype_e", "_btype_w", "_bonus_num_e", "_vec_typex", "_bonus_num_w", "_d_bonus_create_pos2", "_vec_type2", "_d_bonus_air_positions2", "_d_bonus_vec_positions2", "_d_bvp_counter2", "_d_bap_counter2", "_vehicle", "_endpos", "_dir", "_vehicle2", "_endpos2", "_dir2","_airval"];
if (!isServer) exitWith {};

{
    _number_v = _x select 0;
    _object = _x select 1;
    _vecclass = toUpper (getText(configFile >> "CfgVehicles" >> _object >> "vehicleClass"));

    _d_bonus_create_pos = GVAR(bonus_create_pos);
    _d_bonus_air_positions = GVAR(bonus_air_positions);
    _d_bonus_vec_positions = GVAR(bonus_vec_positions);
    _d_bap_counter = GVAR(bap_counter);
    _d_bvp_counter = GVAR(bvp_counter);

    sleep 1.012;

    _vehicle = createVehicle [_object, _d_bonus_create_pos, [], 0, "NONE"];
    _endpos = [];
    _dir = 0;

    if (_vehicle isKindOf "Air") then {
        _endpos = (_d_bonus_air_positions select _d_bap_counter) select 0;
        _dir = (_d_bonus_air_positions select _d_bap_counter) select 1;
        __INC(GVAR(bap_counter));
        if (GVAR(bap_counter) > (count _d_bonus_air_positions - 1)) then {GVAR(bap_counter) = 0};
    } else {
        _endpos = (_d_bonus_vec_positions select _d_bvp_counter) select 0;
        _dir = (_d_bonus_vec_positions select _d_bvp_counter) select 1;
        __INC(GVAR(bvp_counter));
        if (GVAR(bvp_counter) > (count _d_bonus_vec_positions - 1)) then {GVAR(bvp_counter) = 0};
    };

    _vehicle setDir _dir;
    _vehicle setPos _endpos;
    _vehicle setVariable [QGVAR(vec), _number_v, true];
    [QGVAR(n_v), _vehicle] call FUNC(NetCallEventToClients);
    _vehicle setVariable ["D_VEC_SIDE", 2, true];
    _vehicle execFSM "fsms\Wreckmarker.fsm";
} forEach _this;
