extends Control


var groupMembersScene = preload("res://Scenes/GroupMembers.tscn")

var Members = []
onready var MembersList = $Background/PanelContainer/ScrollContainer/VBoxContainer
onready var AmountInput = $Background/AmountInput
onready var TitleInput = $Background/TitleInput
onready var http : HTTPRequest = $HTTPRequest
onready var Notification = $Background/Notification
onready var Result = $Background/Result
onready var AmountlyCheckButton = $Background/AmountlyCheckButton
onready var CustomCheckButton = $Background/CustomCheckButton

var t

func _ready():
	print(ChosenGroup.Name)
	print(ChosenGroup.Members)
	generateMembersList()

func generateMembersList():
	var allMembersProfiles = yield(Database.getProfiles(ChosenGroup.Members), "completed").Result
	for m in ChosenGroup.Members:
		var tmpMembersCard = groupMembersScene.instance()
		tmpMembersCard.get_node("Background/Name").text = allMembersProfiles[m]["Name"]
		tmpMembersCard.get_node("Background/AmountLabel").visible = false
		tmpMembersCard.get_node("Background/AmountInput").visible = false
		tmpMembersCard.get_node("Background").connect("gui_input", self, "_onPressMembersCard", [String(m)])
		tmpMembersCard.get_node("Background/AmountInput").connect("text_changed", self, "updateAmount")
		tmpMembersCard.name = String(m)
		MembersList.add_child(tmpMembersCard)
		print(m)

func updateAmount(a):
	var fullAmount = float(AmountInput.text)
	if(CustomCheckButton.pressed):
		for i in ChosenGroup.Members:
			fullAmount -= float(MembersList.get_node(i).get_node("Background/AmountInput").text)
		Result.text = "Pozostało %.2f zł" % fullAmount
		t = fullAmount

func _onPressMembersCard(event, name):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if Members.has(name):
					Members.erase(name)
					MembersList.get_node(name).modulate = Color("#ffffff")
				else:
					Members.append(name)
					MembersList.get_node(name).modulate = Color("#aaaaaa")




func _on_SendButton_pressed():
	if TitleInput.text == "":
		print("Ustaw tytuł")
		return
	if AmountInput.text == "":
		print("Ustaw kwotę")
		return
	if Members.empty():
		print("Zaznacz kogoś")
		return
	
	
	var allBills = []
	var B = {}
	B["Description"] = TitleInput.text
	B["To"] = Database.userID
	B["IsPayed"] = 0
	
	var amount = float(AmountInput.text)
	
	var rest : float = amount
	
	var dividedAmount
	var result = ""
	if(!AmountlyCheckButton.pressed and !CustomCheckButton.pressed):
		dividedAmount = stepify(float(amount / Members.size()), 0.01)
		for m in Members:
			B["Amount"] = dividedAmount
			rest -= dividedAmount
			B["From"] = m
			MembersList.get_node(m).get_node("Background/ResultLabel").text = "Do oddania %.2f zł" % B["Amount"]
			if Database.userID == m:
				MembersList.get_node(m).get_node("Background/ResultLabel").text = "Do oddania %.2f zł" % (B["Amount"] + rest)
				continue
				#B["IsPayed"] = 1
			allBills.append(B.duplicate())
			B["IsPayed"] = 0
	elif(AmountlyCheckButton.pressed):
		var fullAmount = 0
		var DividedAmounts = []
		var counter = 0
		for i in range(ChosenGroup.Members.size()):
				fullAmount = fullAmount + int(MembersList.get_child(i).get_node("Background/AmountInput").text) 
		for i in range(ChosenGroup.Members.size()):
				DividedAmounts.append(stepify(float((int(MembersList.get_child(i).get_node("Background/AmountInput").text) * amount) / fullAmount), 0.01))
		print(DividedAmounts)
		for m in ChosenGroup.Members:
			if(DividedAmounts[counter] != 0):
				B["Amount"] = DividedAmounts[counter]
				rest -= DividedAmounts[counter]
				B["From"] = m
				MembersList.get_node(m).get_node("Background/ResultLabel").text = "Do oddania %.2f zł" % B["Amount"]
				if Database.userID == m:
					MembersList.get_node(m).get_node("Background/ResultLabel").text = "Do oddania %.2f zł" % (B["Amount"] + rest)
					continue
					#B["IsPayed"] = 1
				allBills.append(B.duplicate())
				B["IsPayed"] = 0
			counter += 1
	else:
		if t != 0:
			print("Rozdziel całą kwotę")
			return
		for i in ChosenGroup.Members:
			B["Amount"] = float(MembersList.get_node(i).get_node("Background/AmountInput").text)
			B["From"] = i
			MembersList.get_node(i).get_node("Background/ResultLabel").text = "Do oddania %.2f zł" % B["Amount"]
			if Database.userID == i:
				continue
				#B["IsPayed"] = 1
			if(B["Amount"] != 0):
				allBills.append(B.duplicate())
			B["IsPayed"] = 0
			
	Database.addBills(allBills)


func _on_AmountlyCheckButton_pressed():
	Result.text = ""
	for i in range(ChosenGroup.Members.size()):
		MembersList.get_child(i).get_node("Background/AmountInput").text = ""
		MembersList.get_child(i).get_node("Background/ResultLabel").text = ""
	CustomCheckButton.pressed = false
	showAdvancedFields()


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")


func _on_CustomCheckButton_pressed():
	Result.text = ""
	for i in range(ChosenGroup.Members.size()):
		MembersList.get_child(i).get_node("Background/AmountInput").text = ""
		MembersList.get_child(i).get_node("Background/ResultLabel").text = ""
	AmountlyCheckButton.pressed = false
	showAdvancedFields()

func showAdvancedFields():
	if(AmountlyCheckButton.pressed or CustomCheckButton.pressed):
		for i in range(ChosenGroup.Members.size()):
			MembersList.get_child(i).get_node("Background/AmountLabel").visible = true
			MembersList.get_child(i).get_node("Background/AmountInput").visible = true
	else:
		for i in range(ChosenGroup.Members.size()):
			MembersList.get_child(i).get_node("Background/AmountLabel").visible = false
			MembersList.get_child(i).get_node("Background/AmountInput").text = ""
			MembersList.get_child(i).get_node("Background/AmountInput").visible = false
