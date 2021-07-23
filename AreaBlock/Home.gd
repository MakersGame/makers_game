extends Node2D



func _on_UpdateArea_body_entered(body):
    if body.Identifier=="Player":
        Global.area_block_change(self)


func _on_UpdateArea_body_exited(body):
    if body.Identifier=="Player":
        Global.area_block_change(null)
