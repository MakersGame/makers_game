extends Area2D
signal open_synthesis

# 这里只是一个用于交互的结点
var WhetherIn=false


func _ready():
    pass # Replace with function body.


func _input(event):
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_F && WhetherIn && Global.GameStatus == "PlayerControl":
            Global.GameStatus = "Paused"
            Global.open_synthesis()

func _on_Synthesis_table_body_shape_entered(body_id, body, body_shape, local_shape):
    if body.Identifier=="Player":
        WhetherIn=true



func _on_Synthesis_table_body_shape_exited(body_id, body, body_shape, local_shape):
    if body.Identifier=="Player":
        WhetherIn=false
