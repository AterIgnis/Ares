// Init some special data that Ares will use. These will sometimes be modified by missions.
call compile preprocessFileLineNumbers '\ares_zeusExtensions\data\Ares_Reinforcement_Unit_Pools.sqf';

// Add any custom modules we want
call compile preprocessFileLineNumbers '\ares_zeusExtensions\scripts\registerBuiltInCustomModules.sqf';

// Blacklist for modules that grab objects. These types should not be added to Zeus automatically.
Ares_EditableObjectBlacklist =
	[
		"Ares_Module_Util_Create_Composition",
		"ModuleCurator_F",
		"GroundWeaponHolder",
		"Salema_F",
		"Ornate_random_F",
		"Mackerel_F",
		"Tuna_F",
		"Mullet_F", 
		"CatShark_F",
		"Rabbit_F",
		"Snake_random_F",
		"Turtle_F",
		"Hen_random_F",
		"Cock_random_F",
		"Cock_white_F",
		"Sheep_random_F"
	];

if(isServer && isDedicated) exitWith { ["Aborting Ares init - Dedicated server detected."] call Ares_fnc_LogMessage; };

[] spawn {
	[] call Ares_fnc_waitForZeus;
	
	// Wait until THIS player is a zeus unit.
	while { !([player] call Ares_fnc_isZeus) } do
	{
		//["Unit not zeus..."] call Ares_fnc_LogMessage;
		sleep 1;
	};

	["Initializing UI ..."] call Ares_fnc_LogMessage;
	["Ares"] spawn Ares_fnc_MonitorCuratorDisplay;
	["... Done initializing UI."] call Ares_fnc_LogMessage;
	
	["Initializing Events ..."] call Ares_fnc_LogMessage;
	_didRegisterForEvents = false;
	{
		if ((getassignedcuratorunit _x) == player) then
		{
			["Found curator instance, registering for callbacks..."] call Ares_fnc_LogMessage;
			_x addEventHandler ["CuratorObjectPlaced", { _this call Ares_fnc_HandleCuratorObjectPlaced; }];
			_x addEventHandler ["CuratorObjectDoubleClicked", { _this call Ares_fnc_HandleCuratorObjectDoubleClicked; }];
			_didRegisterForEvents = true;
		}
		else
		{
			["Skipping curator with different assigned unit."] call Ares_fnc_LogMessage;
		}
	} foreach allCurators;
	if (_didRegisterForEvents) then
	{
		["... Done initializing events (Success)."] call Ares_fnc_LogMessage;
	}
	else
	{
		["... Failed initializing events!"] call Ares_fnc_LogMessage;
	};
};