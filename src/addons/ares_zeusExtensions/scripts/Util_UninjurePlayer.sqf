[
	"Util",
	"Uninjure Player",
	{
		_unitUnderCursor = _this select 1;
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
	}
] call Ares_fnc_RegisterCustomModule;
