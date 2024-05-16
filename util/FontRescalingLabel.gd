extends Label

class_name FontRescalingLabel

@export_range(10,78) var base_font_size := 50

func _set(k,v):
	if "text" == k:
		text = v
		rescale_font()

func rescale_font(font_size := base_font_size):
	var font = theme.get_font("default_font","")
	while font.get_string_size(text, horizontal_alignment, -1, font_size).x > size.x:
		font_size -= 1
	set("theme_override_font_sizes/font_size",font_size)
