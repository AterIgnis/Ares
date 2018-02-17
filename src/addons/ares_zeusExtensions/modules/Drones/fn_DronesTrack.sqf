//
#include "\ares_zeusExtensions\module_header.hpp"

_logic = _this select 0;
_activated = _this select 2;

_deleteModuleOnExit = false;

if (_activated && local _logic) then {
  _unit = [_logic, false] call Ares_fnc_GetUnitUnderCursor;

  if (!isNull _unit && alive _unit) then {
    _logic synchronizeObjectsAdd [_unit];
    [_logic, _unit] spawn {
      _logic = _this select 0;
      _uav = _this select 1;

      while { not isNull _logic && alive _uav} do
      {
        _pos = getPosASL _uav;
        _pos set [2, (_pos select 2) + 1.1];
        _logic setPosASL _pos;

        sleep 0.01;
      };
      if (not isNull _logic) then {
        deleteVehicle _logic;
      };
    };
  };

  _logic spawn {
    _logic = _this;
    while { not isNull _logic; } do {
      {
        _unit = _x;
        if (not alive _unit) then {
          _logic synchronizeObjectsRemove [_unit];
        };
      } foreach synchronizedObjects _logic;
      sleep 1;
    };
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
