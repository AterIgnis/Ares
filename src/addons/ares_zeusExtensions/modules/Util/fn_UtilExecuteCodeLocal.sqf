#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_unitUnderCursor = [_logic, false] call Ares_fnc_GetUnitUnderCursor;

if (not (missionNamespace getVariable ["Ares_Allow_Zeus_To_Execute_Code", true])) exitWith
{
	["This module has been disabled by the mission creator."] call Ares_fnc_ShowZeusMessage;
};

missionNamespace setVariable ["Ares_CopyPaste_Dialog_Text", ""];
missionNamespace setVariable ["Ares_CopyPaste_Dialog_Result", ""];
_dialog = createDialog "Ares_CopyPaste_Dialog";
waitUntil { dialog };
waitUntil { !dialog };
_dialogResult = missionNamespace getVariable ["Ares_CopyPaste_Dialog_Result", -1];
if (_dialogResult == 1) then
{
	_pastedText = missionNamespace getVariable ["Ares_CopyPaste_Dialog_Text", "[]"];
	try
	{
		[position _logic, _unitUnderCursor] call (compile _pastedText);
	}
	catch
	{
		diag_log _exception;
		["Failed to parse code. See RPT for error."] call Ares_fnc_ShowZeusMessage;
	};
};

#include "\ares_zeusExtensions\module_footer.hpp"
