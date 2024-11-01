extends Node

# shaz's pausemenu ================================================================================
@onready var pause_menu: pausemenu = $entities/Player/Camera2D/PauseMenu
@onready var inventory: Control = $CanvasLayer/inventory

var paused = false
var current_state
#==================================================================================================

# shaz's AudioPlaybackScript =======================================================================
func _ready() -> void:
	key_quest_show()
	$entities/Player/interact_popup2.hide()
	$Entering.play()
	$CanvasLayer/SceneFade.play("fade in")
	await get_tree().create_timer(3).timeout
	$"World 1 Music".play()
	current_state = choose([POS_1,POS_2,POS_3])
	set_key_pos()
#===================================================================================================
#key_chest random postion
enum{
	POS_1,     #0
	POS_2,  #1
	POS_3   #2
}
#choose keychecst state (Pos)
func choose(array):
	#create an array for randomizer
	array.shuffle()
	return array.front()

func set_key_pos():
	match current_state:
		POS_1:
			$Keys/key.position.x = 105
			$Keys/key.position.y = 417
		POS_2:
			$Keys/key.position.x = -151
			$Keys/key.position.y = 582
		POS_3:
			$Keys/key.position.x = -472
			$Keys/key.position.y = -367
			
			
#====================================================================================================
#this is for debug 
#REMOVE WHEN GAME IS RELEASED
func _input(_event):
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
		inventory.hide() 
		pause_menu.show()
		#Engine.time_scale = 0  
		get_tree().paused = true
		print("[Pause Menu] Game Paused")
		
	paused = !paused

#==================================================================================================
func _on_tp_area_body_entered(body) -> void:
	if body is Player:
		# shaz's SceneTransitionFadeout =======================================
		$Leaving.play()
		$CanvasLayer/SceneFade.play("fade out")
		await get_tree().create_timer(3).timeout
		# ======================================================================
		print("travelling to world 1_3")
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_1_3.tscn")


func _on_key_popup_hide() -> void:
	$entities/Player/interact_popup2.hide()
	# Shaz's DS4 UI
	$"entities/Player/Camera2D/DS4-UI".show()

func _on_key_popup_show() -> void:
	$entities/Player/interact_popup2.show()
	# Shaz's DS4 UI
	$"entities/Player/Camera2D/DS4-UI".show()
	

func _on_key_key_pickedup() -> void:
	$entities/Player/Camera2D/key_Notification.show()
	$entities/Player/Camera2D/quest_1/questbanner/questtitle.hide()
	$entities/Player/Camera2D/quest_1/questbanner/Label.show()
	$entities/Player/Camera2D/quest_1/questdetails/key_collect/NkeyObtained.show()
func key_quest_show():
	$entities/Player/Camera2D/quest_1.show()
	$entities/Player/Camera2D/quest_1/questdetails.show()
	$entities/Player/Camera2D/quest_1/questdetails/key_collect/NkeyObtained.hide()
	
func key_quest_hide():
	$entities/Player/Camera2D/quest_1.hide()
