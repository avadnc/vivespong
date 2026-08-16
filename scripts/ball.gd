class_name Ball
extends CharacterBody3D

signal paddle_hit(paddle: Node3D, hit_offset: float)

@export var start_speed: float = CourtExtents.BALL_START_SPEED
@export var speed_increment: float = CourtExtents.BALL_SPEED_INCREMENT
@export var max_speed: float = CourtExtents.BALL_MAX_SPEED

var is_live: bool = false
var speed: float = CourtExtents.BALL_START_SPEED


func _ready() -> void:
	motion_mode = MOTION_MODE_FLOATING


func _physics_process(delta: float) -> void:
	if not is_live:
		return
	var remaining: Vector3 = velocity * delta
	var budget: int = 4
	while remaining.length() > 0.0001 and budget > 0:
		budget -= 1
		var collision: KinematicCollision3D = move_and_collide(remaining)
		if collision == null:
			break
		_handle_collision(collision)
		var leftover: float = collision.get_remainder().length()
		if velocity.length_squared() < 0.0001:
			remaining = Vector3.ZERO
		else:
			remaining = velocity.normalized() * leftover
	global_position.y = CourtExtents.BALL_Y


func _handle_collision(collision: KinematicCollision3D) -> void:
	var collider_node: Node = collision.get_collider() as Node
	var normal: Vector3 = collision.get_normal()
	if collider_node != null and collider_node.is_in_group("paddles"):
		var paddle: Node3D = collider_node as Node3D
		var half_w: float = CourtExtents.PADDLE_SIZE.x * 0.5
		var hit_offset: float = (global_position.x - paddle.global_position.x) / half_w
		hit_offset = clampf(hit_offset, -1.0, 1.0)
		var dir: Vector3 = compute_paddle_bounce(hit_offset, velocity.z)
		speed = accelerate(speed, speed_increment, max_speed)
		velocity = dir * speed
		paddle_hit.emit(paddle, hit_offset)
		return
	if collider_node != null and collider_node.is_in_group("walls"):
		velocity = reflect_wall(velocity, normal)
		return
	if absf(normal.x) > 0.9:
		velocity = reflect_wall(velocity, normal)
		return
	velocity = reflect_wall(velocity, normal)


static func compute_paddle_bounce(hit_offset: float, incoming_z_sign: float) -> Vector3:
	var ox: float = clampf(hit_offset, -1.0, 1.0)
	var z_out: float = -signf(incoming_z_sign)
	if z_out == 0.0:
		z_out = -1.0
	var dir: Vector3 = Vector3(ox * CourtExtents.PADDLE_BOUNCE_MAX_X, 0.0, z_out)
	return dir.normalized()


static func accelerate(speed: float, increment: float, max_speed: float) -> float:
	return minf(speed + increment, max_speed)


static func reflect_wall(velocity: Vector3, normal: Vector3) -> Vector3:
	var reflected: Vector3 = velocity.bounce(normal)
	reflected.y = 0.0
	return reflected


func reset_to_center() -> void:
	global_position = Vector3(0.0, CourtExtents.BALL_Y, 0.0)


func stop_and_center() -> void:
	is_live = false
	velocity = Vector3.ZERO
	reset_to_center()


func serve(direction: Vector3) -> void:
	is_live = true
	speed = start_speed
	var dir: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if dir.length_squared() < 0.0001:
		dir = CourtExtents.BALL_START_DIR
	velocity = dir.normalized() * start_speed


func serve_toward(player: int) -> void:
	var z_out: float = -1.0 if player == 1 else 1.0
	serve(Vector3(CourtExtents.BALL_START_DIR.x, 0.0, z_out))
