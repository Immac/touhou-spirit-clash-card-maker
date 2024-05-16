extends Resource

class_name CardResource

@export_category("Basic Information")
@export var id : String
@export var name : String
@export var flavor_text : String
@export var level : int

@export_subgroup("Illustration")
@export var artwork : Texture
@export var background : Texture

@export_category("Stats")
@export var stats : Array
@export var resources_generated : Array
@export var skills : Array
