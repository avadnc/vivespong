class_name CourtExtents
extends Object

const HALF_WIDTH: float = 6.0
const HALF_LENGTH: float = 10.0
const FLOOR_Y: float = 0.0
const WALL_HEIGHT: float = 0.8
const WALL_THICKNESS: float = 0.3
const WALL_CENTER_Y: float = 0.4
const GOAL_SIZE: Vector3 = Vector3(12.6, 1.2, 1.0)
const GOAL_CENTER_Y: float = 0.6
const GOAL_Z: float = 10.5
const PADDLE_SIZE: Vector3 = Vector3(2.4, 0.4, 0.3)
const PADDLE_Z: float = 9.0
const PADDLE_Y: float = 0.3
const PADDLE_SPEED: float = 10.0
const BALL_RADIUS: float = 0.25
const BALL_Y: float = 0.25
const BALL_START_SPEED: float = 8.0
const BALL_SPEED_INCREMENT: float = 0.5
const BALL_MAX_SPEED: float = 20.0
const BALL_START_DIR: Vector3 = Vector3(0.5, 0.0, 1.0)
const PADDLE_BOUNCE_MAX_X: float = 1.15
const SERVE_DELAY: float = 1.0
const GO_MESSAGE_DURATION: float = 0.5
const CAMERA_POSITION: Vector3 = Vector3(0.0, 16.0, 18.0)
const CAMERA_LOOK_AT: Vector3 = Vector3.ZERO
const CAMERA_FOV: float = 48.0
const INPUT_DEADZONE: float = 0.2


static func playable_half_x() -> float:
	return HALF_WIDTH - PADDLE_SIZE.x * 0.5


static func wall_inner_x(sign_x: float) -> float:
	return signf(sign_x) * HALF_WIDTH


static func wall_center(sign_x: float) -> Vector3:
	var x: float = signf(sign_x) * (HALF_WIDTH + WALL_THICKNESS * 0.5)
	return Vector3(x, WALL_CENTER_Y, 0.0)


static func goal_center(player: int) -> Vector3:
	var z: float = -GOAL_Z if player == 1 else GOAL_Z
	return Vector3(0.0, GOAL_CENTER_Y, z)
