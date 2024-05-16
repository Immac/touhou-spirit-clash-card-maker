extends BoxContainer

@export var stat_minimum_size : Vector2 = Vector2(100,100)
@export var stat_rotation := Util.Cardinal.UP
@export var stats : Array[Stat]

func _ready():
	for child in get_children():
		child.queue_free()
	update.call_deferred()

var stat_display_scene := preload("res://card/stat_display.tscn")
func update() -> void:
	for child in get_children():
		child.queue_free()
	for stat in stats:
		var container := Control.new()
		var stat_display := stat_display_scene.instantiate()
		stat_display.stat = stat
		container.custom_minimum_size = stat_minimum_size
		add_child(container)
		container.add_child(stat_display)
		var set_stat_display_dimensions = func():
			stat_display.size = stat_minimum_size
			stat_display.cardinal_rotation = stat_rotation
			stat_display.update()
			stat_display.position = Vector2.ZERO
		set_stat_display_dimensions.call_deferred()
