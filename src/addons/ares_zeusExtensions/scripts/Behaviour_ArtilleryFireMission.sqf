#define FIRST_SPECIFIC_ARTILLERY_TARGET_INDEX 3
[
	"AI Behaviours",
	"Artillery Fire Mission",
	{
		// get all units within range
		_nearObjects = nearestObjects [(_this select 0), ["All"], 150];

		// Filter for artillery
		_filteredObjects = [];
		{
			_ammo = getArtilleryAmmo [_x];
			if (count _ammo > 0) then
			{
				_filteredObjects pushBack _x;
			};
			
		} forEach _nearObjects;

		/**
		 * Group by type. The structure of batteries is
		 * [
		 *   ["Type name", [Unit1, unit2, ...], [ammotype1, ammotype2, ...]],
		 *   ["Type name", [Unit1, unit2, ...], [ammotype1, ammotype2, ...]]
		 * ]
		 */
		_batteries = [];
		{
			_unit = _x;
			_type = getText(configfile >> "CfgVehicles" >> (typeOf _unit) >> "displayName");
			_alreadyContained = false;
			{
				_battery = _x;

				if ((_battery select 0) == _type) then
				{
					_units = _battery select 1;
					_units pushBack _unit;
					_alreadyContained = true;
				};
			} forEach _batteries;
			
			if (!_alreadyContained) then
			{
				_ammo = getArtilleryAmmo [_unit];
				_batteries pushBack [_type, [_unit], _ammo];
			};
			
		} forEach _filteredObjects;
		if (count _batteries == 0) exitWith { ["No nearby artillery units."] call Ares_fnc_ShowZeusMessage; };

		// pick battery
		_batteryTypes = [];
		{
			_batterytypes pushBack (_x select 0);
		} forEach _batteries;

		// Pick a battery
		_pickBatteryResult = [
				"Pick battery to fire.",
				[
					["Battery", _batteryTypes]
				]] call Ares_fnc_ShowChooseDialog;
		if (count _pickBatteryResult == 0) exitWith { ["Fire mission aborted."] call Ares_fnc_ShowZeusMessage; };
		_battery = _batteries select (_pickBatteryResult select 0);

		// Pick fire mission details
		_fireMission = nil;
		_units = _battery select 1;
		_artilleryAmmo = _battery select 2;
		
		_numberOfGuns = [];
		{
			_numberOfGuns pushBack (str (_forEachIndex + 1));
		} forEach _units;

		_allTargetsUnsorted = allMissionObjects "Ares_Module_Behaviour_Create_Artillery_Target";
		_allTargets = [_allTargetsUnsorted, [], { _x getVariable ["SortOrder", 0]; }, "ASCEND"] call BIS_fnc_sortBy;
		_targetChoices = ["Custom", "Random", "Nearest", "Farthest"];
		{
			_targetChoices pushBack (name _x);
		} forEach _allTargets;
			
		// pick guns, rounds, ammo and coordinates
		_pickFireMissionResult = [
			"Pick fire mission details.",
			[
				["Guns", _numberOfGuns],
				["Rounds", ["All","1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]],
				["Ammo", _artilleryAmmo],
				["Choose Target", _targetChoices, 1],
				["Grid East-West", ""],
				["Grid North-South", ""]
			]] call Ares_fnc_ShowChooseDialog;

		if (count _pickFireMissionResult == 0) exitWith { ["Fire mission aborted."] call Ares_fnc_ShowZeusMessage; };
		_guns = (_pickFireMissionResult select 0) + 1;
		_rounds = (_pickFireMissionResult select 1);
		_ammo = (_artilleryAmmo select (_pickFireMissionResult select 2));
		_targetChooseAlgorithm = _pickFireMissionResult select 3;
                _targetPos = [];

		if (_rounds==0) then {
			_rounds = getNumber (configFile >> "CfgMagazines" >> _ammo >> "count");
		};

		if (_targetChooseAlgorithm == 0) then {
			// TODO: Add validation that coordinates are actually numbers.
			_targetX = _pickFireMissionResult select 4;
			_targetY = _pickFireMissionResult select 5;
			_targetPos = [_targetX,_targetY] call CBA_fnc_mapGridToPos;
		} else {
			_targetChooseAlgorithm = _targetChooseAlgorithm - 1;
			// Make sure we only consider targets that are in range.
			_targetsInRange = [];
			{
				if ((position _x) inRangeOfArtillery [_units, _ammo]) then
				{
					_targetsInRange pushBack _x;
				};
			} forEach _allTargets;
				
			if (count _targetsInRange == 0) exitWith { [objNull, "No targets in range"] call bis_fnc_showCuratorFeedbackMessage; };

			// Choose a target to fire at
			_selectedTarget = objNull;
			switch (_targetChooseAlgorithm) do
			{
				case 0: // Random
				{
					_selectedTarget = _targetsInRange call BIS_fnc_selectRandom;
				};
				case 1: // Nearest
				{
					_selectedTarget = [position _logic, _targetsInRange] call Ares_fnc_GetNearest;
				};
				case 2: // Furthest
				{
					_selectedTarget = [position _logic, _targetsInRange] call Ares_fnc_GetFarthest;
				};
				default // Specific target
				{
					_selectedTarget = _allTargets select (_targetChooseAlgorithm - FIRST_SPECIFIC_ARTILLERY_TARGET_INDEX);
				};
			};

			if (isNull _selectedTarget) exitWith { [objNull, "Target is null"] call bis_fnc_showCuratorFeedbackMessage; };

			_targetPos = position _selectedTarget;
		};
		if (count _targetPos < 3) exitWith { [objNull, "Target not acquired"] call bis_fnc_showCuratorFeedbackMessage; };

		// Generate a list of the actual units to fire.
		_gunsToFire = [];
		for "_i" from 1 to _guns do
		{
			_gunsToFire pushBack (_units select (_i - 1));
		};
		if (count _gunsToFire == 0) exitWith { [objNull, "No guns? how?"] call bis_fnc_showCuratorFeedbackMessage; };
		
		enableEngineArtillery true;
		// Get the ETA and exit if any one of the guns can't reach the target.
		_roundEta = -1;
		_checkedGuns = 0;
		{
			_eta = (_x getArtilleryETA [_targetPos, _ammo]);
			_checkedGuns = _checkedGuns + 1;

			if (_eta == -1) exitWith {
				_dx = (_targetPos select 0) - (position _x select 0);
				_dy = (_targetPos select 1) - (position _x select 1);
				_dz = (_targetPos select 2) - (position _x select 2);
				[format ["Target not in range of gun %1. Distance: %2. Pos: %3", _checkedGuns, sqrt (_dx*_dx+_dy*_dy+_dz*_dz), _targetPos]] call Ares_fnc_ShowZeusMessage;
			};
			if (_roundEta==-1 || _eta < _roundEta) then { _roundEta = _eta; };
		} forEach _gunsToFire;
		if (_roundEta == -1) exitWith { [format ["Target not in range. Checked %1 guns from %2.", _checkedGuns, _guns]] call Ares_fnc_ShowZeusMessage; };

		// Fire the guns
		{
			[[_x, _targetPos, _ammo, _rounds], "Ares_FireArtilleryFunction", _x] call BIS_fnc_MP;
		} forEach _gunsToFire;
		["Firing %1x%2 rounds of '%3' at target. ETA %4", _guns, _rounds, _ammo, _roundEta] call Ares_fnc_ShowZeusMessage;
	}
] call Ares_fnc_RegisterCustomModule;
