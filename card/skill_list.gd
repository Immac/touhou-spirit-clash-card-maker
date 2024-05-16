extends BoxContainer

@export var skill_list : Array[Skill]
@export var skill_icons: Array[AttributeCollection]
var skill_display_scene = preload("res://card/skill_display.tscn")

func update():
	for child in get_children():
		child.queue_free()
	for skill in skill_list:
		var new_skill_display := skill_display_scene.instantiate()
		new_skill_display.skill = skill
		new_skill_display.icons = skill_icons
		add_child(new_skill_display)
		new_skill_display.update()
