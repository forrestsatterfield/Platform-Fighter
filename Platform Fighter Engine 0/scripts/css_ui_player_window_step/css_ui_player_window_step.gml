function css_ui_player_window_step()
	{
	//Exit if a popup is open
	if (popup_is_open()) then exit;

	if (obj_css_ui.state == CSS_STATE.normal)
		{
		//Exit out if it's a CPU
		if (css_player_get(player_id, CSS_PLAYER.is_cpu)) then return;
		
		//Inputs
		var _custom = css_player_get(player_id, CSS_PLAYER.custom);
		var _device_id = _custom.device_id;
		var _confirm = mis_device_input(_device_id, MIS_INPUT.confirm);
		var _option = mis_device_input(_device_id, MIS_INPUT.option);
		var _back = mis_device_input(_device_id, MIS_INPUT.back);
		var _back_held = mis_device_input(_device_id, MIS_INPUT.back, true);
		var _delete = mis_device_input(_device_id, MIS_INPUT.remove);
		var _next = mis_device_input(_device_id, MIS_INPUT.page_next);
		var _last = mis_device_input(_device_id, MIS_INPUT.page_last);
		var _start = mis_device_input(_device_id, MIS_INPUT.start);
		var _confirm_repeated = mis_device_input_repeated(_device_id, MIS_INPUT.confirm);
		var _back_repeated = mis_device_input_repeated(_device_id, MIS_INPUT.back);
		var _stick_press = mis_device_stick_press_repeated(_device_id);
		var _stick_values = mis_device_stick_values(_device_id);
		var _rl = sign(_stick_values.x);
		var _ud = sign(_stick_values.y);

		//States
		switch (state)
			{
			case CSS_PLAYER_WINDOW_STATE.select_character:
				//Recall token
				if ((_back || _delete) && _custom.token_held == noone)
					{
					_custom.token_held = player_id;
					}
					
				//Hold to go back
				if (_back_held > 0)
					{
					obj_css_ui.css_back_button_timer = _back_held;
					}
					
				//Change color
				if (_option || _next || _last)
					{
					var _char = css_player_get(player_id, CSS_PLAYER.character);
					css_player_set
						(
						player_id, 
						CSS_PLAYER.color, 
						css_character_color_get_next
							(
							player_id, 
							_char,
							css_player_get(player_id, CSS_PLAYER.color),
							_option ? 1 : sign(_next - _last),
							)
						);
						
					//Store the favorite color
					var _favorite_colors = profile_get(css_player_get(player_id, CSS_PLAYER.profile), PROFILE.favorite_colors);
					_favorite_colors[@ _char] = css_player_get(player_id, CSS_PLAYER.color);
					}
					
				//Start shortcut
				if (_start && css_can_start_match())
					{
					menu_sound_play(snd_menu_start);
					with (obj_css_ui)
						{
						css_engine_player_data_save();
						engine().mis_json = mis_devices_save();
						engine().load_css_data = true;
						room_goto(rm_sss);
						exit;
						}
					}
				break;
			case CSS_PLAYER_WINDOW_STATE.select_profile:
				//Scrolling
				if (_stick_press.y)
					{
					menu_sound_play(snd_menu_move);
					profile_current = modulo(profile_current + _ud, profile_count());
					while (profile_current > profile_scroll + 3) 
						{
						profile_scroll++;
						}
					while (profile_current < profile_scroll) 
						{
						profile_scroll--;
						}
					}
		
				//Selecting a profile
				if (_confirm)
					{
					menu_sound_play(snd_menu_select);
					css_player_set(player_id, CSS_PLAYER.profile, profile_current);
					state = CSS_PLAYER_WINDOW_STATE.select_character;
					//Re activate cursor
					_custom.cursor_active = true;
					break;
					}
					
				//Cancel (don't change the profile)
				if (_back)
					{
					state = CSS_PLAYER_WINDOW_STATE.select_character;
					//Re activate cursor
					_custom.cursor_active = true;
					break;
					}
					
				//Create a new profile
				if (_option)
					{
					menu_sound_play(snd_menu_alert);
					//New profile
					state = CSS_PLAYER_WINDOW_STATE.create_profile;
					break;
					}
					
				//Delete profiles. Cannot delete autogenerated profiles or profiles used by other players
				if (_delete)
					{
					menu_sound_play(snd_menu_back);
					if (!profile_get(profile_current, PROFILE.autogenerated))
						{
						var _used = false;
						var _array = css_players_get_array();
						for (var i = 0; i < array_length(_array); i++)
							{
							if (css_player_get(_array[@ i], CSS_PLAYER.profile) == profile_current)
								{
								_used = true;
								break;
								}
							}
						if (!_used)
							{
							profile_destroy(profile_current);
							
							//Make sure the profile indexes still line up correctly
							var _deleted_profile = profile_current;
							with (obj_css_player_window)
								{
								//Move down the profile index if it was after the deleted profile...
								var _profile_number = css_player_get(player_id, CSS_PLAYER.profile);
								if (_profile_number > _deleted_profile)
									{
									css_player_set(player_id, CSS_PLAYER.profile, _profile_number - 1);
									}
									
								//Make sure other players' cursors are not on an undefined profile
								profile_scroll = 0;
								profile_current = modulo(profile_current, profile_count());
								}
								
							//Save profiles
							profile_save_all();
							}
						break;
						}
					}
				break;
			case CSS_PLAYER_WINDOW_STATE.create_profile:
				//Scrolling
				if (_stick_press.x)
					{
					profile_new_letter = modulo(profile_new_letter + _rl, array_length(profile_valid_letters));
					}
			
				//Adding a letter
				if (_confirm_repeated)
					{
					menu_sound_play(snd_menu_select);
					if (string_length(profile_new_name) < profile_name_length_max)
						{
						profile_new_name += profile_valid_letters[profile_new_letter];
						}
					}
					
				//Deleting a letter
				if (_back_repeated)
					{
					profile_new_name = string_copy(profile_new_name, 0, string_length(profile_new_name) - 1);
					}
					
				//Cancel
				if (_delete)
					{
					state = CSS_PLAYER_WINDOW_STATE.select_profile;
					profile_new_letter = 0;
					profile_new_name = "";
					break;
					}
					
				//Creating the new profile
				if (_option)
					{
					if (profile_new_name != "")
						{
						menu_sound_play(snd_menu_start);
						var _profile = profile_create(profile_new_name, custom_controls_create(), false);
						css_player_set(player_id, CSS_PLAYER.profile, _profile);
						//Save profiles
						profile_save_all();
						//Re-activate cursor
						state = CSS_PLAYER_WINDOW_STATE.select_character;
						_custom.cursor_active = true;
						profile_new_letter = 0;
						profile_new_name = "";
						}
					break;
					}
				break;
			case CSS_PLAYER_WINDOW_STATE.controls:
				var _device_type = mis_device_convert_to_game_device(mis_device_get(_device_id, MIS_DEVICE_PROPERTY.device_type));
				
				//Scrolling
				if (_stick_press.y)
					{
					menu_sound_play(snd_menu_move);
					
					var _length = 0;
					if (_device_type == DEVICE.controller) then _length = CC_INPUT_CONTROLLER.LENGTH;
					else if (_device_type == DEVICE.keyboard) then _length = CC_INPUT_KEYBOARD.LENGTH;
					else if (_device_type == DEVICE.touch) then _length = CC_INPUT_TOUCH.LENGTH;
					else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
			
					//Add in the right stick input
					_length += 1;
			
					//Add in the special control settings (SCS)
					_length += SCS.LENGTH;
					
					//Add in the advanced controller settings (ACS)
					_length += ACS.LENGTH;
			
					custom_controls_current = modulo(custom_controls_current + _ud, _length);
					while (custom_controls_current > custom_controls_scroll + 3) 
						{
						custom_controls_scroll++;
						}
					while (custom_controls_current < custom_controls_scroll) 
						{
						custom_controls_scroll--;
						}
					}
		
				//Cancel
				if (_back || _delete)
					{
					state = CSS_PLAYER_WINDOW_STATE.select_character;
					//Re activate cursor
					_custom.cursor_active = true;
					//Save profiles
					profile_save_all();
					break;
					}
			
				//Remap / Toggle
				if (_confirm || _option)
					{
					menu_sound_play(snd_menu_select);
					
					var _length = 0;
					if (_device_type == DEVICE.controller) then _length = CC_INPUT_CONTROLLER.LENGTH;
					else if (_device_type == DEVICE.keyboard) then _length = CC_INPUT_KEYBOARD.LENGTH;
					else if (_device_type == DEVICE.touch) then _length = CC_INPUT_TOUCH.LENGTH;
					else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
					
					//Inputs
					if (custom_controls_current < _length)
						{
						state = CSS_PLAYER_WINDOW_STATE.control_set;
						custom_controls_choosing = false;
						custom_controls_array = [];
						}
					//Right stick input
					else if (custom_controls_current == _length)
						{
						var _right_stick = custom_controls_struct.right_stick_input;
						custom_controls_struct.right_stick_input = modulo(_right_stick + 1, INPUT.LENGTH);
						}
					//SCS
					else if (custom_controls_current <= SCS.LENGTH + _length)
						{
						var _scs_array = custom_controls_struct.scs;
						var _n = (custom_controls_current - _length - 1);
						_scs_array[@ _n] = !_scs_array[@ _n];
						}
					//ACS
					else
						{
						var _acs_array = custom_controls_struct.acs;
						var _n = (custom_controls_current - _length - SCS.LENGTH - 1);
						_acs_array[@ _n] = acs_change(_n, _acs_array[@ _n]);
						}
					break;
					}
				break;
			case CSS_PLAYER_WINDOW_STATE.control_set:
				var _any_input = false;
				var _any_held = false;
				var _stop = false;
				var _device_type = mis_device_convert_to_game_device(mis_device_get(_device_id, MIS_DEVICE_PROPERTY.device_type));
				var _device = mis_device_get(_device_id, MIS_DEVICE_PROPERTY.port_number);
		
				//Inputs
				if (_device_type == DEVICE.controller)
					{
					//Control sticks don't count
					_any_input = controller_any_input(_device, 1, true);
					_any_held = controller_any_input(_device, 1, false);
					_stop = gamepad_button_check_pressed(_device, menu_select_button);
					}
				else if (_device_type == DEVICE.keyboard)
					{
					_any_input = keyboard_check_pressed(vk_anykey);
					_any_held = keyboard_check(vk_anykey);
					_stop = keyboard_check_pressed(menu_select_key);
					}
				else if (_device_type == DEVICE.touch)
					{
					_any_input = false;
					_any_held = 0;
					_stop = false;
					with (obj_touch_button)
						{
						//By default, the Pause button is numbered -1
						if (pressed)
							{
							if (number == -1)
								{
								_stop = true;
								}
							else
								{
								_any_input = true;
								_any_held = true;
								}
							}
						else if (held_time > 0)
							{
							_any_held = true;
							}
						}
					}
				else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
			
				//Actions
				if (_any_input)
					{
					custom_controls_choosing = true;
			
					//Add to the array
					var _currently_held = [];
					if (_device_type == DEVICE.controller)
						{
						//Limit to 3 buttons per input
						if (array_length(custom_controls_array) < 3)
							{
							_currently_held = controller_get_input(_device);
							for (var i = 0; i < array_length(_currently_held); i++)
								{
								var _exists = false;
								for (var m = 0; m < array_length(custom_controls_array); m++)
									{
									if (custom_controls_array[@ m] == _currently_held[@ i])
										{
										_exists = true;
										break;
										}
									}
								if (!_exists) then array_push(custom_controls_array, _currently_held[@ i]);
								}
							}
						}
					else if (_device_type == DEVICE.keyboard)
						{
						//Limit to 3 keys per input
						if (array_length(custom_controls_array) < 3)
							{
							_currently_held = keyboard_key;
							var _exists = false;
							for (var m = 0; m < array_length(custom_controls_array); m++)
								{
								if (custom_controls_array[@ m] == _currently_held)
									{
									_exists = true;
									break;
									}
								}
							if (!_exists) then array_push(custom_controls_array, _currently_held);
							}
						}
					else if (_device_type == DEVICE.touch)
						{
						//Limit to 1 button per input
						if (array_length(custom_controls_array) < 1)
							{
							_currently_held = 0;
							with (obj_touch_button)
								{
								if (held_time > 0)
									{
									_currently_held = number;
									break;
									}
								}
							var _exists = false;
							for (var m = 0; m < array_length(custom_controls_array); m++)
								{
								if (custom_controls_array[@ m] == _currently_held)
									{
									_exists = true;
									break;
									}
								}
							if (!_exists) then array_push(custom_controls_array, _currently_held);
							}
						}
					else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
					}
				else if (!_any_held && custom_controls_choosing)
					{
					custom_controls_choosing = false;
					state = CSS_PLAYER_WINDOW_STATE.controls;
			
					//Set the new controls
					var _inputs = [];
					if (_device_type == DEVICE.controller) then _inputs = custom_controls_struct.inputs_controller;
					else if (_device_type == DEVICE.keyboard) then _inputs = custom_controls_struct.inputs_keyboard;
					else if (_device_type == DEVICE.touch) then _inputs = custom_controls_struct.inputs_touch;
					else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
					_inputs[@ custom_controls_current] = custom_controls_array;
					break;
					}
			
				//Stopping / Clearing the controls
				if (_stop)
					{
					custom_controls_choosing = false;
					state = CSS_PLAYER_WINDOW_STATE.controls;
					var _inputs = [];
					if (_device_type == DEVICE.controller) then _inputs = custom_controls_struct.inputs_controller;
					else if (_device_type == DEVICE.keyboard) then _inputs = custom_controls_struct.inputs_keyboard;
					else if (_device_type == DEVICE.touch) then _inputs = custom_controls_struct.inputs_touch;
					else crash("[css_ui_player_window_step] Invalid device type (", _device_type, ")");
					array_resize(_inputs[@ custom_controls_current], 0);
					break;
					}
				break;
			case CSS_PLAYER_WINDOW_STATE.ready:
				//Nothing
				break;
			}
		}
	}
/* Copyright 2023 Springroll Games / Yosi */