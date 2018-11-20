#include "\ares_zeusExtensions\module_header.hpp"

_scopeModes = ["Spawn"];
_enableDisable = ["Enabled", "Disabled"];
_unit = [_logic, false] call Ares_fnc_GetUnitUnderCursor;

if (not isNull _unit) then {
  _scopeModes = ["Unit", "Group", "Side", "Spawn"];
};

_units = [];
_aiModes = [["TARGET","AUTOTARGET"], ["FSM"], ["SUPPRESSION"], ["COVER"], ["AUTOCOMBAT"], ["MINEDETECTION"], ["MOVE"]];
_dialogResult = [
  "Choose Mode",
  [
    ["Change AI for", _scopeModes],
    ["Target", _enableDisable, 0],
    ["FSM", _enableDisable, 0],
    ["Suppression", _enableDisable, 0],
    ["Cover", _enableDisable, 0],
    ["Autocombat", _enableDisable, 0],
    ["Mines", _enableDisable, 0],
    ["Move", _enableDisable, 0]
  ]
] call Ares_fnc_ShowChooseDialog;

if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

_setDefault = false;
if (count _scopeModes == 1) then {
  if ((_dialogResult select 0) == 0) then {
    _setDefault = true;
  };
}
else {
  switch (_dialogResult select 0) do
  {
    case 0: {
      _units = [_unit];
    };
    case 1: {
      _units = units (group _unit);
    };
    case 2: {
      {
        if (side _x == side _unit) then {
          _units pushBack _x;
        };
      } foreach allUnits;
    };
    case 3: {
      _setDefault = true;
    };
  };
};

if (_setDefault) then {
  Ares_default_AI_behaviors = [];
  {
    _modes = _x;
    _dialogIdx = _forEachIndex + 1;
    {
      _mode = _x;
      _value = true;
      if ((_dialogResult select _dialogIdx) > 0) then {
        _value = false;
      };
      Ares_default_AI_behaviors pushBack [_mode, _value];
    } foreach _modes;
  } foreach _aiModes;
}
else {
  if (count _units > 0) then {
    {
      _unit = _x;
      {
        _modes = _x;
        _dialogIdx = _forEachIndex + 1;
        {
          _mode = _x;
          _cmd = "enableAI";
          if ((_dialogResult select _dialogIdx) > 0) then {
            _cmd = "disableAI";
          };
          [_unit, _mode] remoteExec [_cmd, _unit];
        } foreach _modes;
      } foreach _aiModes;
    } forEach _units;
    ["Changed AI for %1 units.", count _units] call Ares_fnc_ShowZeusMessage;
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
