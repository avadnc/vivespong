class_name VivesPongMain
extends Node3D

enum MatchPhase { READY, COUNTDOWN_GO, PLAYING, SERVING, WON }

var match_state: MatchState
var phase: MatchPhase = MatchPhase.READY
var _hud: ScoreUI
var _ball: Ball
var _p1: Paddle
var _p2: Paddle
var _phase_timer: float = 0.0
var _serve_toward_player: int = 2


func configure_for_test(
	p_ball: Ball,
	p_hud: ScoreUI,
	p_match: MatchState,
	p1: Paddle,
	p2: Paddle
) -> void:
	_ball = p_ball
	_hud = p_hud
	match_state = p_match
	_p1 = p1
	_p2 = p2


func begin_match() -> void:
	phase = MatchPhase.READY
	_phase_timer = 0.0
	_serve_toward_player = 2
	if _ball != null:
		_ball.stop_and_center()
	if _hud != null:
		if match_state != null:
			_hud.set_scores(match_state.player1_score, match_state.player2_score)
		_hud.show_message("ready")


func tick_phase(delta: float) -> void:
	match phase:
		MatchPhase.READY:
			_phase_timer += delta
			if _phase_timer >= CourtExtents.SERVE_DELAY:
				_enter_countdown_go()
		MatchPhase.COUNTDOWN_GO:
			_phase_timer += delta
			if _phase_timer >= CourtExtents.GO_MESSAGE_DURATION:
				_enter_playing_and_serve()
		MatchPhase.SERVING:
			_phase_timer += delta
			if _phase_timer >= CourtExtents.SERVE_DELAY:
				_enter_playing_and_serve()
		MatchPhase.PLAYING, MatchPhase.WON:
			pass


func handle_goal(scoring_player: int) -> void:
	if phase != MatchPhase.PLAYING:
		return
	if match_state == null:
		return
	if _ball != null:
		_ball.stop_and_center()
	match_state.score_goal(scoring_player)
	if _hud != null:
		_hud.set_scores(match_state.player1_score, match_state.player2_score)
	if match_state.is_finished():
		phase = MatchPhase.WON
		_set_paddles_input_enabled(false)
		if _hud != null:
			_hud.show_win(scoring_player)
		return
	phase = MatchPhase.SERVING
	_phase_timer = 0.0
	_serve_toward_player = 2 if scoring_player == 1 else 1
	if _hud != null:
		if scoring_player == 1:
			_hud.show_message("p1_scores")
		elif scoring_player == 2:
			_hud.show_message("p2_scores")


func handle_start_pressed() -> void:
	if phase != MatchPhase.WON:
		return
	if match_state != null:
		match_state.reset()
	_set_paddles_input_enabled(true)
	begin_match()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		handle_start_pressed()
		if get_viewport() != null:
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	tick_phase(delta)


func _enter_countdown_go() -> void:
	phase = MatchPhase.COUNTDOWN_GO
	_phase_timer = 0.0
	if _hud != null:
		_hud.show_message("go")


func _set_paddles_input_enabled(enabled: bool) -> void:
	if _p1 != null:
		_p1.input_enabled = enabled
	if _p2 != null:
		_p2.input_enabled = enabled


func _enter_playing_and_serve() -> void:
	phase = MatchPhase.PLAYING
	_phase_timer = 0.0
	if _hud != null:
		_hud.clear_message()
	if _ball != null:
		_ball.serve_toward(_serve_toward_player)
