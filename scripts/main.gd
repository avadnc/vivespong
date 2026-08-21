class_name VivesPongMain
extends Node3D

const _AiPaddle := preload("res://scripts/ai_paddle.gd")

enum MatchPhase { READY, COUNTDOWN_GO, PLAYING, SERVING, WON, MODE_SELECT }

@export var vs_cpu: bool = true

var match_state: MatchState
var phase: MatchPhase = MatchPhase.READY
var _hud: ScoreUI
var _ball: Ball
var _p1: Paddle
var _p2: Paddle
var _phase_timer: float = 0.0
var _serve_toward_player: int = 2


func _ready() -> void:
	match_state = MatchState.new()
	_hud = %UI as ScoreUI
	if _hud != null:
		_hud.setup_labels(
			%ScorePlayer1 as Label,
			%ScorePlayer2 as Label,
			%Message as Label,
			%FPS as Label
		)
	_p1 = %Player1 as Paddle
	_p2 = %Player2 as Paddle
	_ball = %Ball as Ball
	_p1.player_id = 1
	_p2.player_id = 2
	_set_paddles_input_enabled(true)
	_ball.reset_to_center()
	(%GoalPlayer1 as Area3D).body_entered.connect(_on_goal_body_entered.bind(2))
	(%GoalPlayer2 as Area3D).body_entered.connect(_on_goal_body_entered.bind(1))
	var camera: Camera3D = $Camera3D
	camera.position = CourtExtents.CAMERA_POSITION
	camera.fov = CourtExtents.CAMERA_FOV
	camera.current = true
	camera.look_at(CourtExtents.CAMERA_LOOK_AT)
	show_mode_select()


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
	vs_cpu = false


func show_mode_select() -> void:
	phase = MatchPhase.MODE_SELECT
	_phase_timer = 0.0
	_set_paddles_input_enabled(false)
	if _ball != null:
		_ball.stop_and_center()
	if _hud != null:
		if match_state != null:
			_hud.set_scores(match_state.player1_score, match_state.player2_score)
		_hud.show_message("mode_select")


func select_player_count(players: int) -> void:
	if phase != MatchPhase.MODE_SELECT:
		return
	if players != 1 and players != 2:
		return
	vs_cpu = players == 1
	if match_state != null:
		match_state.reset()
	_set_paddles_input_enabled(true)
	begin_match()


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
		MatchPhase.PLAYING, MatchPhase.WON, MatchPhase.MODE_SELECT:
			pass


func _on_goal_body_entered(body: Node3D, scoring_player: int) -> void:
	if body is Ball:
		handle_goal(scoring_player)
		return
	if body != null and body.is_in_group("ball"):
		handle_goal(scoring_player)
		return
	push_warning("VivesPongMain: goal body_entered ignored for %s" % str(body))


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
	show_mode_select()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		handle_start_pressed()
		if get_viewport() != null:
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("one_player"):
		select_player_count(1)
		if get_viewport() != null:
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("two_player"):
		select_player_count(2)
		if get_viewport() != null:
			get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	tick_phase(delta)
	if _hud != null:
		var fps: int = Engine.get_frames_per_second()
		_hud.set_perf(fps, delta * 1000.0)


func _physics_process(delta: float) -> void:
	tick_cpu(delta)


func tick_cpu(delta: float) -> void:
	if not vs_cpu:
		return
	if phase == MatchPhase.WON or phase == MatchPhase.MODE_SELECT:
		return
	if _p2 == null or _ball == null:
		return
	_p2.input_enabled = false
	var axis: float = _AiPaddle.compute_axis(_p2.global_position.x, _ball.global_position.x)
	_p2.apply_axis(axis, delta)
	_p2.global_position.y = CourtExtents.PADDLE_Y
	_p2.global_position.z = _p2.home_z


func _enter_countdown_go() -> void:
	phase = MatchPhase.COUNTDOWN_GO
	_phase_timer = 0.0
	if _hud != null:
		_hud.show_message("go")


func _set_paddles_input_enabled(enabled: bool) -> void:
	if _p1 != null:
		_p1.input_enabled = enabled
	if _p2 != null:
		if vs_cpu:
			_p2.input_enabled = false
		else:
			_p2.input_enabled = enabled


func _enter_playing_and_serve() -> void:
	phase = MatchPhase.PLAYING
	_phase_timer = 0.0
	if _hud != null:
		_hud.clear_message()
	if _ball != null:
		_ball.serve_toward(_serve_toward_player)
