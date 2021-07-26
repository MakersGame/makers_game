extends Node2D


func update_items():
    $ItemInBackpack.update_items_in_backpack()
    $ItemInHome.update_items_in_home()

func _physics_process(delta):
    global_position=Global.PlayerCamera.global_position-Vector2(640,360)
