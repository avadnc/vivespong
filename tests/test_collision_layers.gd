@tool
extends McpTestSuite


func suite_name() -> String:
	return "collision_layers"


func _main_root() -> Node:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		return null
	var path: String = str(root.scene_file_path)
	if not path.ends_with("Main.tscn"):
		return null
	return root


func test_layer_names() -> void:
	assert_eq(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_1"),
		"walls",
		"layer_1"
	)
	assert_eq(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_2"),
		"paddles",
		"layer_2"
	)
	assert_eq(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_3"),
		"ball",
		"layer_3"
	)
	assert_eq(
		ProjectSettings.get_setting("layer_names/3d_physics/layer_4"),
		"goals",
		"layer_4"
	)


func test_goal_mask_sees_ball_layer() -> void:
	var root: Node = _main_root()
	if root == null or root.get_node_or_null("%GoalPlayer1") == null:
		skip("no Main.tscn")
		return
	var goal: Area3D = root.get_node("%GoalPlayer1") as Area3D
	assert_true(goal.get_collision_mask_value(3), "goal mask ball")
	assert_true(goal.get_collision_layer_value(4), "goal layer")


func test_ball_mask_sees_walls_and_paddles() -> void:
	var root: Node = _main_root()
	if root == null or root.get_node_or_null("%Ball") == null:
		skip("no Main.tscn")
		return
	var ball: CollisionObject3D = root.get_node("%Ball") as CollisionObject3D
	assert_true(ball.get_collision_layer_value(3), "ball layer")
	assert_true(ball.get_collision_mask_value(1), "mask walls")
	assert_true(ball.get_collision_mask_value(2), "mask paddles")
	assert_false(ball.get_collision_mask_value(4), "not goals")
