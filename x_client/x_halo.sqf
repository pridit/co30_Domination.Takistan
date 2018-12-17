// by Xeno
#define THIS_FILE "x_halo.sqf"
#include "x_setup.sqf"

player action ["EJECT", _this select 0];

if (vehicle player isKindOf "ParachuteBase") then {
    _vec = vehicle player;
    player action ["EJECT", _vec];
    deleteVehicle _vec;
};

[player, player call FUNC(GetHeight)] spawn bis_fnc_halo;