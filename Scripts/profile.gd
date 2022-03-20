extends Control

# Formula for copying
#onready var XXXLabel = $background/Informations/XXX/XXXLabel
#onready var XXXInput = $background/Informations/XXX/XXXInput
#onready var XXXValue = $background/Informations/XXX/XXXValue

onready var http : HTTPRequest = $HTTPRequest

onready var NameLabel = $background/Informations/Name/NameInput
onready var NameInput = $background/Informations/Name/NameInput
onready var NameValue = $background/Informations/Name/NameValue

onready var SurnameLabel = $background/Informations/Surname/SurnameLabel
onready var SurnameInput = $background/Informations/Surname/SurnameInput
onready var SurnameValue = $background/Informations/Surname/SurnameValue

onready var BankAccountLabel = $background/Informations/BankAccount/BankAccountLabel
onready var BankAccountInput = $background/Informations/BankAccount/BankAccountInput
onready var BankAccountValue = $background/Informations/BankAccount/BankAccountValue

onready var TelephoneLabel = $background/Informations/Telephone/TelephoneLabel
onready var TelephoneInput = $background/Informations/Telephone/TelephoneInput
onready var TelephoneValue = $background/Informations/Telephone/TelephoneValue

onready var EditButton = $background/EditButton
onready var Notification = $background/Notification

onready var Avatar = $background/Avatar
onready var AvatarFileDialog = $AvatarFileDialog

var new_profile := false
var EditMode : bool = false
var information_sent = false




var UserAccount : UserProfile = UserProfile.new()

func _ready():
	# Uncomment for loading profile from file
	#var file = File.new()
	#file.open("res://profile.dat", File.READ)
	#UserAccount.load_from_json(file.get_as_text())
	#file.close()
	
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	#Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, UserAccount.to_dictionary() ,http)
	#UserAccount.Name = "ddewdwe"
	
	
	var AvatarImg : Image = Image.new()
	if UserAccount.Avatar == []:
		AvatarImg.load("res://Images/AvatarPlaceholder.png")
	else:
		AvatarImg.load_png_from_buffer(UserAccount.Avatar)
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
	get_tree().change_scene("res://Scenes/main.tscn")

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
			#UserAccount.Avatar = result_body.fields["Avatar"].stringValue
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
			

