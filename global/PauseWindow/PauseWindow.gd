extends Node2D

func _ready():
    hide_all()
    $Backpack.show()
    hide()

func update_all():
    $Backpack.update_items_in_backpack()
    $TeamInfo.update_team()

func _physics_process(delta):
    global_position=Global.PlayerCamera.global_position

func hide_all():
    $TeamInfo.hide()
    $TeamInfo/WeaponChoiceWindow.hide()
    $TeamInfo.WeaponTypeChosen=""
    $Backpack.hide()
    $Backpack/QuickUseItem.hide()
    $Backpack/DropItemWindow.hide()
    $Backpack/DropWeaponWindow.hide()
    $Backpack.FocusChangable=true
    $Diary.hide()
    $Home.hide()
    $Map.hide()
    $TechnologyTree.hide()

func _on_CloseButton_pressed():
    hide()
    get_tree().paused=false
    Global.GameStatus="PlayerControl"


func _on_QuitGameButton_pressed():
    get_tree().quit()


func _on_TeamButton_pressed():
    hide_all()
    $TeamInfo.show()
    
func _on_BackpackButton_pressed():
    hide_all()
    $Backpack.show()

func _on_DiaryButton_pressed():
    hide_all()
    $Diary.show()


func _on_HomeButton_pressed():
    hide_all()
    $Home.show()


func _on_MapButton_pressed():
    hide_all()
    $Map.show()


