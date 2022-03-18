extends Control

# Formula for copying
#onready var XXXLabel = $background/Informations/XXX/XXXLabel
#onready var XXXInput = $background/Informations/XXX/XXXInput
#onready var XXXValue = $background/Informations/XXX/XXXValue

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

var EditMode : bool = false

var UserAccount : UserProfile = UserProfile.new()

func _ready():
	# Uncomment for loading profile from file
	#var file = File.new()
	#file.open("res://profile.dat", File.READ)
	#UserAccount.load_from_json(file.get_as_text())
	#file.close()
	
	NameValue.text = UserAccount.Name
	SurnameValue.text = UserAccount.Surname
	BankAccountValue.text = UserAccount.BankAccount
	TelephoneValue.text = UserAccount.Telephone
	
	NameInput.text = UserAccount.Name
	SurnameInput.text = UserAccount.Surname
	BankAccountInput.text = UserAccount.BankAccount
	TelephoneInput.text = UserAccount.Telephone
	
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
