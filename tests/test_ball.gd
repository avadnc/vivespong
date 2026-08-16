@tool
extends McpTestSuite

const _Ball := preload("res://scripts/ball.gd")
const _Court := preload("res://scripts/court.gd")


func suite_name() -> String:
	return "ball"


func _make_ball() -> CharacterBody3D:
	var ball: CharacterBody3D = _Ball.new()
	track(ball)
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.add_child(ball)
	return ball


func test_center_hit_goes_straight() -> void:
	var d: Vector3 = _Ball.compute_paddle_bounce(0.0, 1.0)
	assert_true(is_equal_approx(d.x, 0.0), "x")
	assert_true(d.z < 0.0, "flip z")


func test_right_edge_opens_positive_x() -> void:
	var d: Vector3 = _Ball.compute_paddle_bounce(1.0, 1.0)
	assert_true(d.x > 0.0, "x>0")
	assert_true(d.z < 0.0, "z<0")


func test_left_edge_opens_negative_x() -> void:
	var d: Vector3 = _Ball.compute_paddle_bounce(-1.0, -1.0)
	assert_true(d.x < 0.0, "x<0")
	assert_true(d.z > 0.0, "z>0")


func test_offset_is_clamped() -> void:
	var clamped: Vector3 = _Ball.compute_paddle_bounce(4.0, 1.0)
	var edge: Vector3 = _Ball.compute_paddle_bounce(1.0, 1.0)
	assert_true(is_equal_approx(clamped.x, edge.x), "x")
	assert_true(is_equal_approx(clamped.y, edge.y), "y")
	assert_true(is_equal_approx(clamped.z, edge.z), "z")


func test_bounce_dir_is_unit_xz() -> void:
	var dir: Vector3 = _Ball.compute_paddle_bounce(1.0, 1.0)
	assert_true(is_equal_approx(dir.length(), 1.0), "length")
	assert_true(is_equal_approx(dir.y, 0.0), "y")


func test_max_angle_matches_constant() -> void:
	var dir: Vector3 = _Ball.compute_paddle_bounce(1.0, 1.0)
	assert_true(
		is_equal_approx(absf(dir.x / dir.z), _Court.PADDLE_BOUNCE_MAX_X),
		"max angle"
	)


func test_reflect_wall_flips_x_only() -> void:
	var reflected: Vector3 = _Ball.reflect_wall(Vector3(3.0, 0.0, 4.0), Vector3.LEFT)
	assert_true(reflected.x < 0.0, "x sign")
	assert_true(is_equal_approx(reflected.x, -3.0), "x")
	assert_true(is_equal_approx(reflected.z, 4.0), "z")
	assert_true(is_equal_approx(reflected.y, 0.0), "y")


func test_accelerate_adds_increment() -> void:
	assert_true(is_equal_approx(_Ball.accelerate(8.0, 0.5, 20.0), 8.5), "inc")


func test_accelerate_caps_at_max() -> void:
	assert_true(is_equal_approx(_Ball.accelerate(19.8, 0.5, 20.0), 20.0), "cap")
	assert_true(is_equal_approx(_Ball.accelerate(20.0, 0.5, 20.0), 20.0), "stay")


func test_stop_and_center_kills_motion() -> void:
	var ball: CharacterBody3D = _make_ball()
	ball.serve(Vector3.FORWARD)
	ball.stop_and_center()
	assert_false(ball.is_live)
	assert_true(is_equal_approx(ball.global_position.x, 0.0), "x")
	assert_true(is_equal_approx(ball.global_position.y, _Court.BALL_Y), "y")
	assert_true(is_equal_approx(ball.global_position.z, 0.0), "z")
	assert_true(ball.velocity.is_zero_approx())


func test_serve_uses_start_speed() -> void:
	var ball: CharacterBody3D = _make_ball()
	assert_true(is_equal_approx(ball.start_speed, _Court.BALL_START_SPEED), "default")
	ball.serve(Vector3(0.5, 0.0, 1.0))
	assert_true(ball.is_live)
	assert_true(is_equal_approx(ball.speed, ball.start_speed), "speed")
	assert_true(is_equal_approx(ball.velocity.length(), ball.start_speed), "len")
	assert_true(is_equal_approx(ball.velocity.y, 0.0), "y")


func test_serve_toward_player1_has_negative_z() -> void:
	var ball: CharacterBody3D = _make_ball()
	ball.serve_toward(1)
	assert_true(ball.velocity.z < 0.0, "z<0")


func test_serve_toward_player2_has_positive_z() -> void:
	var ball: CharacterBody3D = _make_ball()
	ball.serve_toward(2)
	assert_true(ball.velocity.z > 0.0, "z>0")
