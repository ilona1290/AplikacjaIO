extends Control

onready var a = $Background/PanelContainer/ScrollContainer/VBoxContainer
var BillCardScene = preload("res://Scenes/BillCard.tscn")

func _ready() -> void:
	var allBills = yield(Database.getBills(Database.userID), "completed").Result
	var allUsers = [Database.userID]
	for b in allBills:
		if b["to_id"] == Database.userID:
			allUsers.append(b["from_id"])
		else:
			allUsers.append(b["to_id"])
		
	var r = yield(Database.getProfiles(allUsers), "completed").Result
	for b in allBills:
		#if b["is_payed"] == "0":
			var tmpBillCard = BillCardScene.instance()
			tmpBillCard.get_node("Background/VBoxContainer/Description/DescriptionValue").text = b["description"]
			tmpBillCard.get_node("Background/VBoxContainer/Amount/AmountValue").text = b["amount"]
			tmpBillCard.get_node("Background/VBoxContainer/From/FromValue").text = r[b["from_id"]].Name + " " + r[b["from_id"]].Surname
			tmpBillCard.get_node("Background/VBoxContainer/Account/AccountValue").text = r[b["from_id"]].Bank
			tmpBillCard.name = b["id_bill"]
			if b["from_id"] != Database.userID:
				tmpBillCard.get_node("Background/VBoxContainer/Account").visible = false
				tmpBillCard.get_node("Background/VBoxContainer/From/FromLabel").text = "Od:"
				tmpBillCard.get_node("Background/ConfirmButton").visible = true
				tmpBillCard.get_node("Background/ConfirmButton").connect("pressed", self, "_onPressConfirmButton", [b["id_bill"]])
			if b["is_payed"] == "1":
				tmpBillCard.get_node("Background").color = Color(0, 0.4, 0, 1)
				tmpBillCard.get_node("Background/ConfirmButton").visible = false
			else:
				tmpBillCard.get_node("Background").color = Color(0.4, 0, 0, 1)
			a.add_child(tmpBillCard)
	
func _onPressConfirmButton(id):
	print(id)
	#a.get_node(id).queue_free()
	a.get_node(id).get_node("Payed").visible = true
	yield(Database.updateBills(id), "completed")

func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://Scenes/Main.tscn")
	pass 
