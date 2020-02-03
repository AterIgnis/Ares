_scripts = [
		"Arsenal_AddArsenal",
		"Arsenal_AddArsenalAmmo",
		"Arsenal_AddFullArsenal",
		"Arsenal_CopyToClipboard",
		"Arsenal_PasteFromClipboard",
		"Equipment_RemoveWeaponOptics",
		"SaveLoad_CreateMissionSQF",
		"Util_MakeZeusInvisible",
		"Util_MakeZeusVisible",
		"Util_RemoveAllActions"
	];
{
	call compile preprocessFileLineNumbers ("\ares_zeusExtensions\scripts\" + _x + ".sqf");
} forEach _scripts;

// We need this to be registered so that the artillery modules can use it to
// fire artillery where it is local.
if (isNil "Ares_FireArtilleryFunction") then {
	Ares_FireArtilleryFunction = {
		_artilleryUnit = _this select 0;
		_targetPos = _this select 1;
		_ammoType = _this select 2;
		_roundsToFire = _this select 3;

		enableEngineArtillery true;

		_artilleryUnit doArtilleryFire [_targetPos, _ammoType, _roundsToFire];
	};
};
if (isNil "Ares_CommandChat") then {
	Ares_CommandChat = {
		_side = _this select 0;
		_sign = _this select 1;
		_text = _this select 2;
		if (alive player && side player == _side) then {
			[_side, _sign] commandChat format["%1",_text];
		} else {
		    if ([player] call Ares_fnc_IsZeus) then {
		        systemChat format["%1 (%2): %3",_side, _sign, _text];
		    };
		};
	};
};
