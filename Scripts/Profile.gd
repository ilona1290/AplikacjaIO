extends Control

# Formula for copying
#onready var XXXLabel = $Background/Informations/XXX/XXXLabel
#onready var XXXInput = $Background/Informations/XXX/XXXInput
#onready var XXXValue = $Background/Informations/XXX/XXXValue

onready var http : HTTPRequest = $HTTPRequest

onready var NameLabel = $Background/Informations/Name/NameInput
onready var NameInput = $Background/Informations/Name/NameInput
onready var NameValue = $Background/Informations/Name/NameValue

onready var SurnameLabel = $Background/Informations/Surname/SurnameLabel
onready var SurnameInput = $Background/Informations/Surname/SurnameInput
onready var SurnameValue = $Background/Informations/Surname/SurnameValue

onready var BankAccountLabel = $Background/Informations/BankAccount/BankAccountLabel
onready var BankAccountInput = $Background/Informations/BankAccount/BankAccountInput
onready var BankAccountValue = $Background/Informations/BankAccount/BankAccountValue

onready var TelephoneLabel = $Background/Informations/Telephone/TelephoneLabel
onready var TelephoneInput = $Background/Informations/Telephone/TelephoneInput
onready var TelephoneValue = $Background/Informations/Telephone/TelephoneValue

onready var EditButton = $Background/EditButton
onready var Notification = $Background/Notification

onready var Avatar = $Background/Avatar
onready var AvatarFileDialog = $AvatarFileDialog

var new_profile := false
var EditMode : bool = false
var information_sent = false



var UserAccount : UserProfile = UserProfile.new()

func _ready():
	#Uncomment for loading profile from file
	#var file = File.new()
	#file.open("res://profile.dat", File.READ)
	#UserAccount.load_from_json(file.get_as_text())
	#file.close()
	
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	yield(http, "request_completed")
	#Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, UserAccount.to_dictionary() ,http)
	#UserAccount.Name = "ddewdwe"
	
	
	var AvatarImg : Image = Image.new()
	#if UserAccount.Avatar == []:
	if UserAccount.AvatarPath == "":
		AvatarImg.load("res://Images/AvatarPlaceholder.png")
	else:
		AvatarImg.load("res://" + UserAccount.AvatarPath)
		#AvatarImg.load_png_from_buffer(UserAccount.Avatar)
	var AvatarTex : ImageTexture = ImageTexture.new()
	AvatarTex.create_from_image(AvatarImg)
	Avatar.texture = AvatarTex

func _on_EditButton_pressed():
	if EditMode == false:
		NameInput.visible = true
		SurnameInput.visible = true
		BankAccountInput.visible = true
		TelephoneInput.visible = true
		
		NameValue.visible = false
		SurnameValue.visible = false
		BankAccountValue.visible = false
		TelephoneValue.visible = false
		
		EditMode = true
		EditButton.text = "Zapisz"
	else:
		NameInput.visible = false
		SurnameInput.visible = false
		BankAccountInput.visible = false
		TelephoneInput.visible = false
		
		NameValue.visible = true
		SurnameValue.visible = true
		BankAccountValue.visible = true
		TelephoneValue.visible = true
		
		#Saving changes
		NameValue.text = NameInput.text
		SurnameValue.text = SurnameInput.text
		BankAccountValue.text = BankAccountInput.text
		TelephoneValue.text = TelephoneInput.text
		
		UserAccount.Name = NameInput.text
		UserAccount.Surname = SurnameInput.text
		UserAccount.BankAccount = BankAccountInput.text
		UserAccount.Telephone = TelephoneInput.text
		
		Notification.text = "Zapisano zmiany"
		match new_profile:
			true:
				Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, UserAccount.to_dictionary(), http)
			false:
				Firebase.update_document("users/%s" % Firebase.user_info.id, UserAccount.to_dictionary(), http)

		information_sent = true
		EditMode = false
		EditButton.text = "Edytuj"
		
		# Uncomment for saving profile to file
		#var file = File.new()
		#file.open("res://profile.dat", File.WRITE)
		#file.store_string(UserAccount.to_json())
		#file.close()
		

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_Avatar_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			AvatarFileDialog.visible = true

func _on_AvatarFileDialog_confirmed():
	var NewFilePath = AvatarFileDialog.current_file
	var NewAvatarImage : Image = Image.new()
	NewAvatarImage.load(NewFilePath)
	var NewAvatarTexture : ImageTexture = ImageTexture.new()
	NewAvatarTexture.create_from_image(NewAvatarImage)
	Avatar.texture = NewAvatarTexture
	
	UserAccount.Avatar = Avatar.texture.get("image").save_png_to_buffer()
	UserAccount.AvatarPath = NewFilePath

###################################
#	Saving to users collection
###################################
func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			Notification.text = "Please, enter your information"
			new_profile = true
			return
		200:
			if information_sent:
				Notification.text = "Information saved successfully"
				information_sent = false
			UserAccount.Name = result_body.fields["Name"].stringValue
			UserAccount.BankAccount = result_body.fields["BankAccount"].stringValue
			UserAccount.Surname = result_body.fields["Surname"].stringValue
			UserAccount.Telephone = result_body.fields["Telephone"].stringValue
			#print(result_body.fields["Avatar"].stringValue)
			UserAccount.AvatarPath = result_body.fields["AvatarPath"].stringValue
			#self.UserAccount.set_profile(result_body.fields)
			
			BankAccountValue.text = UserAccount.BankAccount
			NameValue.text = UserAccount.Name
			SurnameValue.text = UserAccount.Surname
			TelephoneValue.text = UserAccount.Telephone
			NameInput.text = UserAccount.Name
			SurnameInput.text = UserAccount.Surname
			BankAccountInput.text = UserAccount.BankAccount
			TelephoneInput.text = UserAccount.Telephone
			#var NewAvatarImage : Image = Image.new()
			#NewAvatarImage.load_png_from_buffer(UserAccount.Avatar)
			#var NewAvatarTexture : ImageTexture = ImageTexture.new()
			#NewAvatarTexture.create_from_image(NewAvatarImage)
			#Avatar.texture = NewAvatarTexture
			

