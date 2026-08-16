class_name ScoreUI
extends CanvasLayer

const _MESSAGES: Dictionary = {
	"ready": "READY",
	"go": "GO!",
	"p1_scores": "PLAYER 1 SCORES",
	"p2_scores": "PLAYER 2 SCORES",
	"p1_wins": "PLAYER 1 WINS",
	"p2_wins": "PLAYER 2 WINS",
	"press_start": "PRESS START",
	"clear": "",
}

var _score1: Label
var _score2: Label
var _message: Label
var _fps: Label


func setup_labels(score1: Label, score2: Label, message: Label, fps: Label) -> void:
	_score1 = score1
	_score2 = score2
	_message = message
	_fps = fps


func set_scores(player1: int, player2: int) -> void:
	if _score1 != null:
		_score1.text = str(player1)
	if _score2 != null:
		_score2.text = str(player2)


func show_message(key: String) -> void:
	if _message == null:
		return
	if _MESSAGES.has(key):
		_message.text = str(_MESSAGES[key])
	else:
		_message.text = ""
		push_warning("ScoreUI: unknown message key '%s'" % key)


func show_win(player: int) -> void:
	if _message == null:
		return
	var win_key: String = "p1_wins" if player == 1 else "p2_wins"
	var win_text: String = str(_MESSAGES.get(win_key, ""))
	var start_text: String = str(_MESSAGES["press_start"])
	_message.text = "%s\n%s" % [win_text, start_text]


func set_perf(fps: int, frame_ms: float) -> void:
	if _fps == null:
		return
	_fps.text = "%d FPS  %.1f ms" % [fps, frame_ms]


func clear_message() -> void:
	if _message == null:
		return
	_message.text = ""
