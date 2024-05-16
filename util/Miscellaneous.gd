extends Node

class_name Util

enum Cardinal {UP,DOWN,LEFT,RIGHT}

static var cardinal_rotation_map = {
  Cardinal.UP: deg_to_rad(0),
	Cardinal.RIGHT: deg_to_rad(90),
	Cardinal.DOWN: deg_to_rad(180),
	Cardinal.LEFT: deg_to_rad(270)
}

static func CardinalToDegrees(cardinal:Cardinal) -> float:
	return cardinal_rotation_map[cardinal]
