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
