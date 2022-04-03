extends Control


var groupMembersScene = preload("res://Scenes/GroupMembers.tscn")
const MODULO_8_BIT = 256
var Members = []
onready var MembersList = $Background/ScrollContainer/VBoxContainer
onready var AmountInput = $Background/AmountInput
onready var TitleInput = $Background/TitleInput
onready var http : HTTPRequest = $HTTPRequest
onready var Notification = $Background/Notification
onready var Result = $Background/Result
onready var AdvancedCheckButton = $Background/AdvancedCheckButton


var Bills := {
	"Title" : {},
	"Amount" : {},
	"Members": { "arrayValue": { "values": []}}
}

func _ready():
	print(ChosenGroup.Name)
	print(ChosenGroup.Members)
	generateMembersList()

func generateMembersList():
	for m in ChosenGroup.Members:
		var tmpMembersCard = groupMembersScene.instance()
		tmpMembersCard.get_node("Background/Name").text = m
		tmpMembersCard.get_node("Background/AmountLabel").visible = false
		tmpMembersCard.get_node("Background/AmountInput").visible = false
		tmpMembersCard.get_node("Background").connect("gui_input", self, "_onPressMembersCard", [{"stringValue": m}])
		tmpMembersCard.name = m
		MembersList.add_child(tmpMembersCard)
		print(m)



func _onPressMembersCard(event, name):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				if Members.has(name):
					Members.erase(name)
					MembersList.get_node(name.stringValue).modulate = Color("#ffffff")
				else:
					Members.append(name)
					MembersList.get_node(name.stringValue).modulate = Color("#aaaaaa")




func _on_SendButton_pressed():
	var BillName = v4()
	Bills["Title"] = {"stringValue": TitleInput.text}
	Bills["Amount"] = {"stringValue": AmountInput.text}
	Bills["Members"] = { "arrayValue": { "values": Members}}
	#Firebase.save_document("bills?documentId=%s" % BillName, Bills, http)



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			Notification.text = "Przesłano"

static func getRandomInt():
  # Randomize every time to minimize the risk of collisions
  randomize()

  return randi() % MODULO_8_BIT

static func uuidbin():
  # 16 random bytes with the bytes on index 6 and 8 modified
  return [
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
	((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
	getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
  ]

static func v4():
  # 16 random bytes with the bytes on index 6 and 8 modified
  var b = uuidbin()

  return '%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x' % [
	# low
	b[0], b[1], b[2], b[3],

	# mid
	b[4], b[5],

	# hi
	b[6], b[7],

	# clock
	b[8], b[9],

	# clock
	b[10], b[11], b[12], b[13], b[14], b[15]
  ]


func _on_AdvancedCheckButton_pressed():
	pass


func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Groups.tscn")
