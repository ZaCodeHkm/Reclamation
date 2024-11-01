extends Node2D

# shaz's pausemenu ================================================================================
@onready var pause_menu: pausemenuW2 = $Player/Camera2D/PauseMenu
@onready var settings_menu: settingsmenuInGameW2 = $Player/Camera2D/settings_menu
@onready var inventory: Control = $CanvasLayer/inventory

var paused = false
var in_tent = false
#commander quest
var commander_quest = false
signal quest_commander
signal exit_gate_open
var gate_soldier_chat = true
var current_state
# shaz's AudioPlaybackScript =======================================================================
func _ready() -> void:
	$Player/Camera2D/search_for_key.hide()
	$Player/Camera2D/search_for_key/key_questdetails.hide()
	$army_camp/tentroof.show()
	Dialogic.signal_event.connect(DialogicSignal)
	$Player/interact_popup2.hide()
	$Entering.play()
	$CanvasLayer/SceneFade.play("fade in")
	await get_tree().create_timer(3).timeout
	$"World 2 Music".play()
	$Player/Camera2D/commander_quest.hide()
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
			$Keys/key.position.x = -385
			$Keys/key.position.y = -444
		POS_2:
			$Keys/key.position.x = 640
			$Keys/key.position.y = -194
		POS_3:
			$Keys/key.position.x = -656
			$Keys/key.position.y = -194
			
#====================================================================================================

func _input(_event):
# shaz's code for pause below =================================================================
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
	# shaz's pausemenu function below =================================================================
func pauseMenu():
	# for resuming, not that paused is !paused
	if paused:
		$ResumeSFX.play()
		$CanvasLayer/NinePatchRect.show()
		$CanvasLayer/SubViewportContainer.show()
		pause_menu.hide()
		#Engine.time_scale = 1
		get_tree().paused = false  
		print("[Pause Menu] Game Resumed")
	# paused
	else:
		$PausedSFX.play()
		$CanvasLayer/NinePatchRect.hide()
		$CanvasLayer/SubViewportContainer.hide()
		inventory.hide()
		pause_menu.show()
		#Engine.time_scale = 0  
		get_tree().paused = true
		print("[Pause Menu] Game Paused")
		
	paused = !paused

#==================================================================================================

func _on_tp_area_2_body_entered(body: Node2D) -> void:
	if body is Player:
		# shaz's SceneTransitionFadeout =======================================
		$Leaving.play()
		print("travelling to world 3_1")
		$CanvasLayer/SceneFade.play("fade out")
		await get_tree().create_timer(3).timeout
		# ======================================================================
		get_tree().change_scene_to_file("res://Scenes/Game_scene/world_3_1.tscn")

func DialogicSignal(arg: String):
	if arg == "chatting":
		$Player/Camera2D/PauseMenu.modulate.a = 0
		$Player.player_idle_anim()
		$Player.can_move = false
	if arg == "exit":
		$Player/Camera2D/PauseMenu.modulate.a = 1
		$Player.can_move = true
	if arg == "opengate":
		$Doors/gate/gate_collision.disabled = true
		$Doors/gate/Sprite2D.hide()
	if arg == "quest_talk_to_commander":
		commander_quest = true
		emit_signal("quest_commander")
		
	if arg == "commander_interact_finished":
		commander_quest = false
		$Player/Camera2D/search_for_key.show()
		$Player/Camera2D/search_for_key/key_questdetails.show()
		$Player/Camera2D/search_for_key/key_questdetails/detail.show()
		$"Player/Camera2D/search_for_key/key_questdetails/key Requirement".show()
		emit_signal("exit_gate_open")
	if arg == "rebel_gate_soldier_finished":
		gate_soldier_chat = false
func run_dialogue(dialogue_string):
	Dialogic.start(dialogue_string)
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


func _on_key_popup_hide() -> void:
	$Player/interact_popup2.hide()
	# Shaz's DS4 UI
	$"Player/Camera2D/DS4-UI".hide()

func _on_key_popup_show() -> void:
	$Player/interact_popup2.show()
	# Shaz's DS4 UI
	$"Player/Camera2D/DS4-UI".show()

func _on_key_key_pickedup() -> void:
	$Player/Camera2D/key_Notification.show()
	$Player/Camera2D/search_for_key/key_questdetails/EkeyObtained.show()
	$Player/Camera2D/search_for_key/key_questdetails/detail2.show()
func _on_gate_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if gate_soldier_chat:
			run_dialogue("rebellionsoldier")
			
	

func _on_commander_area_body_entered(body: Node2D) -> void:
	if body is Player:
		$army_camp/tentroof.hide()
		$Player/Camera2D.zoom.x = 5
		$Player/Camera2D.zoom.y = 5
		# shaz's pausemenuScaling and SFX
		commander_quest_stop()
		pauseMenuHouseScaling()


func _on_commander_area_body_exited(body: Node2D) -> void:
	if body is Player:
		$army_camp/tentroof.show()
		$Player/Camera2D.zoom.x = 3
		$Player/Camera2D.zoom.y = 3
		# shaz's pausemenuScaling
		in_tent = false
		pauseMenuDefaultScaling()
		
func commander_quest_start():
	$Player/Camera2D/commander_quest.show()
	$Player/Camera2D/commander_quest/questdetails.show()


func commander_quest_stop():
	$Player/Camera2D/commander_quest.hide()
	$Player/Camera2D/commander_quest/questdetails.hide()


func _on_quest_commander() -> void:
	commander_quest_start()
