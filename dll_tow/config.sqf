//if front axis AND wheels is defined (not nil), it can be towed)
//0 classname or base class - 1 front axis offset - 2 wheel offset
dll_tow_defs =	 [		
    ["Mi24_D_TK_EP1 ", 		[0,9], 	    [0,-1]],		
    ["A10_US_EP1", 			[0,8], 	    [0,-1]],
    ["AV8B2", 				[0,7.5],    [0,-1]],	
    ["MH60S", 				[0,-9],     [0,-1]],	
    ["Mi17_base",			[0,8], 	    [0,0]],	
    ["Mi17_rockets_RU",		[0,8.5],    [0,0]],	
    ["F35B", 				[0,7], 	    [0,-3.5]],		
    ["Su39", 				[0,5.5],    [0,-1]],
    ["Su34", 				[0,6], 	    [0,-2]],
    ["MQ9PredatorB", 		[0,5.5],    [0,-1]],
    ["C130J_US_EP1",		[0,15],	    [0,-5]]
];

//create list of only classnames from defs
dll_tow_classlist = [];
{
    dll_tow_classlist = dll_tow_classlist + [_x select 0];
} forEach dll_tow_defs;