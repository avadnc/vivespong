class_name Paddle
extends CharacterBody3D

@export var player_id: int = 1
@export var speed: float = CourtExtents.PADDLE_SPEED
@export var input_enabled: bool = true

var home_z: float = 0.0
var move_left_action: String = ""
var move_right_action: String = ""


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING
	home_z = global_position.z


func _physics_process(delta: float) -> void:
	physics_step(delta)


func bind_move_actions(left_action: String, right_action: String) -> void:
	move_left_action = left_action
	move_right_action = right_action


func get_left_action() -> String:
	if not move_left_action.is_empty():
		return move_left_action
	return "player1_left" if player_id == 1 else "player2_left"


func get_right_action() -> String:
	if not move_right_action.is_empty():
		return move_right_action
	return "player1_right" if player_id == 1 else "player2_right"


func get_move_axis() -> float:
	return Input.get_axis(get_left_action(), get_right_action())


func clamp_x(x: float) -> float:
	return compute_clamped_x(x, CourtExtents.PADDLE_SIZE.x * 0.5, CourtExtents.HALF_WIDTH)


static func compute_clamped_x(x: float, half_w: float, half_arena: float) -> float:
	return clampf(x, -(half_arena - half_w), half_arena - half_w)


func apply_axis(axis: float, delta: float) -> void:
	var next_x: float = clamp_x(global_position.x + axis * speed * delta)
	global_position.x = next_x


func physics_step(delta: float) -> void:
	if not input_enabled:
		return
	apply_axis(get_move_axis(), delta)
	global_position.y = CourtExtents.PADDLE_Y
	global_position.z = home_z
