class_name AiPaddle
extends RefCounted

const ALIGN_DEADZONE: float = 0.15


static func compute_axis(paddle_x: float, target_x: float, deadzone: float = ALIGN_DEADZONE) -> float:
	var dx: float = target_x - paddle_x
	if absf(dx) <= deadzone:
		return 0.0
	return signf(dx)
