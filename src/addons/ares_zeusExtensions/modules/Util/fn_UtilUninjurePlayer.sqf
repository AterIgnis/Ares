#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_unitUnderCursor = [_logic, false] call Ares_fnc_GetUnitUnderCursor;

if (isNull _unitUnderCursor) then
{
	["Module must be dropped on an object."] call Ares_fnc_ShowZeusMessage;
}
else
{
	if (!isNil "FAR_HandleRevive") then
	{
		publicVariable "FAR_HandleRevive";
		[[_unitUnderCursor], "FAR_HandleRevive", _unitUnderCursor] call BIS_fnc_MP;
	};
};

#include "\ares_zeusExtensions\module_footer.hpp"
