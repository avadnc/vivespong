@tool
extends McpTestSuite

const _Paddle := preload("res://scripts/paddle.gd")
const _Court := preload("res://scripts/court.gd")


func suite_name() -> String:
	return "paddle"


func _make_paddle() -> CharacterBody3D:
	var p: CharacterBody3D = _Paddle.new()
	track(p)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.add_child(p)
	return p


func test_clamp_center_unchanged() -> void:
	assert_true(is_equal_approx(_Paddle.compute_clamped_x(0.0, 1.2, 6.0), 0.0), "center")


func test_clamp_stops_at_right_edge() -> void:
	assert_true(is_equal_approx(_Paddle.compute_clamped_x(10.0, 1.2, 6.0), 4.8), "right")


func test_clamp_stops_at_left_edge() -> void:
	assert_true(is_equal_approx(_Paddle.compute_clamped_x(-10.0, 1.2, 6.0), -4.8), "left")


func test_apply_axis_moves_only_x() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.home_z = -9.0
	p.global_position = Vector3.ZERO
	p.speed = 10.0
	p.apply_axis(1.0, 0.1)
	assert_true(is_equal_approx(p.global_position.x, 1.0), "x")
	assert_true(is_equal_approx(p.global_position.y, 0.0), "y")
	assert_true(is_equal_approx(p.global_position.z, 0.0), "z")


func test_player1_defaults_to_ad_actions() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.player_id = 1
	assert_eq(p.get_left_action(), "player1_left")
	assert_eq(p.get_right_action(), "player1_right")


func test_bind_move_actions_overrides_defaults() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.player_id = 1
	p.bind_move_actions("player2_left", "player2_right")
	assert_eq(p.get_left_action(), "player2_left")
	assert_eq(p.get_right_action(), "player2_right")


func test_physics_step_disabled_does_not_move() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.input_enabled = false
	p.global_position = Vector3.ZERO
	p.physics_step(0.1)
	assert_true(is_equal_approx(p.global_position.x, 0.0), "disabled")


func test_apply_axis_zero_does_not_move() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.global_position = Vector3.ZERO
	p.speed = _Court.PADDLE_SPEED
	p.apply_axis(0.0, 0.1)
	assert_true(is_equal_approx(p.global_position.x, 0.0), "x")
	assert_true(is_equal_approx(p.global_position.y, 0.0), "y")
	assert_true(is_equal_approx(p.global_position.z, 0.0), "z")


func test_apply_axis_respects_clamp() -> void:
	var p: CharacterBody3D = _make_paddle()
	p.global_position = Vector3(4.7, 0.0, 0.0)
	p.speed = _Court.PADDLE_SPEED
	p.apply_axis(1.0, 1.0)
	assert_true(is_equal_approx(p.global_position.x, _Court.playable_half_x()), "x")
