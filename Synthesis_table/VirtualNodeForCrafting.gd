extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
    Global.GameStatus = "Paused"
    var middle_position=Global.PlayerCamera.global_position
    $SynthesisTablePanel.set_global_position(Vector2(middle_position.x - 350, middle_position.y - 250))
    # 开始播放动画
    $AnimationPlayer.play("panel")
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_Synthesis_table_panel_ClosePanel():
    Global.GameStatus = "PlayerControl"
    
    # 开始播放结束动画
    $AnimationPlayer.play_backwards("panel")
    
    Global.close_synthesis()
    pass # Replace with function body.
