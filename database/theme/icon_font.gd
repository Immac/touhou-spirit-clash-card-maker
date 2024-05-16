class_name IconLabel
extends Label

@export var label_font: Font:
	set(new_font):
		label_font = new_font
		add_theme_font_override("font", new_font)

@export var label_color: Font:
	set(new_color):
		label_color = new_color
		add_theme_font_override("font_color", new_color)

@export var label_size: int:
	set(new_size):
		label_size = new_size
		add_theme_font_size_override("font_size",new_size)
		add_theme_constant_override("theme_override_constants/outline_size",new_size)
