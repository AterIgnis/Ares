#include "\ares_zeusExtensions\module_header.hpp"

if (isNil "ccl_fnc_Distance") then {
	ccl_fnc_Distance = {
		_v0 = _this select 0;
		_v1 = _this select 1;

		if(isNil "_v0" || isNil "_v1") exitWith {nil};

		sqrt (
			((_v0 select 0) - (_v1 select 0)) ^ 2 + 
			((_v0 select 1) - (_v1 select 1)) ^ 2 + 
			((_v0 select 2) - (_v1 select 2)) ^ 2
		);
	};
};

_density = ["8","4","2","1","0.5","0.25","0.125"];
_sides = [["Blue","Red","Green","Civilian"],[west,east,resistance,civilian],["BLU_F","OPF_F","IND_F","CIV_F"]];

_dialogResult = ["Create Reinforcements",
	[
		["Radius", [], 100],
		["Density", _density],
		["Side", _sides select 0]
	]
] call Ares_fnc_ShowChooseDialog;

if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

_center = position _logic;
_radius = parseNumber format ["%1", _dialogResult select 0];
if (_radius == 0) exitWith { [objNull, format ["Radius '%1' is invalid", _radius]] call bis_fnc_showCuratorFeedbackMessage; };
if (_radius<10) then { _radius = 10; };
_density = parseNumber (_density select (_dialogResult select 1));
_side = (_sides select 1) select (_dialogResult select 2);
_faction = (_sides select 2) select (_dialogResult select 2);

_unitCountMax = 150;
_groupCountMax = 25;

//Get a list of available unit types
_CfgVehicles = configFile >> "CfgVehicles";
_classType = "men";
_displayNameFilterArray = ["Rifleman", "Grenadier", "Autorifleman", "Combat Life Saver", "Rifleman (AT)", "Civilian"];
_unitsArray = [];
for [{_i=1},{_i<(count _CfgVehicles - 1)},{_i=_i+1}] do 
{
	_CfgVehicle = _CfgVehicles select _i;

	if (getNumber(_CfgVehicle >> "scope") == 2) then 
	{
		_vehicleDisplayName 	= getText(_CfgVehicle >> "displayname");
		_cfgclass 				= configName _CfgVehicle;  
		_cfgFaction 			= getText(_CfgVehicle >> "faction");
		_simulation 			= getText(_CfgVehicle >> "simulation");
		_vehicleClass			= getText(_CfgVehicle >> "vehicleClass");
		_unitDataArray			= [_vehicleDisplayName, gettext(_CfgVehicle >> "picture")];
		  
		if (toLower(_cfgFaction) == _faction && toLower(_simulation)== "soldier" && ((toLower(_vehicleClass) == _classType) || (_classType == ""))) then
		{
			if(_vehicleDisplayName in _displayNameFilterArray) then
			{
				_unitsArray pushBack [_cfgclass, _unitDataArray];
			};
		};
	};
};

_buildingsArray	= nearestObjects [_center, ["House","Ruins","Church","FuelStation","Strategic"], _radius];
_buildingscount	= count _buildingsArray;

//Exit if there were no buildings found
if (_buildingscount < 1) exitwith {
	[objNull, "Error - No buildings within area"] call bis_fnc_showCuratorFeedbackMessage;
};

_unitCount = 0;
_groupCount = 0;
_group = creategroup _side;
_groupArray = [];

//Iterate through each building
{
	_building = _x;

	//Get a count of the interior positions in the building
	_buildingPosCount = 0;
	while { format ["%1", _building buildingPos _buildingPosCount] != "[0,0,0]" } do {_buildingPosCount = _buildingPosCount + 1};

	//Only spawn units if the building has interior positions
	if (_buildingPosCount > 0) then
	{
		//Create a group for the units in this building
		if(_groupCount < _groupCountMax) then {
			_group = creategroup _side;
			_groupArray set [_groupCount, _group];
			_groupCount = _groupCount + 1;
		} else {
			//If we have reach the group limit, find the closest group to this building
			_buildingPos = _building buildingPos 0;
			_closestGroup = _group;
			{
				_groupLeader = leader _x;
				_distance = [getPosATL _groupLeader, _buildingPos] call ccl_fnc_Distance;
				_closestGroupLeader = leader _closestGroup;
				_closestDistance = [getPosATL _closestGroupLeader, _buildingPos] call ccl_fnc_Distance;

				if(_closestDistance > _distance) then {
					_closestGroup = _x;
				};
			} forEach _groupArray;
			_group = _closestGroup;
		};

		//Iterate through each building position
		for [{_i=0},{_i<_buildingPosCount},{_i=_i+1}] do 
		{
			_spawnPos = _building buildingPos _i; 
			
			//Density check based on random value
			if (random 10 < _density) then	
			{	
				//Spawn as long as there are no other nearby units and we're below the max
				if (count (nearestObjects [_spawnPos, ["Man"], 1]) < 1 && (_unitCount < _unitCountMax)) then
				{
					//Determine the unit type
					_typeIndex = 0;
					if (random 100 < 50) then
					{
						_typeIndex = floor (random 5);
					};
					if(_typeIndex < 0) then {_typeIndex = 0};
					if(_typeIndex >= (count _unitsArray)) then {_typeIndex = 0};
					_type = _unitsArray select _typeIndex;

					//Create the new unit
					_unit = _group createUnit [_type select 0, _spawnPos, [], 0.5, "NONE"];
					waituntil {alive _unit}; 
					_unit setpos _spawnPos;

					_unitCount = _unitCount + 1;
				};
			}
		};

		//Clean up empty groups
		if(count (units _group) < 1) then {
			deleteGroup _group;
			_group = objnull;
			_groupCount = _groupCount - 1;
		} else {
			//Put them on safe
			_group setBehaviour "SAFE";
			_group setSpeedMode "LIMITED";
			
			//Get a random facing direction
			_dir = round(random 360); 
			
			//Make them stand
			{
				_x setUnitPos "UP";
				_x setdir _dir;
			} foreach units _group;
			
			//Look somewhere randomly
			_group setFormDir _dir;

			//Register the units with all curators
			{
				_units = units _group;
				_x addCuratorEditableObjects [_units, true];
			} foreach allCurators;
		};
	};
} foreach _buildingsArray;

[objNull, format["Spawned garrison of %5 units in %6 groups at %1,%2 within distance of %3 for %4", _center select 0, _center select 1, _radius, _side, _unitCount, _groupCount]] call bis_fnc_showCuratorFeedbackMessage;

#include "\ares_zeusExtensions\module_footer.hpp"
