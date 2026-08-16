@tool
extends McpTestSuite

const _Court := preload("res://scripts/court.gd")
const _MatchState := preload("res://scripts/match_state.gd")


func suite_name() -> String:
	return "court"


func test_playable_half_x_is_4_8() -> void:
	assert_true(is_equal_approx(_Court.playable_half_x(), 4.8), "playable_half_x")


func test_ball_start_dir_is_toward_player2() -> void:
	var d: Vector3 = _Court.BALL_START_DIR.normalized()
	assert_true(d.z > 0.0, "z>0")
	assert_true(is_equal_approx(d.y, 0.0), "y=0")


func test_serve_delay_is_one_second() -> void:
	assert_true(is_equal_approx(_Court.SERVE_DELAY, 1.0), "SERVE_DELAY")


func test_win_score_matches_match_state() -> void:
	assert_eq(_MatchState.WIN_SCORE, 10)


func test_speeds_match_sdd_defaults() -> void:
	assert_true(is_equal_approx(_Court.BALL_START_SPEED, 8.0), "start")
	assert_true(is_equal_approx(_Court.BALL_SPEED_INCREMENT, 0.5), "inc")
	assert_true(is_equal_approx(_Court.BALL_MAX_SPEED, 20.0), "max")


func test_paddle_z_is_inside_goals() -> void:
	assert_true(_Court.PADDLE_Z < _Court.HALF_LENGTH, "paddle inside length")


func test_wall_and_goal_centers() -> void:
	var wall: Vector3 = _Court.wall_center(-1)
	assert_true(is_equal_approx(wall.x, -6.15), "wall.x")
	assert_true(is_equal_approx(wall.y, 0.4), "wall.y")
	assert_true(is_equal_approx(wall.z, 0.0), "wall.z")
	var goal: Vector3 = _Court.goal_center(1)
	assert_true(is_equal_approx(goal.y, 0.6), "goal.y")
	assert_true(is_equal_approx(goal.z, -10.5), "goal.z")
