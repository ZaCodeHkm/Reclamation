extends Node2D

@onready var SceneTransition = $SceneTransition/AnimationPlayer
# shaz's pausemenu =================================================================================
@onready var pause_menu: pausemenuW2 = $Player/Camera2D/PauseMenu
@onready var settings_menu: settingsmenuInGameW2 = $Player/Camera2D/settings_menu

var paused = false
# shaz's AudioPlaybackScript =======================================================================
func _ready() -> void:
	$Player/interact_popup2.hide()
	$Entering.play()
	$CanvasLayer/SceneFade.play("fade in")
	await get_tree().create_timer(3).timeout
	$"World 2 Music".play()
	Dialogic.signal_event.connect(DialogicSignal)
	#===============================================================================================
	#SceneTransitionAnimation.play("fade_out")
	pass
	#============================================================
# dialogue behaviour
func DialogicSignal(arg: String):
	if arg == "chatting":
		print("chatting with gate soldier")
	if arg == "exit":
		print("exit chatting with gate soldier")
	
#this is to reload levels
func _input(_event):
	#if Input.is_action_pressed("exit"):
		#get_tree().quit()
		#print("quit")
	if Input.is_action_just_pressed('reset'):
		get_tree().reload_current_scene()
		print("resetted")
	if Input.is_action_just_pressed("transition1"):
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_1_1.tscn")
	if Input.is_action_just_pressed("transition2"):
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_2_1.tscn")
	if Input.is_action_just_pressed("transition3"):
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_3_1.tscn")
# shaz's code for pause below =================================================================
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
	# shaz's pausemenu function below =================================================================
func pauseMenu():
	if paused:
		$ResumeSFX.play()
		$CanvasModulate.show()
		pause_menu.hide()
		#Engine.time_scale = 1
		get_tree().paused = false  
		print("[Pause Menu] Game Resumed")
	else:
		$PausedSFX.play()
		$CanvasModulate.hide()
		pause_menu.show()
		#Engine.time_scale = 0  
		get_tree().paused = true
		print("[Pause Menu] Game Paused")
		
	paused = !paused
# Pausemenu Zoom Compatibility Scaling ===========================================

func pauseMenuDefaultScaling():
	pause_menu.scale = Vector2(.375 , .375)
	pause_menu.position = Vector2(-360, -210)
	settings_menu.scale = Vector2(0.35, 0.35)
	settings_menu.position = Vector2(-335, -180)
	
func pauseMenuHouseScaling():
	pause_menu.scale = Vector2(.2, .2)
	pause_menu.position = Vector2(-192.5, -108.5)
	settings_menu.scale = Vector2(0.2, 0.2)
	settings_menu.position = Vector2(-192.5, -108.5)

#=================================================================================

func _on_tp_area_2_body_entered(body: Node2D) -> void:
	if body is Player:
		# shaz's SceneTransitionFadeout =======================================
		$Leaving.play()
		print("travelling to world 2_2")
		$CanvasLayer/SceneFade.play("fade out")
		await get_tree().create_timer(3).timeout
		# ======================================================================
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_2_2.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		$Map/TileMap/village/roof.hide()
		$Map/TileMap/village/roofchimney.hide()
		$Player/Camera2D.zoom.x = 5
		$Player/Camera2D.zoom.y = 5
		# shaz's pausemenuScaling and SFX
		pauseMenuHouseScaling()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		$Map/TileMap/village/roof.show()
		$Map/TileMap/village/roofchimney.show()
		$Player/Camera2D.zoom.x = 3
		$Player/Camera2D.zoom.y = 3
		# shaz's pausemenuScaling
		pauseMenuDefaultScaling()


func _on_door_opening_animation_body_entered(body: Node2D) -> void:
	if body is Player:
		$Map/TileMap/village/door.hide()
		$DoorOpening.play()

func _on_door_opening_animation_body_exited(body: Node2D) -> void:
	if body is Player:
		$Map/TileMap/village/door.show()
		$DoorClosing.play()

func _on_key_popup_hide() -> void:
	$Player/interact_popup2.hide()
	#Shaz's DS4 UI ==================================================
	$"Player/Camera2D/DS4-UI".hide()

func _on_key_popup_show() -> void:
	$Player/interact_popup2.show()
	#Shaz's DS4 UI ==================================================
	$"Player/Camera2D/DS4-UI".show()
