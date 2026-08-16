@tool
extends McpTestSuite


func suite_name() -> String:
	return "input_map"


func _key_matches(ev: InputEventKey, key: Key) -> bool:
	return ev.keycode == key or ev.physical_keycode == key


func _action_has_key(action: String, key: Key) -> bool:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and _key_matches(ev as InputEventKey, key):
			return true
	return false


func test_player1_actions_exist() -> void:
	assert_true(InputMap.has_action("player1_left"), "player1_left")
	assert_true(InputMap.has_action("player1_right"), "player1_right")


func test_player2_actions_exist() -> void:
	assert_true(InputMap.has_action("player2_left"), "player2_left")
	assert_true(InputMap.has_action("player2_right"), "player2_right")


func test_start_action_exists() -> void:
	assert_true(InputMap.has_action("start"), "start")


func test_player1_left_has_key_a() -> void:
	assert_true(_action_has_key("player1_left", KEY_A), "KEY_A")


func test_player1_right_has_key_d() -> void:
	assert_true(_action_has_key("player1_right", KEY_D), "KEY_D")


func test_player2_left_has_key_left() -> void:
	assert_true(_action_has_key("player2_left", KEY_LEFT), "KEY_LEFT")


func test_player2_right_has_key_right() -> void:
	assert_true(_action_has_key("player2_right", KEY_RIGHT), "KEY_RIGHT")


func test_start_has_enter() -> void:
	assert_true(_action_has_key("start", KEY_ENTER), "KEY_ENTER")


func test_deadzone_on_joy_axes() -> void:
	var axis_actions: Array[String] = [
		"player1_left", "player1_right", "player2_left", "player2_right",
	]
	var found_motion: bool = false
	for action: String in axis_actions:
		for ev: InputEvent in InputMap.action_get_events(action):
			if ev is InputEventJoypadMotion:
				found_motion = true
				var dz: float = InputMap.action_get_deadzone(action)
				assert_true(
					is_equal_approx(dz, CourtExtents.INPUT_DEADZONE),
					"%s deadzone=%s" % [action, str(dz)]
				)
	assert_true(found_motion, "expected InputEventJoypadMotion on move actions")


func test_player1_joy_uses_device_0() -> void:
	var joy_events: Array[InputEvent] = _joy_events_for_actions(
		["player1_left", "player1_right"]
	)
	assert_true(joy_events.size() > 0, "P1 has joy events")
	for ev: InputEvent in joy_events:
		assert_eq(ev.device, 0, "P1 joy device")


func test_player2_joy_uses_device_1() -> void:
	var joy_events: Array[InputEvent] = _joy_events_for_actions(
		["player2_left", "player2_right"]
	)
	assert_true(joy_events.size() > 0, "P2 has joy events")
	for ev: InputEvent in joy_events:
		assert_eq(ev.device, 1, "P2 joy device")


func _joy_events_for_actions(actions: Array[String]) -> Array[InputEvent]:
	var out: Array[InputEvent] = []
	for action: String in actions:
		if not InputMap.has_action(action):
			continue
		for ev: InputEvent in InputMap.action_get_events(action):
			if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				out.append(ev)
	return out
