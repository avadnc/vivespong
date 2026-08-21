@tool
extends McpTestSuite

const _AiPaddle := preload("res://scripts/ai_paddle.gd")
const _Main := preload("res://scripts/main.gd")
const _Ball := preload("res://scripts/ball.gd")
const _Paddle := preload("res://scripts/paddle.gd")
const _ScoreUI := preload("res://ui/score_ui.gd")
const _MatchState := preload("res://scripts/match_state.gd")
const _Court := preload("res://scripts/court.gd")


func suite_name() -> String:
	return "ai_paddle"


func _wired_main():
	var main = _Main.new()
	track(main)
	var ball = _Ball.new()
	var hud = _ScoreUI.new()
	var p1 = _Paddle.new()
	var p2 = _Paddle.new()
	track(ball)
	track(hud)
	track(p1)
	track(p2)
	var s1 := Label.new()
	var s2 := Label.new()
	var msg := Label.new()
	var fps := Label.new()
	track(s1)
	track(s2)
	track(msg)
	track(fps)
	hud.setup_labels(s1, s2, msg, fps)
	main.configure_for_test(ball, hud, _MatchState.new(), p1, p2)
	return main


func _enter_tree(node: Node) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.add_child(node)


func test_moves_right_when_ball_is_right() -> void:
	assert_true(is_equal_approx(_AiPaddle.compute_axis(0.0, 2.0), 1.0), "right")


func test_moves_left_when_ball_is_left() -> void:
	assert_true(is_equal_approx(_AiPaddle.compute_axis(0.0, -2.0), -1.0), "left")


func test_stays_when_aligned() -> void:
	assert_true(is_equal_approx(_AiPaddle.compute_axis(1.0, 1.0), 0.0), "aligned")


func test_stays_inside_deadzone() -> void:
	var dz: float = _AiPaddle.ALIGN_DEADZONE
	assert_true(is_equal_approx(_AiPaddle.compute_axis(0.0, dz * 0.5), 0.0), "deadzone")


func test_vs_cpu_keeps_p2_input_disabled() -> void:
	var main = _wired_main()
	main.vs_cpu = true
	main._set_paddles_input_enabled(true)
	assert_true(main._p1.input_enabled)
	assert_false(main._p2.input_enabled)


func test_tick_cpu_moves_p2_toward_ball() -> void:
	var main = _wired_main()
	_enter_tree(main._p2)
	_enter_tree(main._ball)
	main.vs_cpu = true
	main.phase = main.MatchPhase.PLAYING
	main._p2.speed = 10.0
	main._p2.home_z = 9.0
	main._p2.global_position = Vector3(0.0, 0.0, 9.0)
	main._ball.global_position = Vector3(2.0, 0.0, 0.0)
	main.tick_cpu(0.1)
	assert_true(main._p2.global_position.x > 0.0, "moves right")


func test_tick_cpu_does_nothing_when_vs_cpu_off() -> void:
	var main = _wired_main()
	_enter_tree(main._p2)
	_enter_tree(main._ball)
	main.vs_cpu = false
	main.phase = main.MatchPhase.PLAYING
	main._p2.speed = 10.0
	main._p2.global_position = Vector3(0.0, 0.0, 9.0)
	main._ball.global_position = Vector3(2.0, 0.0, 0.0)
	main.tick_cpu(0.1)
	assert_true(is_equal_approx(main._p2.global_position.x, 0.0), "idle")


func test_tick_cpu_does_nothing_when_won() -> void:
	var main = _wired_main()
	_enter_tree(main._p2)
	_enter_tree(main._ball)
	main.vs_cpu = true
	main.phase = main.MatchPhase.WON
	main._p2.speed = 10.0
	main._p2.global_position = Vector3(0.0, 0.0, 9.0)
	main._ball.global_position = Vector3(2.0, 0.0, 0.0)
	main.tick_cpu(0.1)
	assert_true(is_equal_approx(main._p2.global_position.x, 0.0), "won idle")
