extends StaticBody2D

@export var Base: Area2D

var Speed : float = 2
var XSpeedMult : float = 1
var YSpeedMult : float = 1

func _ready() -> void:
	Target()

func Target() -> void:
	while get_tree().paused == false:
		await get_tree().physics_frame
		look_at(Base.position)
		position = Vector2(move_toward(position.x, Base.position.x, Speed * XSpeedMult), move_toward(position.y, Base.position.y, Speed * YSpeedMult))
		if position.distance_to(Base.position) < 55:
			Base.GameOver()

func Respawn() -> void:
	$DeathParticles.position = position
	$DeathParticles.restart()
	XSpeedMult = randf_range(0.5, 1.5)
	YSpeedMult = randf_range(0.5, 1.5)
	$Sprite2D.modulate = Color(1, randf_range(.5, 1), randf_range(.5, 1))
	scale = Vector2(randf_range(.9, 1.1), randf_range(.9, 1.1))
	if randi_range(0, 1):
		position = Vector2(randi_range(-600, 600), -375)
	else:
		if randi_range(0, 1):
			position = Vector2(-650, randi_range(-325, 175))
		else:
			position = Vector2(650, randi_range(-325, 175))
