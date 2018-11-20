[
	"Util",
	"Incarnate Player",
	{
		_unitUnderCursor = _this select 1;
		if (isNull _unitUnderCursor) then
		{
			["Module must be dropped on an object."] call Ares_fnc_ShowZeusMessage;
		}
		else
		{
			Ares_oneshotCodeBlockIncarn = {
				_who = _this select 0;
				_where = _this select 1;
				
				if (!local _who) exitwith { true; };

				if (!isPlayer _where && alive _where) then {
					selectPlayer _where;
                                
	                                if (!isNil "FAR_Player_Init") then { [] spawn FAR_Player_Init; };

                                        [] call bis_fnc_showRespawnMenu;
                                        BIS_fnc_respawnMenuPosition_draw = nil;
                                        BIS_fnc_respawnMenuPosition_mouseMoving = nil;
                                        BIS_fnc_respawnMenuPosition_mouseButtonClick = nil;
                                        BIS_fnc_respawnMenuPosition_systemSelect = nil;
                                        BIS_fnc_respawnMenuPosition_positions = nil;
                                        BIS_fnc_respawnMenuPosition_commitTime = nil;
                                        with uinamespace do {
                                        	BIS_fnc_respawnMenuPosition_ctrlList = nil;
                                                BIS_fnc_respawnMenuPosition_positions = nil
					};
				};
			};

			// Generate a list of the player objects and their names
			_playerList = [];
			_playerNameList = [];
			{
				if (isPlayer _x && _x != player) then
				{
					_playerList pushBack _x;
					_playerNameList pushBack (name _x);
				};
			} forEach allPlayers;

			_dialogResult =
				[
					"Incarnate Player",
					[
						["Player Name", _playerNameList]
					],
					false
				] call Ares_fnc_ShowChooseDialog;

			if ((count _dialogResult) > 0) then
			{
				_playerToIncarnate = _playerList select (_dialogResult select 0);
				publicVariable "Ares_oneshotCodeBlockIncarn";
				[[_playerToIncarnate,_unitUnderCursor], Ares_oneshotCodeBlockIncarn] remoteExec ["call", _playerToIncarnate];

				["Incarnation started."] call Ares_fnc_ShowZeusMessage;
			};
		};
	}
] call Ares_fnc_RegisterCustomModule;
