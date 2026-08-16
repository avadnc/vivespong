class_name MatchState
extends RefCounted

const WIN_SCORE: int = 10

var player1_score: int = 0
var player2_score: int = 0
var winner: int = 0


func is_finished() -> bool:
	return winner != 0


func reset() -> void:
	player1_score = 0
	player2_score = 0
	winner = 0


func score_goal(player: int) -> void:
	if is_finished():
		return
	if player == 1:
		player1_score += 1
		if player1_score >= WIN_SCORE:
			winner = 1
	elif player == 2:
		player2_score += 1
		if player2_score >= WIN_SCORE:
			winner = 2
