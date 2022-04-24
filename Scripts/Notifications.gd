extends Control

onready var a = $Background/ScrollContainer/VBoxContainer
var BillCardScene = preload("res://Scenes/BillCard.tscn")

func _ready() -> void:
	var allBills = yield(Database.getBills(Database.userID), "completed").Result
	var allUsers = []
	for b in allBills:
		print(b)
		allUsers.append(b[3])
		
	var r = yield(Database.getProfiles(allUsers), "completed").Result
	for b in allBills:
		if b[5] == "0":
			var tmpBillCard = BillCardScene.instance()
			tmpBillCard.get_node("Background/VBoxContainer/Description/DescriptionValue").text = b[2]
			tmpBillCard.get_node("Background/VBoxContainer/Amount/AmountValue").text = b[1]
			tmpBillCard.get_node("Background/VBoxContainer/From/FromValue").text = r[b[3]].Name + " " + r[b[3]].Surname
			tmpBillCard.get_node("Background/VBoxContainer/Account/AccountValue").text = r[b[3]].Bank
			tmpBillCard.name = b[0]
			if b[3] != "6":
				tmpBillCard.get_node("Background/VBoxContainer/Account").visible = false
				tmpBillCard.get_node("Background/VBoxContainer/From/FromLabel").text = "Od:"
				tmpBillCard.get_node("Background/ConfirmButton").visible = true
				tmpBillCard.get_node("Background/ConfirmButton").connect("pressed", self, "_onPressConfirmButton", [b[0]])
			a.add_child(tmpBillCard)
	
func _onPressConfirmButton(id):
	print(id)
	a.get_node(id).queue_free()
	yield(Database.updateBills(id), "completed")

func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Main.tscn")
	pass 
