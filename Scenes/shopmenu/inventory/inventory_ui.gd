extends Control

#le inventoryUI script

@onready var Inv: Inventory = preload("res://Scenes/shopmenu/inventory/player inventory.tres")
@onready var slots: Array = $NinePatchRect.get_children()

var isOpen = false

func _ready():
	update_slots()
	close()

func update_slots():
	for i in range(min(Inv.items.size(), slots.size())):
		slots[i].update(Inv.items[i])
		
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if isOpen:
			close()
		else:
			open()

func open():
	visible = true
	isOpen = true
func close():
	visible = false
	isOpen = false
