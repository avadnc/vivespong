@tool
extends McpTestSuite

const _MatchState := preload("res://scripts/match_state.gd")


func suite_name() -> String:
	return "match"


func test_player_wins_on_tenth_goal() -> void:
	var match_state = _MatchState.new()

	assert_eq(match_state.player1_score, 0)
	assert_eq(match_state.player2_score, 0)
	assert_false(match_state.is_finished())

	for _i in 9:
		match_state.score_goal(1)
	assert_false(match_state.is_finished())

	match_state.score_goal(1)
	assert_eq(match_state.player1_score, 10)
	assert_true(match_state.is_finished())
	assert_eq(match_state.winner, 1)


func test_player2_wins_on_tenth_goal() -> void:
	var match_state = _MatchState.new()
	for _i in 10:
		match_state.score_goal(2)
	assert_eq(match_state.player2_score, 10)
	assert_eq(match_state.player1_score, 0)
	assert_true(match_state.is_finished())
	assert_eq(match_state.winner, 2)


func test_score_after_finish_is_ignored() -> void:
	var match_state = _MatchState.new()
	for _i in 10:
		match_state.score_goal(1)
	match_state.score_goal(2)
	match_state.score_goal(1)
	assert_eq(match_state.player1_score, 10)
	assert_eq(match_state.player2_score, 0)
	assert_eq(match_state.winner, 1)


func test_invalid_player_is_ignored() -> void:
	var match_state = _MatchState.new()
	match_state.score_goal(0)
	match_state.score_goal(3)
	match_state.score_goal(-1)
	assert_eq(match_state.player1_score, 0)
	assert_eq(match_state.player2_score, 0)
	assert_false(match_state.is_finished())


func test_reset_clears_scores_and_winner() -> void:
	var match_state = _MatchState.new()
	for _i in 10:
		match_state.score_goal(1)
	match_state.reset()
	assert_eq(match_state.player1_score, 0)
	assert_eq(match_state.player2_score, 0)
	assert_eq(match_state.winner, 0)
	assert_false(match_state.is_finished())
	match_state.score_goal(2)
	assert_eq(match_state.player2_score, 1)
	assert_false(match_state.is_finished())
