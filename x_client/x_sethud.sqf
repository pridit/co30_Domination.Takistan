// by Xeno
#define THIS_FILE "x_sethud.sqf"
#include "x_setup.sqf"

switch (GVAR(chophud_on)) do {
    case true: {
        GVAR(chophud_on) = false;
    };
    case false: {
        GVAR(chophud_on) = true;
    };
};