extends Node2D

func _ready():
    $Enermies/Enermy.init("test_enermy",Vector2(-1,0),-1,global_position)
    $Enermies/Enermy2.init("test_enermy",Vector2(-1,0),-1,global_position)
    $Enermies/Enermy3.init("test_enermy",Vector2(0,-1),-1,global_position)
    $Enermies/Enermy4.init("test_enermy",Vector2(0,-1),-1,global_position)
    $Enermies/Enermy5.init("test_enermy",Vector2(0,-1),-1,global_position)

func _on_UpdateArea_body_entered(body):
    if body.Identifier=="Player":
        Global.area_block_change(self)


func _on_UpdateArea_body_exited(body):
    if body.Identifier=="Player":
        Global.area_block_change(null)
