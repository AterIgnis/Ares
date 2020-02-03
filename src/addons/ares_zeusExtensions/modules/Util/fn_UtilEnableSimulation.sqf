#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_unitUnderCursor = [_logic, false] call Ares_fnc_GetUnitUnderCursor;

if (isNull _unitUnderCursor) then
{
  ["Module must be dropped on an object."] call Ares_fnc_ShowZeusMessage;
}
else
{
  _codeBlock = {_this enableSimulationGlobal true;};
  [_codeBlock, _unitUnderCursor, false] call Ares_fnc_BroadcastCode;
  ["Simulation enabled."] call Ares_fnc_ShowZeusMessage;
};

#include "\ares_zeusExtensions\module_footer.hpp"
