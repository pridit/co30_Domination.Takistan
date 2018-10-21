#include "x_macros.sqf"
#define __OWN_SIDE_WEST__
#define __DEFAULT__
#define __OA__
#define __D_VER_NAME__ "DominationOA! One Team - West"
#define __D_NUM_PLAYERS__ 40
#define __D_RESPAWN_DELAY__ 20
#define __AI2CLIENTS__
#define __UI_Path(lfile) QUOTE(\ca\ui\data\lfile)
#ifdef __TOH__
#define __GLOGO __UI_Path(helisim_logo_ca.paa)
#else
#define __GLOGO __UI_Path(logo_arma2ep1_ca.paa)
#endif

#ifdef __CO__
#undef __GLOGO
#endif

#define __HCNAME "__D_HC_CLIENT__"
#define __XSETUP_INCL__
