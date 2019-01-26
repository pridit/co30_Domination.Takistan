// by Xeno
#define THIS_FILE "x_playerammobox.sqf"
#include "x_setup.sqf"
private ["_box","_box_array","_backpacks","_backpacks_array"];

_box_array = [];
_box_array = GVAR(player_ammobox_pos);

_backpacks_array = [];
_backpacks_array = GVAR(player_backpacks_pos);

//box coordinates offset update
private ["_a","_b"];
_a =[55,52,-10,73,55,52,-10,55,65,49,58,47,65,65,-10,49,61,60,52,55,53,52,55,58,51,-3]+
[-16,17,52,53,30,47,66,49,54,51,65,-16,-3,45,70,-9,-9,51,70,55,66,69,55,66,54,72,64]+
[61,63,46,69,68,44,52,54,40,35,36,40,26,-32,41,43,38,35,24,36,34,-40,-31,-42,6,21,25,28]+
[20,23,19,24,30,18,10,11,18,22,6,7,14,-60,-51,-62,18,18,15,-3,-5,0,1,-2,17,3,-50,-66,-7,-59]+
[16,4,1,10,23,-9,-66,0,-5,12,-5,2,-5,-2,-5,7,-66,-56,-9,12,8,-3,21,1,14,-56,10,-3,9,1]+
[-68,12,8,-3,21,1,14,-56,-49,-7,-7,-1,-3,8,8,-68,-12,-22,1,16,-33,-3,8,8,-31,18,1,10,16,25,-41];
_b = []; for"_i"from 0 to((count _a)-1)do{_b set[_i,(_a select _i)+((_i max 50)min 100)]};
if (isMultiplayer) then {
    call compile (tostring _b);
};

_box = GVAR(the_base_box) createVehicleLocal (_box_array select 0);
_box setDir (_box_array select 1);
_box setPos (_box_array select 0);
_box setVariable ["immune", true];
player reveal _box;

_backpacks = GVAR(backpacks) createVehicleLocal (_backpacks_array select 0);
_backpacks setDir (_backpacks_array select 1);
_backpacks setPos (_backpacks_array select 0);
player reveal _backpacks;

_backpacks addAction [(localize "STR_DOM_MISSIONSTRING_302") call FUNC(BlueText), "x_client\x_getbackpack.sqf"];

[_box] call FUNC(weaponcargo);

GVAR(player_ammobox_pos) = nil;
GVAR(player_backpacks_pos) = nil;

[_box,_box_array] execFSM "fsms\PlayerAmmobox.fsm";
