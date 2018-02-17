#include "\ares_zeusExtensions\module_header.hpp"

_deleteModuleOnExit = false;

_logic = _this select 0;
_activated = _this select 2;

if (_activated && local _logic) then {
  _unit = [_logic] call Ares_fnc_GetUnitUnderCursor;
  
  if (!isNull _unit && alive _unit) then {
    [_logic, _unit] spawn {
      _logic = _this select 0;
      _heli = _this select 1;

      _heli enableRopeAttach true;
      while { not isNull _logic && alive _heli} do
      {
        _pos = getPosASL _heli;
        _pos set [2, (_pos select 2) + 1];
        _logic setPosASL _pos;

        {
          _heli setSlingLoad _x;
          [objnull, format["Trying slingload %1 to %2", typeOf _x, typeOf _heli]] call bis_fnc_showCuratorFeedbackMessage;
        } foreach (synchronizedObjects _logic);
        _logic synchronizeObjectsRemove (synchronizedObjects _logic);

        sleep 0.1;
      };
      if (alive _heli) then {
        _heli setSlingLoad objNull;
      };
      if (not isNull _logic) then {
        deletevehicle _logic;
      };
    };
  } else {
    deletevehicle _logic;
  };
} else {
  deletevehicle _logic;
};

#include "\ares_zeusExtensions\module_footer.hpp"
