@tool
extends McpTestSuite

const _Main := preload("res://scripts/main.gd")
const _Ball := preload("res://scripts/ball.gd")
const _Paddle := preload("res://scripts/paddle.gd")
const _ScoreUI := preload("res://ui/score_ui.gd")
const _MatchState := preload("res://scripts/match_state.gd")
const _Court := preload("res://scripts/court.gd")


func suite_name() -> String:
	return "score_flow"


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


func test_begin_match_starts_in_ready() -> void:
	var main = _wired_main()
	main.begin_match()
	assert_eq(main.phase, main.MatchPhase.READY)
	assert_eq(main.match_state.player1_score, 0)
	assert_eq(main.match_state.player2_score, 0)
	assert_false(main._ball.is_live)
	assert_eq(main._hud._message.text, "READY")


func test_ready_becomes_go_after_one_second() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	assert_eq(main.phase, main.MatchPhase.COUNTDOWN_GO)
	assert_eq(main._hud._message.text, "GO!")
	assert_false(main._ball.is_live)


func test_go_becomes_playing_and_serves() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	assert_eq(main.phase, main.MatchPhase.PLAYING)
	assert_true(main._ball.is_live)
	assert_true(main._ball.velocity.z > 0.0, "z>0")


func test_goal_awards_point_to_opponent() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	main.handle_goal(1)
	assert_eq(main.match_state.player1_score, 1)
	assert_eq(main.match_state.player2_score, 0)
	assert_eq(main._hud._score1.text, "1")
	assert_eq(main._hud._score2.text, "0")
	assert_eq(main.phase, main.MatchPhase.SERVING)
	assert_false(main._ball.is_live)
	assert_eq(main._hud._message.text, "PLAYER 1 SCORES")


func test_goal_when_not_playing_is_ignored() -> void:
	var main = _wired_main()
	main.begin_match()
	main.handle_goal(1)
	assert_eq(main.match_state.player1_score, 0)
	assert_eq(main.match_state.player2_score, 0)
	assert_eq(main.phase, main.MatchPhase.READY)


func test_serve_after_goal_waits_one_second() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	main.handle_goal(1)
	main.tick_phase(0.99)
	assert_eq(main.phase, main.MatchPhase.SERVING)
	assert_false(main._ball.is_live)
	main.tick_phase(0.01)
	assert_eq(main.phase, main.MatchPhase.PLAYING)
	assert_true(main._ball.is_live)
	assert_true(main._ball.velocity.z > 0.0, "z>0")


func test_second_goal_does_not_double_count_same_frame() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	main.handle_goal(1)
	main.handle_goal(1)
	assert_eq(main.match_state.player1_score, 1)
	assert_eq(main.match_state.player2_score, 0)
	assert_eq(main.phase, main.MatchPhase.SERVING)


func test_tenth_goal_goes_to_won() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	for _i in 9:
		main.handle_goal(1)
		main.tick_phase(_Court.SERVE_DELAY)
	main.handle_goal(1)
	assert_eq(main.phase, main.MatchPhase.WON)
	assert_eq(main.match_state.winner, 1)
	assert_true(main._hud._message.text.contains("PLAYER 1 WINS"))
	assert_true(main._hud._message.text.contains("PRESS START"))
	assert_false(main._ball.is_live)
	assert_false(main._p1.input_enabled)
	assert_false(main._p2.input_enabled)


func test_start_only_works_when_won() -> void:
	var main = _wired_main()
	main.begin_match()
	main.tick_phase(_Court.SERVE_DELAY)
	main.tick_phase(_Court.GO_MESSAGE_DURATION)
	main.handle_goal(1)
	main.tick_phase(_Court.SERVE_DELAY)
	assert_eq(main.phase, main.MatchPhase.PLAYING)
	assert_eq(main.match_state.player1_score, 1)
	main.handle_start_pressed()
	assert_eq(main.match_state.player1_score, 1)
	assert_eq(main.match_state.player2_score, 0)
	assert_eq(main.phase, main.MatchPhase.PLAYING)
	for _i in 8:
		main.handle_goal(1)
		main.tick_phase(_Court.SERVE_DELAY)
	main.handle_goal(1)
	assert_eq(main.phase, main.MatchPhase.WON)
	var same_state = main.match_state
	main.handle_start_pressed()
	assert_true(main.match_state == same_state)
	assert_eq(main.match_state.player1_score, 0)
	assert_eq(main.match_state.player2_score, 0)
	assert_eq(main.match_state.winner, 0)
	assert_eq(main.phase, main.MatchPhase.READY)
	assert_true(main._p1.input_enabled)
	assert_true(main._p2.input_enabled)
	assert_eq(main._hud._message.text, "READY")
	assert_false(main._ball.is_live)
