class_name UserProfile
extends Node

var Name : String = ""
var Surname : String = ""
var BankAccount : String = ""
var Telephone : String = ""
var Avatar : Array = []
var AvatarPath : String = ""

func to_json():
	return "{" \
		+ "\"Name\":\"" + Name + "\"," \
		+ "\"Surname\":\"" + Surname + "\"," \
		+ "\"BankAccount\":\"" + BankAccount + "\"," \
		+ "\"Telephone\":\"" + Telephone + "\"," \
		+ "\"Avatar\":" + String(Avatar) \
		+ "}"

func load_from_json(json : String):
	var jsonParse = JSON.parse(json)
	Name = jsonParse.result["Name"]
	Surname = jsonParse.result["Surname"]
	BankAccount = jsonParse.result["BankAccount"]
	Telephone = jsonParse.result["Telephone"]
	Avatar = jsonParse.result["Avatar"]


func to_dictionary() -> Dictionary:
	return {"Name": {"stringValue": Name}, 
	"Surname": {"stringValue": Surname}, 
	"BankAccount": {"stringValue": BankAccount}, 
	"Telephone": {"stringValue": Telephone},
	"AvatarPath": {"stringValue": AvatarPath}}

