#include "\ares_zeusExtensions\module_header.hpp"

_unit = [_logic] call Ares_fnc_GetUnitUnderCursor;

if (not isNull _unit) then {
  _units = [];
  _aiModes = [["TARGET","AUTOTARGET"], ["FSM"], ["SUPPRESSION"], ["COVER"], ["AUTOCOMBAT"]];
  _dialogResult = [
    "Choose Mode",
    [
      ["Change AI for", ["Unit", "Group", "Side"]],
      ["Target", ["Enabled", "Disabled"], 0],
      ["FSM", ["Enabled", "Disabled"], 0],
      ["Suppression", ["Enabled", "Disabled"], 0],
      ["Cover", ["Enabled", "Disabled"], 0],
      ["Autocombat", ["Enabled", "Disabled"], 0]
    ]
  ] call Ares_fnc_ShowChooseDialog;

  if (count _dialogResult == 0) exitWith { [objNull, "Aborted"] call bis_fnc_showCuratorFeedbackMessage; };

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
  };

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
          [[_unit, _mode], _cmd, _unit] call BIS_fnc_MP;
        } foreach _modes;
      } foreach _aiModes;
    } forEach _units;
    ["Changed AI for %1 units.", count _units] call Ares_fnc_ShowZeusMessage;
  };
};

#include "\ares_zeusExtensions\module_footer.hpp"
