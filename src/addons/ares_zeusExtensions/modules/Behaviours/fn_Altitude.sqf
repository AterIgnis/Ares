#include "\ares_zeusExtensions\module_header.hpp"

_unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (alive _unit) then
{
	_dialogResult = [
		"Flight parameters",
		[
			["Speed", ["Limited", "Normal", "Full"]],
			["Altitude", [], 100]
		]
	] call Ares_fnc_ShowChooseDialog;

	if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

	_speed = _dialogResult select 0;
	_altitude = parseNumber (_dialogResult select 1);

	switch (_speed) do {
		case 0: {
			_speed = "LIMITED";
		};
		case 1: {
			_speed = "NORMAL";
		};
		case 2: {
			_speed = "FULL";
		};
	};
	_unit setSpeedMode _speed;

	_wpIdx = currentWaypoint group _unit;
	_wps = waypoints group _unit;
	if (_wpIdx >= count _wps) then {
		_tempPos = getPosATL _unit;
		_wpPos = [_tempPos select 0, _tempPos select 1, _altitude];
	} else {
		_wp = _wps select _wpIdx;
		_tempPos = getWPPos _wp;
		_wpPos = [_tempPos select 0, _tempPos select 1, _altitude];
		_wp setWPPos _wpPos;
	};
	_unit move _wpPos;
	_unit flyInHeight _altitude;
};

#include "\ares_zeusExtensions\module_footer.hpp"
