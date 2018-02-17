#include "\ares_zeusExtensions\module_header.hpp"

_unitToDisembark = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (alive _unitToDisembark) then
{
	_dialogResult = [
		"Disembark",
		[
			["Who?", ["Crew", "Passengers", "Everybody"], 1]
		]
	] call Ares_fnc_ShowChooseDialog;

	if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

	_units = [];

	if ((_dialogResult select 0) == 2) then
	{
		_units = crew _unitToDisembark;
	}
	else
	{
		_cargoOnly = ((_dialogResult select 0) == 1);
		{
			_isCargo = ((_x select 1) == "cargo");
			if ((not _cargoOnly && not _isCargo) || (_cargoOnly && _isCargo)) then
			{
				_units pushBack (_x select 0);
			};
		} foreach fullCrew _unitToDisembark;
	};

	{
		if(!isnull _x && alive _x) then {
			[_x] orderGetIn false;
			sleep 0.1;
			unAssignVehicle _x;
			sleep 0.1;
			_x leaveVehicle _unitToDisembark;
			sleep 0.1;
			_x action ["getOut", _unitToDisembark];
			sleep 0.1;
			moveOut _x;
			sleep 0.6;
		};
	} foreach _units;
};

#include "\ares_zeusExtensions\module_footer.hpp"
