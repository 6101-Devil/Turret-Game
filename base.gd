extends Area2D

var SpecialUpgTable : Array = [
	{"Image" : preload("res://LaserPointer.png"), "Func" : LaserPointer},
	{"Image" : preload("res://AutomaticUpg.png"), "Func" : Automatic}
]
var UpgTable : Array = [preload("res://FireRateUpg.png"), preload("res://MoreXPUpg.png"), preload("res://TurnSpeedUpg.png"), preload("res://FireDuration.png"), preload("res://EfficiencyUpg.png"), preload("res://PowerUpg.png")]
var UpgStatTable : Array = [
	{"FireRate" : 0.1},
	{"XPGain" : 1.1},
	{"TurnSpeed" : 0.2},
	{"FireDuration" : 0.05},
	{"FireRate" : 0.05, "TurnSpeed" : 0.1},
	{"FireDuration" : 0.03, "XPGain" : 1.05}
]
var TableNum : int = 0
var LvlUpAmount : int = 0
var AmountOfEnemies : int = 1
var ReplacementSpecialUpgTable : Array
var DeathText : Array = [
	[" GENUINELY ", " LOWKEY ", " JUST ", " ", " FR ", " KINDA "],
	["DIED", "LOST"]
]

func _ready() -> void:
	ReplacementSpecialUpgTable = SpecialUpgTable.duplicate()

func GameOver():
	SpecialUpgTable = ReplacementSpecialUpgTable.duplicate()
	get_tree().paused = true
	$DeathParticles.process_material.color = Color(255, 0, 0, 1)
	$DeathParticles.restart()
	$LoseScreen/Instructions.visible = false
	await get_tree().create_timer(0.5, true, false, true).timeout
	$LoseScreen/Label.text = "YOU"+DeathText[0][randi_range(0, DeathText[0].size() - 1)] + DeathText[1][randi_range(0, DeathText[1].size() - 1)]
	$LoseScreen.visible = true
	await get_tree().create_timer(0.2, true, false, true).timeout
	$LoseScreen/Instructions.visible = true
	%Cannon.FireRate = 1
	%Cannon.FireDuration = 0.1
	%Cannon.XPGain = 10
	%Cannon.TurnSpeed = 1
	%XPBar.max_value = 100
	%XPBar.value = 0
	AmountOfEnemies = 1
	LvlUpAmount = 0
	%Cannon.Automatic = false
	%Cannon.FullAuto = false
	while not Input.is_action_just_pressed("Fire"):
		await get_tree().process_frame
	%Cannon/LaserPointer.visible = false
	$DeathParticles.process_material.color = Color(1, 0, 0, 0)
	$LoseScreen.visible = false
	get_tree().paused = false
	for i in %Enemies.get_children():
		if i.name != "Enemy":
			i.queue_free()
		else:
			i.position = Vector2(0, -325)
	%Enemies.get_node("Enemy").Target()

func LevelUp() -> void:
	get_tree().paused = true
	%XPBar.value = 0
	%XPBar.max_value *= 1.05
	%XPBar/Particles.restart()
	$Upgrades.modulate = Color(1, 1, 1, 0)
	$Upgrades/Background.position = Vector2(77.3, -45)
	create_tween().tween_property($Upgrades/Background, "position", Vector2(77.3, 20), 1)
	create_tween().tween_property($Upgrades, "modulate", Color(1, 1, 1, 1), 1)
	$Upgrades.visible = true
	for i in $Upgrades.get_children():
		if i.name.begins_with("Button"):
			if randi_range(1, 9) == 1 and SpecialUpgTable.size() > 0:
				TableNum = randi_range(0, SpecialUpgTable.size() - 1)
				i.get_node("Sprite2D").texture = SpecialUpgTable[TableNum]["Image"]
				i.set_meta("UpgNum", TableNum)
				i.set_meta("Special", true)
			else:
				TableNum = randi_range(0, UpgTable.size() - 1)
				i.get_node("Sprite2D").texture = UpgTable[TableNum]
				i.set_meta("UpgNum", TableNum)
				i.set_meta("Special", false)

func _on_button_pressed(Source) -> void:
	$Upgrades.visible = false
	var AccessNum = $Upgrades.get_node(Source).get_meta("UpgNum")
	if $Upgrades.get_node(Source).get_meta("Special") == false:
		%Cannon.FireRate += UpgStatTable[AccessNum].get("FireRate", 0)
		%Cannon.XPGain *= UpgStatTable[AccessNum].get("XPGain", 1)
		%Cannon.TurnSpeed += UpgStatTable[AccessNum].get("TurnSpeed", 0)
		%Cannon.FireDuration += UpgStatTable[AccessNum].get("FireDuration", 0)
	else:
		SpecialUpgTable[AccessNum]["Func"].call()
		SpecialUpgTable.remove_at(AccessNum)
	get_tree().paused = false
	for i in %Enemies.get_children():
		i.Target()
	LvlUpAmount += 1
	if LvlUpAmount >= 5:
		LvlUpAmount = 0
		var NewEnemy = %Enemies.get_node("Enemy").duplicate()
		%Enemies.add_child(NewEnemy)
		NewEnemy.name = "Enemy"
		if AmountOfEnemies <= 5:
			NewEnemy.Speed = 2 / 1.1 ** AmountOfEnemies
		else:
			NewEnemy.Speed = 2 * 1.05 ** AmountOfEnemies
		NewEnemy.position = Vector2(0, -325)
		AmountOfEnemies += 1

func LaserPointer() -> void:
	%Cannon/LaserPointer.visible = true

func Automatic() -> void:
	%Cannon.Automatic = true
	%Cannon.FireRate += .05
	SpecialUpgTable.append({"Image" : preload("res://FullAuto.png"), "Func" : FullAuto})

func FullAuto() -> void:
	%Cannon.FireRate += .1
	%Cannon.FullAuto = true
