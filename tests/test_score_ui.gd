@tool
extends McpTestSuite

const _ScoreUI := preload("res://ui/score_ui.gd")

var _ui
var _score1: Label
var _score2: Label
var _msg: Label
var _fps: Label


func suite_name() -> String:
	return "score_ui"


func setup() -> void:
	_ui = _ScoreUI.new()
	track(_ui)
	_score1 = Label.new()
	_score2 = Label.new()
	_msg = Label.new()
	_fps = Label.new()
	track(_score1)
	track(_score2)
	track(_msg)
	track(_fps)
	_ui.setup_labels(_score1, _score2, _msg, _fps)


func test_set_scores_writes_labels() -> void:
	_ui.set_scores(3, 7)
	assert_eq(_score1.text, "3")
	assert_eq(_score2.text, "7")


func test_show_message_ready() -> void:
	_ui.show_message("ready")
	assert_eq(_msg.text, "READY")


func test_show_message_go() -> void:
	_ui.show_message("go")
	assert_eq(_msg.text, "GO!")


func test_show_message_p1_scores() -> void:
	_ui.show_message("p1_scores")
	assert_eq(_msg.text, "PLAYER 1 SCORES")


func test_show_message_p2_scores() -> void:
	_ui.show_message("p2_scores")
	assert_eq(_msg.text, "PLAYER 2 SCORES")


func test_show_win_contains_press_start() -> void:
	_ui.show_win(2)
	assert_true(_msg.text.contains("PLAYER 2 WINS"), "wins")
	assert_true(_msg.text.contains("PRESS START"), "press start")


func test_unknown_key_clears() -> void:
	_ui.show_message("go")
	_ui.show_message("foobar")
	assert_eq(_msg.text, "")


func test_set_perf_format() -> void:
	_ui.set_perf(60, 16.666)
	assert_true(_fps.text.contains("60 FPS"), "fps")
	assert_true(_fps.text.contains("16.7"), "ms")


func test_clear_message() -> void:
	_ui.show_message("go")
	_ui.clear_message()
	assert_eq(_msg.text, "")
